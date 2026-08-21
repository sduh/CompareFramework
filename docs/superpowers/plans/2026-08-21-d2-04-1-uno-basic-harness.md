# D2-04.1 LibreOffice Basic UNO Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish a real GitHub Actions harness that builds the current CompareFramework monolith, injects it into a versioned `.ods` fixture under LibreOffice 7.4.7.2 via UNO, executes `CF_CI_RuntimeSmoke`, and validates a deterministic result from the `CompareFramework_CI` sheet.

**Architecture:** Keep D2-04.0 as the runtime provider and D2-03.24 as the cumulative architecture/regression gate. Add a technical Basic smoke entrypoint outside the six user APIs, a minimal versioned Calc fixture, a focused Python/UNO orchestrator, static contract tests, negative-path checks, and a dedicated real-runtime GitHub Actions workflow.

**Tech Stack:** LibreOffice 7.4.7.2, LibreOffice Basic, Python 3, PyUNO/UNO bridge from the pinned LibreOffice installation, GitHub Actions on `ubuntu-22.04`, Python `unittest`.

**Spec:** `docs/superpowers/specs/2026-08-21-d2-04-1-uno-basic-harness-design.md`

## Global Constraints

- LibreOffice **7.4.7.2** is the only supported runtime baseline for D2-04.1.
- The tested Basic artifact is the monolith produced by `tools/build_monolith.py`; loading individual `src/*.bas` files directly is forbidden.
- The versioned fixture is `tests/fixtures/ci/CompareFramework_CI.ods` and must not contain a stale embedded copy of CompareFramework.
- `CF_CI_RuntimeSmoke` is a technical CI entrypoint and must not be added to `CompareFramework_API.bas` or to the six supported user-facing APIs frozen by D2-03.24.
- The success contract is `CompareFramework_CI!B1 == "OK"` and `CompareFramework_CI!B2 == "COMPAREFRAMEWORK_CI_SMOKE_OK"`.
- No T001–T010 business scenario, comparison workflow, dialog, launcher, or `CF_RunReleaseValidation` call belongs to D2-04.1.
- Every LibreOffice execution uses an isolated temporary user profile and bounded timeout.
- D2-04.1 is not `VALIDATED` until a fresh real GitHub Actions run succeeds on the final PR HEAD.
- Documentation is maintained in English and French; every new D2-04.1 plan/report document has a `_FR.md` equivalent with the same status and validation evidence.

---

## File Structure

- Create `src/CompareFramework_CI.bas` — technical Basic entrypoint `CF_CI_RuntimeSmoke`; no user-facing API role.
- Create `tests/fixtures/ci/CompareFramework_CI.ods` — minimal real Calc document used as the runtime container.
- Create `tools/ci/run_libreoffice_basic_smoke.py` — UNO orchestrator for process startup, document open, Basic injection, invocation, result validation, cleanup, and negative-path modes.
- Create `tests/test_d2_04_1_uno_harness_contract.py` — static contract tests for packaging boundary, API-freeze compatibility, fixture/harness contract, and forbidden business calls.
- Create `.github/workflows/d2-04-1-uno-basic-harness.yml` — real LibreOffice 7.4.7.2 integration workflow.
- Create `D2_04_1_REPORT.md` and `D2_04_1_REPORT_FR.md` — implementation/evidence reports.

### Task 1: Define the D2-04.1 static contract in tests

**Files:**
- Create: `tests/test_d2_04_1_uno_harness_contract.py`
- Test later-created files: `src/CompareFramework_CI.bas`, `tools/ci/run_libreoffice_basic_smoke.py`, `tests/fixtures/ci/CompareFramework_CI.ods`, `.github/workflows/d2-04-1-uno-basic-harness.yml`

**Interfaces:**
- Consumes: repository root and frozen API contract from D2-03.24.
- Produces: executable static requirements for all later D2-04.1 tasks.

- [ ] **Step 1: Write the failing contract tests**

Create `tests/test_d2_04_1_uno_harness_contract.py` with tests equivalent to:

