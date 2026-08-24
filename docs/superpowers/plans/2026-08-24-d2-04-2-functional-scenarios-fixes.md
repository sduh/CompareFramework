# D2-04.2 Functional Scenario Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the real LibreOffice 7.4.7.2 scenarios T006, T007, and T010 satisfy their canonical contracts without changing frozen user APIs or moving business comparison logic into Python.

**Architecture:** Keep comparison and decision semantics in LibreOffice Basic. Add a generic technical runner filter for focused executions and a generic optional `setup/*.csv` fixture loader that materializes scenario-local sheets inside each isolated Calc document. Fix T006 and T007 at their Basic root causes, preserving reference-mode execution across unrelated target sheets.

**Tech Stack:** LibreOffice Basic, Python 3 `unittest`, PyUNO, LibreOffice 7.4.7.2, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-08-21-d2-04-2-functional-scenarios-design_FR.md`

## Global Constraints

- Start from PR #4 HEAD `1ef138376da764f8a93cd8573c325747e8f4cdb4`; never merge into `main` without explicit user approval.
- Do not change the six frozen user APIs; `CF_CI_RunScenario` remains a technical non-user entrypoint.
- Python orchestrates only and must not reimplement row/cell comparison, counters, or decisions.
- `actual.json` continues to come only from native `Stats_Comparaison` and `Compare_Reference_Summary` outputs.
- Every scenario runs in its own LibreOffice process, temporary profile, and document.
- T006 duplicate blocking exits only `CF_CompareSheetPairMemory` for the affected pair; reference mode and other targets continue.
- The scenario filter is generic and contains no T006/T007/T010 business branch.
- T010 configuration is discovered generically from scenario fixtures and exists only in that scenario's isolated document.
- Every production change follows RED → GREEN; each task is reviewed by a distinct agent before its commit.
- D2-04.2 remains `IMPLEMENTED — verification pending` until a fresh GitHub Actions HEAD proves T001–T010 `10/10 PASS` and D2-03.24, D2-04.0, D2-04.1 green.

---

### Task 1: Generic Focused Runner and Pair-Local T006 Blocking

**Files:**
- Modify: `tools/ci/run_functional_scenarios.py`
- Modify: `tests/test_d2_04_2_runner_unit.py`
- Modify: `src/CompareFramework_EngineMemory.bas`
- Modify: `src/Modes/CF_ModeReference.bas`
- Modify: `tests/test_d2_04_2_scenario_contract.py`
- Create: `tests/datasets/duplicates/setup/TARGET_OK.csv`

**Interfaces:**
- Produces: repeatable CLI option `--scenario ID`; `select_scenarios(scenarios, requested_ids)` preserving catalogue order.
- Produces: generic `discover_setup_sheets(directory)` and scenario-local materialization of optional `setup/*.csv` sheets; Task 3 reuses this interface.
- Produces: `CF_CompareSheetPairMemory` returns immediately after recording duplicates for one pair, while its caller continues with other targets.

- [ ] **Step 1: Add focused failing unit tests for the generic filter**

Add imports for `parse_args` and `select_scenarios`, then add literal behavior tests:

```python
def test_scenario_filter_preserves_catalogue_order_and_is_generic(self):
    scenarios = discover_scenarios(ROOT / "tests" / "datasets")
    selected = select_scenarios(scenarios, ["T010", "T006", "T007"])
    self.assertEqual(["T006", "T007", "T010"], [item.scenario_id for item in selected])

def test_scenario_filter_rejects_unknown_ids(self):
    scenarios = discover_scenarios(ROOT / "tests" / "datasets")
    with self.assertRaises(ScenarioContractError) as ctx:
        select_scenarios(scenarios, ["T999"])
    self.assertIn("T999", str(ctx.exception))

def test_parse_args_accepts_repeatable_scenario_filter(self):
    args = parse_args([
        "--soffice", "/opt/libreoffice7.4/program/soffice",
        "--monolith", "dist/current.bas",
        "--scenario", "T006",
        "--scenario", "T010",
    ])
    self.assertEqual(["T006", "T010"], args.scenario)

def test_setup_discovery_is_generic_and_sorted(self):
    with TemporaryDirectory() as tmp:
        directory = Path(tmp)
        setup = directory / "setup"
        setup.mkdir()
        second = setup / "Zeta.csv"
        first = setup / "Alpha.csv"
        second.write_text("Key,Value\nB,2\n", encoding="utf-8")
        first.write_text("Key,Value\nA,1\n", encoding="utf-8")
        self.assertEqual((first, second), discover_setup_sheets(directory))

def test_prepare_document_materializes_arbitrary_setup_sheets(self):
    # Extend the existing fake sheet collection with insertNewByName and
    # getElementNames, then use a Scenario whose setup contains Alpha.csv.
    # Assert the created Alpha sheet contains the literal CSV matrix.

def test_prepare_document_rejects_reserved_setup_sheet_names(self):
    # Exercise both setup/MODELE.csv and setup/target.csv and assert a
    # ScenarioContractError before either reserved sheet can be overwritten.
```

- [ ] **Step 2: Run RED for the filter**

Run: `PYTHONPATH=. python3 tests/test_d2_04_2_runner_unit.py`

Expected: import or assertion failure because `select_scenarios`, `--scenario`, and generic setup discovery do not exist.

- [ ] **Step 3: Implement the minimal generic filter**

Implement `select_scenarios` without scenario-specific branches:

```python
def select_scenarios(
    scenarios: list[Scenario], requested_ids: list[str] | None
) -> list[Scenario]:
    if not requested_ids:
        return scenarios
    requested = {item.upper() for item in requested_ids}
    known = {scenario.scenario_id for scenario in scenarios}
    unknown = sorted(requested - known)
    if unknown:
        raise ScenarioContractError(
            f"unknown scenario id(s): {', '.join(unknown)}"
        )
    return [scenario for scenario in scenarios if scenario.scenario_id in requested]
```

Add `parser.add_argument("--scenario", action="append")`, apply selection after discovery, and make suite success depend on `passed == len(scenarios)` while retaining the unfiltered ten-scenario behavior.

Add `setup_sheets: tuple[Path, ...] = ()` to `Scenario`. Implement `discover_setup_sheets(directory)` by returning sorted optional `setup/*.csv` paths. Extend the existing fake document/sheet collection only as needed to drive `prepare_document` through its public behavior. In `prepare_document`, generically create each nonreserved setup sheet from its filename stem and CSV contents; reject case-insensitive `MODELE`/`TARGET` overrides before inserting them. This is orchestration only and contains no scenario ID or comparator branch.

- [ ] **Step 4: Run GREEN for the generic filter**

Run: `PYTHONPATH=. python3 tests/test_d2_04_2_runner_unit.py`

Expected: all runner unit tests pass.

- [ ] **Step 5: Build the monolith and capture T006 RED through real LibreOffice**

Run:

```bash
python3 tools/build_monolith.py
PYTHONPATH=".:/opt/libreoffice7.4/program" \
LD_LIBRARY_PATH="/opt/libreoffice7.4/program" \
python3 -m tools.ci.run_functional_scenarios \
  --soffice /opt/libreoffice7.4/program/soffice \
  --monolith dist/CompareFramework-4.0.0-D1.bas \
  --datasets tests/datasets \
  --artifacts /tmp/d2-04-2-task1-red \
  --scenario T006 --timeout 60
```

Expected: T006 contract mismatch showing nonzero business modifications while `duplicate_ids=1`.

- [ ] **Step 6: Implement pair-local duplicate blocking**

Immediately after both `CF_ReportMemoryDuplicates` calls, when `pairDuplicates > 0`:

1. write one stats row with added/removed/modified row/modified cell counters all `0`, `pairDuplicates`, `oldCount`, `newCount`, and structure alerts `0`;
2. increment `statsRow` and `totalDuplicates`;
3. `Exit Sub` from `CF_CompareSheetPairMemory` only.

Do not exit `CF_RunAgainstReference`, change target selection, or suppress subsequent target sheets.

- [ ] **Step 7: Add and prove the pair-isolation regression**

Create `tests/datasets/duplicates/setup/TARGET_OK.csv` as a byte-for-byte CSV copy of `tests/datasets/duplicates/MODELE.csv`. Change only the technical `CF_CI_RunScenario` target mode from `SELECTED/TARGET` to `ALL`; configuration/report sheets remain excluded by the existing reference target predicate.

Update the static technical-entrypoint contract to require `CF_REFERENCE_TARGET_MODE = "ALL"`, while keeping `CF_CI_RunScenario` outside the frozen API. This setup makes the real T006 run contain two pairs: duplicate `TARGET` and valid `TARGET_OK`.

- [ ] **Step 8: Run T006 GREEN and focused Python tests**

Rebuild the monolith and repeat Step 5 with artifacts `/tmp/d2-04-2-task1-green`.

Expected: `T006 PASS`, `1/1 PASS`, actual business counters zero, `duplicate_ids=1`, `A CONTROLER`. Inspect `Compare_Reference_Summary` in the ODS artifact and assert it contains both `TARGET` and `TARGET_OK`, proving that exiting the duplicate pair did not terminate reference mode.

Run: `PYTHONPATH=. python3 tests/test_d2_04_2_runner_unit.py`

- [ ] **Step 9: Self-review and produce the task report without committing**

The controller dispatches an independent reviewer over the uncommitted diff. Commit only after review approval.

Commit subject after approval: `fix(D2-04.2): stop duplicate pairs before comparison`

---

### Task 2: Count One Root Structural Alert for T007

**Files:**
- Modify: `src/Modes/CF_ModeReference.bas`
- Modify: `tools/ci/run_functional_scenarios.py`
- Create: `tests/test_d2_04_2_reference_runtime.py`
- Modify: `.github/workflows/d2-04-2-functional-scenarios.yml`

**Interfaces:**
- Consumes: Task 1 generic `--scenario` filter.
- Produces: one precise missing-key incident; the generic zero-eligible-target incident remains available only when no precise target rejection was already recorded.
- Produces: a generic synthetic-runtime seam where `Scenario.target_csv` may be `None`; official discovery still requires every catalogue scenario's `TARGET.csv`.

- [ ] **Step 1: Add a failing real-UNO regression harness for both branches**

Create `tests/test_d2_04_2_reference_runtime.py`. It must use `run_scenario` and native extraction, not reproduce counters or decisions. Read `SOFFICE_BIN` and `CF_MONOLITH` from the environment and fail clearly when the workflow invokes it without them. Use literal CSV inputs and literal expected native contracts:

```python
class D2042ReferenceRuntimeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.soffice = os.environ["SOFFICE_BIN"]
        cls.monolith = Path(os.environ["CF_MONOLITH"])

    def _run(self, target_text: str | None, artifacts: Path):
        directory = artifacts.parent
        model = directory / "MODELE.csv"
        model.write_text("ProductId,Value\nP001,Alpha\n", encoding="utf-8")
        target = None
        if target_text is not None:
            target = directory / "TARGET.csv"
            target.write_text(target_text, encoding="utf-8")
        expected = directory / "expected.json"
        expected.write_text("{}\n", encoding="utf-8")
        scenario = Scenario("TSYN", "synthetic", directory, model, target, expected)
        return run_scenario(scenario, self.soffice, self.monolith, artifacts, 60)

    def test_missing_key_is_one_precise_incident(self):
        with TemporaryDirectory() as tmp:
            actual = self._run("Value\nAlpha\n", Path(tmp) / "artifacts")
        self.assertEqual("A CONTROLER", actual["decision"])
        self.assertEqual(1, actual["structure_alerts"])

    def test_no_target_keeps_one_generic_incident(self):
        with TemporaryDirectory() as tmp:
            actual = self._run(None, Path(tmp) / "artifacts")
        self.assertEqual("A CONTROLER", actual["decision"])
        self.assertEqual(1, actual["structure_alerts"])
```

The first test catches double counting; the second catches accidental deletion of the generic no-target diagnostic. Both invoke the real Basic path and assert only native outputs.

- [ ] **Step 2: Run the harness RED before changing production code**

Build the monolith, export `SOFFICE_BIN=/opt/libreoffice7.4/program/soffice`, `CF_MONOLITH=<built monolith>`, PyUNO `PYTHONPATH`, and LibreOffice `LD_LIBRARY_PATH`, then run `python3 tests/test_d2_04_2_reference_runtime.py`.

Expected initial failure/error: synthetic no-target preparation cannot yet represent `target_csv=None`. This is RED for the generic test seam.

- [ ] **Step 3: Implement the minimal generic no-target test seam**

Change `Scenario.target_csv` to `Path | None`. Keep `discover_scenarios` strict: its required-path check still requires official `TARGET.csv` and passes a `Path`. In `prepare_document`, create and populate `TARGET` only when `scenario.target_csv is not None`; otherwise leave the isolated document with `MODELE` plus any generic setup sheets.

Run the harness again before changing Basic.

Expected behavioral RED: `test_missing_key_is_one_precise_incident` reports actual `structure_alerts=2`; `test_no_target_keeps_one_generic_incident` passes with `1`.

- [ ] **Step 4: Capture official T007 RED through real LibreOffice**

Build the current monolith and run the Task 1 command with `--scenario T007` and `/tmp/d2-04-2-task2-red`.

Expected: contract mismatch `structure_alerts: expected=1 actual=2`.

- [ ] **Step 5: Implement the minimal cause-aware guard**

Add a local Boolean such as `targetEligibilityIssueReported`. Set it to `True` in the branch that writes `Colonne identifiant absente de la feuille cible.` Change the post-loop condition from `If targetCount = 0 Then` to:

```basic
If targetCount = 0 And Not targetEligibilityIssueReported Then
```

Do not alter decision logic, native output extraction, or other target processing.

- [ ] **Step 6: Run both T007 GREEN paths**

Rebuild the monolith and repeat Step 1 with `/tmp/d2-04-2-task2-green`.

Expected: `T007 PASS`, `1/1 PASS`, `structure_alerts=1`, `A CONTROLER`.

Run the synthetic runtime harness again. Expected: both tests pass; the precise missing-key case and generic no-target case each expose exactly one native structure alert.

- [ ] **Step 7: Add the real harness to GitHub Actions**

After resolving `UNO_PYTHON`, add a workflow step that resolves the built monolith, exports `CF_MONOLITH`, preserves the existing PyUNO environment, and executes:

```bash
PYTHONPATH=".:${PYTHONPATH:-}" "${UNO_PYTHON}" tests/test_d2_04_2_reference_runtime.py
```

This step is technical and generic; it does not branch on official scenario IDs.

- [ ] **Step 8: Run focused regression tests**

Run:

```bash
PYTHONPATH=. python3 tests/test_d2_04_2_scenario_contract.py
PYTHONPATH=. python3 tests/test_d2_04_2_runner_unit.py
```

- [ ] **Step 9: Self-review and produce the task report without committing**

The controller dispatches an independent reviewer over the uncommitted diff. Commit only after review approval.

Commit subject after approval: `fix(D2-04.2): avoid derived duplicate structure alert`

---

### Task 3: Generic Ephemeral Scenario Setup for T010

**Files:**
- Create: `tests/datasets/typed_values/setup/Compare_Config.csv`
- Create: `tests/datasets/typed_values/setup/Compare_Comparators.csv`
- Modify: `tests/datasets/typed_values/README.md`
- Modify: `tests/test_d2_04_2_runner_unit.py`

**Interfaces:**
- Consumes: Task 1 `discover_setup_sheets`, `Scenario.setup_sheets`, and generic document-local materialization.
- Produces: exact T010 `Compare_Config` and `Compare_Comparators` scenario fixtures.
- No setup filename or content is special-cased by scenario ID.

- [ ] **Step 1: Add failing tests for exact T010 fixture discovery and document-local materialization**

Before creating the fixture files, assert that the discovered T010 setup sheet names equal `("Compare_Comparators", "Compare_Config")` and that `prepare_document` materializes their exact literal rows in a fresh fake document. The RED is missing fixture data, not a source-text assertion. Also retain Task 1's generic arbitrary-name and reserved-name loader tests.

- [ ] **Step 2: Run RED for the generic fixture loader**

Run: `PYTHONPATH=. python3 tests/test_d2_04_2_runner_unit.py`

Expected: failure because T010 has no setup fixture files yet.

- [ ] **Step 3: Add the exact T010 fixture data**

`Compare_Config.csv`:

```csv
Parametre,Valeur,Description
IGNORE_CASE,TRUE,Ignore case for typed equivalence scenario
```

`Compare_Comparators.csv`:

```csv
Enabled,Profile,Column,Comparator,Tolerance,Comment
TRUE,GLOBAL,Amount,CURRENCY,0,Exact currency equivalence
TRUE,GLOBAL,Rate,PERCENT,0,Exact percent equivalence
TRUE,GLOBAL,Enabled,BOOLEAN,,Boolean vocabulary equivalence
TRUE,GLOBAL,Date,DATE,0,Exact date equivalence
```

Document the two setup sheets in the T010 README.

- [ ] **Step 4: Run GREEN for generic fixture behavior**

Run: `PYTHONPATH=. python3 tests/test_d2_04_2_runner_unit.py`

Expected: all runner unit tests pass.

- [ ] **Step 5: Capture T010 RED without setup and GREEN with setup**

Before adding the fixture CSVs, run real LibreOffice with `--scenario T010` and `/tmp/d2-04-2-task3-red`; retain the mismatch showing Label/Rate are not equivalent under defaults.

After adding fixture CSVs, rebuild and rerun with `/tmp/d2-04-2-task3-green`.

Expected GREEN: `T010 PASS`, `1/1 PASS`, all counters zero, decision `OK`. Inspect the scenario ODS artifact to confirm the two configuration sheets exist only in T010's document.

- [ ] **Step 6: Run focused Python regressions**

Run:

```bash
PYTHONPATH=. python3 tests/test_d2_04_2_scenario_contract.py
PYTHONPATH=. python3 tests/test_d2_04_2_runner_unit.py
```

- [ ] **Step 7: Self-review and produce the task report without committing**

The controller dispatches an independent reviewer over the uncommitted diff. Commit only after review approval.

Commit subject after approval: `fix(D2-04.2): load ephemeral typed scenario setup`

---

### Task 4: Whole-Branch Verification and Status Evidence

**Files:**
- Modify only if the fresh GitHub Actions evidence is successful: `D2_04_2_REPORT.md`, `D2_04_2_REPORT_FR.md`

**Interfaces:**
- Consumes: Tasks 1–3 commits.
- Produces: local validation evidence and, after push, fresh GitHub Actions run URLs for the exact new HEAD.

- [ ] **Step 1: Run focused real scenarios together**

Run the runner with `--scenario T006 --scenario T007 --scenario T010`.

Expected: `T006 PASS`, `T007 PASS`, `T010 PASS`, `3/3 PASS`.

- [ ] **Step 2: Run full T001–T010 through LibreOffice 7.4.7.2**

Run without `--scenario`.

Expected: T001 through T010 pass and `10/10 PASS`.

- [ ] **Step 3: Run repository and predecessor-gate commands**

Run the exact commands from `.github/workflows/d2-03-24-validation.yml`, `.github/workflows/d2-04-0-libreoffice-7-4-7-2.yml`, `.github/workflows/d2-04-1-uno-basic-harness.yml`, and `.github/workflows/d2-04-2-functional-scenarios.yml`, including monolith regeneration and the public API freeze check.

- [ ] **Step 4: Dispatch the final whole-branch review**

Review the complete diff from `1ef1383` to the new HEAD, including all deferred findings and rulings.

- [ ] **Step 5: Push to the existing PR branch and observe fresh actions**

Only after local verification and final review, push the reviewed commits to `origin/d2-04.2-functional-scenarios-design`. Do not merge.

- [ ] **Step 6: Preserve status unless all remote gates are fresh and green**

Keep both reports at `IMPLEMENTED — verification pending` during the correction commits. If the exact pushed correction HEAD has T001–T010 `10/10 PASS` and D2-03.24, D2-04.0, D2-04.1 green, a later evidence-only status commit may record the run URLs; that new status HEAD itself must then receive a fresh successful run before D2-04.2 is reported as `VALIDATED`. Otherwise report the remaining evidence gap without changing status.
