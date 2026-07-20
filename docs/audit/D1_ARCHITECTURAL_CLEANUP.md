# CompareFramework 4.0-D1 — Architectural Cleanup Report

## Scope

This milestone establishes architecture boundaries without changing functional behavior. No existing public procedure has been made `Private` in D1.

## Baseline

- Modules analyzed: **20**
- Source lines: **5988**
- Procedures: **285**
- Public procedures: **204**
- Private procedures: **81**
- Official supported API entries: **6**
- Safe-review candidates with no cross-module references: **92**
- Module dependency edges: **77**
- Dependency cycles (SCC > 1): **2**

## Supported public facade

The only supported user-facing API is defined in `src/CompareFramework_API.bas`:

- `CF_ExportLastReportHTML`
- `CF_OpenSettings`
- `CF_RunDiagnostics`
- `CF_RunReleaseValidation`
- `CF_RunStandardComparison`
- `CF_StartReferenceComparison`


All other `Public` procedures are compatibility or implementation symbols. Their visibility is unchanged in D1.

## Visibility strategy

1. D1 classifies symbols only.
2. A symbol can become `Private` only after its callers are migrated behind a service boundary.
3. Legacy user macros require wrappers or a documented breaking-change decision before removal.
4. Each visibility batch must pass the complete regression suite.

## Large-module preparation

### `CompareFramework_Report.bas`

Target split for a later milestone:

- report sheet writing and formatting;
- statistics and dashboard generation;
- action plan generation;
- HTML serialization and file output.

### `Modes/CF_ModeReference.bas`

Target split for a later milestone:

- launcher/UI sheet;
- target discovery and selection;
- reference comparison orchestration;
- summary generation and formatting.

D1 does not move any procedure, preventing accidental dependency or Basic visibility regressions.

## Dependency cycles

- src/CompareFramework_Config.bas -> src/CompareFramework_Rules.bas
- src/CompareFramework_EngineMemory.bas -> src/CompareFramework_Main.bas -> src/CompareFramework_Profiles.bas -> src/CompareFramework_Quality.bas -> src/CompareFramework_Scenarios.bas -> src/CompareFramework_Tests.bas -> src/CompareFramework_Validation.bas

## D1 decision

**PASS for architectural preparation.** The supported API is explicit, migration candidates are inventoried, large-module split boundaries are defined, and the dependency graph is reproducible.

## Generated evidence

- `D1_PUBLIC_API_INVENTORY.csv`
- `D1_DEPENDENCY_MAP.csv`
- `D1_MODULE_METRICS.csv`
- `D1_ARCHITECTURE_SNAPSHOT.json`
