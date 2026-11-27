---
name: teddy-universal-testing-by-agent
description: Ciclo automatico di test e correzione per qualunque applicazione, con subagent Codex. Riconosce gli strati del progetto (database, backend/API, frontend web, mobile, CLI, end-to-end), genera un agente tester per ogni strato e un agente fixer in .codex/agents/, scrive un catalogo di test con risultati attesi, poi esegue da 1 a 5 giri test+fix su un branch dedicato e chiude con un report. Usala quando l'utente chiede di testare e correggere un'app con agenti, un ciclo QA, giri di test e fix.
---

# Ciclo QA → Fix con subagent Codex

Sei l'**orchestratore**. Non correggi codice e non esegui test tu: prepari tutto, fai approvare all'utente, avvii i subagent **uno alla volta** e decidi quando fermarti. Scrivi in italiano.

File di supporto nella cartella di questa skill: `references/strati.md` (come riconoscere e testare ogni strato), `templates/tester.toml`, `templates/fixer.toml`, `templates/catalogo.md`, `templates/bugs.md`, `templates/config.md`. Leggili quando servono.

## Specifiche di Codex

- **Agenti**: un file TOML per agente in `.codex/agents/` del progetto (`qa-tester-<strato>.toml`, `qa-fixer.toml`). Campi obbligatori `name`, `description`, `developer_instructions`; facoltativi `model`, `model_reasoning_effort`.
- **Modelli**: se l'utente non indica modelli, ometti `model` (i subagent ereditano quello della sessione). Proponi un modello più leggero per i tester e uno più capace per il fixer, chiedendo i nomi esatti disponibili all'utente: non inventarli.
- **Avvio di un subagent**: chiedi esplicitamente di avviare l'agente per nome e di aspettarne la fine, per esempio: "Avvia il subagent `qa-tester-db` con questo compito: … Aspetta che finisca prima di fare qualunque altra cosa." Codex avvia i subagent in parallelo se glielo permetti: **avvia sempre un solo subagent per volta** e non avviare il successivo finché non hai la sua risposta finale.
- Se il progetto ha `.codex/config.toml`, puoi proporre all'utente `[agents] max_concurrent_threads_per_session = 1` per garantire l'esecuzione in sequenza. Non modificare la configurazione personale dell'utente.
- **Agenti appena creati**: se Codex non trova un agente per nome (`unknown agent_type` o simile), avvia il subagent `worker` con il compito: "Leggi `.codex/agents/<file>.toml` e segui alla lettera `developer_instructions`, poi: <compito>". Dalla sessione successiva funzionano per nome.
- **Domande all'utente**: in chat, con opzioni numerate e una scelta consigliata.
- **Token e tempi**: riportali se Codex li mostra per ogni subagent; altrimenti scrivi solo la durata e dichiara che i token non sono disponibili.
- **Sandbox**: i subagent ereditano sandbox e approvazioni della sessione. Se avviare servizi locali (Docker, emulatori, server) richiede permessi, avvisa l'utente prima di iniziare.

## Argomenti

Dal testo dopo `$teddy-universal-testing-by-agent`: un numero = giri X (default **2**, accettati da 1 a 5, oltre rifiuta e spiega); `strati=db,api,web` = limita gli strati; `tester=<modello>`, `fixer=<modello>` = modelli. Se `.qa/config.md` esiste già, proponi di riusarlo e salta alla fase 4.

## Fase 1 – Ricognizione (economica)

1. Leggi `references/strati.md`, sezione "Indizi", e cerca gli indizi con ricerche mirate (mai leggere tutto il repo).
2. Leggi i requisiti: README, `docs/`, AGENTS.md, specifiche. Solo funzioni e decisioni.
3. Ricava per ogni strato: cartella, tecnologia, avvio in locale, build e test automatici, servizi locali necessari.

## Fase 2 – Proposta e conferma

Mostra una tabella: strato · cartella · tecnologia · come verrà testato · servizi locali · modello del tester. Più: giri X, modello del fixer, branch `qa/<AAAA-MM-GG>`. Chiedi conferma e le informazioni mancanti (utenti di test, URL locali). **Mai** credenziali o ambienti di produzione. Il ciclo parte solo da un albero git pulito: se non lo è, chiedi commit, stash o stop.

## Fase 3 – Generazione

1. `git switch -c qa/<data>`.
2. `.qa/config.md` dal modello.
3. Catalogo `.qa/catalogo/<strato>.md` per ogni strato: 10–25 test con ID, passi precisi, **atteso verificabile** dai requisiti o dal codice, casi limite, elenco "Non sono bug" in cima.
4. Dati di prova, se servono, come script ripetibile in `.qa/dati/`.
5. Mostra numero e titoli dei test per strato; chiedi approvazione.
6. Agenti da `templates/tester.toml` e `templates/fixer.toml` in `.codex/agents/`; nessun segnaposto `{{…}}` deve restare.
7. `.qa/BUGS.md` dal modello; `.qa/evidenze/` nel `.gitignore`.
8. Commit `QA: configurazione, catalogo e agenti`.

## Fase 4 – Ciclo (X giri)

Strati dal basso verso l'alto: db → api → web/mobile → e2e. Per ogni giro `r`:
1. **Test**: un subagent tester per volta, compito `Round r, strato <strato>. Ultimo bug: BUG-<n>.` Dal giro 2 aggiungi `Modalità verifica` e l'elenco dei file modificati dal fixer.
2. Dopo ogni tester: `git status --short` deve mostrare cambiamenti solo in `.qa/`; altrimenti ripristina i soli file estranei con `git restore` e segnalalo.
3. Se in `.qa/BUGS.md` non restano bug `aperto` o `riaperto`: **fermati**.
4. **Fix**: subagent `qa-fixer` con `Round r`. `BUILD FALLITA` → ferma il ciclo.
5. Annota per ogni esecuzione: agente, giro, strato, durata, token se disponibili, esito.

Dopo il giro X **fermati comunque**.

## Vincoli (sempre)

- Subagent in sequenza, mai in parallelo. Massimo 5 giri. Stop anticipato senza bug aperti o con build fallita due volte di seguito.
- Solo ambienti locali e di prova: mai produzione, servizi remoti reali, invii reali.
- I tester non toccano codice né configurazione; il fixer non avvia servizi e non tocca dati.
- Nessun push, merge o rebase. Mai segreti in `.qa/`, nei commit o nel report.
- Usa solo la risposta finale dei subagent e `.qa/BUGS.md`, non le loro trascrizioni.

## Fase 5 – Report finale

Esito in una riga; tabella bug (ID · severità · strato · stato finale · file modificati); bug aperti o non risolti con il motivo; tabella esecuzioni (giro · agente · strato · modello · durata · token · esito) con i totali; branch e commit creati; cosa provare a mano.
