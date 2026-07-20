# CompareFramework 4.0 Roadmap

**Status:** approved for implementation  
**Baseline:** 3.8.0  
**Target:** 4.0

## Vision

Version 4.0 improves internal architecture while preserving the functional reliability achieved by 3.8.0.

## Objectives

- reduce the supported public API to a stable façade;
- improve module cohesion and encapsulation;
- split the two largest modules by responsibility;
- reduce avoidable dependency cycles;
- strengthen regression automation and architecture controls.

## Milestones

### 4.0-D1 — Architectural cleanup

- freeze the supported façade;
- inventory all public symbols and Private candidates;
- map module dependencies and cycles;
- define split boundaries for `CompareFramework_Report.bas` and `Modes/CF_ModeReference.bas`;
- make no functional change.

### 4.0-D2 — API stabilization

- migrate internal callers toward service boundaries;
- retain compatibility wrappers where required;
- reduce language-level `Public` exposure in controlled batches.

### 4.0-D3 — Dependency cleanup

- remove avoidable cycles;
- introduce clear service direction;
- validate module order and regression after each batch.

### 4.0-D4 — Module refactoring

- split Report responsibilities;
- split Reference Mode responsibilities;
- preserve workbook and configuration compatibility.

### 4.0-RC1 — Qualification

- complete build, LibreOffice compilation and regression validation;
- validate migration notes and supported API;
- publish a release candidate.

### 4.0 — Stable release

- publish only after all qualification gates pass.

## Success criteria

- exactly one documented supported user-facing façade;
- significant reduction of implementation symbols exposed as `Public`;
- fewer dependency cycles than 3.8.0;
- large modules split into cohesive responsibilities;
- no regression against 3.8.0 scenarios;
- reproducible build and LibreOffice validation.

## Out of scope

- complete rewrite;
- language migration;
- UI redesign;
- incompatible workbook format;
- feature accumulation unrelated to architecture.
