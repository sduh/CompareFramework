# D2-04.0 — LibreOffice 7.4.7.2 CI Runtime Baseline

## Statut

**VALIDATED**

## Runtime contract

- Baseline: LibreOffice 7.4.7.2 only
- Provenance: official LibreOffice archive
- Platform: GitHub Actions `ubuntu-22.04`
- Execution: headless
- User profile: isolated temporary profile
- CompareFramework macro execution: out of scope for D2-04.0

## Validation evidence

Successful GitHub Actions runtime run:

- Workflow: `D2-04.0 LibreOffice 7.4.7.2 runtime`
- Run ID: `32382296896`
- Tested commit SHA: `9e5632d1f3f53abc28e5bf0bc2b4a764a22e0e9d`
- Runner: Ubuntu 22.04.5 LTS (`ubuntu-22.04`)
- Official archive: `LibreOffice_7.4.7.2_Linux_x86-64_deb.tar.gz`
- Packages installed from archive: 42
- Resolved executable: `/usr/local/bin/libreoffice7.4`
- Observed version: `LibreOffice 7.4.7.2 723314e595e8007d3cf785c16538505a1c878ca5`
- Static runtime contract tests: PASS (4 tests)
- Installer shell syntax check: PASS
- Isolated-profile headless smoke conversion: PASS
- Smoke output: `smoke.txt -> smoke.pdf` using `writer_pdf_Export`
- Existing D2-03.24 cumulative validation on the same tested commit: PASS

## Implementation notes

The installer is repository-owned at `tools/ci/install_libreoffice_7_4_7_2.sh`.
It downloads the pinned Debian archive from the official Document Foundation
archive, installs only that package set, verifies the observed runtime version,
and exports the resolved `SOFFICE_BIN` path to GitHub Actions.

The D2-03.24 validation workflow remains unchanged and separate.

## Final merge gate

This report commit must itself receive fresh successful runs for both the
D2-04.0 runtime workflow and the existing D2-03.24 cumulative workflow before
merge. A success from an earlier commit is evidence recorded above but is not
sufficient to merge the final PR head.
