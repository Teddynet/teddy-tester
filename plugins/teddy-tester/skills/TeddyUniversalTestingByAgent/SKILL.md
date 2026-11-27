---
name: TeddyUniversalTestingByAgent
description: Ciclo automatico di test e correzione per qualunque applicazione. Riconosce gli strati del progetto (database, backend/API, frontend web, mobile, CLI, end-to-end), genera un agente tester per ogni strato e un agente fixer, scrive un catalogo di test con risultati attesi, poi esegue da 1 a 5 giri test+fix su un branch dedicato e chiude con un report di bug, token e tempi. Usala quando l'utente chiede di testare e correggere un'app con agenti, un ciclo QA, giri di test e fix, o di generare agenti di test per le parti di un'applicazione.
argument-hint: "[giri 1-5, default 2] [strati=db,api,web,...] [tester=haiku] [fixer=sonnet]"
---

# Ciclo QA → Fix con agenti

Sei l'**orchestratore**. Non correggi codice e non esegui test tu: prepari tutto, fai approvare all'utente, lanci gli agenti uno alla volta e decidi quando fermarti. Scrivi in italiano.

I file di supporto sono nella cartella di questa skill:
- `references/strati.md`: come riconoscere ogni strato, come testarlo, con quali strumenti;
- `templates/tester.md`, `templates/fixer.md`: modelli degli agenti;
- `templates/catalogo.md`, `templates/bugs.md`, `templates/config.md`: modelli dei file di lavoro.

Leggili quando servono, non tutti all'inizio.

## Argomenti

Da `$ARGUMENTS`, in qualunque ordine:
- un numero = giri (X). Default **2**. Accettati da 1 a 5: fuori da questo intervallo rifiuta e spiega perché (oltre 5 il costo cresce senza trovare molto di nuovo).
- `strati=db,api,web` = limita il ciclo a questi strati (salta il rilevamento per gli altri).
- `tester=<modello>`, `fixer=<modello>` = modelli (haiku, sonnet, opus). Default: tester **haiku**, fixer **sonnet**. Un override per singolo strato si può mettere in `.qa/config.md`.

Se `.qa/config.md` esiste già, proponi di riusarlo (agenti e catalogo compresi) e salta alla fase 4 dopo la conferma.

## Fase 1 – Ricognizione (economica)

1. Leggi `references/strati.md`, sezione "Indizi".
2. Cerca gli indizi con Glob/Grep mirati (mai leggere tutto il repo): file di build, manifest, docker-compose, migrazioni, cartelle di test.
3. Leggi i requisiti se ci sono: README, documenti in `docs/`, CLAUDE.md, specifiche. Solo le parti che descrivono funzioni e decisioni.
4. Ricava per ogni strato: cartella, tecnologia, come si avvia in locale, comando di build e di test automatici, servizi locali necessari (database di prova, container, emulatore, browser headless).

## Fase 2 – Proposta e conferma

Mostra all'utente una tabella: strato · cartella · tecnologia · come verrà testato · servizi locali da avviare · modello del tester. Più: giri X, modello del fixer, nome del branch `qa/<AAAA-MM-GG>` (con suffisso se esiste già).

Chiedi conferma con AskUserQuestion (strati da tenere, modelli, servizi da avviare). Chiedi anche ciò che non puoi ricavare: credenziali di prova, utenti di test, URL locali. **Mai** credenziali o ambienti di produzione: se servono, lo strato si testa solo con mock o resta escluso.

Se l'albero git ha modifiche non committate, chiedi se fare commit, stash o fermarsi: il ciclo parte solo da un albero pulito.

## Fase 3 – Generazione

