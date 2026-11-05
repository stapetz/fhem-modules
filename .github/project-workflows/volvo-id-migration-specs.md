# VolvoConnect Volvo ID Migration - Technische Spezifikation

**Version:** 1.0  
**Status:** 🟡 In Arbeit  
**Last Updated:** 2026-11-05

---

## Übersicht der Änderungen

### Discovery Endpoints

#### Altes System (Deprecated)
```
Discovery URL: https://volvoid.eu.volvocars.com/.well-known/openid-configuration
Issuer: https://volvoid.eu.volvocars.com
Client ID Format: dc-xxxxxxxx
Deprecated: Nach Volvo-Ankündigung
```

#### Neues System (Migration)
```
Discovery URL: https://login.volvoid.volvocars.com/.well-known/openid-configuration
Issuer: https://login.volvoid.volvocars.com
Client ID Format: vid-dc-xxxxxxxx
Status: Produktiv ab [DATE]
Required: PKCE Support
```

---

## Implementierungs-Anforderungen

### 1. PKCE (Proof Key for Code Exchange) Support

**RFC:** [RFC 7636](https://tools.ietf.org/html/rfc7636)

#### Code Challenge Generierung
```perl
# Pseudo-Code für Perl-Implementierung
sub generate_pkce_pair {
    my $code_verifier = generate_random_string(128);  # 43-128 chars
    my $code_challenge = base64url_encode(sha256($code_verifier));
    return ($code_verifier, $code_challenge);
}
```

**Parameter für Authorization Request:**
- `code_challenge`: Base64URL-encoded SHA256 des code_verifier
- `code_challenge_method`: "S256" (SHA256)

**Parameter für Token Exchange:**
- `code_verifier`: Original-String aus Authorization Request

#### Perl CPAN Module
- `Digest::SHA` (Standardmodul)
- `MIME::Base64` (Standardmodul)
- Oder: Eigene Base64URL-Implementierung

### 2. Dual Service Support

#### Attribute
```
volvoIdService: "old" (default) | "new"
  Wählt zwischen altem und neuem Volvo ID Service
  
volvoIdDiscoveryUrl: <URL>
  Manuelles Override der Discovery URL (optional)
  Default: Basierend auf volvoIdService
  
volvoIdIssuer: <URL>
  Manuelles Override des Issuers (optional)
```

#### Logik
```
if (getAttribute("volvoIdService") eq "new") {
    use NEW discovery endpoint
    require PKCE
    expect new token claims
} else {
    use OLD discovery endpoint
    optional PKCE
    use legacy token claims
}
```

### 3. Token Structure & Claims

#### Alte Claims (Legacy)
```json
{
  "iss": "https://volvoid.eu.volvocars.com",
  "sub": "user-id",
  "aud": "client-id",
  "exp": 1234567890,
  "iat": 1234567890,
  "scope": "scope1 scope2"
}
```

#### Neue Claims (Keycloak)
```json
{
  "iss": "https://login.volvoid.volvocars.com",
  "sub": "user-id",
  "aud": "client-id",
  "exp": 1234567890,
  "iat": 1234567890,
  "scope": "scope1 scope2",
  "client_id": "vid-dc-xxxxxxxx",
  "preferred_username": "username",
  "acr": "urn:mace:incommon:iap:silver"
}
```

**Migration Hinweise:**
- Neue Claims sind Superset der alten
- Fallback auf `sub` für user identification
- `scope` kann sich unterscheiden

### 4. VCC API Key Changes

**Alte Version:**
```
X-VCC-Authorization: Bearer <access_token>
Accept: application/json
```

**Neue Version:**
```
Authorization: Bearer <access_token>
Accept: application/json
```

Oder:
```
X-VCC-API-Key: <new-format-api-key>
```

**Zu klären:** Exakte neue Format mit Volvo Developer Portal

### 5. Module Config Änderungen

#### Altes Modul
```
define volvo VolvoConnect
attr volvo clientId dc-xxxxxxxx
attr volvo clientSecret xxxxx
attr volvo username user@example.com
attr volvo password pass
```

#### Neues Modul (mit Migration)
```
define volvo VolvoConnect
attr volvo clientId vid-dc-xxxxxxxx
attr volvo clientSecret xxxxx
attr volvo username user@example.com
attr volvo password pass
attr volvo volvoIdService new     # New: Service Selector
```

---

## Test-Szenarien im Detail

### Unit Tests

#### Test: PKCE Code Challenge
```perl
sub test_pkce_code_challenge {
    my ($verifier, $challenge) = generate_pkce_pair();
    
    # Verify format
    assert_match($verifier, qr/^[A-Za-z0-9\-._~]{43,128}$/);
    assert_match($challenge, qr/^[A-Za-z0-9\-_]+$/);
    
    # Verify determinism (same verifier = same challenge)
    my $challenge2 = generate_challenge($verifier);
    assert_equal($challenge, $challenge2);
}
```

#### Test: Discovery Endpoint Parsing
```perl
sub test_discovery_parsing {
    my $old_discovery = fetch_discovery("old");
    my $new_discovery = fetch_discovery("new");
    
    # Verify required fields
    assert($old_discovery->{authorization_endpoint});
    assert($new_discovery->{authorization_endpoint});
    assert($new_discovery->{token_endpoint});
    assert($new_discovery->{userinfo_endpoint});
    
    # Verify issuer matches
    assert_equal($old_discovery->{issuer}, 
                 "https://volvoid.eu.volvocars.com");
    assert_equal($new_discovery->{issuer}, 
                 "https://login.volvoid.volvocars.com");
}
```

### Integration Tests

#### Scenario 1: New Service OAuth Flow with PKCE
```
1. User initiates login
2. Module generates PKCE pair (code_verifier, code_challenge)
3. Redirect to authorization endpoint with code_challenge
4. User authenticates at Volvo ID
5. Callback with authorization_code
6. Exchange code for token with code_verifier
7. Parse JWT and extract claims
8. Store token and refresh token
9. User can access vehicle data
```

#### Scenario 2: Token Refresh
```
1. Module detects expired token
2. Uses refresh_token to get new access_token
3. Parse new JWT claims
4. Update stored token
5. Continue normal operation
```

#### Scenario 3: Error Scenarios
```
Scenario: Invalid Code Verifier
- Expected: Token endpoint rejects request
- Error handling: Clear error message in log

Scenario: Discovery Endpoint Down
- Expected: Fallback to cached endpoints or error
- Error handling: Graceful degradation

Scenario: Malformed JWT
- Expected: Module detects and rejects
- Error handling: Alert user, log details

Scenario: Expired Refresh Token
- Expected: Full re-authentication required
- Error handling: Redirect to login
```

---

## Backward Compatibility Strategie

### Phase 1: Both Services Supported (Deployment)
- Module supports both old and new service
- Default: `volvoIdService = old` (no breaking change)
- New users: Can select `volvoIdService = new`
- Existing users: No action required

### Phase 2: Migration Period (Parallel Ops)
- Users gradually migrate to new service
- Old service still works
- Community support for migration

### Phase 3: Old Service Deprecation (After Volvo Cutoff)
- Old service endpoints stop working
- Module logs warnings if old service is configured
- Documentation updated

### Phase 4: Old Service Removal (Future)
- Old service code removed from module
- Clean code without legacy support

---

## Implementation Checklist

### Code Changes
- [ ] PKCE utility functions
- [ ] Dual service endpoint selection
- [ ] Discovery endpoint caching
- [ ] Token claims parsing (both formats)
- [ ] Error handling & logging
- [ ] Attribute validation

### Tests
- [ ] Unit tests for PKCE
- [ ] Unit tests for endpoint parsing
- [ ] Integration tests for auth flow
- [ ] Integration tests for token refresh
- [ ] Error scenario tests

### Documentation
- [ ] README update
- [ ] Migration guide
- [ ] Attribute documentation
- [ ] Troubleshooting guide
- [ ] Release notes

### Community
- [ ] Announcement
- [ ] Beta testing period
- [ ] Feedback collection
- [ ] Final release

---

## Dependencies

### CPAN Modules (Existing in VolvoConnect)
- `LWP::UserAgent` - HTTP requests
- `JSON` - JSON parsing
- `URI` - URL handling
- `Digest::SHA` - PKCE
- `MIME::Base64` - Base64 encoding

### FHEM Core
- `HttpUtils_NonblockingGet` - Non-blocking HTTP
- `Log3` - Logging
- `readingsBeginUpdate/readingsEndUpdate` - Readings

### External Services
- Volvo Developer Portal API
- Volvo ID Service (old & new)

---

## Risiken & Mitigations

| Risiko | Likelihood | Impact | Mitigation |
|--------|-----------|--------|-----------|
| API Breaking Changes | Low | High | Regular testing, monitoring |
| PKCE Implementation Issues | Low | Medium | RFC review, unit tests |
| User Config Migration | Medium | Medium | Clear docs, auto-migration hints |
| Performance Impact | Low | Low | Caching, profiling |
| Security Issues | Low | High | Code review, security testing |

---

## Timeline

| Phase | Duration | Target |
|-------|----------|--------|
| Analysis | 1 week | 2026-11-12 |
| Implementation | 2 weeks | 2026-11-26 |
| Testing | 1 week | 2026-12-03 |
| Beta Release | 1 week | 2026-12-10 |
| Final Release | 2 days | 2026-12-12 |

**Deadline:** Before Volvo official cutoff (TBD)

---

## References

- [Volvo ID Migration](https://developer.volvocars.com/news/volvoid-migration/)
- [PKCE RFC 7636](https://tools.ietf.org/html/rfc7636)
- [OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect](https://openid.net/connect/)

