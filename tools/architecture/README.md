# Architecture Analyzer

Internal, read-only architecture analysis tooling for CompareFramework.

## Current implementation

### D2-03.0-A1.1 — Repository foundation

- repository discovery under `src/**/*.bas`;
- version discovery from `VERSION`;
- canonical `build/architecture/architecture.json` metadata output.

### D2-03.0-A1.2 — LibreOffice Basic lexer

- deterministic token stream with one-based line and column positions;
- keywords and identifiers, including Basic type suffixes;
- numbers, strings with doubled-quote escapes and date literals;
- apostrophe and `Rem` comments;
- operators, separators, physical newlines and line continuations;
- UTF-8 and UTF-8-BOM source support;
- corpus test covering every current `src/**/*.bas` module.

Run tests from the repository root:

```bash
python -m pytest tests/test_architecture_lexer.py
```

Generate repository metadata:

```bash
python -m tools.architecture
```

The parser and symbol extraction are introduced in the next A1 increments.
