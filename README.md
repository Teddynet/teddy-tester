# teddy-tester – ciclo di test e correzione con agenti

Skill per cicli automatici di test e correzione con agenti, in cinque versioni ottimizzate per strumento. In qualunque progetto, la skill:

1. riconosce gli strati dell'applicazione (database, backend/API, frontend web, mobile, CLI, job, end-to-end);
2. propone gli strati, i servizi locali da avviare e i modelli, e aspetta la tua conferma;
3. scrive un catalogo di test per strato con risultati attesi, da approvare;
4. genera un agente tester per strato (`qa-tester-<strato>`) e un solo agente fixer (`qa-fixer`);
5. esegue da 1 a 5 giri test+fix (default 2) su un branch dedicato `qa/<data>`, con un commit per giro;
6. chiude con un report in chat: bug, stato finale, file modificati, tempi (e token dove lo strumento li fornisce).

| Strumento | Cartella | Nome della skill | Comando | Agenti generati in |
|---|---|---|---|---|
| Claude Code | radice (plugin) | `TeddyUniversalTestingByAgent` | `/teddy-tester:TeddyUniversalTestingByAgent 3` | `.claude/agents/` |
| ChatGPT Codex | [codex/](codex/README.md) | `teddy-universal-testing-by-agent` | `$teddy-universal-testing-by-agent 3` | `.codex/agents/` (TOML) |
| Cursor | [cursor/](cursor/README.md) | `teddy-universal-testing-by-agent` | `/teddy-universal-testing-by-agent 3` | `.cursor/agents/` |
| GitHub Copilot | [copilot/](copilot/README.md) | `teddy-universal-testing-by-agent` | `/teddy-universal-testing-by-agent 3` | `.github/agents/` |
| OpenCode | [opencode/](opencode/README.md) | `teddy-universal-testing-by-agent` | `/teddy-tester 3` | `.opencode/agents/` |

Cursor, Copilot e OpenCode accettano solo nomi di skill in minuscolo con trattini, per questo il nome cambia. Il comportamento è lo stesso ovunque; cambiano il formato degli agenti, il modo di avviarli in sequenza e la disponibilità di token e tempi nel report.

## Installazione

### Claude Code

Direttamente da GitHub, senza clonare:

```
claude plugin marketplace add Teddynet/teddy-tester
claude plugin install teddy-tester@teddy-tester
```

Oppure dentro Claude Code: `/plugin marketplace add Teddynet/teddy-tester` e poi `/plugin install teddy-tester@teddy-tester`. Aggiornamenti: `claude plugin marketplace update teddy-tester`.

### Altri strumenti: prima clona il repository

```
git clone https://github.com/Teddynet/teddy-tester.git && cd teddy-tester
```

Poi copia la skill nella cartella dello strumento. "Per tutti i progetti" la installa nella tua cartella utente; "solo un progetto" la mette nel repository del progetto (con commit, la ricevono tutti quelli che lo clonano). Aggiornamenti: `git pull` nel clone e ripeti la copia.

### ChatGPT Codex

