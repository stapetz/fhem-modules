# Hinweise für KI-Agenten

Vor Änderungen [`dev-docs/ENTWICKLUNG.md`](dev-docs/ENTWICKLUNG.md) lesen.

Kurzfassung:

- Auf Branch `dev` arbeiten und dorthin pushen. **Nach `main` NUR nach expliziter Anweisung des Entwicklers ("pushe nach main")** — nicht automatisch!
- `controls_*.txt` und `CHANGED*` werden vom Workflow erzeugt und nicht von Hand geändert.
- Vor jedem Push `git pull --rebase --autostash`.
- Commit-Trailer: `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`.
- Kommunikation mit dem Entwickler auf Deutsch.

## 🚨 WICHTIG: main vs. dev

- **dev**: Frei pushen nach jedem Commit
- **main**: **NIEMALS** pushen ohne explizite Anweisung! Warte auf "pushe nach main" oder "push to main"
- Ein Bugreport/Fix geht ERST nach dev, wird getestet, DANN nach Freigabe nach main
