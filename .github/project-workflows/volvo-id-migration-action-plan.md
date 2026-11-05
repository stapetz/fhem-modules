# VolvoConnect Volvo ID Migration - Praktischer Action Plan

**Status:** 🟢 Konkrete Arbeitsschritte  
**Timeline:** Start jetzt, Testen bis 31.01.2027

---

## 🎯 Strategie: Parallel Development & Staged Migration

### Übersicht
1. **Phase 1A: Setup** (Diese Woche)
   - Neue Volvo Developer Application erstellen
   - New Credentials (Client ID, Secret) holen
   - Test Device mit neuem Modul starten

2. **Phase 1B: Testing** (Nov - Dez 2026)
   - Parallel Test auf neuem Modul
   - Altes Modul läuft weiter
   - Beide gleichzeitig nutzen

3. **Phase 1C: Cutover** (31.01.2027)
   - Neues Modul wird Main
   - Altes Modul wird Deprecated
   - Publishing mit Migration Guide

---

## 📋 TODO FÜR STEFAN (DU)

### SOFORT (Diese Woche) - Volvo Developer Portal

- [ ] **New Application im Volvo Developer Portal erstellen**
  - Gehe zu: https://developer.volvocars.com/account/#your-api-applications
  - Erstelle neue Application (z.B. "VolvoConnect-Test-New")
  - Wähle "New Service" (Keycloak-basiert)
  - Generiere neue Credentials

- [ ] **Notiere die neuen Credentials**
  ```
  Client ID: vid-dc-xxxxxx
  Client Secret: [geheim]
  API Key (falls benötigt): [notieren]
  Expires: [Datum]
  ```

- [ ] **Teste die Discovery Endpoint**
  ```bash
  curl https://auth.volvocars.com/realms/volvocars/.well-known/openid-configuration
  ```
  → Sollte alle Endpoints zeigen

- [ ] **Testhehicle im Volvo-Account aktivieren** (falls noch nicht geschehen)
  - Stelle sicher, dass mindestens ein Fahrzeug mit dem neuen Account verbunden ist

---

### Phase 1B - Testing Setup (Diese Woche/nächste)

- [ ] **Altes Modul-Backup erstellen**
  ```bash
  cp 70_VolvoConnect.pm 70_VolvoConnect_LEGACY.pm
  ```

- [ ] **Neues Test-Modul erstellen**
  ```bash
  cp 70_VolvoConnect.pm 70_VolvoConnect_NEW.pm
  ```
  → Dieses wird später zur neuen Main Version

- [ ] **Test-Device im FHEM anlegen**
  ```
  define volvo_new VolvoConnect_NEW
  attr volvo_new clientId <NEW vid-dc-xxxxxxxx>
  attr volvo_new clientSecret <NEW SECRET>
  attr volvo_new volvoIdService new    ← WICHTIG!
  attr volvo_new username <email>
  attr volvo_new password <pass>
  ```

- [ ] **Parallel-Struktur im Repository**
  ```
  FHEM/
  ├── 70_VolvoConnect.pm          (Alt, für alte Users)
  ├── 70_VolvoConnect_NEW.pm      (Neu, für Testing)
  └── 70_VolvoConnect_LEGACY.pm   (Backup)
  ```

---

### Phase 1C - Testing Durchführung (Nov-Dez)

- [ ] **Täglich/wöchentlich testen:**
  - Vehicles laden mit neuem Modul
  - Status abrufen
  - Daten vergleichen zwischen Alt und Neu
  - Errors/Issues sammeln

- [ ] **Migration Guide Feedback einholen**
  - Mit wem von der Community testen?
  - Feedback in Issue #3 sammeln

- [ ] **Bug Reports erstellen** (falls Probleme mit neuem Modul)
  - Sub-Issues von #3 erstellen
  - Tag: `volvo-id-migration`

---

### Phase 1D - Cutover (Nach 31.01.2027)

