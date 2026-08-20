# CompareFramework — Architecture Report

Generated automatically from `build/architecture/architecture.json`.

## Repository

- Version: **4.0.0-D1**
- Canonical schema: **1.4.0**
- LibreOffice Basic modules: **20**
- Lines: **5988**
- Procedures: **285**
- Public procedures: **134**
- Private procedures: **151**
- Parse warnings: **0**

## Call graph

- Resolved procedure edges: **600**
- Resolved call sites: **1207**
- Cross-module procedure edges: **321**
- Recursive edges: **1**

## Module dependencies

- Directed module dependencies: **77**
- Strongly connected cyclic components: **2**
- Modules participating in cycles: **9**
- Largest cyclic component: **7**

## Highest coupling

| Module | Fan-in | Fan-out | Coupling | Instability |
| --- | --- | --- | --- | --- |
| CompareFramework_Main | 5 | 15 | 20 | 0.750 |
| CompareFramework_EngineMemory | 4 | 10 | 14 | 0.714 |
| CompareFramework_Utils | 12 | 0 | 12 | 0.000 |
| CF_ModeReference | 1 | 9 | 10 | 0.900 |
| CompareFramework_Tests | 2 | 8 | 10 | 0.800 |
| CompareFramework_ComparatorConfig | 6 | 2 | 8 | 0.250 |
| CompareFramework_Config | 6 | 2 | 8 | 0.250 |
| CompareFramework_Context | 8 | 0 | 8 | 0.000 |
| CompareFramework_Rules | 4 | 4 | 8 | 0.500 |
| CompareFramework_Report | 6 | 1 | 7 | 0.143 |

## Cyclic components

1. **7 modules** — `CompareFramework_EngineMemory` → `CompareFramework_Main` → `CompareFramework_Profiles` → `CompareFramework_Quality` → `CompareFramework_Scenarios` → `CompareFramework_Tests` → `CompareFramework_Validation`
2. **2 modules** — `CompareFramework_Config` → `CompareFramework_Rules`

## Interpretation

`fan-in` is the number of modules depending on a module. `fan-out` is the
number of modules on which it depends. `coupling` is `fan-in + fan-out`.
`instability` is `fan-out / (fan-in + fan-out)`.

Cycles are strongly connected components of the directed module dependency
graph. They identify groups for which dependencies cannot be ordered
acyclically without refactoring.

## Machine-readable sources

- `architecture.json`
- `call_graph.json`
- `dependency_analysis.json`
- `module_dependencies.csv`
- `module_metrics.csv`
- `dependency_cycles.csv`