```python
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CI_BASIC = ROOT / "src" / "CompareFramework_CI.bas"
HARNESS = ROOT / "tools" / "ci" / "run_libreoffice_basic_smoke.py"
FIXTURE = ROOT / "tests" / "fixtures" / "ci" / "CompareFramework_CI.ods"
WORKFLOW = ROOT / ".github" / "workflows" / "d2-04-1-uno-basic-harness.yml"
API = ROOT / "src" / "CompareFramework_API.bas"


class D2041UnoHarnessContractTests(unittest.TestCase):
    def test_ci_basic_entrypoint_is_technical_and_not_user_api(self):
        ci_text = CI_BASIC.read_text(encoding="utf-8-sig")
        api_text = API.read_text(encoding="utf-8-sig")
        self.assertRegex(ci_text, r"(?mi)^\s*Public\s+Sub\s+CF_CI_RuntimeSmoke\b")
        self.assertNotIn("CF_CI_RuntimeSmoke", api_text)
        self.assertIn("COMPAREFRAMEWORK_CI_SMOKE_OK", ci_text)
        self.assertIn("CompareFramework_CI", ci_text)

    def test_harness_uses_built_monolith_and_result_contract(self):
        text = HARNESS.read_text(encoding="utf-8")
        self.assertIn("dist", text)
        self.assertIn("CF_CI_RuntimeSmoke", text)
        self.assertIn("CompareFramework_CI", text)
        self.assertIn("COMPAREFRAMEWORK_CI_SMOKE_OK", text)
        self.assertNotRegex(text, r"src/.+\.bas")

    def test_harness_does_not_run_business_regression(self):
        text = HARNESS.read_text(encoding="utf-8")
        for forbidden in (
            "CF_RunReleaseValidation",
            "CF_RunStandardComparison",
            "CF_StartReferenceComparison",
            "T001",
            "T010",
        ):
            self.assertNotIn(forbidden, text)

    def test_fixture_and_workflow_exist(self):
        self.assertTrue(FIXTURE.is_file())
        workflow = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("install_libreoffice_7_4_7_2.sh", workflow)
        self.assertIn("build_monolith.py", workflow)
        self.assertIn("run_libreoffice_basic_smoke.py", workflow)
        self.assertIn("ubuntu-22.04", workflow)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run the contract tests and confirm RED**

Run:

```bash
PYTHONPATH=. python tests/test_d2_04_1_uno_harness_contract.py
```

Expected: FAIL because the D2-04.1 Basic entrypoint, harness, fixture and workflow do not exist yet.

- [ ] **Step 3: Commit the RED contract tests**

```bash
git add tests/test_d2_04_1_uno_harness_contract.py
git commit -m "test(D2-04.1): define UNO Basic harness contract"
```

### Task 2: Add the technical Basic runtime smoke entrypoint

**Files:**
- Create: `src/CompareFramework_CI.bas`
- Test: `tests/test_d2_04_1_uno_harness_contract.py`

**Interfaces:**
- Consumes: active Calc document available through `ThisComponent`.
- Produces: sheet `CompareFramework_CI` with `A1=STATUS`, `B1=OK`, `A2=MARKER`, `B2=COMPAREFRAMEWORK_CI_SMOKE_OK`.

- [ ] **Step 1: Add a focused failing source-level test for exact smoke semantics**

Extend `tests/test_d2_04_1_uno_harness_contract.py` with:

```python
def test_ci_smoke_has_exact_noninteractive_result_contract(self):
    text = CI_BASIC.read_text(encoding="utf-8-sig")
    self.assertIn('getCellRangeByName("A1").String = "STATUS"', text)
    self.assertIn('getCellRangeByName("B1").String = "OK"', text)
    self.assertIn('getCellRangeByName("A2").String = "MARKER"', text)
    self.assertIn('getCellRangeByName("B2").String = "COMPAREFRAMEWORK_CI_SMOKE_OK"', text)
    self.assertNotRegex(text, r"(?i)MsgBox|InputBox|CF_RunReleaseValidation|CF_RunStandardComparison")
```

Run the test and confirm it still fails because `src/CompareFramework_CI.bas` is absent.

- [ ] **Step 2: Implement the minimal Basic entrypoint**

Create `src/CompareFramework_CI.bas`:

```basic
Option Explicit

' Technical CI-only runtime smoke entrypoint.
' This is not part of the supported user-facing API.
Public Sub CF_CI_RuntimeSmoke()
    Dim oDoc As Object
    Dim oSheets As Object
    Dim oSheet As Object

    oDoc = ThisComponent
    oSheets = oDoc.Sheets

    If oSheets.hasByName("CompareFramework_CI") Then
        oSheet = oSheets.getByName("CompareFramework_CI")
    Else
        oSheets.insertNewByName("CompareFramework_CI", oSheets.getCount())
        oSheet = oSheets.getByName("CompareFramework_CI")
    End If

    oSheet.getCellRangeByName("A1").String = "STATUS"
    oSheet.getCellRangeByName("B1").String = "OK"
    oSheet.getCellRangeByName("A2").String = "MARKER"
    oSheet.getCellRangeByName("B2").String = "COMPAREFRAMEWORK_CI_SMOKE_OK"
