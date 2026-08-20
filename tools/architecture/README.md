# CompareFramework Architecture Analyzer

The analyzer reads `src/**/*.bas` and generates a canonical architecture model under:

```text
build/architecture/
```

## Run

```bash
python -m tools.architecture
```

From another working directory:

```bash
python -m tools.architecture --root /path/to/CompareFramework
```

Print statistics:

```bash
python -m tools.architecture --summary
```

## Exit codes

- `0`: success
- `2`: CLI usage error (`argparse`)
- `3`: repository, parsing, export or model validation error

## Canonical output

`build/architecture/architecture.json` is the canonical analyzer output. CSV and statistics exports are derived from the same in-memory model.

The current schema version is `1.0.0`.
