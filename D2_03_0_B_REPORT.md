# D2-03.0-B — Procedure call graph

## Status

**VALIDATED**

## Scope

This increment analyzes LibreOffice Basic procedure bodies and resolves calls
between parsed CompareFramework procedures.

No Basic runtime source was modified.

## Canonical schema

`architecture.json` schema: **1.1.0**

The additive `call_graph` section contains nodes, resolved edges and graph
statistics.

## Generated outputs

```text
build/architecture/
├── architecture.json
├── call_graph.json
├── cross_module_calls.csv
├── dependency_matrix.csv
├── modules.csv
├── procedures.csv
├── statistics.json
└── symbol_index.csv
```

## Repository results

```text
Modules: 20
Procedures: 285
Public procedures: 204
Private procedures: 81
Resolved call edges: 600
Resolved call sites: 1207
Cross-module edges: 321
Recursive edges: 1
Unresolved known-name candidates: 0
Ambiguous known-name candidates: 0
```

## Resolution policy

- local procedure precedence;
- public cross-module resolution;
- explicit module qualification;
- object/UNO member calls ignored;
- function result assignment excluded from recursion;
- comments and strings ignored.

## Validation

- Python compilation: PASS
- focused call-graph tests: PASS
- full repository analysis: PASS
- deterministic outputs across two executions: PASS

## Commands

```bash
python -m tools.architecture --summary
python -S tests/test_architecture_callgraph.py
```
