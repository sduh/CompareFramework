# D2-04.0 LibreOffice 7.4.7.2 CI Runtime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish a reproducible GitHub Actions runtime that installs and smoke-tests exactly LibreOffice 7.4.7.2 from the official LibreOffice archive.

**Architecture:** Keep the existing D2-03.24 Python/architecture workflow unchanged. Add a repository-owned installer under `tools/ci/`, static contract tests that pin its behavior, and a separate GitHub Actions workflow that installs LibreOffice 7.4.7.2 on a clean Ubuntu runner and executes a headless smoke operation with an isolated temporary user profile.

**Tech Stack:** Bash, GitHub Actions, Ubuntu hosted runner, LibreOffice 7.4.7.2 Linux x86_64 Debian packages, Python `unittest` for static contract tests.

**Spec:** `docs/superpowers/specs/2026-08-20-d2-04-0-libreoffice-7-4-7-2-ci-runtime-design.md`

## Global Constraints

- LibreOffice **7.4.7.2** is the only supported runtime baseline for D2-04.0.
- Packages must come from the official LibreOffice archive; no Ubuntu `apt install libreoffice`, third-party mirror, Docker image, or version fallback.
- The runtime version check must fail unless the observed version contains exactly `7.4.7.2`.
- Every headless execution must use an isolated temporary LibreOffice user profile.
- D2-04.0 must not execute CompareFramework Basic macros or T001–T010 business scenarios.
- The existing `.github/workflows/d2-03-24-validation.yml` remains unchanged.
- D2-04.0 is not `VALIDATED` until a fresh real GitHub Actions run passes.

---

## File Structure

- Create `tools/ci/install_libreoffice_7_4_7_2.sh` — sole owner of archive download, extraction, package installation, executable discovery, and exact version verification.
- Create `tests/test_d2_04_0_libreoffice_runtime_contract.py` — static tests for version pinning, official provenance, fail-fast behavior, isolated-profile policy, and absence of unpinned system-LibreOffice fallback.
- Create `.github/workflows/d2-04-0-libreoffice-7-4-7-2.yml` — dedicated real-runtime CI job.
- Create `D2_04_0_REPORT.md` — delivery evidence/status document; starts as `IMPLEMENTED — verification pending` and changes to `VALIDATED` only after a successful real workflow run.

### Task 1: Pin and test the installer contract

**Files:**
- Create: `tests/test_d2_04_0_libreoffice_runtime_contract.py`
- Create later in Task 2: `tools/ci/install_libreoffice_7_4_7_2.sh`

**Interfaces:**
- Consumes: repository root and the expected future installer/workflow paths.
- Produces: static regression tests defining the D2-04.0 runtime contract.

- [ ] **Step 1: Write the failing installer contract tests**

Create `tests/test_d2_04_0_libreoffice_runtime_contract.py` with tests equivalent to:

```python
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = ROOT / "tools" / "ci" / "install_libreoffice_7_4_7_2.sh"
WORKFLOW = ROOT / ".github" / "workflows" / "d2-04-0-libreoffice-7-4-7-2.yml"


class D2040LibreOfficeRuntimeContractTests(unittest.TestCase):
    def test_installer_pins_exact_version_and_official_archive(self):
        text = INSTALLER.read_text(encoding="utf-8")
        self.assertIn('LO_VERSION="7.4.7.2"', text)
        self.assertIn("downloadarchive.documentfoundation.org/libreoffice/old/7.4.7.2", text)
        self.assertNotRegex(text, r"apt(?:-get)?\s+install\s+.*\blibreoffice\b")

    def test_installer_is_fail_fast_and_checks_version(self):
        text = INSTALLER.read_text(encoding="utf-8")
        self.assertRegex(text, r"(?m)^set -euo pipefail$")
        self.assertIn("--version", text)
        self.assertIn("7.4.7.2", text)

    def test_workflow_uses_dedicated_installer_and_isolated_profile(self):
        text = WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("tools/ci/install_libreoffice_7_4_7_2.sh", text)
        self.assertIn("mktemp -d", text)
        self.assertIn("-env:UserInstallation=file://", text)
        self.assertNotIn("apt install libreoffice", text)
        self.assertNotIn("apt-get install libreoffice", text)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run the new tests and confirm RED**

Run:

```bash
PYTHONPATH=. python tests/test_d2_04_0_libreoffice_runtime_contract.py
```

Expected: FAIL because the installer and workflow files do not exist yet.

- [ ] **Step 3: Commit the RED contract tests**

```bash
git add tests/test_d2_04_0_libreoffice_runtime_contract.py
git commit -m "test(D2-04.0): define LibreOffice runtime contract"
```

### Task 2: Implement the pinned LibreOffice 7.4.7.2 installer

**Files:**
- Create: `tools/ci/install_libreoffice_7_4_7_2.sh`
- Test: `tests/test_d2_04_0_libreoffice_runtime_contract.py`

**Interfaces:**
- Consumes: network access to the official LibreOffice archive and `sudo dpkg` on Ubuntu.
- Produces: an installed `soffice` executable whose `--version` output matches `7.4.7.2`; exports no persistent runner state beyond installed packages.

- [ ] **Step 1: Implement the minimal fail-fast installer**

Create `tools/ci/install_libreoffice_7_4_7_2.sh` with this structure:

```bash
#!/usr/bin/env bash
set -euo pipefail

