# CompareFramework Architecture Analyzer

Run:

```bash
python -m tools.architecture
python -m tools.architecture --summary
```

Current canonical schema: **1.5.0**

Schema 1.2.0 adds dependency, cycle and coupling analysis derived from the
resolved procedure call graph.

Generated files include:

```text
architecture.json
call_graph.json
cross_module_calls.csv
dependency_matrix.csv
dependency_analysis.json
module_dependencies.csv
module_metrics.csv
dependency_cycles.csv
modules.csv
procedures.csv
statistics.json
symbol_index.csv
```

Coupling metrics:

- fan-out: number of modules called;
- fan-in: number of calling modules;
- instability = fan-out / (fan-in + fan-out);
- coupling score = fan-in + fan-out.

Cycles are detected with strongly connected components on the directed module
dependency graph.

The analyzer is read-only and never modifies LibreOffice Basic runtime sources.


## Human-readable reports

D2-03.0-D generates two deterministic UTF-8 Markdown reports from the canonical
model:

```text
ARCHITECTURE_REPORT.md
DEPENDENCY_REPORT.md
```

The reports are derived views. They do not change schema `1.2.0` and do not
introduce a second source of truth.


## Contract-aware privatization

D2-03.19 integrates `docs/audit/PUBLIC_SYMBOL_INVENTORY.csv` directly into
candidate qualification. A documented `Keep Public` decision overrides static
call-graph heuristics and is exported under `protected_public`, never under
`candidates`.

This closes the automatic high-confidence privatization phase: when
`local_only_public_count` reaches zero, no further automatic visibility change
is permitted without explicit review of the remaining zero-caller procedures.


## Entrypoint audit

D2-03.20 classifies unresolved Public procedures by combining:

- `D1_PUBLIC_API_INVENTORY.csv`;
- `PUBLIC_SYMBOL_INVENTORY.csv`;
- references in user-facing documentation.

Outputs:

```text
entrypoint_audit.json
entrypoint_audit.csv
```

No visibility is changed by this audit. `documentation-conflict-review` and
`maintenance-entrypoint-review` require an explicit human decision.
