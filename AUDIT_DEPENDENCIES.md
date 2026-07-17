# RC-03 — Audit statique des dépendances

**Projet :** CompareFramework 3.8.0-RC1  
**Périmètre :** 19 modules LibreOffice Basic sous `src/`  
**Méthode :** analyse lexicale des procédures, symboles publics et références croisées.

## 1. Synthèse exécutive

- **19 modules** analysés, représentant **5947 lignes**.
- **198 procédures publiques** et **81 procédures privées** détectées.
- **19 modules** intégrés au graphe et **72 dépendances orientées** détectées.
- **3 composantes cycliques** détectées.
- **0 noms de procédures dupliqués** entre modules.

**Décision RC-03 : favorable avec réserves.** Les cycles ne bloquent pas la RC1, mais doivent être documentés et réduits en V4.

## 2. Méthode et limites

L’analyse associe chaque procédure appelée au module qui la déclare. Elle relève également les usages de constantes, variables, types et énumérations publics. LibreOffice Basic utilisant un espace de noms global, les appels ne sont généralement pas qualifiés par nom de module.

Limites : les appels dynamiques, les chaînes exécutées comme macros, les API UNO et certaines ambiguïtés syntaxiques ne peuvent pas être résolus complètement par une analyse lexicale. Les résultats décrivent donc les dépendances statiques visibles dans les sources.

## 3. Carte des modules

| Module | Lignes | Public | Privé | Dépend de | Utilisé par | Couplage |
|---|---:|---:|---:|---:|---:|---|
| `CompareFramework_Main.bas` | 466 | 19 | 0 | 15 | 4 | fort |
| `CompareFramework_EngineMemory.bas` | 372 | 12 | 0 | 10 | 4 | fort |
| `CompareFramework_Utils.bas` | 251 | 19 | 0 | 0 | 12 | fort |
| `CompareFramework_Tests.bas` | 485 | 8 | 18 | 8 | 2 | moyen |
| `Modes/CF_ModeReference.bas` | 670 | 13 | 1 | 9 | 0 | moyen |
| `CompareFramework_ComparatorConfig.bas` | 214 | 7 | 5 | 3 | 5 | moyen |
| `CompareFramework_Config.bas` | 220 | 13 | 0 | 2 | 6 | moyen |
| `CompareFramework_Context.bas` | 177 | 9 | 2 | 0 | 8 | moyen |
| `CompareFramework_Rules.bas` | 185 | 9 | 0 | 4 | 4 | moyen |
| `CompareFramework_Comparators.bas` | 244 | 19 | 0 | 2 | 5 | moyen |
| `CompareFramework_Audit.bas` | 313 | 8 | 9 | 2 | 4 | moyen |
| `CompareFramework_Index.bas` | 133 | 6 | 0 | 2 | 4 | moyen |
| `CompareFramework_Report.bas` | 616 | 26 | 0 | 1 | 5 | moyen |
| `CompareFramework_Profiles.bas` | 202 | 6 | 5 | 4 | 1 | faible |
| `CompareFramework_Quality.bas` | 347 | 4 | 10 | 4 | 1 | faible |
| `CompareFramework_Reliability.bas` | 260 | 4 | 5 | 2 | 2 | faible |
| `CompareFramework_Validation.bas` | 260 | 4 | 11 | 2 | 2 | faible |
| `CompareFramework_Performance.bas` | 189 | 7 | 3 | 1 | 2 | faible |
| `CompareFramework_Scenarios.bas` | 343 | 5 | 12 | 1 | 1 | faible |

## 4. Dépendances inter-modules

