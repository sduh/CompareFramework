# D2-03.0-C — Dependency, cycle and coupling analysis

## Status

**VALIDATED**

## Canonical schema

`architecture.json`: **1.2.0**

## Repository results

```text
Modules: 20
Resolved procedure edges: 600
Resolved call sites: 1207
Cross-module procedure edges: 321
Module dependency relations: 77
Dependency cycles (SCC): 2
Modules participating in cycles: 9
Largest cycle: 7
```

## Highest coupling

- `CompareFramework_Main`: coupling=20, fan-in=5, fan-out=15, instability=0.75
- `CompareFramework_EngineMemory`: coupling=14, fan-in=4, fan-out=10, instability=0.714286
- `CompareFramework_Utils`: coupling=12, fan-in=12, fan-out=0, instability=0.0
- `CF_ModeReference`: coupling=10, fan-in=1, fan-out=9, instability=0.9
- `CompareFramework_Tests`: coupling=10, fan-in=2, fan-out=8, instability=0.8
- `CompareFramework_ComparatorConfig`: coupling=8, fan-in=6, fan-out=2, instability=0.25

## Cyclic components

- size 7: CompareFramework_EngineMemory -> CompareFramework_Main -> CompareFramework_Profiles -> CompareFramework_Quality -> CompareFramework_Scenarios -> CompareFramework_Tests -> CompareFramework_Validation
- size 2: CompareFramework_Config -> CompareFramework_Rules

## Generated files

```text
build/architecture/
├── architecture.json
├── dependency_analysis.json
├── module_dependencies.csv
├── module_metrics.csv
├── dependency_cycles.csv
└── previous A1/B exports
```

## Validation

- Python compilation: PASS
- A1.5 regression tests: PASS
- call-graph regression tests: PASS
- dependency tests: PASS
- full repository analysis: PASS
- deterministic outputs: PASS

No LibreOffice Basic runtime source was modified.
