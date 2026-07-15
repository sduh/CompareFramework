# Correctif D4 — appels `Round()` réels dans les sources

Le build a identifié trois vrais appels incompatibles avec LibreOffice Basic :

- `src/CompareFramework_Audit.bas`
- `src/CompareFramework_Performance.bas` (deux appels)

Ils doivent être remplacés par `CF_RoundCompat()`.

## Application automatique

Depuis la racine du dépôt :

```bash
bash /chemin/vers/APPLY_PATCH.sh .
```

Le script :

1. remplace les trois appels ;
2. ajoute `CF_RoundCompat()` dans `src/CompareFramework_Utils.bas` si nécessaire ;
3. relance `python3 tools/build_monolith.py`.

## Remplacements manuels

```basic
CF_AuditDurationSeconds = CF_RoundCompat((endValue - CF_AUDIT_STARTED_AT) * 86400, 3)
```

```basic
CF_PerfCell oSheet, 1, r, CStr(CF_RoundCompat(CF_PERF_ELAPSED(i), 3))
```

```basic
CF_PerfCell oSheet, 4, r, CStr(CF_RoundCompat(CF_PERF_PAIR_SECONDS(i), 3))
```
