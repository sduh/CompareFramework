# D2-03.0-A1.2 — LibreOffice Basic Lexer

## Delivered

- `tools/architecture/tokens.py`
- `tools/architecture/lexer.py`
- `tests/test_architecture_lexer.py`
- updated `tools/architecture/README.md`

## Supported lexical constructs

- case-insensitive Basic keywords while preserving original spelling;
- identifiers and Basic declaration suffixes (`$`, `%`, `&`, `!`, `#`, `@`);
- decimal, exponent, hexadecimal and octal numeric literals;
- string literals with doubled-quote escaping;
- date literals delimited by `#`;
- apostrophe and `Rem` comments;
- operators and separators;
- physical newlines and explicit line continuations;
- one-based source line and column positions;
- UTF-8 and UTF-8-BOM input.

## Validation

Commands executed from the repository root:

```bash
python -m compileall -q tools/architecture tests
python -m pytest -q
python -m tools.architecture
```

Results:

- 8 tests passed;
- all 20 current `src/**/*.bas` files tokenized successfully;
- 40,639 tokens emitted across the current Basic corpus;
- existing `architecture.json` generation remains operational.

## Scope boundary

This increment performs lexical analysis only. Declaration parsing and symbol
model construction belong to A1.3 and later increments.
