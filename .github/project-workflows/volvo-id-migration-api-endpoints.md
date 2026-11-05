# API Endpoint Changes - Detaillierte Analyse

## 🔴 WICHTIGE KORREKTUREN

### Discovery Endpoint ist ANDERS als anfangs dokumentiert!

**Meine ursprüngliche Dokumentation (FALSCH):**
```
New: https://login.volvoid.volvocars.com/.well-known/openid-configuration
```

**Korrekt gemäß Volvo Dokumentation:**
```
New: https://auth.volvocars.com/realms/volvocars/.well-known/openid-configuration
```

---

## 🔑 OAuth 2.0 / OpenID Connect Endpoints (NEUE API)

**Base**: `https://auth.volvocars.com/realms/volvocars`

### 1. Authorization Endpoint
```
https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/auth
```
**Verwendung:** User-Redirect für OAuth Authorization Code Flow
**Parameter:** 
- `client_id` (vid-dc-xxxxxxxx)
- `redirect_uri`
- `scope`
- `response_type=code`
- `code_challenge` (PKCE - neue Anforderung!)
- `code_challenge_method=S256` (PKCE)
- `state`

### 2. Token Endpoint
```
https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/token
```
**Verwendung:** Token Exchange (Authorization Code → Access Token)
**Parameter:**
- `grant_type=authorization_code`
- `code` (vom Authorization Endpoint)
- `code_verifier` (PKCE - neue Anforderung!)
- `client_id`
- `client_secret`
- `redirect_uri`

**Verwendung:** Token Refresh
**Parameter:**
- `grant_type=refresh_token`
- `refresh_token`
- `client_id`
- `client_secret`

### 3. Userinfo Endpoint
```
https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/userinfo
```
**Verwendung:** Abrufen von Benutzerinformationen
**Header:**
- `Authorization: Bearer <access_token>`

**Response:** User Claims (sub, name, email, preferences, etc.)

### 4. Token Revocation Endpoint
```
https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/revoke
```
**Verwendung:** Token revoken (Logout)
**Parameter:**
- `token` (Access oder Refresh Token)
- `client_id`
- `client_secret`

### 5. Token Introspection Endpoint
```
https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/token/introspect
```
**Verwendung:** Token Details validieren
**Parameter:**
- `token` (Access Token)
- `client_id`
- `client_secret`

**Response:** Token Metadata (active, exp, iat, scope, etc.)

### 6. End Session (Logout) Endpoint
```
https://auth.volvocars.com/realms/volvocars/protocol/openid-connect/logout
```
**Verwendung:** User Logout / Session beenden
**Parameter:**
- `redirect_uri` (wohin nach Logout)
- `id_token_hint` (optional, empfohlen)

---

## 🚗 Volvo Connected Cars (VCC) API Endpoints

**WICHTIG:** Diese sind SEPARATE von OAuth Endpoints!

### VCC API Base URLs
```
Production: https://api.volvocars.com/v2/
Region-spezifisch (China): https://api-cn.volvocars.com/v2/
```

### Häufig verwendete VCC Endpoints

#### Vehicle List
```
GET https://api.volvocars.com/v2/vehicles
Header: Authorization: Bearer <access_token>
```

#### Vehicle Details
```
GET https://api.volvocars.com/v2/vehicles/{vehicleId}
Header: Authorization: Bearer <access_token>
```

#### Vehicle Status (Readings)
```
GET https://api.volvocars.com/v2/vehicles/{vehicleId}/status
Header: Authorization: Bearer <access_token>
```

#### Location Data
```
GET https://api.volvocars.com/v2/vehicles/{vehicleId}/location
Header: Authorization: Bearer <access_token>
```

#### Trip History
```
GET https://api.volvocars.com/v2/vehicles/{vehicleId}/trips
Header: Authorization: Bearer <access_token>
```

---

## 🔄 OLD Endpoints (Deprecated)

**Discovery Endpoint (ALT):**
```
https://volvoid.eu.volvocars.com/.well-known/openid-configuration
```

Die alten Endpoints unter `volvoid.eu.volvocars.com` werden nach dem Deadline (**31. Januar 2027**) abgeschaltet.

---

## 📋 Vergleich: Alt vs. Neu

