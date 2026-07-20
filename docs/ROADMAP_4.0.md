# CompareFramework 4.0 Roadmap

**Document version** : 1.0  
**Status** : Approved for planning  
**Target release** : CompareFramework 4.0  
**Previous stable release** : 3.8.0

---

# 1. Introduction

CompareFramework 3.8.0 marks the first fully industrialized release of the project.

The objectives achieved include:

- stable comparison engine;
- reference comparison mode;
- reproducible build process;
- release qualification procedure;
- automated validation;
- complete documentation;
- version management;
- release governance.

Version 4.0 is **not intended to introduce new user-visible features first**.

Its primary objective is to **improve the internal architecture** while preserving the functional quality reached by version 3.8.0.

---

# 2. Vision

Version 4.0 aims to make CompareFramework:

- easier to maintain;
- easier to extend;
- easier to test;
- easier to understand;
- easier to integrate.

The guiding principle is:

> Improve the architecture without degrading functional behavior.

---

# 3. Architectural Objectives

## 3.1 Public API Rationalization

### Current situation

Approximately 198 public procedures are exposed.

Most of them are implementation details.

### Objective

Expose only the supported API.

Target:

- stable public façade;
- minimal public surface;
- internal procedures become Private whenever possible.

Expected result:

- clearer API
- easier maintenance
- reduced coupling

---

## 3.2 Module Responsibilities

Some modules have become significantly larger than the rest.

Priority candidates:

- CompareFramework_Report.bas
- CF_ModeReference.bas

Objectives:

- split responsibilities;
- improve readability;
- simplify maintenance;
- improve unit testing.

---

## 3.3 Dependency Simplification

Static audits identified several dependency cycles.

Objectives:

- remove unnecessary cycles;
- improve layering;
- isolate services;
- simplify compilation dependencies.

Target architecture:

```
API
 │
 ▼
Services
 │
 ▼
Engine
 │
 ▼
Infrastructure
```

---

## 3.4 Internal Encapsulation

Internal implementation details should not leak through the public interface.

Objectives:

- hide implementation details;
- reduce global state;
- improve module cohesion.

---

## 3.5 Testability

Increase automated verification.

Objectives:

- larger regression suite;
- more datasets;
- additional reference scenarios;
- stronger validation automation.

---

# 4. Functional Scope

Version 4.0 is **not** primarily a feature release.

Functional additions are accepted only if they naturally fit the new architecture.

Architecture has priority over feature count.

---

# 5. Out of Scope

The following items are intentionally excluded from version 4.0:

- graphical redesign;
- user interface overhaul;
- migration to another language;
- complete rewrite;
- incompatible workbook format.

---

# 6. Compatibility Policy

Backward compatibility remains an important objective.

Whenever possible:

- existing macros continue to work;
- workbook formats remain compatible;
- configuration sheets remain compatible.

Breaking changes must be documented before implementation.

---

# 7. Development Strategy

Development will proceed incrementally.

Proposed milestones:

```
4.0-D1
Architecture cleanup

4.0-D2
API stabilization

4.0-D3
Dependency cleanup

4.0-D4
Module refactoring

4.0-RC1
Qualification

4.0
Stable Release
```

---

# 8. Success Criteria

Version 4.0 will be considered complete when the following objectives are met.

## Architecture

- Public API reduced significantly
- Large modules refactored
- Dependency cycles reduced
- Clear layering established

## Quality

- All regression tests pass
- Build reproducible
- Documentation updated
- Qualification completed

## Stability

No regression compared with version 3.8.0.

---

# 9. Risks

Main risks:

- unnecessary refactoring;
- breaking compatibility;
- increasing complexity instead of reducing it.

Mitigation:

- incremental development;
- continuous regression testing;
- architectural reviews before implementation.

---

# 10. Guiding Principles

Every architectural decision should improve at least one of:

- readability;
- maintainability;
- modularity;
- robustness;
- testability.

If a refactoring improves none of these aspects, it should not be implemented.

---

# 11. Expected Deliverables

Version 4.0 should produce:

- improved architecture;
- simplified API;
- cleaner dependencies;
- updated documentation;
- complete qualification report;
- stable release 4.0.

---

# 12. Conclusion

Version 3.8 established a robust and reproducible software release process.

Version 4.0 builds upon that foundation by focusing on architectural excellence rather than feature accumulation.

The objective is clear:

> **Make CompareFramework easier to evolve for the next several years while preserving the reliability achieved with version 3.8.0.**