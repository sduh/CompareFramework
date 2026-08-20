# CompareFramework Architecture Analyzer

The analyzer reads `src/**/*.bas` and generates a canonical architecture model
and deterministic derived exports under:

```text
build/architecture/
```

## Run

```bash
python -m tools.architecture
```

Print statistics:

```bash
python -m tools.architecture --summary
```

Analyze another checkout:

```bash
python -m tools.architecture --root /path/to/CompareFramework
```

## Canonical output

`architecture.json` is the canonical model.

Schema `1.1.0` adds a resolved procedure call graph while preserving all A1
fields.

Generated files:

```text
architecture.json
call_graph.json
cross_module_calls.csv
dependency_matrix.csv
modules.csv
procedures.csv
statistics.json
symbol_index.csv
```

## Call resolution rules

- same-module procedures take precedence;
- only `Public` procedures are resolved across modules;
- `ModuleName.Procedure` is supported;
- dotted UNO/object calls are ignored;
- a Basic function result assignment (`MyFunction = value`) is not recursion;
- strings and comments never generate calls.

The analyzer does not attempt to resolve Basic built-ins or UNO methods.

## Exit codes

- `0`: success
- `2`: CLI usage error
- `3`: repository, parsing, validation or export error