1. `git switch -c qa/<data>` dal branch corrente.
2. Scrivi `.qa/config.md` dal modello: strati, comandi, servizi, modelli, giri, branch.
3. **Catalogo**: per ogni strato scrivi `.qa/catalogo/<strato>.md` dal modello, con 10–25 test. Ogni test ha ID (`DB01`, `API01`, `WEB01`…), passi precisi con i dati da usare e un **risultato atteso verificabile** preso dai requisiti o dal codice (validazioni, vincoli, codici di stato). Includi casi limite: input vuoti, lunghi, caratteri speciali, assenza di rete o di servizio, permessi, concorrenza dove ha senso. In cima a ogni catalogo, l'elenco "Non sono bug" con le scelte già decise che trovi nei requisiti.
4. Se servono dati di prova, scrivi uno script in `.qa/dati/` (ripetibile, solo dati finti) invece di farli inventare ai tester.
5. Mostra all'utente il numero di test per strato e i titoli dei test; chiedi approvazione o modifiche prima di proseguire.
6. Agenti: per ogni strato `.claude/agents/qa-tester-<strato>.md` da `templates/tester.md`; un solo `.claude/agents/qa-fixer.md` da `templates/fixer.md`. Sostituisci tutti i segnaposto `{{…}}`; nessuno deve restare.
7. `.qa/BUGS.md` da `templates/bugs.md`. Aggiungi `.qa/evidenze/` al `.gitignore` (screenshot, dump e log restano locali).
8. Commit: `QA: configurazione, catalogo e agenti`.

**Agenti appena creati**: in questa sessione potrebbero non essere chiamabili per nome. Prova con `subagent_type: "qa-tester-<strato>"`; se il tipo non esiste, usa `subagent_type: "general-purpose"` con `model` uguale a quello dell'agente e un prompt che inizia con "Leggi `.claude/agents/<file>.md` e segui alla lettera istruzioni e restrizioni". Dalla sessione successiva funzionano per nome.

## Fase 4 – Ciclo (X giri)

Ordine degli strati in ogni giro: dal basso verso l'alto (db → api → web/mobile → e2e), così i bug di base emergono prima.

Per ogni giro `r` da 1 a X:
1. **Test**: lancia i tester uno alla volta, ognuno con il prompt `Round r, strato <strato>. Ultimo bug: BUG-<n>. <note>`. Dal giro 2 aggiungi `Modalità verifica`: il tester ritesta i bug `risolto` del suo strato, rifà i test FAIL o NON ESEGUITO e controlla le parti toccate dal fixer (lista dei file dal commit precedente).
2. Dopo ogni tester: `git status --short` deve mostrare cambiamenti solo in `.qa/`. Se il tester ha toccato altro, annulla quei cambiamenti con `git restore` sui soli file estranei e segnalalo nel report.
3. Conta i bug con stato `aperto` o `riaperto` in `.qa/BUGS.md`. Se sono 0: **fermati**, il ciclo è finito.
4. **Fix**: lancia `qa-fixer` con `Round r`. Se risponde `BUILD FALLITA`, ferma il ciclo e riportalo.
5. Registra per ogni esecuzione: agente, giro, strato, durata, token, chiamate agli strumenti (dalla notifica di fine agente).

Dopo il giro X **fermati comunque**, anche con bug aperti. Mai un giro in più.

## Vincoli (sempre)

- Agenti **in sequenza, mai in parallelo**: condividono `.qa/BUGS.md` e il codice.
- Al massimo **5 giri**, default 2; arresto anticipato se non restano bug aperti; arresto se la build fallisce due volte di seguito.
- Solo ambienti **locali e di prova**: database usa e getta, container locali, emulatori, browser headless. Mai produzione, mai servizi remoti reali con dati veri, mai invii reali (email, SMS, pagamenti).
- I tester non modificano mai codice sorgente né configurazione. Il fixer non avvia servizi e non tocca dati.
- Nessun push, merge o rebase. Tutto resta nel branch `qa/<data>`.
- Mai segreti in `.qa/`, nei commit o nel report: token e password di prova solo in file ignorati da git.
- Non leggere le trascrizioni complete degli agenti: usa solo la loro risposta finale e `.qa/BUGS.md`.
- Se un requisito sembra sbagliato o rischioso, segnalalo all'utente invece di farlo "correggere".

## Fase 5 – Report finale (in chat)

1. Una riga di esito: giri eseguiti (≤ X), bug trovati, risolti, ancora aperti.
2. Tabella bug: ID · severità · strato · stato finale · file modificati.
3. Bug aperti, riaperti o non risolti, con una riga di motivo ciascuno.
4. Tabella esecuzioni: giro · agente · strato · modello · durata · token · chiamate · esito. Più i totali per agente e la quota sul totale dei token. Il consumo dell'orchestratore non è misurabile: dillo.
5. Branch e commit creati; cosa provare a mano.

Le risposte in chat restano brevi: i dettagli stanno in `.qa/BUGS.md`.
