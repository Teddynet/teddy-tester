# teddy-tester per ChatGPT Codex

Skill `teddy-universal-testing-by-agent`: ciclo di test e correzione con subagent Codex (un tester per strato e un fixer, in `.codex/agents/`).

## Installazione

Per tutti i tuoi progetti (dalla cartella `codex` di questo repository):

```
mkdir -p ~/.agents/skills && cp -r .agents/skills/teddy-universal-testing-by-agent ~/.agents/skills/
```

Solo per un progetto: copia la stessa cartella in `<progetto>/.agents/skills/`.

Su Windows (PowerShell): `New-Item -ItemType Directory -Force $HOME\.agents\skills; Copy-Item -Recurse .agents\skills\teddy-universal-testing-by-agent $HOME\.agents\skills\`

## Uso

Nel progetto da testare, con l'albero git pulito:

```
$teddy-universal-testing-by-agent 3
$teddy-universal-testing-by-agent 2 strati=db,api
```

Oppure `/skills` e scegli la skill.

## Note

- I subagent di Codex partono in parallelo se non si dice il contrario: la skill li avvia uno alla volta. Per esserne certi si può mettere nel `.codex/config.toml` del progetto `[agents]` con `max_concurrent_threads_per_session = 1`.
- I nomi dei modelli non sono preimpostati: senza indicazioni i subagent usano il modello della sessione.
- Sandbox e approvazioni sono quelle della sessione: avviare Docker o emulatori può richiedere conferme.
- Gli agenti creati durante una sessione potrebbero non essere chiamabili per nome fino alla sessione successiva: la skill usa allora il subagent `worker` che legge il loro file.
