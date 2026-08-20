# D2-04.0 — LibreOffice 7.4.7.2 CI Runtime Baseline

## Status

**DESIGN APPROVED — implementation plan pending**

## Context

D2-03 established and validated the architecture analyzer, public API freeze,
and a GitHub Actions regression workflow. D2-04 begins the next quality phase:
executing CompareFramework against a real LibreOffice runtime in CI.

LibreOffice **7.4.7.2** is the contractual baseline for this phase. Other
LibreOffice versions are explicitly out of scope for D2-04.0.

The repository already contains an official functional regression catalogue
(`tests/catalog.md`) with scenarios T001–T010. D2-04.0 does not execute those
business scenarios yet; it establishes the deterministic runtime foundation
required by later D2-04 deliveries.

## Goal

A fresh GitHub Actions Ubuntu runner must be able to install and start exactly
LibreOffice **7.4.7.2** in headless mode using an isolated CI user profile.

The workflow must fail if:

- LibreOffice cannot be downloaded from the official LibreOffice archive;
- installation is incomplete;
- the installed runtime reports a version other than 7.4.7.2;
- headless startup fails;
- the smoke test cannot terminate cleanly.

## Non-goals

D2-04.0 does not:

- execute a CompareFramework Basic macro;
- load the T001–T010 functional datasets;
- validate comparison results;
- support a LibreOffice version matrix;
- introduce a Docker image;
- optimize download/install time through caching.

Those capabilities belong to later D2-04 deliveries.

## Architecture

### 1. Versioned installer

Add a repository-owned shell script:

`tools/ci/install_libreoffice_7_4_7_2.sh`

The script has one responsibility: establish the exact LibreOffice 7.4.7.2
runtime required by CI.

It will:

1. define the expected version as an immutable constant;
2. construct or use an explicit URL pointing to the official LibreOffice
   archive for the Linux x86_64 Debian package set;
3. download the archive with failure propagation enabled;
4. extract the package set into a temporary working directory;
5. install the required `.deb` packages on the Ubuntu runner;
6. locate the installed `soffice`/`libreoffice` executable;
7. execute `--version` and require an exact 7.4.7.2 match;
8. expose a non-zero exit code for every failure condition.

The installation logic remains outside the workflow YAML so that it is
versioned, readable and independently testable.

### 2. CI runtime smoke test

Add a dedicated D2-04.0 GitHub Actions workflow rather than overloading the
D2-03.24 architecture workflow.

The D2-04.0 workflow will:

1. check out the repository;
2. run the versioned LibreOffice installer;
3. verify the exact version again at workflow level;
4. create a unique temporary LibreOffice user profile;
5. start LibreOffice headless with that profile;
6. execute a minimal non-interactive smoke operation;
7. verify successful exit and clean up the temporary profile.

The profile isolation is mandatory. CI must not depend on or pollute the
runner's default LibreOffice profile.

### 3. Relationship with D2-03 CI

The existing D2-03.24 cumulative validation workflow remains intact and keeps
its current responsibility: Python architecture/regression validation and
monolith build.

D2-04.0 introduces a separate runtime validation concern. Keeping the jobs
separate makes failures attributable:

- D2-03 workflow failure => analyzer/architecture/regression problem;
- D2-04.0 workflow failure => LibreOffice runtime baseline problem.

A later D2-04 delivery may consolidate policy around required checks, but
D2-04.0 avoids coupling unrelated validation layers.

## Runtime provenance

LibreOffice 7.4.7.2 must come from the official LibreOffice archive. The CI
must not silently substitute:

- Ubuntu's current `apt` LibreOffice package;
- a newer upstream LibreOffice release;
- a third-party mirror;
- a prebuilt Docker image.

The source URL must be explicit in the installer and therefore reviewable in
the repository history.

## Error handling

The installer and workflow use fail-fast semantics.

Expected hard failures include:

- HTTP/download error;
- archive format mismatch;
- package installation error;
- missing executable after installation;
- unexpected version string;
- profile directory creation failure;
- non-zero headless smoke-test exit.

Diagnostics should print the failed phase and the observed LibreOffice version
when available, while avoiding noisy unrelated package-manager output where
possible.

## Testing strategy

D2-04.0 requires two levels of evidence.

### Static/script contract tests

Repository tests verify that the installer and workflow preserve the contractual
properties:

- expected version is 7.4.7.2;
- official archive URL is pinned;
- version verification is mandatory;
- CI uses an isolated user profile;
- no fallback to an unpinned system LibreOffice package exists.

### Real GitHub Actions execution

The delivery is not `VALIDATED` until a fresh GitHub Actions run proves on a
clean Ubuntu runner that:

- the official archive is downloadable;
- LibreOffice 7.4.7.2 installs;
- `--version` reports 7.4.7.2;
- headless startup/smoke operation succeeds;
- the job exits successfully.

Static tests alone are insufficient for closure.

## Security and reproducibility

The installer downloads only from the official LibreOffice archive over HTTPS.
The implementation plan should evaluate whether an upstream checksum is
available and practical to pin. If a stable official checksum can be obtained,
checksum verification should be included; otherwise the design must not invent
or hard-code an unverified digest.

No secret or authenticated download is required.

No persistent runner state is assumed.

## Deliverables

D2-04.0 is expected to produce:

- `tools/ci/install_libreoffice_7_4_7_2.sh`;
- a dedicated GitHub Actions workflow for the LibreOffice runtime baseline;
- static contract tests for the installer/workflow;
- `D2_04_0_REPORT.md` recording runtime evidence and final status.

The exact filenames of the workflow and tests may be refined by the
implementation plan, but their responsibilities are fixed by this design.

## Exit criteria

D2-04.0 is complete only when all of the following are true:

1. LibreOffice 7.4.7.2 is installed from the official archive on a fresh GitHub
   Actions runner.
2. The runtime reports exactly 7.4.7.2.
3. LibreOffice starts headlessly with an isolated temporary profile.
4. The smoke operation exits successfully and cleanly.
5. Existing D2-03 validation remains unaffected.
6. Static contract tests pass.
7. A fresh real CI run passes.

Only then may `D2_04_0_REPORT.md` be marked `VALIDATED`.

## Follow-on sequence

After D2-04.0:

- **D2-04.1** — harness capable of loading CompareFramework and invoking a
  LibreOffice Basic macro;
- **D2-04.2** — automated execution of functional scenarios T001–T010;
- **D2-04.3** — CI policy/required-check integration for runtime regression
  protection.
