# CompareFramework Architecture Analyzer

The analyzer reads `src/**/*.bas` without modifying source files and writes the
canonical model to `build/architecture/architecture.json`.

## Run

```bash
python -m tools.architecture
```

## A1.3 scope

The LibreOffice Basic lexer and declaration parser extract:

- `Option Explicit`;
- public and private `Sub`, `Function`, and `Property` declarations;
- parameters, return types, signatures and source bounds;
- module constants and variables;
- user-defined `Type` and `Enum` blocks.

Call-graph and procedure-body analysis are intentionally deferred to D2-03.0-B.
