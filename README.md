# teddy-tester – ciclo di test e correzione con agenti Claude Code

Plugin per Claude Code con la skill `TeddyUniversalTestingByAgent`. In qualunque progetto, la skill:

1. riconosce gli strati dell'applicazione (database, backend/API, frontend web, mobile, CLI, job, end-to-end);
2. propone gli strati, i servizi locali da avviare e i modelli, e aspetta la tua conferma;
3. scrive un catalogo di test per strato con risultati attesi, da approvare;
4. genera un agente tester per strato (`qa-tester-<strato>`) e un solo agente fixer (`qa-fixer`) in `.claude/agents/`;
5. esegue da 1 a 5 giri test+fix (default 2) su un branch dedicato `qa/<data>`, con un commit per giro;
6. chiude con un report in chat: bug, stato finale, file modificati, token e tempi per agente.

## Installazione

Dal terminale (sostituisci il percorso con quello della cartella del plugin):

```
claude plugin marketplace add C:\percorso\teddy-tester
claude plugin install teddy-tester@teddy-tester
```

Oppure dentro Claude Code: `/plugin marketplace add C:\percorso\teddy-tester` e poi `/plugin install teddy-tester@teddy-tester`.

Per provarlo senza installarlo: `claude --plugin-dir C:\percorso\teddy-tester\plugins\teddy-tester`

## Uso

Apri Claude Code nella cartella del progetto da testare, con l'albero git pulito:

```
/teddy-tester:TeddyUniversalTestingByAgent
/teddy-tester:TeddyUniversalTestingByAgent 3
/teddy-tester:TeddyUniversalTestingByAgent 2 strati=db,api tester=sonnet
```

| Argomento | Significato | Default |
|---|---|---|
| numero | giri test+fix, da 1 a 5 | 2 |
| `strati=` | strati da testare, separati da virgola | tutti quelli rilevati |
| `tester=` | modello dei tester (haiku, sonnet, opus) | haiku |
| `fixer=` | modello del fixer | sonnet |

Si può anche chiedere a parole: "fai 3 giri di test e correzione su questa app".

## Cosa resta nel progetto

| Percorso | Contenuto | In git |
|---|---|---|
| `.qa/config.md` | strati, comandi, modelli, giri | sì |
| `.qa/catalogo/<strato>.md` | test con risultati attesi | sì |
| `.qa/BUGS.md` | bug, stati, cause, correzioni | sì |
| `.qa/dati/` | script dei dati di prova | sì |
| `.qa/evidenze/` | esiti, screenshot, dump, log | no |
| `.claude/agents/qa-*.md` | agenti generati | sì |

Rilanciando la skill nello stesso progetto, ti propone di riusare configurazione, catalogo e agenti.

## Regole che la skill rispetta

- Agenti sempre uno alla volta; mai più di 5 giri; stop appena non restano bug aperti o se la build fallisce due volte di seguito.
- Solo ambienti locali e di prova: niente produzione, servizi remoti reali, invii reali.
- I tester non toccano il codice; il fixer non avvia servizi e non tocca dati.
- Nessun push, merge o rebase: decidi tu se e quando unire il branch `qa/<data>`.

## Note

- Gli agenti generati durante una sessione si possono chiamare per nome solo dalla sessione successiva: nel frattempo la skill li fa eseguire a un agente generico con lo stesso modello, che legge il loro file.
- La maggior parte dei token va ai tester (in un caso reale l'87%): per risparmiare conviene restringere gli strati o il catalogo, più che cambiare il modello del fixer.
