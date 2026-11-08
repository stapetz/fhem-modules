# Hinweise für KI-Agenten

Vor Änderungen [`dev-docs/ENTWICKLUNG.md`](dev-docs/ENTWICKLUNG.md) lesen.

Kurzfassung:

- Auf Branch `dev` arbeiten und dorthin pushen. **Nach `main` NUR nach expliziter Anweisung des Entwicklers** — nicht automatisch!
- `controls_*.txt` und `CHANGED*` werden vom Workflow erzeugt und nicht von Hand geändert.
- Vor jedem Push `git pull --rebase --autostash`.
- Commit-Trailer: `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`.
- Kommunikation mit dem Entwickler auf Deutsch.

## 🚨 WICHTIG: main vs. dev

- **dev**: Frei pushen nach jedem Commit
- **main**: **NIEMALS** pushen ohne explizite Anweisung! Warte auf "pushe nach main"
- Ein Bugreport/Fix geht ERST nach dev, wird getestet, DANN nach Freigabe nach main

## 📦 NACH JEDEM PUSH ZU DEV - PFLICHT!

Nach jedem erfolgreichen Push zu `dev` **MUSS DER FOLGENDE BEFEHL ANGEZEIGT WERDEN:**

```
update all https://raw.githubusercontent.com/stapetz/fhem-modules/dev/controls_volvo.txt
```

Dies ermöglicht dem Entwickler, die Änderungen sofort in FHEM zu testen!
