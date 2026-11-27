#!/usr/bin/env bash
# Copia i file comuni dalla versione Claude Code alle versioni Codex, Cursor, Copilot e OpenCode,
# e rigenera i modelli degli agenti di Cursor, Copilot e OpenCode con l'intestazione di ogni strumento.
# I modelli TOML di Codex (codex/.../templates/*.toml) si aggiornano a mano.
# Uso, dalla radice del repository: bash scripts/sincronizza-comuni.sh
set -euo pipefail
cd "$(dirname "$0")/.."
SRC=plugins/teddy-tester/skills/TeddyUniversalTestingByAgent
ID=teddy-universal-testing-by-agent
CODEX=codex/.agents/skills/$ID
CURSOR=cursor/.cursor/skills/$ID
COPILOT=copilot/.github/skills/$ID
OPENCODE=opencode/.opencode/skills/$ID

# corpo di un file Markdown senza il frontmatter
corpo() { awk '/^---$/ && n < 2 { n++; next } n >= 2' "$1"; }
# valore del campo description del frontmatter
descr() { sed -n 's/^description: //p' "$1" | head -n 1; }

for D in "$CODEX" "$CURSOR" "$COPILOT" "$OPENCODE"; do
  mkdir -p "$D/references" "$D/templates"
  cp "$SRC/references/strati.md" "$D/references/"
  cp "$SRC/templates/catalogo.md" "$SRC/templates/bugs.md" "$SRC/templates/config.md" "$D/templates/"
done

T="$SRC/templates/tester.md"; F="$SRC/templates/fixer.md"
DT=$(descr "$T"); DF=$(descr "$F")

# Cursor
{ printf -- '---\nname: qa-tester-{{STRATO}}\ndescription: %s\nmodel: {{MODELLO_TESTER}}\nreadonly: false\nis_background: false\n---\n' "$DT"; corpo "$T"; } > "$CURSOR/templates/tester.md"
{ printf -- '---\nname: qa-fixer\ndescription: %s\nmodel: {{MODELLO_FIXER}}\nreadonly: false\nis_background: false\n---\n' "$DF"; corpo "$F"; } > "$CURSOR/templates/fixer.md"

# GitHub Copilot
{ printf -- "---\nname: qa-tester-{{STRATO}}\ndescription: %s\ntools: ['read', 'search', 'edit', 'execute']\nuser-invocable: false\n# model: {{MODELLO_TESTER}}\n---\n" "$DT"; corpo "$T"; } > "$COPILOT/templates/tester.agent.md"
{ printf -- "---\nname: qa-fixer\ndescription: %s\ntools: ['read', 'search', 'edit', 'execute']\nuser-invocable: false\n# model: {{MODELLO_FIXER}}\n---\n" "$DF"; corpo "$F"; } > "$COPILOT/templates/fixer.agent.md"

# OpenCode (versione 2): permessi in lista ordinata, vince l'ultima regola che corrisponde
{ printf -- '---\ndescription: %s\nmode: subagent\n# model: {{MODELLO_TESTER}}\npermissions:\n  - action: edit\n    resource: "*"\n    effect: deny\n  - action: edit\n    resource: ".qa/**"\n    effect: allow\n  - action: shell\n    resource: "*"\n    effect: allow\n---\n' "$DT"; corpo "$T"; } > "$OPENCODE/templates/tester.md"
{ printf -- '---\ndescription: %s\nmode: subagent\n# model: {{MODELLO_FIXER}}\npermissions:\n  - action: edit\n    resource: "*"\n    effect: allow\n  - action: shell\n    resource: "*"\n    effect: allow\n---\n' "$DF"; corpo "$F"; } > "$OPENCODE/templates/fixer.md"

echo "File comuni e modelli degli agenti aggiornati in codex/, cursor/, copilot/, opencode/"
