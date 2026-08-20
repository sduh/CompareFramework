# D2-03.0-D — Automatic architecture reports

## Status

**VALIDATED**

## Scope

D2-03.0-D adds deterministic, human-readable Markdown reports generated from
the canonical architecture model.

The canonical schema remains **1.2.0** because this milestone adds derived
views only.

## New outputs

```text
build/architecture/
├── ARCHITECTURE_REPORT.md
└── DEPENDENCY_REPORT.md
```

## Current repository metrics

```text
Modules: 20
Procedures: 285
Resolved call edges: 600
Resolved call sites: 1207
Module dependencies: 77
Cyclic components: 2
Cyclic modules: 9
Largest cycle: 7
```

## Report principles

- generated exclusively from canonical analyzer data;
- UTF-8;
- deterministic;
- no duplicated analysis logic;
- no modification of LibreOffice Basic runtime sources;
- machine-readable exports remain the source of truth.

## Validation

- Python compilation: PASS
- A1.5 regression tests: PASS
- call-graph regression tests: PASS
- dependency regression tests: PASS
- report tests: PASS
- full repository analysis: PASS
- UTF-8 decoding: PASS
- deterministic outputs: PASS
