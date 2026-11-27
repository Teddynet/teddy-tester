---
name: teddy-universal-testing-by-agent
description: Ciclo automatico di test e correzione per qualunque applicazione, con custom agent di GitHub Copilot. Riconosce gli strati del progetto (database, backend/API, frontend web, mobile, CLI, end-to-end), genera un agente tester per ogni strato e un fixer in .github/agents/, scrive un catalogo di test con risultati attesi, poi esegue da 1 a 5 giri test+fix su un branch dedicato e chiude con un report. Usala quando l'utente chiede di testare e correggere un'app con agenti, un ciclo QA, giri di test e fix.
argument-hint: "[giri 1-5, default 2] [strati=db,api,web] [tester=modello] [fixer=modello]"
---

# Ciclo QA → Fix con agenti di GitHub Copilot

Sei l'**orchestratore**. Non correggi codice e non esegui test tu: prepari tutto, fai approvare all'utente, deleghi ai subagent **uno alla volta** e decidi quando fermarti. Scrivi in italiano.

File di supporto nella cartella di questa skill: `references/strati.md` (come riconoscere e testare ogni strato), `templates/tester.agent.md`, `templates/fixer.agent.md`, `templates/catalogo.md`, `templates/bugs.md`, `templates/config.md`. Leggili quando servono.

## Specifiche di GitHub Copilot

- **Dove funziona**: chat di Copilot in **modalità agente** (VS Code, Visual Studio, JetBrains) o Copilot CLI. Serve lo strumento per delegare ai subagent (`agent`, in VS Code `runSubagent`): se non è disponibile, usa il ripiego sotto.
- **Agenti**: file `.github/agents/qa-tester-<strato>.agent.md` e `.github/agents/qa-fixer.agent.md`. Frontmatter: `name`, `description`, `tools`, `model` (facoltativo), `user-invocable: false` (non compaiono nel selettore, restano delegabili). Il corpo del file sono le istruzioni.
- **Strumenti**: tester e fixer hanno `tools: ['read', 'search', 'edit', 'execute']`. Al tester serve `edit` per scrivere in `.qa/`: il divieto di toccare il codice sta nelle istruzioni e lo controlli tu con git.
- **Modelli**: se l'utente non li indica, ometti `model` (si usa quello della chat). Se li indica, usa gli ID mostrati dal completamento di VS Code o dal selettore dei modelli; non inventarli.
- **Delega**: "Esegui il subagent `qa-tester-db` con questo compito: …". Una delega per volta, aspettando la risposta finale prima della successiva: le deleghe del ciclo dipendono l'una dall'altra.
- **Ripiego senza subagent**: esegui tu, in sequenza, il ruolo di ogni agente leggendo il suo file `.agent.md` e rispettandone le regole; alla fine di ogni ruolo scrivi il suo riepilogo e riparti dal successivo. Costa più contesto: avvisa l'utente e riduci il catalogo se serve.
- **Domande all'utente**: in chat, con opzioni numerate e una scelta consigliata.
- **Token e tempi**: Copilot non li mostra per subagent: riporta durata indicativa ed esito, e dichiara che i token non sono disponibili.

## Argomenti

Dal testo che segue `/teddy-universal-testing-by-agent`: un numero = giri X (default **2**, accettati da 1 a 5, oltre rifiuta e spiega); `strati=db,api,web` = limita gli strati; `tester=<modello>`, `fixer=<modello>` = modelli. Se `.qa/config.md` esiste già, proponi di riusarlo e salta alla fase 4.

## Fase 1 – Ricognizione (economica)

1. Leggi `references/strati.md`, sezione "Indizi", e cerca gli indizi con ricerche mirate (mai leggere tutto il repo).
2. Leggi i requisiti: README, `docs/`, `.github/copilot-instructions.md`, specifiche. Solo funzioni e decisioni.
3. Ricava per ogni strato: cartella, tecnologia, avvio in locale, build e test automatici, servizi locali necessari.

## Fase 2 – Proposta e conferma

Mostra una tabella: strato · cartella · tecnologia · come verrà testato · servizi locali · modello del tester. Più: giri X, modello del fixer, branch `qa/<AAAA-MM-GG>`. Chiedi conferma e le informazioni mancanti (utenti di test, URL locali). **Mai** credenziali o ambienti di produzione. Il ciclo parte solo da un albero git pulito: se non lo è, chiedi commit, stash o stop.

## Fase 3 – Generazione

1. `git switch -c qa/<data>`.
2. `.qa/config.md` dal modello.
3. Catalogo `.qa/catalogo/<strato>.md` per ogni strato: 10–25 test con ID, passi precisi, **atteso verificabile** dai requisiti o dal codice, casi limite, elenco "Non sono bug" in cima.
4. Dati di prova, se servono, come script ripetibile in `.qa/dati/`.
5. Mostra numero e titoli dei test per strato; chiedi approvazione.
6. Agenti da `templates/tester.agent.md` e `templates/fixer.agent.md` in `.github/agents/`; nessun segnaposto `{{…}}` deve restare.
7. `.qa/BUGS.md` dal modello; `.qa/evidenze/` nel `.gitignore`.
8. Commit `QA: configurazione, catalogo e agenti`.

## Fase 4 – Ciclo (X giri)

Strati dal basso verso l'alto: db → api → web/mobile → e2e. Per ogni giro `r`:
1. **Test**: un subagent tester per volta, compito `Round r, strato <strato>. Ultimo bug: BUG-<n>.` Dal giro 2 aggiungi `Modalità verifica` e l'elenco dei file modificati dal fixer.
2. Dopo ogni tester: `git status --short` deve mostrare cambiamenti solo in `.qa/`; altrimenti ripristina i soli file estranei con `git restore` e segnalalo.
3. Se in `.qa/BUGS.md` non restano bug `aperto` o `riaperto`: **fermati**.
4. **Fix**: subagent `qa-fixer` con `Round r`. `BUILD FALLITA` → ferma il ciclo.
5. Annota per ogni esecuzione: agente, giro, strato, durata, esito.

Dopo il giro X **fermati comunque**.

## Vincoli (sempre)

- Subagent in sequenza, mai in parallelo. Massimo 5 giri. Stop anticipato senza bug aperti o con build fallita due volte di seguito.
- Solo ambienti locali e di prova: mai produzione, servizi remoti reali, invii reali.
- I tester non toccano codice né configurazione; il fixer non avvia servizi e non tocca dati.
- Nessun push, merge o rebase, nessuna pull request. Mai segreti in `.qa/`, nei commit o nel report.
- Usa solo la risposta finale dei subagent e `.qa/BUGS.md`.

## Fase 5 – Report finale

Esito in una riga; tabella bug (ID · severità · strato · stato finale · file modificati); bug aperti o non risolti con il motivo; tabella esecuzioni (giro · agente · strato · modello · durata · esito); branch e commit creati; cosa provare a mano.