End Sub
```

Do not add this procedure to `CompareFramework_API.bas`.

- [ ] **Step 3: Build the monolith and prove the entrypoint is included**

Run:

```bash
python tools/build_monolith.py
grep -R "Public Sub CF_CI_RuntimeSmoke" dist/*.bas
```

Expected: build succeeds and the generated monolith contains `CF_CI_RuntimeSmoke`.

- [ ] **Step 4: Run D2-03.24 API freeze regression**

Run:

```bash
PYTHONPATH=. python tests/test_d2_03_24_public_api_freeze.py
```

Expected: PASS; the supported API remains exactly six procedures.

- [ ] **Step 5: Commit the Basic smoke entrypoint**

```bash
git add src/CompareFramework_CI.bas tests/test_d2_04_1_uno_harness_contract.py
git commit -m "feat(D2-04.1): add technical Basic runtime smoke entrypoint"
```

### Task 3: Create the minimal versioned Calc fixture

**Files:**
- Create binary: `tests/fixtures/ci/CompareFramework_CI.ods`
- Test: `tests/test_d2_04_1_uno_harness_contract.py`

**Interfaces:**
- Consumes: nothing from CompareFramework at rest.
- Produces: a valid Calc `.ods` document containing a `CompareFramework_CI` sheet but no embedded CompareFramework monolith.

- [ ] **Step 1: Create the fixture using LibreOffice 7.4.7.2**

Using the D2-04.0 runtime, create a blank Calc document with a single sheet named `CompareFramework_CI`, save it as:

```text
tests/fixtures/ci/CompareFramework_CI.ods
```

The fixture must not contain a Basic module named `CompareFramework`, `CompareFramework_CI`, or a copy of the generated monolith.

- [ ] **Step 2: Add a structural fixture test**

Extend the Python contract test to treat `.ods` as ZIP and verify it is a real OpenDocument spreadsheet:

```python
import zipfile


def test_fixture_is_valid_ods_container(self):
    self.assertTrue(FIXTURE.is_file())
    with zipfile.ZipFile(FIXTURE) as archive:
        names = set(archive.namelist())
        self.assertIn("mimetype", names)
        self.assertIn("content.xml", names)
        mimetype = archive.read("mimetype").decode("ascii")
        self.assertEqual("application/vnd.oasis.opendocument.spreadsheet", mimetype)
```

- [ ] **Step 3: Run the contract test**

Run:

```bash
PYTHONPATH=. python tests/test_d2_04_1_uno_harness_contract.py
```

Expected: fixture-related assertions PASS; harness/workflow assertions remain RED until later tasks.

- [ ] **Step 4: Commit the fixture**

```bash
git add tests/fixtures/ci/CompareFramework_CI.ods tests/test_d2_04_1_uno_harness_contract.py
git commit -m "test(D2-04.1): add minimal Calc CI fixture"
```

### Task 4: Implement the Python/UNO harness core

**Files:**
- Create: `tools/ci/run_libreoffice_basic_smoke.py`
- Test: `tests/test_d2_04_1_uno_harness_contract.py`
- Create unit test: `tests/test_d2_04_1_harness_unit.py`

**Interfaces:**
- Consumes: `--soffice`, `--fixture`, `--monolith`, optional `--macro-name`, optional `--expected-marker`, timeout value.
- Produces: exit code `0` only when the macro invocation and exact result contract succeed; stage-specific non-zero failure otherwise.

- [ ] **Step 1: Write unit tests for pure validation helpers before UNO code**

Create `tests/test_d2_04_1_harness_unit.py`:

```python
import unittest

from tools.ci.run_libreoffice_basic_smoke import (
    ResultContractError,
    validate_result_values,
)


class HarnessUnitTests(unittest.TestCase):
    def test_exact_result_contract_passes(self):
        validate_result_values("OK", "COMPAREFRAMEWORK_CI_SMOKE_OK")

    def test_wrong_status_fails(self):
        with self.assertRaises(ResultContractError):
            validate_result_values("KO", "COMPAREFRAMEWORK_CI_SMOKE_OK")

    def test_wrong_marker_fails(self):
        with self.assertRaises(ResultContractError):
            validate_result_values("OK", "WRONG")


if __name__ == "__main__":
    unittest.main()
```

Run it and confirm RED because the harness module does not exist.

- [ ] **Step 2: Implement pure contract helpers and CLI parsing**

Create `tools/ci/run_libreoffice_basic_smoke.py` with, at minimum:

```python
from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path

EXPECTED_STATUS = "OK"
EXPECTED_MARKER = "COMPAREFRAMEWORK_CI_SMOKE_OK"
RESULT_SHEET = "CompareFramework_CI"
DEFAULT_MACRO = "CF_CI_RuntimeSmoke"


class HarnessError(RuntimeError):
    pass


class ResultContractError(HarnessError):
    pass


def validate_result_values(status: str, marker: str, expected_marker: str = EXPECTED_MARKER) -> None:
    if status != EXPECTED_STATUS:
        raise ResultContractError(f"result validation failed: expected STATUS=OK, got {status!r}")
    if marker != expected_marker:
        raise ResultContractError(
            f"result validation failed: expected marker {expected_marker!r}, got {marker!r}"
        )


def parse_args(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--soffice", required=True)
    parser.add_argument("--fixture", type=Path, required=True)
    parser.add_argument("--monolith", type=Path, required=True)
    parser.add_argument("--macro-name", default=DEFAULT_MACRO)
    parser.add_argument("--expected-marker", default=EXPECTED_MARKER)
    parser.add_argument("--timeout", type=int, default=60)
    return parser.parse_args(argv)
```

Run the unit tests and verify GREEN for the pure validation layer.

- [ ] **Step 3: Add fail-fast input validation**

Add helpers that require:

- fixture exists and is non-empty;
- monolith exists, is non-empty, and contains the requested macro name;
- `soffice --version` output contains exactly `7.4.7.2` before runtime startup.

Add unit tests for missing fixture, missing monolith, macro absent from monolith, and wrong LibreOffice version string.

- [ ] **Step 4: Implement isolated LibreOffice process startup and UNO connection**

The harness must:

1. create a temporary profile directory and working directory;
2. copy the fixture into the working directory;
3. choose a localhost TCP port dynamically;
4. start `${soffice}` with:

```text
--headless
--nologo
--nodefault
--nofirststartwizard
-env:UserInstallation=file://<temp-profile>
--accept=socket,host=127.0.0.1,port=<port>;urp;StarOffice.ComponentContext
```

5. connect using the LibreOffice-provided Python/UNO environment;
6. retry connection until the configured timeout, then raise `HarnessError("UNO connection timeout ...")`.

Keep process creation, connection retry and cleanup in focused helper functions so failure messages identify the stage.

- [ ] **Step 5: Implement document open and dynamic Basic injection**

Using UNO:

- convert the copied fixture path to a file URL;
- open it hidden through the desktop loader;
- access the document Basic library container;
- ensure `Standard` exists and is loaded;
- remove a prior module named `CompareFramework_CI_Runtime` if present;
- insert the entire freshly generated monolith text as module `CompareFramework_CI_Runtime`.

Do not load any individual `src/*.bas` file.

- [ ] **Step 6: Resolve and invoke the macro through the document script provider**

Resolve:

```text
vnd.sun.star.script:Standard.CompareFramework_CI_Runtime.<macro-name>?language=Basic&location=document
```

Invoke with empty arguments and capture UNO exceptions as:

```text
macro invocation failed: <macro-name>: <exception>
```

A nonexistent macro supplied via `--macro-name` must return non-zero and contain `macro invocation failed` or `macro resolution failed` in stderr.

- [ ] **Step 7: Read the exact result contract through UNO**

After invocation, read:

```text
CompareFramework_CI!B1
CompareFramework_CI!B2
```

Pass these strings to `validate_result_values(status, marker, expected_marker)`.

A wrong `--expected-marker` must reach this stage and fail with `result validation failed`.

- [ ] **Step 8: Implement unconditional cleanup and deterministic exit**

Use `try/finally` so the harness always attempts to:

- close the document without interactive save prompts;
- terminate LibreOffice;
- wait briefly then kill only if necessary;
- remove the temporary profile and work directory.

Main behavior:

```python
try:
    run_smoke(...)
except HarnessError as exc:
    print(f"D2-04.1 FAIL: {exc}", file=sys.stderr)
    return 1
print("D2-04.1 PASS: LibreOffice Basic runtime smoke completed")
return 0
```

- [ ] **Step 9: Run unit and static tests**

Run:

```bash
PYTHONPATH=. python tests/test_d2_04_1_harness_unit.py
PYTHONPATH=. python tests/test_d2_04_1_uno_harness_contract.py
python -m py_compile tools/ci/run_libreoffice_basic_smoke.py
```

Expected: harness unit tests PASS; all static contract assertions except workflow existence PASS.

- [ ] **Step 10: Commit the harness core**

```bash
git add tools/ci/run_libreoffice_basic_smoke.py tests/test_d2_04_1_harness_unit.py tests/test_d2_04_1_uno_harness_contract.py
git commit -m "feat(D2-04.1): add Python UNO Basic smoke harness"
```

### Task 5: Add the real LibreOffice 7.4.7.2 integration workflow

**Files:**
- Create: `.github/workflows/d2-04-1-uno-basic-harness.yml`
- Test: `tests/test_d2_04_1_uno_harness_contract.py`

**Interfaces:**
- Consumes: D2-04.0 installer, monolith builder, fixture, Python/UNO harness.
- Produces: positive real-runtime smoke evidence plus two negative-path proofs.

- [ ] **Step 1: Create the dedicated workflow**

Create `.github/workflows/d2-04-1-uno-basic-harness.yml`:

```yaml
name: D2-04.1 LibreOffice Basic UNO harness

on:
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

jobs:
  uno-basic-smoke:
    runs-on: ubuntu-22.04
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@v4

      - name: Static D2-04.1 contract
        run: PYTHONPATH=. python tests/test_d2_04_1_uno_harness_contract.py

      - name: Harness unit tests
        run: PYTHONPATH=. python tests/test_d2_04_1_harness_unit.py

      - name: Install LibreOffice 7.4.7.2
        run: bash tools/ci/install_libreoffice_7_4_7_2.sh

      - name: Build current monolith
        run: python tools/build_monolith.py

      - name: Locate monolith and LibreOffice Python environment
        shell: bash
        run: |
          monolith="$(find dist -maxdepth 1 -type f -name '*.bas' | sort | tail -n 1)"
          test -n "${monolith}"
          echo "CF_MONOLITH=${monolith}" >> "${GITHUB_ENV}"
          test -n "${SOFFICE_BIN}"

      - name: Positive UNO Basic runtime smoke
        run: |
          python tools/ci/run_libreoffice_basic_smoke.py \
            --soffice "${SOFFICE_BIN}" \
            --fixture tests/fixtures/ci/CompareFramework_CI.ods \
            --monolith "${CF_MONOLITH}"

      - name: Negative proof - nonexistent macro must fail
        shell: bash
        run: |
          set +e
          output="$(python tools/ci/run_libreoffice_basic_smoke.py \
            --soffice "${SOFFICE_BIN}" \
            --fixture tests/fixtures/ci/CompareFramework_CI.ods \
            --monolith "${CF_MONOLITH}" \
            --macro-name CF_CI_RuntimeSmoke_DOES_NOT_EXIST 2>&1)"
          rc=$?
          set -e
          echo "${output}"
          test ${rc} -ne 0
          grep -E "macro (resolution|invocation) failed" <<<"${output}"

      - name: Negative proof - wrong marker must fail at validation
        shell: bash
        run: |
          set +e
          output="$(python tools/ci/run_libreoffice_basic_smoke.py \
            --soffice "${SOFFICE_BIN}" \
            --fixture tests/fixtures/ci/CompareFramework_CI.ods \
            --monolith "${CF_MONOLITH}" \
            --expected-marker WRONG_MARKER 2>&1)"
          rc=$?
          set -e
          echo "${output}"
          test ${rc} -ne 0
          grep -F "result validation failed" <<<"${output}"
```

If LibreOffice's bundled Python or `PYTHONPATH` adjustment is required for `import uno`, encode that explicitly in the workflow/harness after observing the actual 7.4.7.2 installation paths; do not install an unrelated PyPI `uno` package as a substitute.

- [ ] **Step 2: Run the static contract test GREEN**

Run:

```bash
PYTHONPATH=. python tests/test_d2_04_1_uno_harness_contract.py
```

Expected: all static assertions PASS.

- [ ] **Step 3: Re-run existing cumulative regressions**

Run the D2-03.24 non-runtime validation sequence, including:

```bash
python -m tools.architecture --root . --summary
PYTHONPATH=. python tests/test_d2_03_24_public_api_freeze.py
python tools/build_monolith.py
```

Expected: PASS.

- [ ] **Step 4: Commit the workflow**

```bash
git add .github/workflows/d2-04-1-uno-basic-harness.yml tests/test_d2_04_1_uno_harness_contract.py
git commit -m "ci(D2-04.1): execute monolith through LibreOffice UNO"
```

### Task 6: Produce bilingual implementation reports and real CI evidence

**Files:**
- Create: `D2_04_1_REPORT.md`
- Create: `D2_04_1_REPORT_FR.md`
- Modify both after successful runtime validation.

**Interfaces:**
- Consumes: real D2-04.1 workflow results and D2-03.24 cumulative results for the same PR HEAD.
- Produces: auditable bilingual evidence and merge gate.

- [ ] **Step 1: Create both pre-validation reports**

`D2_04_1_REPORT.md` starts with:

```markdown
# D2-04.1 — LibreOffice Basic UNO Harness

## Status

**IMPLEMENTED — verification pending**
```

`D2_04_1_REPORT_FR.md` starts with:

```markdown
# D2-04.1 — Harness UNO pour LibreOffice Basic

## Statut

**IMPLÉMENTÉ — validation en attente**
```

Both reports record the same contracts: LibreOffice 7.4.7.2, freshly built monolith, versioned fixture, dynamic UNO injection, `CF_CI_RuntimeSmoke`, exact result cells, negative-path requirements, and final fresh-run gate.

- [ ] **Step 2: Commit the implementation reports**

```bash
git add D2_04_1_REPORT.md D2_04_1_REPORT_FR.md
git commit -m "docs(D2-04.1): add bilingual UNO harness reports"
```

- [ ] **Step 3: Open a PR to `main`**

Use title:

```text
D2-04.1 — LibreOffice Basic UNO Harness
```

PR body states:

- exactly LibreOffice 7.4.7.2;
- monolith is built from current `src/` then injected dynamically;
- fixture is versioned and contains no stale CompareFramework copy;
- `CF_CI_RuntimeSmoke` is technical and outside the six supported user APIs;
- validation remains pending until real positive and negative runtime checks succeed.

- [ ] **Step 4: Inspect the first real workflow run**

Require both:

- `D2-04.1 LibreOffice Basic UNO harness` reaches `completed / success`;
- existing D2-03.24 cumulative validation reaches `completed / success` on the same PR HEAD.

If the UNO job fails, inspect the exact failing stage and logs. Apply the systematic-debugging process; do not weaken the contract to make the workflow green.

- [ ] **Step 5: Record exact successful evidence in both reports**

After a real green D2-04.1 run, update both language versions with identical facts:

- workflow run ID;
- tested commit SHA;
- observed LibreOffice version;
- monolith path/name used;
- positive `CF_CI_RuntimeSmoke` result;
- `STATUS=OK` proof;
- `MARKER=COMPAREFRAMEWORK_CI_SMOKE_OK` proof;
- nonexistent-macro negative proof PASS;
- wrong-marker negative proof PASS;
- D2-03.24 cumulative validation PASS.

Set statuses to `VALIDATED` / `VALIDÉ` only at this point.

- [ ] **Step 6: Commit the validated evidence**

```bash
git add D2_04_1_REPORT.md D2_04_1_REPORT_FR.md
git commit -m "docs(D2-04.1): record validated UNO runtime evidence"
```

This evidence commit creates a new PR HEAD and must receive a fresh successful D2-04.1 runtime run plus D2-03.24 cumulative run.

- [ ] **Step 7: Merge only with fresh green checks on final HEAD**

Verify the successful workflow commit SHA equals the current PR head SHA before merge. Do not reuse a success from the pre-evidence commit.

## Self-review result

- Spec coverage: monolith packaging boundary, versioned fixture, UNO orchestration, technical Basic entrypoint, API freeze compatibility, exact result contract, fail-fast errors, cleanup, global timeout, positive runtime proof, both required negative paths, cumulative regression compatibility, bilingual documentation, and final fresh-run merge gate are all mapped to tasks.
- Placeholder scan: no `TODO`, `TBD`, or unspecified implementation steps remain.
- Interface consistency: `CF_CI_RuntimeSmoke`, `CompareFramework_CI`, `STATUS=OK`, `COMPAREFRAMEWORK_CI_SMOKE_OK`, fixture path, harness path, and workflow path are consistent across tasks.
