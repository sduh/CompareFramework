# D2-03.0-A1.5 — Model validation and stable CLI

## Result

Status: **VALIDATED**

## Changes

- Canonical architecture model validation before export.
- Stable CLI with `--root` and `--summary`.
- Explicit exit code `3` for analysis/model errors.
- Backward-compatible repository discovery.
- Schema version remains `1.0.0`.
- No runtime Basic source modified.

## Verification

- Python compilation: PASS
- CLI analysis: PASS
- A1.5 unit tests: PASS
- Deterministic architecture.json rerun: PASS

## Repository metrics

```text
{
  "module_count": 20,
  "line_count": 5988,
  "procedure_count": 285,
  "public_procedure_count": 204,
  "private_procedure_count": 81,
  "constant_count": 41,
  "module_variable_count": 51,
  "type_count": 0,
  "enum_count": 0,
  "symbol_count": 917,
  "parse_warning_count": 0
}
```

## Commands

```bash
python -S -m compileall -q tools/architecture
python -S tests/test_architecture_a15.py
python -S -m tools.architecture --summary
```

`-S` is only used in the validation environment to disable unrelated site-level
startup hooks. The normal project command remains:

```bash
python -m tools.architecture
```