### `Modes/CF_ModeReference.bas`
- → `CompareFramework_Audit.bas` — procédures : `CF_AuditFail`, `CF_AuditSet`
- → `CompareFramework_ComparatorConfig.bas` — procédures : `CF_LoadComparatorConfig`
- → `CompareFramework_Config.bas` — procédures : `LoadCompareConfig`, `NormalizeList`
- → `CompareFramework_Context.bas` — procédures : `CF_ContextSet`
- → `CompareFramework_EngineMemory.bas` — procédures : `CF_CompareSheetPairMemory`, `CF_MemoryHeaders`, `CF_ReadUsedData`
- → `CompareFramework_Index.bas` — procédures : `HeaderIndex`
- → `CompareFramework_Report.bas` — procédures : `BuildActionPlan`, `FormatActionPlan`, `FormatAuditLog`, `FormatDashboard`, `FormatReport`, `FormatStats`, `PrepareSheet`, `WriteAuditLog`, `WriteDashboard`, `WriteGlobalSummary`, `WriteReportHeader`, `WriteReportRow`, `WriteStatsHeader`
- → `CompareFramework_Rules.bas` — procédures : `LoadCompareRules`
- → `CompareFramework_Utils.bas` — procédures : `IsReportOrStatsSheet`, `LastUsedRow`; symboles : `CF_ACTION_SHEET`, `CF_AUDIT_SHEET`, `CF_DASHBOARD_SHEET`, `CF_REPORT_SHEET`, `CF_STATS_SHEET`, `CF_STATUS_ERROR`

### `CompareFramework_Audit.bas`
- → `CompareFramework_Context.bas` — procédures : `CF_ContextGet`, `CF_ContextSet`
- → `CompareFramework_Utils.bas` — procédures : `CF_RoundCompat`

### `CompareFramework_ComparatorConfig.bas`
- → `CompareFramework_Comparators.bas` — symboles : `CF_TYPE_AUTO`, `CF_TYPE_CURRENCY`, `CF_TYPE_DATE`
- → `CompareFramework_Context.bas` — procédures : `CF_ContextGet`, `CF_ContextSet`
- → `CompareFramework_Utils.bas` — procédures : `CellText`, `LastUsedRow`

### `CompareFramework_Comparators.bas`
- → `CompareFramework_ComparatorConfig.bas` — procédures : `CF_ResolveComparatorConfig`
- → `CompareFramework_Config.bas` — procédures : `NormalizeCompareValue`

### `CompareFramework_Config.bas`
- → `CompareFramework_Rules.bas` — procédures : `LoadCompareRules`
- → `CompareFramework_Utils.bas` — procédures : `CellText`, `LastUsedRow`, `NormalizeHeader`, `SetCell`; symboles : `CF_CONFIG_SHEET`, `CF_RULES_SHEET`

### `CompareFramework_EngineMemory.bas`
- → `CompareFramework_Audit.bas` — procédures : `CF_AuditFail`, `CF_AuditSet`
- → `CompareFramework_ComparatorConfig.bas` — procédures : `CF_LoadComparatorConfig`
- → `CompareFramework_Comparators.bas` — procédures : `CF_TypedValuesEqual`
- → `CompareFramework_Config.bas` — procédures : `ColumnIsIgnored`, `FindIdColumn`, `IgnoreThisEmptyChange`, `LoadCompareConfig`, `NormalizeCompareValue`
- → `CompareFramework_Context.bas` — procédures : `CF_ContextSet`
- → `CompareFramework_Index.bas` — procédures : `FindRowInIndex`, `HeaderIndex`, `QuickSortIndex`
- → `CompareFramework_Report.bas` — procédures : `BuildActionPlan`, `FormatActionPlan`, `FormatAuditLog`, `FormatDashboard`, `FormatReport`, `FormatStats`, `PrepareSheet`, `WriteAuditLog`, `WriteDashboard`, `WriteGlobalSummary`, `WriteReportHeader`, `WriteReportRow`, `WriteStatsHeader`, `WriteStatsRow`
- → `CompareFramework_Rules.bas` — procédures : `LoadCompareRules`, `ReportColumnDifferences`, `ShouldIgnoreDifference`
- → `CompareFramework_Tests.bas` — procédures : `CF_CreateTestWorkbook`
- → `CompareFramework_Utils.bas` — procédures : `FindNewSheetForBase`, `IsOldSheetName`, `IsReportOrStatsSheet`, `LastUsedCol`, `LastUsedRow`, `PairBaseName`, `RowNumberText`; symboles : `CF_ACTION_SHEET`, `CF_AUDIT_SHEET`, `CF_DASHBOARD_SHEET`, `CF_FIRST_DATA_ROW`, `CF_REPORT_SHEET`, `CF_STATS_SHEET`, `CF_STATUS_ADDED`, `CF_STATUS_CHANGED`, `CF_STATUS_DUPLICATE`, `CF_STATUS_ERROR`, `CF_STATUS_REMOVED`, `CF_VERSION`

