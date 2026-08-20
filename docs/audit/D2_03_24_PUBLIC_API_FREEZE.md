# D2-03.24 — Public API Freeze & Closure

## Status

**D2-03 CLOSED / VALIDATED**

## Frozen supported user API

The supported user API is frozen to exactly six procedures in
`CompareFramework_API.bas`:

- `CF_StartReferenceComparison`
- `CF_RunStandardComparison`
- `CF_ExportLastReportHTML`
- `CF_OpenSettings`
- `CF_RunDiagnostics`
- `CF_RunReleaseValidation`

No seventh procedure may be added to this facade without an explicit API
contract decision and corresponding update of the architecture contract.

## Technical Public procedures

LibreOffice Basic still requires procedures to remain `Public` when they form
cross-module technical contracts. These procedures are not part of the
supported user API merely because their Basic visibility is `Public`.

D2-03 therefore freezes the user-facing facade without incorrectly forcing
technical cross-module contracts to `Private`.

## Closure baseline

D2-03.23 established the final visibility baseline used for closure:

- Public procedures: 118
- Private procedures: 167
- Initial Public procedures: 204
- Cumulative Public reduction: 86
- Remaining entrypoint reviews: 6
- Remaining maintenance/test reviews: 0
- Remaining documentation conflicts: 0

The six remaining entrypoint reviews are exactly the six frozen API commands
and carry the `keep-public-api` disposition.

## Guardrail

The architecture analyzer now exports `public_api_contract` as canonical data.
The D2-03.24 regression test requires:

1. exactly the six frozen procedures in `CompareFramework_API.bas`;
2. a canonical `public_api_contract` with status `frozen`;
3. an entrypoint audit containing only those six `keep-public-api` entries.

A change to the supported user API must therefore be explicit rather than an
accidental consequence of a new `Public` Basic procedure.
