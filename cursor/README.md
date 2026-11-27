# teddy-tester per Cursor

Skill `teddy-universal-testing-by-agent`: ciclo di test e correzione con subagent di Cursor (un tester per strato e un fixer, in `.cursor/agents/`).

## Installazione

Per tutti i tuoi progetti (dalla cartella `cursor` di questo repository):

```
mkdir -p ~/.cursor/skills && cp -r .cursor/skills/teddy-universal-testing-by-agent ~/.cursor/skills/
```

Solo per un progetto: copia la stessa cartella in `<progetto>/.cursor/skills/`.

Su Windows (PowerShell): `New-Item -ItemType Directory -Force $HOME\.cursor\skills; Copy-Item -Recurse .cursor\skills\teddy-universal-testing-by-agent $HOME\.cursor\skills\`

## Uso

Nella chat Agent, nel progetto da testare, con l'albero git pulito:

```
/teddy-universal-testing-by-agent 3
/teddy-universal-testing-by-agent 2 strati=db,api
```

## Note

- La skill avvia un subagent per messaggio, in primo piano (`is_background: false`): Cursor li esegue così in sequenza.
- Modello di default `inherit`. Alcune versioni di Cursor ignorano il campo `model` dei subagent: in quel caso tutti usano il modello della chat.
- `readonly` resta `false` anche per i tester, che devono scrivere in `.qa/` e avviare servizi locali.
- Se un subagent appena creato non viene riconosciuto, ricarica la finestra di Cursor; nel frattempo la skill usa un subagent generico che legge il suo file.