| Aspekt | Alt (Deprecated) | Neu (Required) |
|--------|-----------------|----------------|
| **Discovery URL** | volvoid.eu.volvocars.com | auth.volvocars.com |
| **Auth Base Path** | /oauth2/auth | /realms/volvocars/protocol/openid-connect |
| **Token Path** | /oauth2/token | /realms/volvocars/protocol/openid-connect/token |
| **Userinfo Path** | /oauth2/userinfo | /realms/volvocars/protocol/openid-connect/userinfo |
| **PKCE** | Optional | **Mandatory** |
| **IAM System** | Custom | **Keycloak** |
| **Logout Path** | (varies) | /realms/volvocars/protocol/openid-connect/logout |
| **Revocation** | (nicht standardisiert) | /realms/volvocars/protocol/openid-connect/revoke |

---

## ⚠️ WICHTIGE BEOBACHTUNGEN

### 1. PKCE ist ZWINGEND erforderlich
- Code Challenge und Code Verifier sind im Flow notwendig
- `code_challenge_method=S256` (SHA256)
- Dies ist eine **Sicherheitsverbesserung**

### 2. Keycloak-basiert
- Neue IAM verwendet Open Source Keycloak
- Standardisierte OpenID Connect Implementierung
- Bekannte, gut dokumentierte Endpoints

### 3. Discovery Endpoint
- **Vollständige Dokumentation** via `.well-known/openid-configuration`
- Alle notwendigen Endpoints sind dort aufgelistet
- VolvoConnect **MUSS** diesen Endpoint parsen

### 4. VCC API ändert sich NICHT direkt
- Die VCC API Endpoints bleiben gleich
- Der Authorization Header bleibt `Authorization: Bearer <token>`
- Aber die Tokens stammen jetzt vom neuen Keycloak Service

### 5. Neue Endpoints, die vorher nicht waren:
- Device Authorization Endpoint (für Desktop/TV Flows)
- Pushed Authorization Request (PAR)
- Backchannel Authentication (CIBA)
- Diese sind optional für Standard OAuth Flow

---

## 🔍 Implikationen für VolvoConnect Modul

### Zu Updatend:

1. **Discovery Endpoint URL**
   - Alt: `https://volvoid.eu.volvocars.com/.well-known/openid-configuration`
   - Neu: `https://auth.volvocars.com/realms/volvocars/.well-known/openid-configuration`

2. **PKCE Implementation** (Critical!)
   - Generierung von Code Verifier
   - SHA256 Code Challenge
   - Parameters im Authorization Request
   - Code Verifier im Token Exchange

3. **Token Revocation Handling**
   - Neuer standardisierter Endpoint für Logout
   - Sollte verwendet werden statt ad-hoc Logout

4. **Error Handling**
   - Keycloak hat andere Error Codes
   - Token Validation könnte andere Claims haben

### Keine Änderungen erforderlich:

- VCC API Endpoints (api.volvocars.com)
- HTTP Header Format (Bearer Token)
- Token Usage in VCC API Calls
- Vehicle Data Parsing

---

## 📌 Implementation Checkliste - AKTUALISIERT

- [ ] Discovery Endpoint URL korrigieren!
  - ✗ FALSCH: login.volvoid.volvocars.com
  - ✓ RICHTIG: auth.volvocars.com/realms/volvocars

- [ ] Alle OAuth Endpoints aus Discovery dynamisch laden
  - Nicht hart-codieren
  - Parsen von .well-known/openid-configuration

- [ ] PKCE Support implementieren
  - Code Challenge/Verifier Generation
  - S256 Method

- [ ] Token Revocation verwenden
  - Statt ad-hoc Logout

- [ ] Keycloak Token Claims parsen
  - Neue Claims Struktur
  - Fallback auf alte wenn nötig (Backward Compat)

- [ ] Error Messages von Keycloak handhaben
  - Andere Error Codes
  - Bessere Error Messages

---

## 🔗 Referenzen

- [Volvo ID Migration](https://developer.volvocars.com/news/volvoid-migration/)
- [Keycloak OpenID Connect](https://www.keycloak.org/docs/latest/server_admin/)
- [RFC 7636 - PKCE](https://tools.ietf.org/html/rfc7636)
- [OpenID Connect Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html)

