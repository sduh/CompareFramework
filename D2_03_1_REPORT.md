# D2-03.1 — Audit des dépendances et candidats à la privatisation

## Status

**VALIDATED**

## Canonical schema

`architecture.json`: **1.3.0**

## Policy

A `Public` procedure is considered a static candidate only when the resolved
repository call graph contains no incoming call from another module.

The analyzer does **not** automatically change source visibility. Procedures
with no resolved caller are review candidates because static repository
analysis cannot prove absence of LibreOffice, dialog, macro, document or user
entry points.

## Repository results

```text
Public procedures: 204
Public procedures used cross-module: 99
Total review/candidate set: 105
High-confidence local-only candidates: 75
Zero-caller review candidates: 30
Entry-point review candidates: 0
```

## High-confidence candidates

- `CF_ModeReference.CF_RunAgainstReference` — 3 local call site(s)
- `CF_ModeReference.CF_BuildReferencePlan` — 1 local call site(s)
- `CF_ModeReference.CF_ReferenceIsTargetSheet` — 3 local call site(s)
- `CF_ModeReference.CF_ReferenceSheetHasKey` — 2 local call site(s)
- `CF_ModeReference.CF_ReferencePlanSetStatus` — 2 local call site(s)
- `CF_ModeReference.CF_ReferenceFormatPlan` — 2 local call site(s)
- `CF_ModeReference.CF_ReferenceBuildSummary` — 1 local call site(s)
- `CF_ModeReference.CF_ReferenceFormatSummary` — 1 local call site(s)
- `CompareFramework_Audit.CF_AuditWriteCurrentRun` — 1 local call site(s)
- `CompareFramework_ComparatorConfig.CF_EnsureComparatorsSheet` — 3 local call site(s)
- `CompareFramework_ComparatorConfig.CF_WriteDefaultComparatorConfig` — 1 local call site(s)
- `CompareFramework_Comparators.CF_ComparatorTypeForHeader` — 1 local call site(s)
- `CompareFramework_Comparators.CF_TextEqual` — 1 local call site(s)
- `CompareFramework_Comparators.CF_NumberEqual` — 3 local call site(s)
- `CompareFramework_Comparators.CF_DateEqual` — 1 local call site(s)
- `CompareFramework_Comparators.CF_BooleanEqual` — 1 local call site(s)
- `CompareFramework_Comparators.CF_LooksNumeric` — 2 local call site(s)
- `CompareFramework_Comparators.CF_LooksDate` — 2 local call site(s)
- `CompareFramework_Comparators.CF_LooksBoolean` — 2 local call site(s)
- `CompareFramework_Comparators.CF_TryParseNumber` — 5 local call site(s)
- `CompareFramework_Comparators.CF_TryParseDateSerial` — 3 local call site(s)
- `CompareFramework_Comparators.CF_BooleanCode` — 3 local call site(s)
- `CompareFramework_Comparators.CF_PercentToNumber` — 2 local call site(s)
- `CompareFramework_Comparators.CF_CurrencyToNumber` — 2 local call site(s)
- `CompareFramework_Comparators.CF_GetNumericTolerance` — 1 local call site(s)
- `CompareFramework_Comparators.CF_GetPercentTolerance` — 1 local call site(s)
- `CompareFramework_Comparators.CF_GetCurrencyTolerance` — 1 local call site(s)
- `CompareFramework_Comparators.CF_GetDateToleranceDays` — 1 local call site(s)
- `CompareFramework_Config.WriteDefaultConfig` — 1 local call site(s)
- `CompareFramework_Config.EnsureRulesSheet` — 1 local call site(s)
- `CompareFramework_Config.WriteDefaultRulesSheet` — 1 local call site(s)
- `CompareFramework_Config.TokenInList` — 2 local call site(s)
- `CompareFramework_Context.CF_ContextInitIfNeeded` — 5 local call site(s)
- `CompareFramework_EngineMemory.CF_CompareDetectedPairsMemory` — 1 local call site(s)
- `CompareFramework_EngineMemory.CF_CompareFallbackMemory` — 1 local call site(s)
- `CompareFramework_EngineMemory.CF_BuildMemoryIdIndex` — 3 local call site(s)
- `CompareFramework_EngineMemory.CF_CompareMemoryRows` — 1 local call site(s)
- `CompareFramework_EngineMemory.CF_MemoryFullRow` — 2 local call site(s)
- `CompareFramework_EngineMemory.CF_ReportMemoryDuplicates` — 2 local call site(s)
- `CompareFramework_EngineMemory.CF_MemoryValueText` — 5 local call site(s)
- `CompareFramework_Main.CompareDetectedPairs` — 1 local call site(s)
- `CompareFramework_Main.CompareFallbackTwoSheets` — 1 local call site(s)
- `CompareFramework_Main.CompareSheetPair` — 2 local call site(s)
- `CompareFramework_Main.GetFrameworkVersion` — 2 local call site(s)
- `CompareFramework_Main.CF_RunMilestoneB_Configured` — 1 local call site(s)
- `CompareFramework_Performance.CF_PerfRecordPair` — 1 local call site(s)
- `CompareFramework_Profiles.CF_WriteDefaultProfiles` — 1 local call site(s)
- `CompareFramework_Profiles.CF_ApplyProfile` — 1 local call site(s)
- `CompareFramework_Quality.CF_RunEndToEndScenario` — 1 local call site(s)
- `CompareFramework_Quality.CF_ValidateExpectedReport` — 1 local call site(s)
- `CompareFramework_Quality.CF_BuildQualityDashboard` — 1 local call site(s)
- `CompareFramework_Reliability.CF_RunTypedRegressionSuite` — 1 local call site(s)
- `CompareFramework_Reliability.CF_BuildComparatorCoverageReport` — 1 local call site(s)
- `CompareFramework_Report.WriteActionHeader` — 1 local call site(s)
- `CompareFramework_Report.IsActionableStatus` — 1 local call site(s)
- `CompareFramework_Report.ActionPriority` — 1 local call site(s)
- `CompareFramework_Report.ActionRecommendation` — 1 local call site(s)
- `CompareFramework_Report.ApplyOptionalAutoFilter` — 2 local call site(s)
- `CompareFramework_Report.BuildHtmlReport` — 1 local call site(s)
- `CompareFramework_Report.HtmlStyleBlock` — 1 local call site(s)
- `CompareFramework_Report.HtmlScriptBlock` — 1 local call site(s)
- `CompareFramework_Report.SheetToHtmlSection` — 4 local call site(s)
- `CompareFramework_Report.SheetToHtmlTableOnly` — 2 local call site(s)
- `CompareFramework_Report.HtmlCssClassForCell` — 1 local call site(s)
- `CompareFramework_Rules.RuleAppliesToColumn` — 1 local call site(s)
- `CompareFramework_Rules.RuleAppliesToScope` — 1 local call site(s)
- `CompareFramework_Rules.EvaluateDifferenceRule` — 1 local call site(s)
- `CompareFramework_Rules.ValuesAreEquivalentByList` — 2 local call site(s)
- `CompareFramework_Rules.ValuesAreWithinNumericTolerance` — 1 local call site(s)
- `CompareFramework_Scenarios.CF_RunFinanceScenario` — 1 local call site(s)
- `CompareFramework_Scenarios.CF_RunHRScenario` — 1 local call site(s)
- `CompareFramework_Scenarios.CF_RunERPScenario` — 1 local call site(s)
- `CompareFramework_Utils.EndsWith` — 9 local call site(s)
- `CompareFramework_Validation.CF_ValidateActiveProfile` — 1 local call site(s)
- `CompareFramework_Validation.CF_PreflightComparison` — 1 local call site(s)

## Outputs

```text
build/architecture/privatization_candidates.json
build/architecture/privatization_candidates.csv
```

## Validation

- compilation: PASS
- A1.5 regression: PASS
- call graph regression: PASS
- dependency regression: PASS
- report regression: PASS
- privatization tests: PASS
- full repository analysis: PASS
- deterministic outputs: PASS

No LibreOffice Basic source visibility was changed.
