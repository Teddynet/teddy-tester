# teddy-tester per OpenCode

Skill `teddy-universal-testing-by-agent` più il comando `/teddy-tester`: ciclo di test e correzione con subagent di OpenCode (un tester per strato e un fixer, in `.opencode/agents/`). Scritta per OpenCode versione 2.

## Installazione

Per tutti i tuoi progetti (dalla cartella `opencode` di questo repository):

```
mkdir -p ~/.config/opencode/skills ~/.config/opencode/commands && cp -r .opencode/skills/teddy-universal-testing-by-agent ~/.config/opencode/skills/ && cp .opencode/commands/teddy-tester.md ~/.config/opencode/commands/
```

Solo per un progetto: copia `.opencode/skills/teddy-universal-testing-by-agent` e `.opencode/commands/teddy-tester.md` nelle stesse cartelle dentro `<progetto>/.opencode/`.

Su Windows (PowerShell): `New-Item -ItemType Directory -Force $HOME\.config\opencode\skills, $HOME\.config\opencode\commands; Copy-Item -Recurse .opencode\skills\teddy-universal-testing-by-agent $HOME\.config\opencode\skills\; Copy-Item .opencode\commands\teddy-tester.md $HOME\.config\opencode\commands\`

## Uso

Nel progetto da testare, con l'albero git pulito:

```
/teddy-tester 3
/teddy-tester 2 strati=db,api tester=anthropic/claude-haiku-5-5
```

## Note

- I modelli si indicano nella forma `provider/modello` dei provider configurati in OpenCode; senza indicazioni si usa il modello della sessione.
- I tester hanno permessi di modifica solo su `.qa/**`; il fixer può modificare tutto il progetto. Entrambi usano la shell.
- I subagent girano in sessioni figlie in background: la skill ne avvia uno per volta e aspetta il resoconto prima del successivo.
- Con OpenCode versione 1 cambiano alcuni percorsi e il formato dei permessi (`permission:` invece di `permissions:`): adatta i modelli in `templates/` se usi ancora quella versione.
