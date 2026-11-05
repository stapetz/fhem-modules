# VolvoConnect Volvo ID Migration - Technische Spezifikation

**Version:** 1.1 - UPDATED MIT KORREKTEN ENDPOINTS  
**Status:** 🟡 In Arbeit  
**Last Updated:** 2026-11-05 (Korrektionen nach API Analyse)

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

#### Neues System (Migration) - KEYCLOAK BASIERT
```
Discovery URL: https://auth.volvocars.com/realms/volvocars/.well-known/openid-configuration
Issuer: https://auth.volvocars.com/realms/volvocars
Client ID Format: vid-dc-xxxxxxxx
Authorization Endpoint: https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/auth
Token Endpoint: https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/token
Userinfo Endpoint: https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/userinfo
Revocation Endpoint: https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/revoke
Logout Endpoint: https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/logout
Status: Produktiv ab sofort
Deadline alt: 31. Januar 2027
Required: PKCE Support (S256)
```

⚠️ **WICHTIG:** Discovery Endpoint dynamisch laden, nicht hart-codieren!

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
    use NEW discovery endpoint: auth.volvocars.com/realms/volvocars
    require PKCE
    expect new Keycloak token claims
} else {
    use OLD discovery endpoint: volvoid.eu.volvocars.com
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

#### Neue Claims (Keycloak/auth.volvocars.com)
```json
{
  "iss": "https://auth.volvocars.com/realms/volvocars",
  "sub": "user-id",
  "aud": "client-id",
  "exp": 1234567890,
  "iat": 1234567890,
  "scope": "scope1 scope2",
  "client_id": "vid-dc-xxxxxxxx",
  "preferred_username": "username",
  "acr": "urn:mace:incommon:iap:silver",
  "name": "User Name",
  "email": "user@example.com"
}
```

**Migration Hinweise:**
- Neue Claims sind Superset der alten
- Keycloak verwendet standardisierte Claims
- Fallback auf `sub` für user identification
- `scope` kann sich unterscheiden
- Issuer ändert sich zu auth.volvocars.com/realms/volvocars

### 4. VCC API Endpoints (SEPARATE VON OAUTH!)

**🔴 WICHTIG:** Die VCC API Endpoints bleiben GLEICH und ändern sich NICHT!

#### VCC API Base URLs
```
Production: https://api.volvocars.com/v2/
Region (China): https://api-cn.volvocars.com/v2/
```

#### Häufig verwendete VCC Endpoints
```
GET https://api.volvocars.com/v2/vehicles
   → Vehicle List abrufen

GET https://api.volvocars.com/v2/vehicles/{vehicleId}
   → Vehicle Details

GET https://api.volvocars.com/v2/vehicles/{vehicleId}/status
   → Vehicle Status/Readings

GET https://api.volvocars.com/v2/vehicles/{vehicleId}/location
   → Location Data

GET https://api.volvocars.com/v2/vehicles/{vehicleId}/trips
   → Trip History
```

#### Authorization Header (BLEIBT GLEICH!)
```
Authorization: Bearer <access_token>
Accept: application/json
```

**WICHTIG:** Der Access Token stammt jetzt vom neuen Keycloak Service (`auth.volvocars.com`), aber das VCC API ändert sich NICHT!

#### OAuth Endpoints (Separate von VCC API)
```
POST https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/token
   → Token Exchange & Refresh

POST https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/revoke
   → Token Revocation / Logout

GET https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/userinfo
   → User Info abrufen

GET https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/logout
   → Logout Redirect
```

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
                 "https://auth.volvocars.com/realms/volvocars");
}
```

#### Test: VCC API Headers (UNVERÄNDERT)
```perl
sub test_vcc_api_headers {
    # Die VCC API braucht weiterhin nur das Bearer Token
    # Keine neuen API Keys erforderlich!
    my $token = get_access_token("new");
    my $response = request_vcc_api(
        url => "https://api.volvocars.com/v2/vehicles",
        headers => {
            "Authorization" => "Bearer $token",
            "Accept" => "application/json"
        }
    );
    
    assert($response->{success});
    assert_array($response->{vehicles});
}
```

### Integration Tests

#### Scenario 1: New Service OAuth Flow with PKCE
```
1. User initiates login
2. Module generates PKCE pair (code_verifier, code_challenge)
3. Redirect to https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/auth
4. User authenticates at Volvo ID (Keycloak)
5. Callback with authorization_code
6. Exchange code for token with code_verifier
7. Parse JWT and extract claims (Keycloak format)
8. Store token and refresh token
9. User can access vehicle data via api.volvocars.com
```

#### Scenario 2: Token Refresh
```
1. Module detects expired token
2. Uses refresh_token to get new access_token
3. POST to https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/token
4. Parse new JWT claims (Keycloak format)
5. Update stored token
6. Continue VCC API calls
```

#### Scenario 3: VCC API Calls (UNVERÄNDERT)
```
1. Get vehicles: GET https://api.volvocars.com/v2/vehicles
2. Get status: GET https://api.volvocars.com/v2/vehicles/{id}/status
3. Get location: GET https://api.volvocars.com/v2/vehicles/{id}/location
4. Header bleibt: Authorization: Bearer <token>
5. Kein VCC API Key Wechsel erforderlich!
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

### Phase 3: Old Service Deprecation (After Jan 31, 2027)
- Old service endpoints stop working
- Module logs warnings if old service is configured
- Documentation updated

### Phase 4: Old Service Removal (Future)
- Old service code removed from module
- Clean code without legacy support

---

## Implementation Checklist

### Code Changes
- [ ] **Discovery Endpoint URL korrigieren!**
  - ✗ FALSCH: login.volvoid.volvocars.com
  - ✓ RICHTIG: auth.volvocars.com/realms/volvocars
  
- [ ] **PKCE utility functions**
- [ ] **Dual service endpoint selection**
- [ ] **Discovery endpoint dynamisch laden** (nicht hart-codieren!)
- [ ] **Token claims parsing (both formats)**
- [ ] **Token Revocation Handling**
- [ ] **Error handling & logging**
- [ ] **Attribute validation**

### Tests
- [ ] Unit tests for PKCE
- [ ] Unit tests for endpoint parsing
- [ ] Unit tests for VCC API (sollte unverändert sein)
- [ ] Integration tests for auth flow
- [ ] Integration tests for token refresh
- [ ] Integration tests for VCC API
- [ ] Error scenario tests

### Documentation
- [ ] README update
- [ ] Migration guide
- [ ] Attribute documentation
- [ ] Troubleshooting guide
- [ ] Release notes

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
- Keycloak @ auth.volvocars.com
- VCC API @ api.volvocars.com

---

## Timeline

| Phase | Duration | Target |
|-------|----------|--------|
| Analysis | 1 week | 2026-11-12 |
| Implementation | 2 weeks | 2026-11-26 |
| Testing | 1 week | 2026-12-03 |
| Beta Release | 1 week | 2026-12-10 |
| Final Release | 2 days | 2026-12-12 |

**Deadline:** Before Volvo official cutoff (31. Januar 2027)

---

## References

- [Volvo ID Migration](https://developer.volvocars.com/news/volvoid-migration/)
- [Keycloak OpenID Connect](https://www.keycloak.org/docs/latest/server_admin/)
- [PKCE RFC 7636](https://tools.ietf.org/html/rfc7636)
- [OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749)
- [OpenID Connect](https://openid.net/connect/)
- [Discovery Endpoint Response](https://auth.volvocars.com/realms/volvocars/.well-known/openid-configuration)

