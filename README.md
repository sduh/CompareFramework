# CompareFramework V3.7.3-D4 — Distribution reproductible

D4 transforme le monolithe en **artefact généré**.

## Source de vérité

- `src/`
- `MODULE_ORDER.txt`

## Build

```bash
python3 tools/build_monolith.py
```

## Sorties

- `dist/CompareFramework_3_7_3_D4_Monolith.bas`
- `dist/BUILD_MANIFEST.json`

Le mode Référence D1, la synthèse D2 et l'assistant D3 sont inclus via
`src/Modes/CF_ModeReference.bas`.

Voir `docs/INSTALLATION_D4.md`.
