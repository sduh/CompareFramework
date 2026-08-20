# CompareFramework — Dependency Report

Generated automatically from the resolved LibreOffice Basic call graph.

## Module coupling metrics

| Module | Fan-in | Fan-out | Incoming edges | Outgoing edges | Incoming sites | Outgoing sites | Instability | Coupling |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CompareFramework_Main | 5 | 15 | 8 | 108 | 8 | 169 | 0.750 | 20 |
| CompareFramework_EngineMemory | 4 | 10 | 9 | 45 | 9 | 67 | 0.714 | 14 |
| CompareFramework_Utils | 12 | 0 | 84 | 0 | 326 | 0 | 0.000 | 12 |
| CF_ModeReference | 1 | 9 | 1 | 30 | 1 | 41 | 0.900 | 10 |
| CompareFramework_Tests | 2 | 8 | 6 | 22 | 6 | 25 | 0.800 | 10 |
| CompareFramework_ComparatorConfig | 6 | 2 | 7 | 6 | 7 | 11 | 0.250 | 8 |
| CompareFramework_Config | 6 | 2 | 22 | 8 | 31 | 57 | 0.250 | 8 |
| CompareFramework_Context | 8 | 0 | 48 | 0 | 92 | 0 | 0.000 | 8 |
| CompareFramework_Rules | 4 | 4 | 7 | 21 | 7 | 43 | 0.500 | 8 |
| CompareFramework_Report | 6 | 1 | 52 | 20 | 72 | 164 | 0.143 | 7 |
| CompareFramework_API | 0 | 6 | 0 | 6 | 0 | 6 | 1.000 | 6 |
| CompareFramework_Audit | 4 | 2 | 41 | 5 | 66 | 12 | 0.333 | 6 |
| CompareFramework_Comparators | 4 | 2 | 4 | 2 | 4 | 3 | 0.333 | 6 |
| CompareFramework_Index | 4 | 2 | 11 | 5 | 19 | 7 | 0.333 | 6 |
| CompareFramework_Quality | 2 | 4 | 3 | 8 | 3 | 8 | 0.667 | 6 |
| CompareFramework_Profiles | 1 | 4 | 1 | 20 | 1 | 43 | 0.800 | 5 |
| CompareFramework_Validation | 3 | 2 | 4 | 6 | 4 | 12 | 0.400 | 5 |
| CompareFramework_Reliability | 2 | 2 | 2 | 2 | 2 | 2 | 0.500 | 4 |
| CompareFramework_Performance | 2 | 1 | 9 | 4 | 18 | 5 | 0.333 | 3 |
| CompareFramework_Scenarios | 1 | 1 | 2 | 3 | 2 | 3 | 0.500 | 2 |

## Directed dependencies

