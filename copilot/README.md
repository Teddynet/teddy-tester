# teddy-tester per GitHub Copilot

Skill `teddy-universal-testing-by-agent`: ciclo di test e correzione con custom agent di Copilot (un tester per strato e un fixer, in `.github/agents/`).

## Installazione

Per tutti i tuoi progetti (dalla cartella `copilot` di questo repository):

```
mkdir -p ~/.copilot/skills && cp -r .github/skills/teddy-universal-testing-by-agent ~/.copilot/skills/
```

Solo per un progetto (consigliato se il team usa lo stesso repository): copia la stessa cartella in `<progetto>/.github/skills/` e fai commit.

Su Windows (PowerShell): `New-Item -ItemType Directory -Force $HOME\.copilot\skills; Copy-Item -Recurse .github\skills\teddy-universal-testing-by-agent $HOME\.copilot\skills\`

## Uso

In VS Code (o Visual Studio, JetBrains), chat di Copilot in **modalità agente**, nel progetto da testare, con l'albero git pulito:

```
/teddy-universal-testing-by-agent 3
/teddy-universal-testing-by-agent 2 strati=db,api
```

## Note

- Serve la delega ai subagent (strumento `agent`, in VS Code `runSubagent`). Senza, la skill esegue i ruoli in sequenza nella stessa chat: funziona ma consuma più contesto.
- Gli agenti generati hanno `user-invocable: false`: non compaiono nel selettore ma restano delegabili.
- Modelli: senza indicazioni si usa quello della chat. Copilot non mostra i token per subagent, quindi il report riporta solo durata ed esito.
- Non usarla con il cloud agent di GitHub: il ciclo ha bisogno di servizi locali (database, emulatori, browser).