### `CompareFramework_Index.bas`
- → `CompareFramework_Report.bas` — procédures : `WriteReportRow`
- → `CompareFramework_Utils.bas` — procédures : `CellText`, `NormalizeHeader`, `RowNumberText`; symboles : `CF_FIRST_DATA_ROW`, `CF_HEADER_ROW`, `CF_STATUS_DUPLICATE`

### `CompareFramework_Main.bas`
- → `CompareFramework_Audit.bas` — procédures : `CF_AuditBegin`, `CF_AuditEnd`, `CF_AuditFail`, `CF_AuditSet`
- → `CompareFramework_ComparatorConfig.bas` — procédures : `CF_LoadComparatorConfig`, `CF_RunComparatorConfigTests`
- → `CompareFramework_Comparators.bas` — procédures : `CF_RunTypedComparatorTests`
- → `CompareFramework_Config.bas` — procédures : `FindIdColumn`, `LoadCompareConfig`
- → `CompareFramework_Context.bas` — procédures : `CF_ContextBeginRun`, `CF_ContextDumpToSheet`, `CF_ContextEndRun`, `CF_ContextGet`, `CF_ContextSet`
- → `CompareFramework_EngineMemory.bas` — procédures : `CF_CompareAllSheetsInMemory`
- → `CompareFramework_Index.bas` — procédures : `BuildIdIndex`, `FindRowInIndex`, `QuickSortIndex`, `ReadHeaders`, `ReportDuplicateIds`
- → `CompareFramework_Performance.bas` — procédures : `CF_PerfReset`, `CF_PerfStart`, `CF_PerfStop`, `CF_PerfWriteReport`
- → `CompareFramework_Quality.bas` — procédures : `CF_RunGlobalRegression`
- → `CompareFramework_Reliability.bas` — procédures : `CF_ValidateComparatorRules`
- → `CompareFramework_Report.bas` — procédures : `BuildActionPlan`, `FormatActionPlan`, `FormatAuditLog`, `FormatDashboard`, `FormatReport`, `FormatStats`, `PrepareSheet`, `WriteAuditLog`, `WriteDashboard`, `WriteGlobalSummary`, `WriteReportHeader`, `WriteReportRow`, `WriteStatsHeader`, `WriteStatsRow`
- → `CompareFramework_Rules.bas` — procédures : `CompareRowCellsDetailed`, `ReportColumnDifferences`
- → `CompareFramework_Scenarios.bas` — procédures : `CF_BuildReleaseReadiness`, `CF_RunAllBusinessScenarios`
- → `CompareFramework_Utils.bas` — procédures : `FindNewSheetForBase`, `FullRowText`, `IsOldSheetName`, `IsReportOrStatsSheet`, `LastUsedCol`, `LastUsedRow`, `PairBaseName`, `RowNumberText`; symboles : `CF_ACTION_SHEET`, `CF_AUDIT_SHEET`, `CF_DASHBOARD_SHEET`, `CF_REPORT_SHEET`, `CF_STATS_SHEET`, `CF_STATUS_ADDED`, `CF_STATUS_ERROR`, `CF_STATUS_REMOVED`, `CF_VERSION`
- → `CompareFramework_Validation.bas` — procédures : `CF_ValidateFramework`

### `CompareFramework_Performance.bas`
- → `CompareFramework_Utils.bas` — procédures : `CF_RoundCompat`, `IsReportOrStatsSheet`, `LastUsedCol`, `LastUsedRow`

### `CompareFramework_Profiles.bas`
- → `CompareFramework_Config.bas` — procédures : `EnsureConfigSheet`, `LoadCompareConfig`, `NormalizeSpaces`
- → `CompareFramework_Context.bas` — procédures : `CF_ContextBeginRun`, `CF_ContextEndRun`, `CF_ContextSet`
- → `CompareFramework_Main.bas` — procédures : `ComparerToutesLesFeuilles`
- → `CompareFramework_Utils.bas` — procédures : `CellText`, `LastUsedRow`, `SetCell`

