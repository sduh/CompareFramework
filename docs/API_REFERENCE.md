# CompareFramework Public API

## Supported façade — 4.0-D1

Only the following entry points are supported for direct user or integration use:

- `CF_StartReferenceComparison`
- `CF_RunStandardComparison`
- `CF_ExportLastReportHTML`
- `CF_OpenSettings`
- `CF_RunDiagnostics`
- `CF_RunReleaseValidation`

All other `Public` procedures remain available for 3.8 compatibility or Basic cross-module calls. They are not part of the stable 4.0 contract unless explicitly promoted here. D1 changes classification only; no existing symbol is removed or made `Private`.

## Compatibility inventory

The generated classification is maintained in `docs/audit/D1_PUBLIC_API_INVENTORY.csv`.
