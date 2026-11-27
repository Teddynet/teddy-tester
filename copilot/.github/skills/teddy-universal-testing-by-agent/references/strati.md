# Strati di un'applicazione: indizi, cosa testare, strumenti

Gli strati di un progetto possono essere più d'uno dello stesso tipo (due frontend, più servizi backend): ogni istanza ha il suo tester (`api-ordini`, `api-utenti`).

## Indizi

| Strato | Indizi nel repository |
|---|---|
| `db` | `migrations/`, `*.sql`, `schema.prisma`, `alembic/`, `flyway`, `liquibase`, entità ORM (`@Entity`, Room `@Database`, SQLAlchemy `Base`), servizi `postgres`/`mysql`/`mariadb`/`mongo` in `docker-compose*` |
| `api` | `package.json` con express/fastify/nest/koa; `requirements.txt`/`pyproject.toml` con fastapi/django/flask; `pom.xml`/`build.gradle` con spring; `go.mod`; `composer.json` o `index.php` da router; `*.csproj` ASP.NET; file OpenAPI (`openapi.yaml`, `swagger.json`) |
| `web` | `package.json` con react/vue/angular/svelte/next/nuxt; `vite.config.*`, `index.html`, `src/app`, `pages/` |
| `mobile` | Android: `build.gradle*` con `com.android.application`, `AndroidManifest.xml`. iOS: `*.xcodeproj`, `Podfile`. Cross: `pubspec.yaml` (Flutter), `app.json` con expo/react-native |
| `cli` | `bin/` in `package.json`, `console_scripts`, `cmd/` in Go, `main` con parsing di argomenti |
| `e2e` | Più strati che parlano tra loro (frontend + API + DB, app + server di sync): flussi completi dall'interfaccia ai dati |
| `job` | Code e lavori pianificati: cron, WorkManager, Celery, Sidekiq, BullMQ |

Test automatici esistenti (cartelle `test/`, `tests/`, `__tests__/`, `src/test`, `spec/`) vanno lanciati dal tester dello strato come primo passo: un fallimento è un bug.

## Cosa testare e con cosa

### db
- Strumenti: database **di prova** usa e getta (container locale o SQLite temporaneo), client a riga di comando (`psql`, `mysql`, `sqlite3`, `mongosh`).
- Test: migrazioni da zero e in sequenza (e rollback se previsto); schema contro i modelli del codice (colonne, tipi, nullabilità); vincoli (NOT NULL, UNIQUE, chiavi esterne, CHECK) con inserimenti che devono fallire; cancellazioni a cascata; indici sulle query principali (`EXPLAIN`); dati con caratteri speciali, emoji, testi lunghi, date al limite e fusi orari.

### api
- Strumenti: server avviato in locale con configurazione di prova, `curl` con `-w "%{http_code}"`, suite esistenti.
- Test per ogni endpoint: caso corretto; validazione (campi mancanti, tipi sbagliati, valori fuori limite); autenticazione e autorizzazione (senza token, token sbagliato, utente senza permessi); codici di stato; errori che non espongono dettagli interni; limiti di dimensione e paginazione; idempotenza di PUT/DELETE; rate limit se previsto; comportamento con il database spento.

### web
- Strumenti: Playwright o Cypress **se già presenti nel progetto**; altrimenti chiedi all'utente prima di installare qualcosa. Server di sviluppo locale. Screenshot in `.qa/evidenze/`.
- Test: navigazione tra le pagine principali; moduli (validazione, messaggi d'errore, doppio invio); stati vuoti, di caricamento e di errore con API spenta; larghezze mobile e desktop; errori nella console del browser; accessibilità di base (etichette, focus da tastiera, contrasto); tasto indietro e ricarica della pagina.

### mobile
- Android: emulatore (`emulator -avd <nome>`, attendi `sys.boot_completed`), `adb install -r`, `uiautomator dump` filtrato con grep, `input tap/text/swipe/keyevent`, `screencap`, `logcat -d *:E` filtrato sul package. Posizione finta: `adb emu geo fix <lng> <lat>`. PIN temporaneo per biometria: `locksettings set-pin` (toglierlo alla fine).
- iOS: simulatore con `xcrun simctl` (install, launch, screenshot, openurl); senza strumenti di automazione UI i test sono limitati: dichiaralo.
- Test: avvio a freddo, navigazione, moduli, rotazione, tasto indietro, permessi concessi e negati, assenza di rete, app in background e ritorno, condivisione da e verso altre app, dati lunghi o in altre lingue.
- Attenzione: un emulatore con poca memoria produce blocchi e disconnessioni che sembrano bug. Un bug visto una sola volta va ripetuto prima di segnalarlo come critico.

### cli
- Test: `--help`; argomenti mancanti, sconosciuti, malformati; codici di uscita; file inesistenti o senza permessi; input molto grandi; output su pipe.

### e2e
- Test: i flussi utente principali dall'interfaccia ai dati e ritorno (crea → modifica → elimina, con verifica nel database o nell'API); due client che modificano lo stesso dato; ripresa dopo assenza di rete.

### job
- Test: esecuzione manuale del lavoro; nuovo tentativo dopo un errore; esecuzione doppia (idempotenza); comportamento senza rete o senza database.

## Servizi locali tipici

| Bisogno | Come, solo in locale |
|---|---|
| Database di prova | `docker compose up -d <servizio>` con volume temporaneo; alla fine `docker compose down -v` solo per i container di prova creati dal ciclo |
| Server backend | comando di sviluppo del progetto con configurazione di prova |
| Servizi esterni (email, pagamenti, SMS) | mock o modalità sandbox già prevista dal progetto; altrimenti test NON ESEGUITO |
| Emulatore Android verso server locale | `adb reverse tcp:<porta> tcp:<porta>` e indirizzo `http://localhost:<porta>` |
