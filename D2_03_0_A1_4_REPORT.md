# D2-03.0-A1.4 — Symbol table and canonical exports

## Scope

This increment builds a normalized symbol table from the A1.3 parser model and
adds deterministic JSON/CSV exports. No LibreOffice Basic source is modified.

## Added

- `tools/architecture/symbols.py`
- `tools/architecture/exporters.py`
- `tests/test_architecture_symbols.py`

## Generated artifacts

- `build/architecture/architecture.json`
- `build/architecture/modules.csv`
- `build/architecture/procedures.csv`
- `build/architecture/symbol_index.csv`
- `build/architecture/statistics.json`

## Architecture contract

`architecture.json` remains the canonical model (`schema_version` 1.0.0). The
new `languages` collection prepares the schema for future Python self-analysis
while the existing top-level `modules` field is retained for A1.3 compatibility.

## Deferred

Procedure-body parsing, call resolution, dependency cycles and private-candidate
analysis remain deliberately deferred to D2-03.0-B and later milestones.