- [ ] **Altes Modul deaktivieren**
  - Warnung in Code: "Deprecated, use VolvoConnect instead"
  - Version Tag hinzufügen

- [ ] **Neues Modul umbenennen**
  ```bash
  mv 70_VolvoConnect_NEW.pm 70_VolvoConnect.pm
  ```

- [ ] **Release auf Main**
  - Tag: `v2.0-keycloak-migration`
  - Release Notes mit Migration Guide
  - Forum Post mit Ankündigung

---

## 📋 TODO FÜR MICH (COPILOT)

### SOFORT

- [ ] **Vorbereitung Phase 2: Code-Skeleton für neues Modul**
  - [ ] Discovery Endpoint dynamisch laden (nicht hart-codieren!)
  - [ ] PKCE Code Challenge/Verifier Generator Funktion
  - [ ] Dual Service Support (old/new Service Selector)
  - [ ] Error Handling für Keycloak

- [ ] **Test-Framework vorbereiten**
  - [ ] Unit Tests für PKCE
  - [ ] Unit Tests für Discovery Parsing
  - [ ] Mock-Responses für beide Services

### Phase 2 (Sobald Stefan neue Credentials hat)

- [ ] **Implementierung in 70_VolvoConnect_NEW.pm:**
  - [ ] Discovery Endpoint laden
    ```perl
    sub loadDiscoveryEndpoint {
        my $service = shift;
        if ($service eq "new") {
            my $url = "https://auth.volvocars.com/realms/volvocars/.well-known/openid-configuration";
        } else {
            my $url = "https://volvoid.eu.volvocars.com/.well-known/openid-configuration";
        }
        # Parse und cache endpoints
    }
    ```

  - [ ] PKCE Support
    ```perl
    sub generatePKCEPair {
        # Generate 128-char code_verifier
        # Generate code_challenge = base64url(sha256(code_verifier))
        # Return both
    }
    ```

  - [ ] New Authorization Request
    ```perl
    # Mit PKCE parameters:
    # code_challenge
    # code_challenge_method=S256
    ```

  - [ ] Token Exchange
    ```perl
    # Mit code_verifier parameter
    # Neu Endpoint: auth.volvocars.com/.../token
    ```

  - [ ] Token Refresh
    ```perl
    # refresh_token grant type
    # Keycloak Endpoint
    ```

- [ ] **Testen mit Stefan's neuen Credentials**
  - [ ] Login Flow mit PKCE
  - [ ] Token Exchange
  - [ ] Vehicle Data abrufen
  - [ ] Token Refresh
  - [ ] Logout

### Phase 3 (Dezember)

- [ ] **Umfassende Tests durchführen**
  - [ ] Alle 6 Szenarien aus Issue #3 testen
  - [ ] Error Handling testen
  - [ ] Edge Cases testen

- [ ] **Migration Guide schreiben**
  - [ ] Für Users (wie man migriert)
  - [ ] Für Community (Timeline, was ändert sich)
  - [ ] Troubleshooting Guide

- [ ] **Release Notes vorbereiten**
  - [ ] Breaking Changes aufzählen
  - [ ] Migration Instructions
  - [ ] Fallback-Optionen

---

## 🔄 SCHRITTWEISE WORKFLOW

### Woche 1: SETUP

**Stefan:**
1. New Volvo Developer App erstellen
2. Credentials notieren
3. Test-Device im Volvo-Account aktivieren

**Copilot:**
1. Code-Skeleton für 70_VolvoConnect_NEW.pm vorbereiten
2. Discovery Endpoint Loader implementieren
3. PKCE Framework erstellen

**Result:** Basis für Parallel Development

---

### Woche 2-3: IMPLEMENTATION

**Stefan:**
1. Neue Credentials in 70_VolvoConnect_NEW.pm eintragen
2. Test-Device im FHEM starten
3. First Login testen

**Copilot:**
1. Full OAuth Flow mit PKCE implementieren
2. Token Exchange & Refresh
3. VCC API Calls (sollten gleich sein)

