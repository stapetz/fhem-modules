# VolvoConnect OAuth 2.0 Redirect Handler

Modern HTML5 + JavaScript-basierter OAuth 2.0 Autorisierungs-Callback-Handler für VolvoConnect.

## Features

- ✅ Responsive Design (Desktop & Mobile)
- ✅ Dark Mode Support (automatisch)
- ✅ Autorisierungscode-Anzeige mit Copy-to-Clipboard
- ✅ Error-Handling mit benutzerfreundlichen Meldungen
- ✅ Zero Server-Dependencies (reine HTML/JavaScript)
- ✅ Keine CGI-Konfiguration nötig

## Konfiguration

### 1. Redirect URI in Volvo Developer Portal

Trage die Redirect URI in deiner OAuth-App im [Volvo Developer Portal](https://developer.volvocars.com) ein:

**Lokal (Heimnetz):**
```
http://fhem.fritz.box/volvoconnect/
```

**Extern (Internet):**
```
http://fhem.apetz.de/fhem/volvoconnect/
```

**Localhost (Entwicklung):**
```
http://localhost/volvoconnect/
```

### 2. FHEM VolvoConnect Konfiguration

Verwende in deinem VolvoConnect-Device die entsprechende URL als `redirectUri`:

```fhem
define Volvo_XC90 VolvoConnect
attr Volvo_XC90 keycloakService volvo
attr Volvo_XC90 redirectUri http://fhem.fritz.box/volvoconnect/
```

## Verwendung

### OAuth-Flow

1. Initiiere die Authentifizierung im VolvoConnect-Device
2. Du wirst zum Volvo-Authentifizierungsportal weitergeleitet
3. Nach erfolgreicher Authentifizierung wirst du automatisch zu dieser Seite weitergeleitet
4. Der Autorisierungscode wird angezeigt
5. Kopiere den Code mit der Copy-Schaltfläche
6. Gebe den Code in deine FHEM-Gerätekonfiguration ein

### URL-Parameter

Die Seite verarbeitet die folgenden OAuth-Standard-Parameter:

| Parameter | Beschreibung |
|-----------|-------------|
| `code` | Autorisierungscode (Erfolg) |
| `state` | CSRF-Protection State Parameter |
| `error` | Error Code (z.B. `invalid_scope`) |
| `error_description` | Error Description |

**Beispiel (erfolgreiche Authentifizierung):**
```
http://fhem.fritz.box/volvoconnect/?code=AUTH_CODE_HERE&state=fhemstate
```

**Beispiel (Fehler):**
```
http://fhem.fritz.box/volvoconnect/?error=invalid_scope&error_description=...
```

## Sicherheit

- **Kein Code auf dem Server:** Die Seite ist pure HTML/JavaScript — nichts wird auf dem FHEM-Server ausgeführt
- **Keine Token-Speicherung:** Codes und Tokens werden nicht in der Seite gespeichert
- **State-Parameter:** CSRF-Protection via `state` Parameter
- **HTTPS recommended:** Verwende HTTPS für externe Redirects

## Troubleshooting

### Seite wird nicht angezeigt

Stelle sicher, dass die URL korrekt ist:
- Lokale Zugriffe: `http://localhost/volvoconnect/`
- Heimnetz: `http://fhem.fritz.box/volvoconnect/`
- Extern: `http://fhem.apetz.de/fhem/volvoconnect/`

### Autorisierungscode wird nicht angezeigt

Überprüfe:
1. Ist die Redirect URI im Volvo Developer Portal korrekt konfiguriert?
2. Browser-Konsole öffnen (F12) und nach Fehlern suchen
3. URL-Parameter überprüfen (in der Adressleiste)

### "Scopes ungültig" Error

Dies ist ein Volvo-Server-Fehler. Überprüfe:
1. Sind alle angeforderten Scopes in der OAuth-App aktiviert?
2. Ist die App im Production-Modus korrekt freigegeben?

## Dateistruktur

```
www/volvoconnect/
├── index.html         (OAuth Redirect Handler - diese Datei)
├── README.md          (Dokumentation)
└── styles.css         (Optional: Erweiterte Styles)
```

## Browser-Kompatibilität

- ✅ Chrome/Edge 88+
- ✅ Firefox 87+
- ✅ Safari 14+
- ✅ Mobile Browser (iOS/Android)

## Lizenz

Teil des VolvoConnect FHEM-Modules
