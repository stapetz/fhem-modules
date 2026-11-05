# VolvoConnect Volvo ID Migration - Workflow

## Projektübersicht
Dieses Projekt verwaltet die Migration des VolvoConnect-FHEM-Moduls zur neuen Volvo ID OAuth 2.0 Service.

**Status:** 🔴 In Planung  
**Priorität:** Hoch  
**Deadline:** Vor Volvo-Abschaltung (siehe offizielle Timeline)  

## Arbeitsabläufe (Workflows)

### 1. Analyse & Planung (Phase 1)
**Dauer:** ~1 Woche  
**Owner:** Stefan Apetz

#### Aufgaben:
- [ ] API-Dokumentation lesen und verstehen
- [ ] Discovery Endpoints dokumentieren
- [ ] Token Structure & Claims analysieren
- [ ] PKCE-Implementierungsanforderungen definieren
- [ ] VCC API Key Format verstehen
- [ ] Backward Compatibility Strategie planen

**Abhängigkeiten:** Keine  
**Ausgabe:** Detaillierte Implementierungsspezifikation

---

### 2. Implementierung (Phase 2)
**Dauer:** ~2 Wochen  
**Owner:** Stefan Apetz  
**Abhängig von:** Phase 1

#### Aufgaben:
- [ ] PKCE Support implementieren
  - Code Challenge/Verifier Generation
  - Parameter handling
- [ ] Dual Service Support
  - Alt-Service für Backward Compatibility
  - Neu-Service für Migration
- [ ] Attribute erweitern
  - `volvoIdNewService` (0/1)
  - Discovery Endpoint URLs
- [ ] Error Handling verbessern
- [ ] Logging für Debug erweitern
- [ ] Alte Service Logik bewahren

**Abhängigkeiten:** Phase 1  
**Ausgabe:** Code auf Branch `feature/volvo-id-migration`

---

### 3. Unit Testing (Phase 3)
**Dauer:** ~1 Woche  
**Owner:** Stefan Apetz  
**Abhängig von:** Phase 2

#### Test-Cases:
- [ ] PKCE Code Challenge Generation
- [ ] Code Verifier Verification
- [ ] Discovery Endpoint Parsing (old & new)
- [ ] Token Claims Parsing (old & new)
- [ ] Token Refresh Logic (old & new)
- [ ] Error Scenarios

**Abhängigkeiten:** Phase 2  
**Ausgabe:** Unit-Test Suite mit >90% Code Coverage

---

### 4. Integration Testing (Phase 4)
**Dauer:** ~1 Woche  
**Owner:** Stefan Apetz  
**Abhängig von:** Phase 2, 3

#### Test-Szenarien (siehe Issue #3):
- [ ] Scenario 1: New Service mit PKCE
- [ ] Scenario 2: Old Service (Backward Compat)
- [ ] Scenario 3: Token Refresh
- [ ] Scenario 4: Mixed Environment
- [ ] Scenario 5: Error Handling
- [ ] Scenario 6: Configuration Edge Cases

**Abhängigkeiten:** Phase 2, 3  
**Ausgabe:** Test Report mit Ergebnissen

---

### 5. Dokumentation & Release (Phase 5)
**Dauer:** ~1 Woche  
**Owner:** Stefan Apetz  
**Abhängig von:** Phase 4

#### Aufgaben:
- [ ] Migration Guide für Nutzer schreiben
- [ ] Neue Credentials anfordern dokumentieren
- [ ] Konfiguration aktualisieren
- [ ] Release Notes schreiben
  - Breaking Changes section
  - Migration Instructions
  - Timeline
- [ ] Version bumpen
- [ ] Changelog updaten

**Abhängigkeiten:** Phase 4  
**Ausgabe:** Release Notes & Dokumentation

---

### 6. Beta Release & Community Testing (Phase 6)
**Dauer:** ~1 Woche  
**Owner:** Stefan Apetz  
**Abhängig von:** Phase 5

#### Aufgaben:
- [ ] Beta-Release auf dev/main erstellen
- [ ] Community informieren
- [ ] Issue sammeln für Feedback
- [ ] Hot-Fixes vorbereiten
- [ ] Monitoring Setup

**Abhängigkeiten:** Phase 5  
**Ausgabe:** Beta Release & Feedback Collection

---

### 7. Final Release (Phase 7)
**Dauer:** ~2 Tage  
**Owner:** Stefan Apetz  
**Abhängig von:** Phase 6

#### Aufgaben:
- [ ] Feedback-Bugs fixen
- [ ] Final Testing durchführen
- [ ] Stable Release erstellen
- [ ] Ankündigung machen
- [ ] Support vorbereiten

**Abhängigkeiten:** Phase 6  
**Ausgabe:** Stable Release

---

## Ressourcen

### Externe Dokumentation
- [Volvo ID Migration News](https://developer.volvocars.com/news/volvoid-migration/)
- [Volvo Developer Portal](https://developer.volvocars.com/)
- [PKCE RFC 7636](https://tools.ietf.org/html/rfc7636)

### Interne Ressourcen
- VolvoConnect Module: [70_VolvoConnect.pm](../../FHEM/70_VolvoConnect.pm)
- Entwicklungs-Guide: [dev-docs/ENTWICKLUNG.md](../../dev-docs/ENTWICKLUNG.md)
- Test-Infrastructure: Vorhanden in repo

### Testing
- Test Volvo Account erforderlich
- Oder: Mock API für Testing aufbauen

---

## Branch-Strategie
- **Main:** Stabiler Code
- **Dev:** Entwicklung & Beta
- **feature/volvo-id-migration:** Diese Migration
- **feature/volvo-id-migration-tests:** Test Suite

---

## Kommunikation & Meetings
- Weekly Status Updates: Sonntag
- Issue Tracking: GitHub Issues im Projekt
- Emergency: Direct kontakt

---

## Risiken & Mitigation

| Risiko | Wahrscheinlichkeit | Impact | Mitigation |
|--------|-------------------|--------|-----------|
| Volvo API instabil | Mittel | Hoch | Mock API aufbauen, Testing Framework |
| Users widerstrebend | Mittel | Mittel | Gute Dokumentation, Smooth Migration |
| PKCE Komplikationen | Niedrig | Mittel | Early Testing, Spec Review |
| Timeline Druck | Mittel | Mittel | Klare Planung, Puffer einplanen |

---

## Status Dashboard

Siehe GitHub Project: [VolvoConnect Volvo ID Migration](https://github.com/stapetz/fhem-modules/projects/3)

**Letzte Aktualisierung:** 2026-11-05