**Result:** Erstes funktionierendes New Module

---

### Woche 4+: TESTING & STABILISIERUNG

**Stefan:**
1. Täglich mit neuem Modul testen
2. Bugs sammeln
3. Feedback geben

**Copilot:**
1. Bugs fixen
2. Error Handling verbessern
3. Test Cases erweitern

**Result:** Stabiles neues Modul

---

### Nach 31.01.2027: CUTOVER

**Stefan:**
1. Modul umbenennen
2. Alte Version deprecaten
3. Release vorbereiten

**Copilot:**
1. Release Notes schreiben
2. Migration Guide finalisieren
3. Main Branch updaten

**Result:** Production-ready New Version

---

## 📊 PARALLEL DEVICE STRUKTUR

```
FHEM Installation Stefan:

VolvoConnect (ALT):
  define volvo VolvoConnect
  attr volvo clientId dc-xxxxxxxx
  attr volvo clientSecret [ALT]
  attr volvo volvoIdService old

VolvoConnect_NEW (NEU - TEST):
  define volvo_new VolvoConnect_NEW
  attr volvo_new clientId vid-dc-xxxxxxxx
  attr volvo_new clientSecret [NEU]
  attr volvo_new volvoIdService new

→ Beide laufen parallel
→ Daten können verglichen werden
→ Kein Service-Ausfall während Testing
```

---

## ✅ SUCCESS CRITERIA

### Phase 1A: Setup ✓
- [ ] New Developer Application erstellt
- [ ] Credentials dokumentiert
- [ ] Discovery Endpoint erreichbar

### Phase 1B: Initial Implementation ✓
- [ ] 70_VolvoConnect_NEW.pm lädt Discovery
- [ ] PKCE Framework implementiert
- [ ] First OAuth Flow attempt läuft

### Phase 1C: Testing ✓
- [ ] Login mit PKCE erfolgreich
- [ ] Token Exchange erfolgreich
- [ ] Vehicle List wird geladen
- [ ] Vehicle Status wird aktualisiert
- [ ] Token Refresh funktioniert

### Phase 1D: Production Ready ✓
- [ ] Keine Bugs in Edge Cases
- [ ] Migration Guide vollständig
- [ ] Community Feedback implementiert
- [ ] Release Notes fertig

---

## 📞 KOMMUNIKATION

### Stefan → Copilot
- Neue Credentials sobald verfügbar
- Testergebnisse täglich/wöchentlich
- Bugs & Fehler sofort melden
- Feedback zur Implementation

### Copilot → Stefan
- Code Updates
- Implementation Fortschritt
- Fragen zu Edge Cases
- Betrieb/Deployment Hints

### Stefan → Community
- Ankündigung in Forum
- Testing Aufruf (wer möchte testen?)
- Migration Timeline Update
- Release Notes

---

## 🎯 KONKRETE NÄCHSTEN SCHRITTE (HEUTE)

### Stefan:
```
1. Zum Volvo Developer Portal gehen
2. Neue Application erstellen → "VolvoConnect_NEW_APP" oder ähnlich
3. Client ID & Secret notieren
4. An Copilot schreiben mit den Credentials (sicher!)
```

### Copilot:
```
1. Code-Skeleton für 70_VolvoConnect_NEW.pm schreiben
2. Discovery Endpoint Loader + Cache implementieren
3. PKCE Code Generator implementieren
4. Branch feature/volvo-id-migration-impl starten
```

### Zusammen:
```
1. Erstes Sync/Meeting zum Testen
2. Debug Discovery Endpoint
3. Debug OAuth Flow
4. First Vehicles Load!
```

---

## 📌 DEADLINES

- **Bis 10. November:** New App & Credentials + Code Skeleton ✓
- **Bis 20. November:** First OAuth successful
- **Bis 30. Dezember:** Stable & tested
- **31. Januar 2027:** Cutover & Production Release

