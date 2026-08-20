# CompareFramework Architecture Analyzer

The analyzer reads `src/**/*.bas` without modifying source files. Its canonical
machine-readable output is `build/architecture/architecture.json`.

## Run

```bash
python -m tools.architecture
```

## A1.4 outputs

The command generates, from one parsed repository model:

```text
build/architecture/
├── architecture.json
├── modules.csv
├── procedures.csv
├── statistics.json
└── symbol_index.csv
```

`architecture.json` is the canonical representation. CSV and statistics files
are deterministic projections of the same in-memory model; source files are not
reparsed for individual exports.

## Current parsing scope

- `Option Explicit`;
- `Sub`, `Function`, and `Property` declarations;
- parameters, return types, signatures and source bounds;
- module constants and variables;
- user-defined `Type` and `Enum` blocks;
- normalized symbol table including parameters and members.

Procedure-body and call-graph analysis are intentionally deferred to
D2-03.0-B.