### `CompareFramework_Quality.bas`
- → `CompareFramework_EngineMemory.bas` — procédures : `CF_RunMemoryEngineTests`
- → `CompareFramework_Main.bas` — procédures : `ComparerToutesLesFeuilles`
- → `CompareFramework_Reliability.bas` — procédures : `CF_RunMilestoneB_FinalTests`
- → `CompareFramework_Tests.bas` — procédures : `CF_RunAuditTests`, `CF_RunContextTests`, `CF_RunPerformanceTests`, `CF_RunProfileTests`, `CF_RunValidationTests`

### `CompareFramework_Reliability.bas`
- → `CompareFramework_ComparatorConfig.bas` — procédures : `CF_RunComparatorConfigTests`
- → `CompareFramework_Comparators.bas` — procédures : `CF_RunTypedComparatorTests`

### `CompareFramework_Report.bas`
- → `CompareFramework_Utils.bas` — procédures : `CellText`, `GetDocumentFolderPath`, `HtmlEscape`, `LastUsedRow`, `NormalizeHeader`, `SetCell`, `WriteTextFile`; symboles : `CF_COL_COLUMN`, `CF_COL_ID`, `CF_COL_MESSAGE`, `CF_COL_NEW_ROW`, `CF_COL_NEW_VALUE`, `CF_COL_OLD_ROW`, `CF_COL_OLD_VALUE`, `CF_COL_PAIR`, `CF_COL_TYPE`, `CF_COL_VERSION`, `CF_LAST_REPORT_COL`, `CF_STATUS_ADDED`, `CF_STATUS_CHANGED`, `CF_STATUS_DUPLICATE`, `CF_STATUS_ERROR`, `CF_STATUS_INFO`, `CF_STATUS_REMOVED`, `CF_VERSION`

### `CompareFramework_Rules.bas`
- → `CompareFramework_Config.bas` — procédures : `ColumnIsIgnored`, `IgnoreThisEmptyChange`, `NormalizeCompareValue`, `NormalizeList`, `ToBoolean`
- → `CompareFramework_Index.bas` — procédures : `HeaderIndex`
- → `CompareFramework_Report.bas` — procédures : `WriteReportRow`
- → `CompareFramework_Utils.bas` — procédures : `AbsDiff`, `CellText`, `IsNumericText`, `LastUsedRow`, `NormalizeHeader`, `RowNumberText`, `ToNumber`; symboles : `CF_RULES_SHEET`, `CF_STATUS_ADDED`, `CF_STATUS_CHANGED`, `CF_STATUS_REMOVED`

### `CompareFramework_Scenarios.bas`
- → `CompareFramework_Main.bas` — procédures : `ComparerToutesLesFeuilles`

### `CompareFramework_Tests.bas`
- → `CompareFramework_Audit.bas` — procédures : `CF_AuditBegin`, `CF_AuditDurationSeconds`, `CF_AuditEnd`, `CF_AuditGetRunId`, `CF_AuditSet`
- → `CompareFramework_Comparators.bas` — procédures : `CF_RunTypedComparatorTests`
- → `CompareFramework_Context.bas` — procédures : `CF_ContextBeginRun`, `CF_ContextEndRun`, `CF_ContextGet`, `CF_ContextHas`, `CF_ContextReset`, `CF_ContextSet`
- → `CompareFramework_EngineMemory.bas` — procédures : `CF_RunMemoryEngineTests`
- → `CompareFramework_Performance.bas` — procédures : `CF_PerfReset`, `CF_PerfStart`, `CF_PerfStop`, `CF_PerfWriteReport`, `CF_ReadSheetDataArray`
- → `CompareFramework_Profiles.bas` — procédures : `CF_EnsureProfilesSheet`; symboles : `CF_PROFILES_SHEET`
- → `CompareFramework_Utils.bas` — procédures : `CellText`, `LastUsedRow`
- → `CompareFramework_Validation.bas` — procédures : `CF_ValidateFramework`

### `CompareFramework_Validation.bas`
- → `CompareFramework_Context.bas` — procédures : `CF_ContextBeginRun`, `CF_ContextEndRun`, `CF_ContextGet`, `CF_ContextSet`
- → `CompareFramework_Main.bas` — procédures : `ComparerToutesLesFeuilles`, `FrameworkManifest`

## 5. Modules centraux

