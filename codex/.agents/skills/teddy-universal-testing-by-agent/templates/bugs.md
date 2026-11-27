# BUGS – {{NOME_APP}}

Stati: `aperto` → `risolto` (fixer) → `verificato` o `riaperto` (tester). `non risolto` = il fixer non può o non deve correggerlo (motivo indicato).

Severità: **critica** = crash, perdita o corruzione di dati, falla di sicurezza · **alta** = funzione principale inutilizzabile · **media** = risultato sbagliato con un modo per aggirarlo · **bassa** = testo, layout, messaggio poco chiaro.

Formato di ogni bug:

```
### BUG-<id> [Severità: critica|alta|media|bassa] [Stato: aperto] [Strato: <strato>]
- Round / Test: <N> / <ID del catalogo>
- Passi per riprodurre:
- Atteso:
- Ottenuto:
- Log (estratto):
- Prove: .qa/evidenze/round_<N>/<file>
- File sospetti:
```

---
