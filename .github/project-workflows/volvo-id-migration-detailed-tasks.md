# Detaillierte Task Breakdown - VolvoConnect Migration

## 👤 STEFAN'S TASKS

### PHASE 1A: Setup (Diese Woche - bis 10.11.2026)

#### Task 1A.1: Neue Volvo Developer Application erstellen
**Status:** ⏳ TODO  
**Effort:** 30 min  
**Deadline:** 08.11.2026

Schritte:
1. Gehe zu: https://developer.volvocars.com/account/#your-api-applications
2. Klick: "Create new application"
3. Gib Namen ein: "VolvoConnect-Keycloak-Test"
4. Wähle: "New Service" / Keycloak (nicht alte)
5. Notiere:
   ```
   Client ID: ____________ (vid-dc-xxxxxxxx)
   Client Secret: ____________
   API Key: ____________ (falls vorhanden)
   Created Date: ____________
   ```

Checklist:
- [ ] Application sichtbar im Developer Portal
- [ ] Credentials sind verfügbar
- [ ] Status ist "Active"

**Output:** Neue Credentials dokumentiert


#### Task 1A.2: Discovery Endpoint validieren
**Status:** ⏳ TODO  
**Effort:** 15 min  
**Deadline:** 08.11.2026

Schritte:
```bash
# Test Discovery Endpoint
curl -s https://auth.volvocars.com/realms/volvocars/.well-known/openid-configuration | head -20

# Expected output: JSON mit authorization_endpoint, token_endpoint, etc.
```

Checklist:
- [ ] Endpoint antwortet mit HTTP 200
- [ ] Response ist valid JSON
- [ ] Alle OAuth Endpoints sind vorhanden

**Output:** Bestätigung dass Discovery funktioniert


#### Task 1A.3: Test-Vehicle im Volvo Account
**Status:** ⏳ TODO  
**Effort:** 30 min (oder N/A wenn bereits vorhanden)  
**Deadline:** 09.11.2026

Schritte:
1. Öffne Volvo On Call App (oder Web)
2. Verbinde ein Fahrzeug mit dem neuen Test-Account
3. Stelle sicher dass Permissions gesetzt sind:
   - [ ] Vehicles (Readonly)
   - [ ] Status (Readonly)
   - [ ] Location (Readonly, falls needed)

**Output:** Mindestens 1 Fahrzeug im neuen Account sichtbar

---

### PHASE 1B: Test Setup (11.11-20.11.2026)

#### Task 1B.1: Test Device im FHEM anlegen
**Status:** ⏳ TODO  
**Effort:** 20 min  
**Deadline:** 12.11.2026

Schritte:
```
Gehe zu FHEM Webinterface:
1. Add Device
2. Define: define volvo_new VolvoConnect_NEW
3. Setze Attribute:
   attr volvo_new clientId <deine neue vid-dc-xxxxx>
   attr volvo_new clientSecret <dein neues secret>
   attr volvo_new username <deine volvo email>
   attr volvo_new password <dein volvo password>
   attr volvo_new volvoIdService new
```

Checklist:
- [ ] Device sichtbar in FHEM
- [ ] Alle Attribute gesetzt
- [ ] Keine Fehler im Log

**Output:** Test Device läuft


#### Task 1B.2: Parallel Device Struktur
**Status:** ⏳ TODO  
**Effort:** 20 min  
**Deadline:** 12.11.2026

Schritte:
```
Repository Structure:
FHEM/
├── 70_VolvoConnect.pm          (Alt - läuft weiter)
├── 70_VolvoConnect_NEW.pm      (Neu - wird getestet)
└── 70_VolvoConnect_LEGACY.pm   (Backup Alt)

Git:
$ git checkout -b feature/volvo-id-migration-new
$ cp 70_VolvoConnect.pm 70_VolvoConnect_NEW.pm
$ git add FHEM/70_VolvoConnect_NEW.pm
$ git commit -m "test: Add new module for Keycloak testing"
```

Checklist:
- [ ] Beide Module im Repository
- [ ] Branch erstellt
- [ ] Alt Module läuft weiter

