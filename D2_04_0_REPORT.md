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

## Implementation notes

The installer is repository-owned at `tools/ci/install_libreoffice_7_4_7_2.sh`.
It downloads the pinned Debian archive from the official Document Foundation
archive, installs only that package set, verifies the observed runtime version,
and exports the resolved `SOFFICE_BIN` path to GitHub Actions.

The D2-03.24 validation workflow remains unchanged and separate.