| Caller module | Callee module | Edges | Call sites |
| --- | --- | --- | --- |
| CF_ModeReference | CompareFramework_Audit | 2 | 5 |
| CF_ModeReference | CompareFramework_ComparatorConfig | 1 | 1 |
| CF_ModeReference | CompareFramework_Config | 2 | 2 |
| CF_ModeReference | CompareFramework_Context | 1 | 4 |
| CF_ModeReference | CompareFramework_EngineMemory | 3 | 3 |
| CF_ModeReference | CompareFramework_Index | 1 | 1 |
| CF_ModeReference | CompareFramework_Report | 16 | 21 |
| CF_ModeReference | CompareFramework_Rules | 1 | 1 |
| CF_ModeReference | CompareFramework_Utils | 3 | 3 |
| CompareFramework_API | CF_ModeReference | 1 | 1 |
| CompareFramework_API | CompareFramework_ComparatorConfig | 1 | 1 |
| CompareFramework_API | CompareFramework_Main | 1 | 1 |
| CompareFramework_API | CompareFramework_Quality | 1 | 1 |
| CompareFramework_API | CompareFramework_Report | 1 | 1 |
| CompareFramework_API | CompareFramework_Validation | 1 | 1 |
| CompareFramework_Audit | CompareFramework_Context | 4 | 11 |
| CompareFramework_Audit | CompareFramework_Utils | 1 | 1 |
| CompareFramework_ComparatorConfig | CompareFramework_Context | 3 | 3 |
| CompareFramework_ComparatorConfig | CompareFramework_Utils | 3 | 8 |
| CompareFramework_Comparators | CompareFramework_ComparatorConfig | 1 | 1 |
| CompareFramework_Comparators | CompareFramework_Config | 1 | 2 |
| CompareFramework_Config | CompareFramework_Rules | 1 | 1 |
| CompareFramework_Config | CompareFramework_Utils | 7 | 56 |
| CompareFramework_EngineMemory | CompareFramework_Audit | 2 | 4 |
| CompareFramework_EngineMemory | CompareFramework_ComparatorConfig | 1 | 1 |
| CompareFramework_EngineMemory | CompareFramework_Comparators | 1 | 1 |
| CompareFramework_EngineMemory | CompareFramework_Config | 6 | 8 |
| CompareFramework_EngineMemory | CompareFramework_Context | 1 | 7 |
| CompareFramework_EngineMemory | CompareFramework_Index | 3 | 5 |
| CompareFramework_EngineMemory | CompareFramework_Report | 17 | 24 |
| CompareFramework_EngineMemory | CompareFramework_Rules | 3 | 3 |
| CompareFramework_EngineMemory | CompareFramework_Tests | 1 | 1 |
| CompareFramework_EngineMemory | CompareFramework_Utils | 10 | 13 |
| CompareFramework_Index | CompareFramework_Report | 1 | 1 |
| CompareFramework_Index | CompareFramework_Utils | 4 | 6 |
| CompareFramework_Main | CompareFramework_Audit | 32 | 52 |
| CompareFramework_Main | CompareFramework_ComparatorConfig | 2 | 2 |
| CompareFramework_Main | CompareFramework_Comparators | 1 | 1 |
| CompareFramework_Main | CompareFramework_Config | 2 | 3 |
| CompareFramework_Main | CompareFramework_Context | 25 | 40 |
| CompareFramework_Main | CompareFramework_EngineMemory | 4 | 4 |
| CompareFramework_Main | CompareFramework_Index | 5 | 10 |
| CompareFramework_Main | CompareFramework_Performance | 4 | 13 |
| CompareFramework_Main | CompareFramework_Quality | 2 | 2 |
| CompareFramework_Main | CompareFramework_Reliability | 1 | 1 |
| CompareFramework_Main | CompareFramework_Report | 15 | 22 |
| CompareFramework_Main | CompareFramework_Rules | 2 | 2 |
| CompareFramework_Main | CompareFramework_Scenarios | 2 | 2 |
| CompareFramework_Main | CompareFramework_Utils | 9 | 13 |
| CompareFramework_Main | CompareFramework_Validation | 2 | 2 |
| CompareFramework_Performance | CompareFramework_Utils | 4 | 5 |
| CompareFramework_Profiles | CompareFramework_Config | 4 | 4 |
| CompareFramework_Profiles | CompareFramework_Context | 4 | 8 |
| CompareFramework_Profiles | CompareFramework_Main | 1 | 1 |
| CompareFramework_Profiles | CompareFramework_Utils | 11 | 30 |
| CompareFramework_Quality | CompareFramework_EngineMemory | 1 | 1 |
| CompareFramework_Quality | CompareFramework_Main | 1 | 1 |
| CompareFramework_Quality | CompareFramework_Reliability | 1 | 1 |
| CompareFramework_Quality | CompareFramework_Tests | 5 | 5 |
| CompareFramework_Reliability | CompareFramework_ComparatorConfig | 1 | 1 |
| CompareFramework_Reliability | CompareFramework_Comparators | 1 | 1 |
| CompareFramework_Report | CompareFramework_Utils | 20 | 164 |
| CompareFramework_Rules | CompareFramework_Config | 7 | 12 |
| CompareFramework_Rules | CompareFramework_Index | 2 | 3 |
| CompareFramework_Rules | CompareFramework_Report | 2 | 3 |
| CompareFramework_Rules | CompareFramework_Utils | 10 | 25 |
| CompareFramework_Scenarios | CompareFramework_Main | 3 | 3 |
| CompareFramework_Tests | CompareFramework_Audit | 5 | 5 |
| CompareFramework_Tests | CompareFramework_Comparators | 1 | 1 |
| CompareFramework_Tests | CompareFramework_Context | 6 | 9 |
| CompareFramework_Tests | CompareFramework_EngineMemory | 1 | 1 |
| CompareFramework_Tests | CompareFramework_Performance | 5 | 5 |
| CompareFramework_Tests | CompareFramework_Profiles | 1 | 1 |
| CompareFramework_Tests | CompareFramework_Utils | 2 | 2 |
| CompareFramework_Tests | CompareFramework_Validation | 1 | 1 |
| CompareFramework_Validation | CompareFramework_Context | 4 | 10 |
| CompareFramework_Validation | CompareFramework_Main | 2 | 2 |

## Cyclic components

### Cycle 1 — 7 modules

- `CompareFramework_EngineMemory`
- `CompareFramework_Main`
- `CompareFramework_Profiles`
- `CompareFramework_Quality`
- `CompareFramework_Scenarios`
- `CompareFramework_Tests`
- `CompareFramework_Validation`

### Cycle 2 — 2 modules

- `CompareFramework_Config`
- `CompareFramework_Rules`

## Reading the report

High fan-in indicates a shared dependency or architectural service. High
fan-out indicates orchestration or broad dependency usage. High coupling alone
is not a defect: it is a prioritization signal for architectural review.

A cyclic component is reported only when at least two modules are mutually
reachable through resolved calls.