**Output:** Ready für Testing


---

### PHASE 1C: Testing (21.11-31.12.2026)

#### Task 1C.1: Tägliche Tests durchführen
**Status:** ⏳ TODO  
**Effort:** 15 min/Tag  
**Deadline:** Täglich bis 31.12.2026

Täglich (oder 2x/Woche):
1. Login mit alt Module → Fahrzeuge laden → Status checken
2. Login mit neu Module → Fahrzeuge laden → Status checken
3. Vergleiche beide:
   - [ ] Fahrzeuglisten identisch?
   - [ ] Status identisch?
   - [ ] Keine Fehler im Log?

**Output:** Test Report (z.B. täglich in Issue #3 kommentieren)


#### Task 1C.2: Bug Reports sammeln
**Status:** ⏳ TODO  
**Effort:** 10 min wenn Bugs gefunden  
**Deadline:** Sofort bei Bugs

Falls Fehler gefunden:
```
Erstelle Sub-Issue in GitHub:
Title: "Bug: [Beschreibung]"
Label: volvo-id-migration
Attached to: #3

Content:
- Fehlermeldung (mit Log)
- Schritte zum Reproduzieren
- Expected vs. Actual Behavior
- Screenshots falls hilfreich
```

**Output:** Dokumentierte Bugs für Copilot


---

### PHASE 1D: Cutover (Nach 31.01.2027)

#### Task 1D.1: Modul umbenennen (nach Volvo Cutoff)
**Status:** ⏳ TODO  
**Effort:** 15 min  
**Deadline:** 01.02.2027

```bash
$ git checkout dev
$ git pull
$ mv FHEM/70_VolvoConnect_NEW.pm FHEM/70_VolvoConnect.pm
$ rm FHEM/70_VolvoConnect_LEGACY.pm  # oder Archive
$ git commit -m "release: Keycloak migration - new module becomes main"
$ git tag v2.0-keycloak-migration
$ git push origin dev --tags
```

**Output:** Neue Version auf Main


---

## 🤖 COPILOT'S TASKS

### PHASE 1A: Vorbereitung (Diese Woche - bis 10.11.2026)

#### Task 1A.C1: Code Skeleton für 70_VolvoConnect_NEW.pm
**Status:** ⏳ TODO  
**Effort:** 2-3 Stunden  
**Deadline:** 09.11.2026

Schritte:
1. Kopiere 70_VolvoConnect.pm zu 70_VolvoConnect_NEW.pm
2. Strukturiere für Dual Service Support:
   ```perl
   # At top
   my $VOLVO_SERVICE = {
       old => {
           discovery => "https://volvoid.eu.volvocars.com/.well-known/openid-configuration",
           issuer => "https://volvoid.eu.volvocars.com",
       },
       new => {
           discovery => "https://auth.volvocars.com/realms/volvocars/.well-known/openid-configuration",
           issuer => "https://auth.volvocars.com/realms/volvocars",
       }
   };
   ```

3. Implementiere Helper Functions:
   - `X_loadDiscoveryEndpoint()` - lädt .well-known/openid-configuration
   - `X_generatePKCEPair()` - generiert Code Verifier + Challenge
   - `X_getServiceConfig()` - gibt Config für old/new Service

Checklist:
- [ ] Modul lädt ohne Fehler
- [ ] Discovery Endpoint Loader implementiert
- [ ] PKCE Generator implementiert
- [ ] Dual Service Logic vorhanden

**Output:** Basis für Keycloak Implementation


#### Task 1A.C2: Discovery Endpoint Cache + Parsing
**Status:** ⏳ TODO  
**Effort:** 1-2 Stunden  
**Deadline:** 10.11.2026

Implementiere:
```perl
sub X_loadDiscoveryEndpoint {
    my ($hash, $serviceName) = @_;
    
    my $url = $VOLVO_SERVICE->{$serviceName}->{discovery};
    
    HttpUtils_NonblockingGet({
        url => $url,
        callback => sub {
            my ($param, $err, $data) = @_;
            if ($err) {
                Log3($hash->{NAME}, 1, "Discovery Error: $err");
            } else {
                my $discovery = decode_json($data);
                # Cache it
                $hash->{discovery} = $discovery;
                Log3($hash->{NAME}, 3, "Discovery loaded for $serviceName");
            }
        }
    });
}
```

Checklist:
- [ ] Dynamisches Discovery Laden
- [ ] Caching implementiert
- [ ] Error Handling vorhanden
- [ ] Beide Services (old/new) funktionieren

**Output:** Discovery Endpoint Loader fertig


#### Task 1A.C3: PKCE Generator implementieren
**Status:** ⏳ TODO  
**Effort:** 1 Stunde  
**Deadline:** 10.11.2026

```perl
sub X_generatePKCEPair {
    use Digest::SHA qw(sha256);
    use MIME::Base64 qw(encode_base64);
    
    # Generate 128-char code verifier
    my $verifier = '';
    my @chars = ('a'..'z', 'A'..'Z', '0'..'9', '-', '.', '_', '~');
    for (1..128) {
        $verifier .= $chars[int(rand(@chars))];
    }
    
    # Generate code challenge
    my $digest = sha256($verifier);
    my $challenge = encode_base64($digest, '');
    # Remove padding and make URL-safe
    $challenge =~ s/=+$//;
    $challenge =~ tr|+/|-_|;
    
    return ($verifier, $challenge);
}
```

Checklist:
- [ ] Code Verifier ist 128 chars
- [ ] Code Challenge ist Base64URL
- [ ] Beide Werte sind unterschiedlich aber deterministisch

**Output:** PKCE Generator fertig


---

### PHASE 1B: Implementation (11.11-20.11.2026)

#### Task 1B.C1: Authorization Request mit PKCE
**Status:** ⏳ TODO  
**Effort:** 2 Stunden  
**Deadline:** 15.11.2026

Sobald Stefan die Credentials hat:
1. Discovery laden
2. Authorization Endpoint extrahieren
3. PKCE Pair generieren
4. Redirect URL mit PKCE Parameters:
   ```
   /auth?
     client_id=vid-dc-xxxxx
     redirect_uri=http://...
     scope=openid+profile+email
     response_type=code
     code_challenge=<SHA256(verifier)>
     code_challenge_method=S256
     state=<random>
   ```

Checklist:
- [ ] Discovery lädt Discovery erfolgreich
- [ ] PKCE Pair wird generiert
- [ ] Authorization URL wird korrekt gebildet
- [ ] Browser öffnet sich

**Output:** Authorization Flow startet


#### Task 1B.C2: Token Exchange mit Code Verifier
**Status:** ⏳ TODO  
**Effort:** 2 Stunden  
**Deadline:** 17.11.2026

Nach Authorization (Code erhalten):
1. Token Endpoint Aufruf:
   ```perl
   POST https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/token
   
   grant_type=authorization_code
   code=<code vom auth endpoint>
   code_verifier=<original verifier>
   client_id=<vid-dc-xxxxx>
   client_secret=<secret>
   redirect_uri=<same als auth>
   ```

2. Response: JWT Access Token + Refresh Token
3. Parse JWT und cache Tokens

Checklist:
- [ ] Token Exchange erfolgreich
- [ ] Tokens sind valid JWT
- [ ] Refresh Token vorhanden
- [ ] Claims werden geparst

**Output:** First Access Token erhalten


#### Task 1B.C3: VCC API Call mit neuem Token
**Status:** ⏳ TODO  
**Effort:** 1 Stunde  
**Deadline:** 18.11.2026

Test VCC API:
```perl
GET https://api.volvocars.com/v2/vehicles

Header:
Authorization: Bearer <access_token>
Accept: application/json

# Response sollte Fahzeugliste sein
```

Checklist:
- [ ] API Call erfolgreich
- [ ] Fahrzeugliste wird geladen
- [ ] Daten formatieren & speichern

**Output:** VCC API funktioniert mit neuem Token


---

### PHASE 1C: Testing & Fixes (19.11-31.12.2026)

#### Task 1C.C1: Bug Fixes durchführen
**Status:** ⏳ TODO  
**Effort:** Variabel  
**Deadline:** Fortlaufend

Stefan meldet Bugs → Copilot fixt:
- Error Handling verbessern
- Edge Cases handhaben
- Performance optimieren
- Token Refresh testen

Checklist:
- [ ] Alle gemeldeten Bugs sind gefixt
- [ ] Keine Crashes
- [ ] Saubere Logs


#### Task 1C.C2: Comprehensive Testing
**Status:** ⏳ TODO  
**Effort:** 3-4 Stunden  
**Deadline:** 20.12.2026

Teste alle 6 Scenarios:
- [ ] New Service + PKCE
- [ ] Old Service (Backward Compat)
- [ ] Token Refresh
- [ ] Mixed Environment
- [ ] Error Scenarios
- [ ] Config Edge Cases

**Output:** Test Report mit Ergebnissen


---

### PHASE 1D: Release (01.02.2027+)

#### Task 1D.C1: Migration Guide schreiben
**Status:** ⏳ TODO  
**Effort:** 2-3 Stunden  
**Deadline:** 25.01.2027

```markdown
# VolvoConnect Migration Guide v2.0

## Was ändert sich?
- OAuth Service von Volvo ID (custom) zu Keycloak
- Neue Client ID Format (vid-dc- statt dc-)
- PKCE (Proof Key) ist jetzt erforderlich
- VCC API bleibt gleich!

## Was ist zu tun?
1. Neue Developer Application erstellen
2. Neue Credentials notieren
3. Module updaten (Kopien bleiben funktional)

## Deadlines
- 31.01.2027: Alter Service wird abgeschaltet
- Ab 01.02.2027: Nur neuer Service unterstützt
```

**Output:** Migration Guide for Users


#### Task 1D.C2: Release Notes vorbereiten
**Status:** ⏳ TODO  
**Effort:** 1 Stunde  
**Deadline:** 31.01.2027

```
v2.0 - Keycloak Migration Release

BREAKING CHANGES:
- OAuth provider changed to Keycloak
- New Client ID format required (vid-dc-*)
- PKCE is now mandatory

FEATURES:
- Full Keycloak support
- PKCE (RFC 7636) implementation
- Better error messages
- Improved token refresh

MIGRATION:
- See: docs/VOLVO-MIGRATION-GUIDE.md
- Old module still available as 70_VolvoConnect_LEGACY.pm
```

**Output:** Release Notes


---

## 📅 TIMELINES & DEPENDENCIES

```
Week 1 (08-14 Nov):
  Stefan: Create App, get Credentials
  Copilot: Code Skeleton, Discovery Loader

Week 2 (15-21 Nov):
  Stefan: Start Testing with new device
  Copilot: Full Auth Flow + VCC API

Week 3-12 (22 Nov - 31 Dec):
  Stefan: Daily Testing, Bug Reports
  Copilot: Fixes, Enhancements, Testing

Week 13+ (01 Jan - 31 Jan 2027):
  Stefan: Final verification
  Copilot: Documentation, Release Prep

31 Jan 2027:
  ⏰ VOLVO CUTOFF

01 Feb 2027+:
  Stefan: Modul umbenennen
  Copilot: Publish as v2.0
  Release Notes & Migration Guide
```

---

## 🎯 SUCCESS METRICS

### By 10 Nov 2026:
- ✅ New Developer App created
- ✅ Credentials documented
- ✅ Code skeleton ready
- ✅ Discovery endpoint validated

### By 20 Nov 2026:
- ✅ First successful OAuth login
- ✅ Token exchange working
- ✅ Vehicle data loaded
- ✅ Parallel testing started

### By 31 Dec 2026:
- ✅ No critical bugs
- ✅ Token refresh stable
- ✅ All scenarios tested
- ✅ Ready for production

### By 31 Jan 2027:
- ✅ Old service verified offline
- ✅ New module 100% stable
- ✅ Migration Guide complete
- ✅ Ready for release