- `CompareFramework_Utils.bas` : utilisé par **12** modules, dépend de **0** modules.
- `CompareFramework_Context.bas` : utilisé par **8** modules, dépend de **0** modules.
- `CompareFramework_Config.bas` : utilisé par **6** modules, dépend de **2** modules.
- `CompareFramework_ComparatorConfig.bas` : utilisé par **5** modules, dépend de **3** modules.
- `CompareFramework_Comparators.bas` : utilisé par **5** modules, dépend de **2** modules.
- `CompareFramework_Report.bas` : utilisé par **5** modules, dépend de **1** modules.
- `CompareFramework_Main.bas` : utilisé par **4** modules, dépend de **15** modules.
- `CompareFramework_EngineMemory.bas` : utilisé par **4** modules, dépend de **10** modules.

## 6. Cycles détectés

L’analyse trouve **trois composantes fortement connexes**. Une composante fortement connexe peut contenir plusieurs cycles ; elle ne doit pas être lue comme une unique chaîne linéaire.

### 6.1 Cycle runtime : `Config ↔ Rules`

```text
Config → Rules → Config
```

- `Config → Rules` : `LoadCompareRules`
- `Rules → Config` : `ColumnIsIgnored`, `IgnoreThisEmptyChange`, `NormalizeCompareValue`, `NormalizeList`, `ToBoolean`

**Analyse :** le chargement de configuration déclenche le chargement des règles, tandis que le moteur de règles réutilise des fonctions génériques placées dans `Config`. Le cycle est réel mais de faible portée.

**Recommandation V4 :** déplacer les fonctions de normalisation génériques vers `Utils` ou un module de normalisation dédié. `Config` pourra alors dépendre de `Rules` sans dépendance inverse.

### 6.2 Cycle runtime : `Comparators ↔ ComparatorConfig`

```text
Comparators → ComparatorConfig → Comparators
```

- `Comparators → ComparatorConfig` : `CF_ResolveComparatorConfig`
- `ComparatorConfig → Comparators` : constantes `CF_TYPE_AUTO`, `CF_TYPE_CURRENCY`, `CF_TYPE_DATE`

**Analyse :** le moteur de comparaison consulte la configuration, mais la configuration dépend des constantes de type définies dans le moteur.

**Recommandation avant RC1 :** aucune modification obligatoire.

**Recommandation V4 :** déplacer les constantes `CF_TYPE_*` dans `ComparatorConfig` ou dans un petit module de contrats partagé. Le sens principal deviendrait alors `Comparators → ComparatorConfig`.

### 6.3 Composante tests, validation et orchestration

La troisième composante contient :

- `EngineMemory`
- `Main`
- `Profiles`
- `Quality`
- `Scenarios`
- `Tests`
- `Validation`

Les cycles courts les plus significatifs sont :

```text
EngineMemory → Tests → EngineMemory
Main → Quality → Main
Main → Scenarios → Main
Main → Validation → Main
```

Les dépendances responsables sont notamment :

- `EngineMemory → Tests` : `CF_CreateTestWorkbook`
- `Tests → EngineMemory` : `CF_RunMemoryEngineTests`
- `Main → Quality` : `CF_RunGlobalRegression`
- `Quality → Main` : `ComparerToutesLesFeuilles`
- `Main → Scenarios` : `CF_RunAllBusinessScenarios`, `CF_BuildReleaseReadiness`
- `Scenarios → Main` : `ComparerToutesLesFeuilles`
- `Main → Validation` : `CF_ValidateFramework`
- `Validation → Main` : `ComparerToutesLesFeuilles`, `FrameworkManifest`

**Analyse :** cette composante mélange le runtime, les points d’entrée, les scénarios de démonstration et l’infrastructure de qualification. Elle n’indique pas nécessairement un défaut du moteur de comparaison, mais elle empêche une séparation nette entre code de production et code de test.

**Recommandation avant RC1 :** ne pas refactorer ; documenter que `CF_CreateTestWorkbook` est une dépendance de test utilisée par `EngineMemory`.

**Recommandation V4 :**

