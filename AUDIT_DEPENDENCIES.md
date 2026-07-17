# AUDIT_DEPENDENCIES

## Synthèse
Analyse basée sur les références textuelles entre modules.

### CF_ModeReference
- Procédures publiques : 13
- Exemples : CF_RunReferenceMode, CF_RunAgainstReference_MODELE, CF_RunAgainstReference, CF_BuildReferencePlan, CF_ReferenceIsTargetSheet, CF_ReferenceSheetHasKey, CF_ReferencePlanSetStatus, CF_ReferenceFormatPlan, CF_ReferenceBuildSummary, CF_ReferenceFormatSummary
- Dépendances : Aucune détectée

### CompareFramework_Audit
- Procédures publiques : 8
- Exemples : CF_AuditBegin, CF_AuditSet, CF_AuditFail, CF_AuditEnd, CF_AuditWriteCurrentRun, CF_AuditClearHistory, CF_AuditGetRunId, CF_AuditDurationSeconds
- Dépendances : Aucune détectée

### CompareFramework_ComparatorConfig
- Procédures publiques : 7
- Exemples : CF_EnsureComparatorsSheet, CF_WriteDefaultComparatorConfig, CF_LoadComparatorConfig, CF_ResolveComparatorConfig, CF_ReloadComparatorConfig, CF_OpenComparatorConfig, CF_RunComparatorConfigTests
- Dépendances : Aucune détectée

### CompareFramework_Comparators
- Procédures publiques : 19
- Exemples : CF_TypedValuesEqual, CF_ComparatorTypeForHeader, CF_TextEqual, CF_NumberEqual, CF_DateEqual, CF_BooleanEqual, CF_LooksNumeric, CF_LooksDate, CF_LooksBoolean, CF_TryParseNumber
- Dépendances : Aucune détectée

### CompareFramework_Config
- Procédures publiques : 13
- Exemples : LoadCompareConfig, EnsureConfigSheet, WriteDefaultConfig, EnsureRulesSheet, WriteDefaultRulesSheet, NormalizeCompareValue, NormalizeSpaces, IgnoreThisEmptyChange, ColumnIsIgnored, TokenInList
- Dépendances : Aucune détectée

### CompareFramework_Context
- Procédures publiques : 9
- Exemples : CF_ContextReset, CF_ContextInitIfNeeded, CF_ContextSet, CF_ContextGet, CF_ContextHas, CF_ContextCount, CF_ContextDumpToSheet, CF_ContextBeginRun, CF_ContextEndRun
- Dépendances : Aucune détectée

### CompareFramework_EngineMemory
- Procédures publiques : 12
- Exemples : CF_CompareAllSheetsInMemory, CF_CompareDetectedPairsMemory, CF_CompareFallbackMemory, CF_CompareSheetPairMemory, CF_ReadUsedData, CF_MemoryHeaders, CF_BuildMemoryIdIndex, CF_CompareMemoryRows, CF_MemoryFullRow, CF_ReportMemoryDuplicates
- Dépendances : Aucune détectée

### CompareFramework_Index
- Procédures publiques : 6
- Exemples : BuildIdIndex, FindRowInIndex, QuickSortIndex, ReportDuplicateIds, ReadHeaders, HeaderIndex
- Dépendances : Aucune détectée

### CompareFramework_Main
- Procédures publiques : 19
- Exemples : ComparerToutesLesFeuilles_Legacy, ComparerToutesLesFeuilles, CF_RunMilestoneA, CompareDetectedPairs, CompareFallbackTwoSheets, CompareSheetPair, FrameworkManifest, GetFrameworkVersion, DiagnosticFramework, ComparerToutesLesFeuilles_Contextualisee
- Dépendances : Aucune détectée

### CompareFramework_Performance
- Procédures publiques : 7
- Exemples : CF_PerfReset, CF_PerfStart, CF_PerfStop, CF_PerfRecordPair, CF_PerfWriteReport, CF_ReadSheetDataArray, CF_RunPerformanceBenchmark
- Dépendances : Aucune détectée

### CompareFramework_Profiles
- Procédures publiques : 6
- Exemples : CF_EnsureProfilesSheet, CF_WriteDefaultProfiles, CF_ApplyProfile, CF_SaveCurrentConfigAsProfile, CF_ListProfiles, CF_RunWithProfile
- Dépendances : Aucune détectée

### CompareFramework_Quality
- Procédures publiques : 4
- Exemples : CF_RunEndToEndScenario, CF_ValidateExpectedReport, CF_RunGlobalRegression, CF_BuildQualityDashboard
- Dépendances : Aucune détectée

### CompareFramework_Reliability
- Procédures publiques : 4
- Exemples : CF_RunTypedRegressionSuite, CF_ValidateComparatorRules, CF_BuildComparatorCoverageReport, CF_RunMilestoneB_FinalTests
- Dépendances : Aucune détectée

### CompareFramework_Report
- Procédures publiques : 26
- Exemples : PrepareSheet, WriteReportHeader, WriteReportRow, WriteStatsHeader, WriteStatsRow, WriteGlobalSummary, WriteDashboard, BuildActionPlan, WriteActionHeader, IsActionableStatus
- Dépendances : Aucune détectée

### CompareFramework_Rules
- Procédures publiques : 9
- Exemples : LoadCompareRules, ShouldIgnoreDifference, RuleAppliesToColumn, RuleAppliesToScope, EvaluateDifferenceRule, ValuesAreEquivalentByList, ValuesAreWithinNumericTolerance, CompareRowCellsDetailed, ReportColumnDifferences
- Dépendances : Aucune détectée

### CompareFramework_Scenarios
- Procédures publiques : 5
- Exemples : CF_RunAllBusinessScenarios, CF_RunFinanceScenario, CF_RunHRScenario, CF_RunERPScenario, CF_BuildReleaseReadiness
- Dépendances : Aucune détectée

### CompareFramework_Tests
- Procédures publiques : 8
- Exemples : CF_CreateTestWorkbook, CF_RunAllTests, CF_RunContextTests, CF_RunProfileTests, CF_RunValidationTests, CF_RunAuditTests, CF_RunPerformanceTests, CF_RunMilestoneBTests
- Dépendances : Aucune détectée

### CompareFramework_Utils
- Procédures publiques : 19
- Exemples : FullRowText, LastUsedRow, LastUsedCol, CellText, SetCell, RowNumberText, NormalizeHeader, IsReportOrStatsSheet, IsOldSheetName, PairBaseName
- Dépendances : Aucune détectée

### CompareFramework_Validation
- Procédures publiques : 4
- Exemples : CF_ValidateFramework, CF_ValidateActiveProfile, CF_PreflightComparison, CF_RunValidated
- Dépendances : Aucune détectée

## Modules les plus référencés
- CompareFramework_Index: 0
- CompareFramework_Rules: 0
- CompareFramework_Report: 0
- CompareFramework_Utils: 0
- CompareFramework_Validation: 0
- CompareFramework_Quality: 0
- CompareFramework_Config: 0
- CompareFramework_Reliability: 0
- CompareFramework_Main: 0
- CompareFramework_Scenarios: 0
- CompareFramework_Context: 0
- CompareFramework_Tests: 0
- CompareFramework_ComparatorConfig: 0
- CompareFramework_Performance: 0
- CompareFramework_Comparators: 0
- CompareFramework_Audit: 0
- CompareFramework_EngineMemory: 0
- CompareFramework_Profiles: 0
- CF_ModeReference: 0