# D2-04.2 — Functional Scenario Automation Design

**Status:** DESIGN APPROVED — implementation pending

## Goal

Automate the official T001–T010 CompareFramework functional regression catalogue through the real LibreOffice 7.4.7.2 UNO runtime harness introduced by D2-04.1.

## Scope and invariants

- The tested Basic artifact is the monolith produced by `tools/build_monolith.py`; `src/*.bas` modules are never injected directly.
- LibreOffice is pinned to exactly 7.4.7.2, reusing the D2-04.0 runtime contract.
- Each T001–T010 scenario runs in a fresh LibreOffice process, a fresh temporary user profile, and a fresh working document.
- The six frozen user-facing public APIs remain unchanged.
- `CF_CI_RuntimeSmoke` remains the D2-04.1 technical smoke entrypoint.
- D2-04.2 introduces `CF_CI_RunScenario` as a technical, non-interactive CI entrypoint outside the frozen user-facing API.
- Python orchestrates; LibreOffice Basic executes the actual CompareFramework business comparison.
- Python must not reimplement row/cell comparison logic.

## Official scenario catalogue

The existing `tests/catalog.md` and `tests/datasets/` catalogue remains the human catalogue for T001–T010:

- T001 identical → `OK`, no differences.
- T002 additions → `ECARTS`, one addition.
- T003 deletions → `ECARTS`, one deletion.
- T004 modifications → `ECARTS`, one modified row and one modified cell.
- T005 combined_changes → `ECARTS`, one addition, one deletion and one modification.
- T006 duplicates → `A CONTROLER`, duplicate detected.
- T007 missing_key_column → `A CONTROLER`, target ignored or structural incident.
- T008 extra_column → `A CONTROLER`, structural alert.
- T009 reordered_columns → `OK`, no business difference.
- T010 typed_values → `OK`, no difference for equivalent typed values.

The comparison key is `ProductId` unless a scenario explicitly states otherwise.

## Machine expectation contract

Each `tests/datasets/<scenario>/` directory gains an `expected.json` file. It is the canonical machine-readable expectation. Existing `expected.md` remains the corresponding human-readable documentation and must stay semantically synchronized.

The normalized contract is:

```json
{
  "scenario_id": "T005",
  "decision": "ECARTS",
  "added_rows": 1,
  "deleted_rows": 1,
  "modified_rows": 1,
  "modified_cells": 1,
  "duplicate_ids": 0,
  "structure_alerts": 0
}
```

All eight fields are mandatory. Counts that are not applicable to a scenario are represented by `0` rather than omitted. `scenario_id` must match the catalogue ID and `decision` must use the framework's native decision vocabulary.

## Scenario execution architecture

For every scenario independently, the runner performs this chain:

`MODELE.csv + TARGET.csv → isolated ODS working document → monolith injection → CF_CI_RunScenario → native CompareFramework output sheets → UNO extraction → actual.json → strict comparison with expected.json`

The runner creates a document containing `MODELE` and `TARGET` sheets from the scenario CSV files. The scenario is configured for a reference comparison from `MODELE` to `TARGET` with key `ProductId` unless the dataset contract overrides it.

A new LibreOffice 7.4.7.2 process and isolated temporary profile are created for every scenario. No Basic library, sheet, configuration, report, cache, context or process state is reused between scenarios.

## Basic technical entrypoint

`CF_CI_RunScenario` is added to the monolith as a technical CI procedure. It is non-interactive and is not added to the six frozen user-facing APIs.

Its responsibility is deliberately narrow:

1. consume the scenario document prepared by Python;
2. establish the minimum CompareFramework configuration required for the `MODELE` → `TARGET` comparison;
3. invoke the real CompareFramework comparison path;
4. return control after the normal framework output sheets have been produced.

It must not contain a CI-specific implementation of comparison, counting or decision rules.

## Native result extraction

D2-04.2 does not use `CompareFramework_CI` as a second business-result channel. That sheet remains the technical smoke-result channel of D2-04.1.

After `CF_CI_RunScenario` returns, Python reads the framework's normal business outputs through UNO, principally:

- `Compare_Reference_Summary`;
- `Stats_Comparaison`;
- `Rapport_Comparaison` when a required detail is not exposed by the summary/statistics sheets.

A single centralized extraction mapping converts native sheet values into the normalized result fields. Python may normalize representation, but it must not infer additions, deletions, modifications, duplicates, structural alerts or the decision from the source CSV data.

The normalized observed result is persisted as `actual.json` with the same eight-field schema as `expected.json`.

## PASS/FAIL contract

A scenario passes only when its normalized `actual.json` strictly equals its canonical `expected.json` for every field.

A successful suite therefore reports all ten scenarios individually and an aggregate `10/10 PASS` result. A scenario failure does not conceptually change the contract of later scenarios; because each run is isolated, the runner should retain enough per-scenario diagnostics to identify every failing case.

Failures are classified explicitly, including at least:

- invalid/missing dataset or expectation contract;
- LibreOffice runtime/version failure;
- UNO connection/open failure;
- monolith injection failure;
- `CF_CI_RunScenario` resolution/invocation failure;
- native output sheet/result extraction failure;
- `actual.json` versus `expected.json` mismatch;
- timeout or unclean runtime termination.

## CI diagnostics and artifacts

The GitHub Actions workflow runs the complete T001–T010 suite after building the monolith and provisioning the pinned LibreOffice runtime.

For each failing scenario, diagnostics must preserve at minimum:

- `expected.json`;
- generated `actual.json` when extraction succeeded;
- the failing working `.ods` document when available;
- a textual runner diagnostic identifying the failure class.

The workflow should expose a concise per-scenario summary such as `T001 PASS` … `T010 PASS`, followed by the aggregate result.

## Tests

### Static/unit contract

Automated Python tests cover:

- discovery of exactly T001–T010;
- presence and schema validation of every `expected.json`;
- catalogue/scenario ID consistency;
- strict expected/actual comparison;
- centralized native-output normalization;
- enforcement that `CF_CI_RunScenario` exists in the built monolith;
- enforcement that the six frozen user APIs are unchanged;
- isolation configuration and pinned LibreOffice 7.4.7.2 contract.

### Real integration contract

GitHub Actions must execute all ten scenarios through real LibreOffice Basic and UNO. Static tests alone cannot validate D2-04.2.

The final integration run must prove that:

- the monolith built from the final HEAD is the artifact injected into every scenario;
- all ten scenarios use LibreOffice 7.4.7.2;
- every scenario has a distinct process/profile/document;
- `CF_CI_RunScenario` invokes the real framework path;
- observed results come only from native CompareFramework output sheets;
- all ten `actual.json` contracts match their `expected.json` contracts.

## Regression gates

D2-04.2 must not regress the already validated gates. Before final validation, fresh CI on the final HEAD must keep the relevant cumulative validation, D2-04.0 runtime validation and D2-04.1 UNO Basic harness validation green in addition to the new D2-04.2 workflow.

## Validation status rule

Documentation/reporting may state `IMPLEMENTED — verification pending` after code completion, but D2-04.2 must not be marked `VALIDATED` until a fresh GitHub Actions run for the final implementation HEAD is `completed / success` and proves the complete T001–T010 real-runtime contract.

## Out of scope

D2-04.2 does not:

- add or change user-facing public APIs;
- support LibreOffice versions other than 7.4.7.2;
- replace native CompareFramework outputs with CI-specific business logic;
- redesign the comparison engine;
- broaden the functional catalogue beyond T001–T010.