1. déplacer les fabriques de jeux de test hors de `CompareFramework_Tests.bas` vers un module sans dépendance vers le moteur ;
2. sortir les lanceurs de validation et de qualité de `Main` ;
3. faire dépendre les scénarios et validations d’une façade runtime stable, sans dépendance inverse ;
4. séparer explicitement les modules runtime des modules de qualification.

## 7. API publique et symboles globaux

Le dépôt expose **198 procédures publiques**. En Basic, l’absence explicite de `Private` rend aussi les procédures publiques par défaut. Cette surface est importante et doit être revue lors de RC-04.

Aucun nom de procédure dupliqué entre modules.

### Procédures publiques sans appel statique interne

Ces procédures peuvent être des points d’entrée légitimes (macros utilisateur, tests ou API), mais elles devront être classées lors de RC-04 :

- `CF_BuildReferencePlan` — `Modes/CF_ModeReference.bas:267`
- `CF_OpenReferenceLauncher` — `Modes/CF_ModeReference.bas:527`
- `CF_ReferenceBuildSummary` — `Modes/CF_ModeReference.bas:405`
- `CF_ReferenceFormatPlan` — `Modes/CF_ModeReference.bas:385`
- `CF_ReferenceFormatSummary` — `Modes/CF_ModeReference.bas:507`
- `CF_ReferenceIsTargetSheet` — `Modes/CF_ModeReference.bas:305`
- `CF_ReferencePlanSetStatus` — `Modes/CF_ModeReference.bas:361`
- `CF_ReferenceSheetHasKey` — `Modes/CF_ModeReference.bas:343`
- `CF_RunAgainstReference` — `Modes/CF_ModeReference.bas:47`
- `CF_RunAgainstReference_MODELE` — `Modes/CF_ModeReference.bas:43`
- `CF_RunFromLauncher` — `Modes/CF_ModeReference.bas:595`
- `CF_RunLauncherQuick` — `Modes/CF_ModeReference.bas:645`
- `CF_RunReferenceMode` — `Modes/CF_ModeReference.bas:22`
- `CF_AuditClearHistory` — `CompareFramework_Audit.bas:154`
- `CF_AuditWriteCurrentRun` — `CompareFramework_Audit.bas:123`
- `CF_EnsureComparatorsSheet` — `CompareFramework_ComparatorConfig.bas:18`
- `CF_OpenComparatorConfig` — `CompareFramework_ComparatorConfig.bas:129`
- `CF_ReloadComparatorConfig` — `CompareFramework_ComparatorConfig.bas:123`
- `CF_WriteDefaultComparatorConfig` — `CompareFramework_ComparatorConfig.bas:32`
- `CF_BooleanCode` — `CompareFramework_Comparators.bas:184`
- `CF_BooleanEqual` — `CompareFramework_Comparators.bas:113`
- `CF_ComparatorTypeForHeader` — `CompareFramework_Comparators.bas:58`
- `CF_CurrencyToNumber` — `CompareFramework_Comparators.bas:208`
- `CF_DateEqual` — `CompareFramework_Comparators.bas:101`
- `CF_GetCurrencyTolerance` — `CompareFramework_Comparators.bas:221`
- `CF_GetDateToleranceDays` — `CompareFramework_Comparators.bas:225`
- `CF_GetNumericTolerance` — `CompareFramework_Comparators.bas:213`
- `CF_GetPercentTolerance` — `CompareFramework_Comparators.bas:217`
- `CF_LooksBoolean` — `CompareFramework_Comparators.bas:134`
- `CF_LooksDate` — `CompareFramework_Comparators.bas:126`
- `CF_LooksNumeric` — `CompareFramework_Comparators.bas:121`
- `CF_NumberEqual` — `CompareFramework_Comparators.bas:89`
- `CF_PercentToNumber` — `CompareFramework_Comparators.bas:197`
- `CF_TextEqual` — `CompareFramework_Comparators.bas:81`
- `CF_TryParseDateSerial` — `CompareFramework_Comparators.bas:168`
- `CF_TryParseNumber` — `CompareFramework_Comparators.bas:138`
- `EnsureRulesSheet` — `CompareFramework_Config.bas:88`
- `TokenInList` — `CompareFramework_Config.bas:184`
- `WriteDefaultConfig` — `CompareFramework_Config.bas:55`
- `WriteDefaultRulesSheet` — `CompareFramework_Config.bas:103`
- `CF_ContextCount` — `CompareFramework_Context.bas:86`
- `CF_ContextInitIfNeeded` — `CompareFramework_Context.bas:34`
- `CF_BuildMemoryIdIndex` — `CompareFramework_EngineMemory.bas:231`
- `CF_CompareDetectedPairsMemory` — `CompareFramework_EngineMemory.bas:80`
- `CF_CompareFallbackMemory` — `CompareFramework_EngineMemory.bas:105`
- `CF_CompareMemoryRows` — `CompareFramework_EngineMemory.bas:262`
- `CF_MemoryFullRow` — `CompareFramework_EngineMemory.bas:301`
- `CF_MemoryValueText` — `CompareFramework_EngineMemory.bas:335`
- `CF_ReportMemoryDuplicates` — `CompareFramework_EngineMemory.bas:316`
- `CF_RunAudited` — `CompareFramework_Main.bas:257`
- `CF_RunMilestoneA` — `CompareFramework_Main.bas:55`
- `CF_RunMilestoneB` — `CompareFramework_Main.bas:338`
- `CF_RunMilestoneB_ConfigTests` — `CompareFramework_Main.bas:380`
- `CF_RunMilestoneB_Configured` — `CompareFramework_Main.bas:359`
- `CF_RunMilestoneB_Final` — `CompareFramework_Main.bas:390`
- `CF_RunMilestoneC` — `CompareFramework_Main.bas:419`
- `CF_RunMilestoneC_Final` — `CompareFramework_Main.bas:444`
- `CF_RunPerformanceProfiled` — `CompareFramework_Main.bas:299`
- `CompareDetectedPairs` — `CompareFramework_Main.bas:71`
- `CompareFallbackTwoSheets` — `CompareFramework_Main.bas:97`
- `CompareSheetPair` — `CompareFramework_Main.bas:125`
- `ComparerToutesLesFeuilles_Contextualisee` — `CompareFramework_Main.bas:226`
- `ComparerToutesLesFeuilles_Legacy` — `CompareFramework_Main.bas:5`
- `DiagnosticFramework` — `CompareFramework_Main.bas:215`
- `DiagnosticFramework_Contextualise` — `CompareFramework_Main.bas:244`
- `GetFrameworkVersion` — `CompareFramework_Main.bas:211`
- `CF_PerfRecordPair` — `CompareFramework_Performance.bas:62`
- `CF_RunPerformanceBenchmark` — `CompareFramework_Performance.bas:137`
- `CF_ApplyProfile` — `CompareFramework_Profiles.bas:51`
- `CF_ListProfiles` — `CompareFramework_Profiles.bas:117`
- `CF_RunWithProfile` — `CompareFramework_Profiles.bas:123`
- `CF_SaveCurrentConfigAsProfile` — `CompareFramework_Profiles.bas:84`
- `CF_WriteDefaultProfiles` — `CompareFramework_Profiles.bas:30`
- `CF_BuildQualityDashboard` — `CompareFramework_Quality.bas:149`
- `CF_RunEndToEndScenario` — `CompareFramework_Quality.bas:20`
- `CF_ValidateExpectedReport` — `CompareFramework_Quality.bas:38`
- `CF_BuildComparatorCoverageReport` — `CompareFramework_Reliability.bas:152`
- `CF_RunTypedRegressionSuite` — `CompareFramework_Reliability.bas:17`
- `ActionPriority` — `CompareFramework_Report.bas:221`
- `ActionRecommendation` — `CompareFramework_Report.bas:242`
- `ApplyOptionalAutoFilter` — `CompareFramework_Report.bas:401`
- `BuildHtmlReport` — `CompareFramework_Report.bas:441`
- `ExporterRapportHTML` — `CompareFramework_Report.bas:414`
- `HtmlCssClassForCell` — `CompareFramework_Report.bas:596`
- `HtmlScriptBlock` — `CompareFramework_Report.bas:522`
- `HtmlStyleBlock` — `CompareFramework_Report.bas:489`
- `IsActionableStatus` — `CompareFramework_Report.bas:217`
- `SheetToHtmlSection` — `CompareFramework_Report.bas:533`
- `SheetToHtmlTableOnly` — `CompareFramework_Report.bas:550`
- `WriteActionHeader` — `CompareFramework_Report.bas:204`
- `EvaluateDifferenceRule` — `CompareFramework_Rules.bas:79`
- `RuleAppliesToColumn` — `CompareFramework_Rules.bas:67`
- `RuleAppliesToScope` — `CompareFramework_Rules.bas:73`
- `ValuesAreEquivalentByList` — `CompareFramework_Rules.bas:103`
- `ValuesAreWithinNumericTolerance` — `CompareFramework_Rules.bas:114`
- `CF_RunERPScenario` — `CompareFramework_Scenarios.bas:83`
- `CF_RunFinanceScenario` — `CompareFramework_Scenarios.bas:44`
- `CF_RunHRScenario` — `CompareFramework_Scenarios.bas:64`
- `CF_RunAllTests` — `CompareFramework_Tests.bas:42`
- `CF_RunMilestoneBTests` — `CompareFramework_Tests.bas:482`
- `EndsWith` — `CompareFramework_Utils.bas:158`
- `CF_PreflightComparison` — `CompareFramework_Validation.bas:71`
- `CF_RunValidated` — `CompareFramework_Validation.bas:80`
- `CF_ValidateActiveProfile` — `CompareFramework_Validation.bas:40`