LO_VERSION="7.4.7.2"
LO_ARCHIVE="LibreOffice_${LO_VERSION}_Linux_x86-64_deb.tar.gz"
LO_BASE_URL="https://downloadarchive.documentfoundation.org/libreoffice/old/${LO_VERSION}/deb/x86_64"
LO_URL="${LO_BASE_URL}/${LO_ARCHIVE}"

workdir="$(mktemp -d)"
trap 'rm -rf "${workdir}"' EXIT

printf 'Downloading LibreOffice %s from official archive\n' "${LO_VERSION}"
curl --fail --location --silent --show-error \
  --output "${workdir}/${LO_ARCHIVE}" \
  "${LO_URL}"

tar -xzf "${workdir}/${LO_ARCHIVE}" -C "${workdir}"
mapfile -t packages < <(find "${workdir}" -type f -path '*/DEBS/*.deb' -print | sort)
if [[ ${#packages[@]} -eq 0 ]]; then
  echo "No LibreOffice Debian packages found in archive" >&2
  exit 1
fi

sudo dpkg -i "${packages[@]}" || sudo apt-get -f install -y

SOFFICE_BIN="$(command -v soffice || command -v libreoffice || true)"
if [[ -z "${SOFFICE_BIN}" ]]; then
  echo "LibreOffice executable not found after installation" >&2
  exit 1
fi

observed_version="$(${SOFFICE_BIN} --version)"
printf 'Observed LibreOffice version: %s\n' "${observed_version}"
if [[ "${observed_version}" != *"${LO_VERSION}"* ]]; then
  printf 'Expected LibreOffice %s, got: %s\n' "${LO_VERSION}" "${observed_version}" >&2
  exit 1
fi

printf 'SOFFICE_BIN=%s\n' "${SOFFICE_BIN}"
```

Do not add any fallback that installs Ubuntu's `libreoffice` package. `apt-get -f install -y` is allowed only to satisfy dependencies after `dpkg -i` of the pinned official packages.

- [ ] **Step 2: Make the installer executable**

```bash
chmod +x tools/ci/install_libreoffice_7_4_7_2.sh
```

- [ ] **Step 3: Run the static contract test**

```bash
PYTHONPATH=. python tests/test_d2_04_0_libreoffice_runtime_contract.py
```

Expected at this point: installer-related assertions PASS; workflow-related assertion still FAIL because the workflow is not created yet.

- [ ] **Step 4: Perform a shell syntax check**

```bash
bash -n tools/ci/install_libreoffice_7_4_7_2.sh
```

Expected: exit code 0 with no output.

- [ ] **Step 5: Commit installer implementation**

```bash
git add tools/ci/install_libreoffice_7_4_7_2.sh tests/test_d2_04_0_libreoffice_runtime_contract.py
git commit -m "feat(D2-04.0): install pinned LibreOffice 7.4.7.2 runtime"
```

### Task 3: Add the real GitHub Actions runtime smoke test

**Files:**
- Create: `.github/workflows/d2-04-0-libreoffice-7-4-7-2.yml`
- Test: `tests/test_d2_04_0_libreoffice_runtime_contract.py`

**Interfaces:**
- Consumes: `tools/ci/install_libreoffice_7_4_7_2.sh`.
- Produces: a dedicated PR/manual GitHub Actions check proving installation, exact version, isolated-profile headless execution, and clean exit.

- [ ] **Step 1: Create the dedicated workflow**

Create `.github/workflows/d2-04-0-libreoffice-7-4-7-2.yml`:

```yaml
name: D2-04.0 LibreOffice 7.4.7.2 runtime

on:
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

jobs:
  libreoffice-runtime:
    runs-on: ubuntu-22.04
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4

      - name: Validate runtime contract
        run: PYTHONPATH=. python tests/test_d2_04_0_libreoffice_runtime_contract.py

      - name: Install LibreOffice 7.4.7.2
        run: tools/ci/install_libreoffice_7_4_7_2.sh

      - name: Verify exact LibreOffice version
        run: |
          observed="$(soffice --version)"
          echo "${observed}"
          [[ "${observed}" == *"7.4.7.2"* ]]

      - name: Headless smoke test with isolated profile
        run: |
          profile_dir="$(mktemp -d)"
          trap 'rm -rf "${profile_dir}"' EXIT
          profile_url="file://${profile_dir}"
          output_dir="$(mktemp -d)"
          trap 'rm -rf "${profile_dir}" "${output_dir}"' EXIT
          printf 'D2-04.0 smoke\n' > "${output_dir}/smoke.txt"
          timeout 60s soffice \
            --headless \
            --nologo \
            --nodefault \
            --nofirststartwizard \
            "-env:UserInstallation=${profile_url}" \
            --convert-to pdf \
            --outdir "${output_dir}" \
            "${output_dir}/smoke.txt"
          test -s "${output_dir}/smoke.pdf"
```

Use `ubuntu-22.04` deliberately so the initial runtime baseline is tied to a stable runner image rather than a moving `ubuntu-latest` alias. Do not modify the D2-03.24 workflow.

- [ ] **Step 2: Run the static runtime contract test GREEN**

```bash
PYTHONPATH=. python tests/test_d2_04_0_libreoffice_runtime_contract.py
```

Expected: PASS, all contract tests green.

- [ ] **Step 3: Re-run existing D2-03.24 static validation locally**

Run the same non-LibreOffice validations currently used by `.github/workflows/d2-03-24-validation.yml`, ending with:

```bash
python -m tools.architecture --root . --summary
python tests/test_d2_03_24_public_api_freeze.py
python tools/build_monolith.py
```

Expected: all existing D2-03 checks PASS, proving the new runtime workflow did not alter the established architecture baseline.

- [ ] **Step 4: Commit the workflow**

```bash
git add .github/workflows/d2-04-0-libreoffice-7-4-7-2.yml tests/test_d2_04_0_libreoffice_runtime_contract.py
git commit -m "ci(D2-04.0): validate LibreOffice 7.4.7.2 headless runtime"
```

### Task 4: Produce delivery evidence, open PR, and validate on a real runner

**Files:**
- Create: `D2_04_0_REPORT.md`
- Modify after successful CI: `D2_04_0_REPORT.md`

**Interfaces:**
- Consumes: successful static tests plus the actual GitHub Actions run for `.github/workflows/d2-04-0-libreoffice-7-4-7-2.yml`.
- Produces: auditable D2-04.0 status and merge-ready PR.

- [ ] **Step 1: Create the pre-validation report**

Create `D2_04_0_REPORT.md` with status:

```markdown
# D2-04.0 — LibreOffice 7.4.7.2 CI Runtime Baseline

## Statut

**IMPLEMENTED — verification pending**

## Runtime contract

- Baseline: LibreOffice 7.4.7.2 only
- Provenance: official LibreOffice archive
- Platform: GitHub Actions `ubuntu-22.04`
- Execution: headless
- User profile: isolated temporary profile
- CompareFramework macro execution: out of scope for D2-04.0

## Validation required

The delivery becomes `VALIDATED` only after a fresh GitHub Actions run proves:

1. official archive download succeeds;
2. package installation succeeds;
3. `soffice --version` reports 7.4.7.2;
4. isolated-profile headless PDF smoke conversion succeeds;
5. the workflow job exits successfully.
```

- [ ] **Step 2: Commit the report**

```bash
git add D2_04_0_REPORT.md
git commit -m "docs(D2-04.0): add runtime baseline report"
```

- [ ] **Step 3: Open a PR to `main`**

Use title:

```text
D2-04.0 — LibreOffice 7.4.7.2 CI Runtime Baseline
```

PR body must state the exact runtime version, official-archive provenance, isolated-profile smoke test, and that validation is pending a real workflow run.

- [ ] **Step 4: Inspect the real workflow run**

Require the D2-04.0 workflow to reach `completed / success`. If it fails, inspect the failing job logs and fix the root cause on the branch; do not mark the report validated based on partial success.

- [ ] **Step 5: Update the report only after fresh success evidence**

Change status to:

```markdown
**VALIDATED**
```

Add the successful workflow run ID, tested commit SHA, observed `soffice --version` output, and smoke-test result.

- [ ] **Step 6: Commit the validated evidence**

```bash
git add D2_04_0_REPORT.md
git commit -m "docs(D2-04.0): record validated LibreOffice runtime evidence"
```

This new commit must trigger a fresh D2-04.0 workflow run. The PR may be merged only after that final commit also has a successful runtime workflow result.

- [ ] **Step 7: Merge only with fresh green checks**

Verify the PR head SHA matches the successful final workflow run, then merge to `main`. Do not reuse a successful run from an earlier commit.

## Self-review result

- Spec coverage: installer provenance/version pin, isolated profile, dedicated CI workflow, fail-fast handling, static tests, real runtime evidence, non-goals, and closure criteria are all mapped to tasks above.
- Placeholder scan: no TBD/TODO/"implement later" steps remain.
- Interface consistency: the installer path, workflow path, runtime version, profile mechanism, and test filename are identical across all tasks.
