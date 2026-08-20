# D2-03.23 — Maintenance/test entry-point lifecycle decision

## Decision

The two remaining maintenance/test entry points are no longer part of the
public macro surface and are approved for `Private` visibility:

- `CompareFramework_Main.CF_RunMilestoneB_ConfigTests`
- `CompareFramework_Tests.CF_RunMilestoneBTests`

## Evidence

For both procedures:

- D2-03.20 classified them as `maintenance-entrypoint-review`;
- the historical D1 inventory classified them as `maintenance-test`;
- the supporting public-symbol inventory classified them `Review -> Private`;
- no resolved repository caller exists;
- no user-facing documentation reference exists;
- no LibreOffice `.xml`, `.xba`, `.xdl`, or `.xlb` binding exists in the repository.

## Contract

These procedures remain available only as internal implementation/test helpers.
They are not part of `CompareFramework_API.bas` and are not supported user or
integration entry points.

The historical D1 inventories are intentionally left unchanged because they
record the state and decision status at D1. This document records the later
D2-03.23 lifecycle decision.