## 8. Constats architecturaux

### 8.1 `Utils` est une fondation globale

`CompareFramework_Utils.bas` est utilisé par **12 modules**. Il contient des constantes transversales et des fonctions utilitaires. Cette centralité est cohérente, mais toute dépendance inverse de `Utils` vers les couches métier doit être évitée.

### 8.2 Version codée en dur

La constante suivante est toujours présente :

```basic
Public Const CF_VERSION As String = "3.5.1"
```

Elle contredit la politique RC-00 fondée sur le fichier `VERSION`. LibreOffice Basic ne pouvant pas lire une constante au moment de la compilation, le build doit injecter ou générer cette valeur dans le monolithe, ou un module de version généré doit être introduit.

### 8.3 Mode Référence

`CF_ModeReference.bas` dépend de **9 modules** et est utilisé par **0 modules**. Sa taille et son nombre de dépendances confirment qu’il cumule orchestration, interface, validation et synthèse. Aucun découpage n’est recommandé avant RC1 ; il devient une priorité V4.

### 8.4 Rapport

`CompareFramework_Report.bas` dépend de **1 modules** et est utilisé par **5 modules**. Ses responsabilités couvrent la génération des feuilles, le formatage et l’export HTML. La séparation de l’export HTML est le découpage futur le moins risqué.