| Dove | bash (Linux, macOS, Git Bash) | PowerShell (Windows) |
|---|---|---|
| Tutti i progetti | `mkdir -p ~/.agents/skills && cp -r codex/.agents/skills/teddy-universal-testing-by-agent ~/.agents/skills/` | `New-Item -ItemType Directory -Force $HOME\.agents\skills; Copy-Item -Recurse codex\.agents\skills\teddy-universal-testing-by-agent $HOME\.agents\skills\` |
| Solo un progetto | `mkdir -p <progetto>/.agents/skills && cp -r codex/.agents/skills/teddy-universal-testing-by-agent <progetto>/.agents/skills/` | `New-Item -ItemType Directory -Force <progetto>\.agents\skills; Copy-Item -Recurse codex\.agents\skills\teddy-universal-testing-by-agent <progetto>\.agents\skills\` |

Uso: `$teddy-universal-testing-by-agent 3`, oppure `/skills` e scegli la skill. Dettagli in [codex/README.md](codex/README.md).

### Cursor

| Dove | bash (Linux, macOS, Git Bash) | PowerShell (Windows) |
|---|---|---|
| Tutti i progetti | `mkdir -p ~/.cursor/skills && cp -r cursor/.cursor/skills/teddy-universal-testing-by-agent ~/.cursor/skills/` | `New-Item -ItemType Directory -Force $HOME\.cursor\skills; Copy-Item -Recurse cursor\.cursor\skills\teddy-universal-testing-by-agent $HOME\.cursor\skills\` |
| Solo un progetto | `mkdir -p <progetto>/.cursor/skills && cp -r cursor/.cursor/skills/teddy-universal-testing-by-agent <progetto>/.cursor/skills/` | `New-Item -ItemType Directory -Force <progetto>\.cursor\skills; Copy-Item -Recurse cursor\.cursor\skills\teddy-universal-testing-by-agent <progetto>\.cursor\skills\` |

Uso, nella chat Agent: `/teddy-universal-testing-by-agent 3`. Dopo l'installazione ricarica la finestra di Cursor. Dettagli in [cursor/README.md](cursor/README.md).

### GitHub Copilot

| Dove | bash (Linux, macOS, Git Bash) | PowerShell (Windows) |
|---|---|---|
| Tutti i progetti | `mkdir -p ~/.copilot/skills && cp -r copilot/.github/skills/teddy-universal-testing-by-agent ~/.copilot/skills/` | `New-Item -ItemType Directory -Force $HOME\.copilot\skills; Copy-Item -Recurse copilot\.github\skills\teddy-universal-testing-by-agent $HOME\.copilot\skills\` |
| Solo un progetto | `mkdir -p <progetto>/.github/skills && cp -r copilot/.github/skills/teddy-universal-testing-by-agent <progetto>/.github/skills/` | `New-Item -ItemType Directory -Force <progetto>\.github\skills; Copy-Item -Recurse copilot\.github\skills\teddy-universal-testing-by-agent <progetto>\.github\skills\` |

Uso, nella chat di Copilot in **modalità agente** (VS Code, Visual Studio, JetBrains): `/teddy-universal-testing-by-agent 3`. Dettagli in [copilot/README.md](copilot/README.md).

### OpenCode (versione 2)

Servono due copie: la skill e il comando `/teddy-tester`.

| Dove | bash (Linux, macOS, Git Bash) | PowerShell (Windows) |
|---|---|---|
| Tutti i progetti | `mkdir -p ~/.config/opencode/skills ~/.config/opencode/commands && cp -r opencode/.opencode/skills/teddy-universal-testing-by-agent ~/.config/opencode/skills/ && cp opencode/.opencode/commands/teddy-tester.md ~/.config/opencode/commands/` | `New-Item -ItemType Directory -Force $HOME\.config\opencode\skills, $HOME\.config\opencode\commands; Copy-Item -Recurse opencode\.opencode\skills\teddy-universal-testing-by-agent $HOME\.config\opencode\skills\; Copy-Item opencode\.opencode\commands\teddy-tester.md $HOME\.config\opencode\commands\` |
| Solo un progetto | `mkdir -p <progetto>/.opencode/skills <progetto>/.opencode/commands && cp -r opencode/.opencode/skills/teddy-universal-testing-by-agent <progetto>/.opencode/skills/ && cp opencode/.opencode/commands/teddy-tester.md <progetto>/.opencode/commands/` | `New-Item -ItemType Directory -Force <progetto>\.opencode\skills, <progetto>\.opencode\commands; Copy-Item -Recurse opencode\.opencode\skills\teddy-universal-testing-by-agent <progetto>\.opencode\skills\; Copy-Item opencode\.opencode\commands\teddy-tester.md <progetto>\.opencode\commands\` |

Uso: `/teddy-tester 3`. Dettagli in [opencode/README.md](opencode/README.md).

## Uso

Apri lo strumento nella cartella del progetto da testare, con l'albero git pulito, e lancia il comando della tabella in cima. Esempi con Claude Code:

```
/teddy-tester:TeddyUniversalTestingByAgent
/teddy-tester:TeddyUniversalTestingByAgent 3
/teddy-tester:TeddyUniversalTestingByAgent 2 strati=db,api tester=sonnet
```

| Argomento | Significato | Default |
|---|---|---|
| numero | giri test+fix, da 1 a 5 | 2 |
| `strati=` | strati da testare, separati da virgola | tutti quelli rilevati |
| `tester=` | modello dei tester | Claude Code: haiku; altri strumenti: modello della sessione |
| `fixer=` | modello del fixer | Claude Code: sonnet; altri strumenti: modello della sessione |

I nomi dei modelli sono quelli dello strumento usato (per OpenCode nella forma `provider/modello`). Si può anche chiedere a parole: "fai 3 giri di test e correzione su questa app".

## Cosa resta nel progetto

| Percorso | Contenuto | In git |
|---|---|---|
| `.qa/config.md` | strati, comandi, modelli, giri | sì |
| `.qa/catalogo/<strato>.md` | test con risultati attesi | sì |
| `.qa/BUGS.md` | bug, stati, cause, correzioni | sì |
| `.qa/dati/` | script dei dati di prova | sì |
| `.qa/evidenze/` | esiti, screenshot, dump, log | no |
| cartella degli agenti dello strumento (tabella in cima) | agenti `qa-tester-*` e `qa-fixer` generati | sì |

Rilanciando la skill nello stesso progetto, ti propone di riusare configurazione, catalogo e agenti.

## Regole che la skill rispetta

- Agenti sempre uno alla volta; mai più di 5 giri; stop appena non restano bug aperti o se la build fallisce due volte di seguito.
- Solo ambienti locali e di prova: niente produzione, servizi remoti reali, invii reali.
- I tester non toccano il codice; il fixer non avvia servizi e non tocca dati.
- Nessun push, merge o rebase: decidi tu se e quando unire il branch `qa/<data>`.

## Note

- Gli agenti generati durante una sessione possono non essere chiamabili per nome fino alla sessione successiva (o al ricaricamento della finestra): nel frattempo la skill li fa eseguire a un agente generico che legge il loro file.
- La maggior parte dei token va ai tester (in un caso reale l'87%): per risparmiare conviene restringere gli strati o il catalogo, più che cambiare il modello del fixer.
- Le versioni per Codex, Cursor, Copilot e OpenCode seguono la documentazione ufficiale di novembre 2026 ma non sono ancora state provate su un progetto vero: segnala i problemi aprendo una issue.
- Per provare la versione Claude Code da un clone, senza installarla: `claude --plugin-dir plugins/teddy-tester`

## Manutenzione

I file comuni (`references/strati.md`, `templates/catalogo.md`, `bugs.md`, `config.md`) e il testo degli agenti si modificano solo nella versione Claude Code (`plugins/teddy-tester/skills/TeddyUniversalTestingByAgent/`); poi `bash scripts/sincronizza-comuni.sh` li copia nelle altre versioni. I modelli TOML di Codex e i file `SKILL.md` di ogni versione si aggiornano a mano. A ogni rilascio alza `version` in `plugins/teddy-tester/.claude-plugin/plugin.json`.