### 8.5 Tests et validation

Les modules de tests, scénarios, qualité, fiabilité et validation peuvent former des dépendances réciproques sans affecter le moteur en production. Ils doivent néanmoins être distingués des dépendances du runtime lors de RC-04 et dans la documentation développeur.

## 9. Recommandations

### Avant RC1

1. Corriger la divergence `CF_VERSION = "3.5.1"` dans le cadre de RC-00.
2. Ne pas entreprendre de refactoring structurel des modules qualifiés.
3. Vérifier manuellement les cycles détectés lorsqu’ils concernent le runtime et non uniquement les tests.
4. Définir lors de RC-04 la liste officielle des macros publiques destinées aux utilisateurs.
5. Ajouter l’analyse des dépendances au contrôle de release, au minimum sous forme de rapport reproductible.

### Pour CompareFramework 4

1. Séparer `CF_ModeReference` en lanceur, plan, exécution, synthèse et validation.
2. Extraire l’export HTML de `CompareFramework_Report`.
3. Séparer les modules de tests des couches runtime.
4. Réduire la surface publique en déclarant `Private` les helpers internes.
5. Introduire une couche de version générée depuis `VERSION`.

## 10. Décision RC-03

**FAVORABLE AVEC RÉSERVES.**

L’architecture actuelle est exploitable pour la RC1. Les dépendances observées ne justifient pas un refactoring tardif. Les réserves portent principalement sur la surface publique, la centralité du Mode Référence, le mélange des responsabilités du rapport et la version codée en dur.

Les corrections à faible risque doivent être réalisées avant RC1 ; les découpages structurels sont reportés à CompareFramework 4.
