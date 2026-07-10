' CompareFramework V3.5 - Main
' Orchestration et API publique.
Option Explicit

Public Sub ComparerToutesLesFeuilles_Legacy()
    Dim oDoc As Object, oReport As Object, oStats As Object, oDash As Object, oAction As Object, oAudit As Object
    Dim reportRow As Long, statsRow As Long, pairCount As Long
    Dim totalAdded As Long, totalRemoved As Long, totalChangedRows As Long
    Dim totalChangedCells As Long, totalDuplicates As Long, totalIssues As Long

    oDoc = ThisComponent

    oReport = PrepareSheet(oDoc, CF_REPORT_SHEET)
    oStats = PrepareSheet(oDoc, CF_STATS_SHEET)
    oDash = PrepareSheet(oDoc, CF_DASHBOARD_SHEET)
    oAction = PrepareSheet(oDoc, CF_ACTION_SHEET)
    oAudit = PrepareSheet(oDoc, CF_AUDIT_SHEET)
    LoadCompareConfig oDoc

    reportRow = 0
    statsRow = 0
    WriteReportHeader oReport, reportRow
    WriteStatsHeader oStats, statsRow
    reportRow = reportRow + 1
    statsRow = statsRow + 1

    pairCount = CompareDetectedPairs(oDoc, oReport, reportRow, oStats, statsRow, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues)

    If pairCount = 0 Then
        pairCount = CompareFallbackTwoSheets(oDoc, oReport, reportRow, oStats, statsRow, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues)
    End If

    WriteGlobalSummary oStats, statsRow, pairCount, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues
    WriteDashboard oDash, pairCount, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues
    BuildActionPlan oReport, oAction, reportRow - 1
    WriteAuditLog oAudit, pairCount, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues, reportRow - 1
    FormatReport oReport, reportRow - 1
    FormatStats oStats, statsRow + 8
    FormatDashboard oDash
    FormatActionPlan oAction
    FormatAuditLog oAudit

    MsgBox "Comparaison terminee." & Chr(10) & _
           "Paires comparees : " & pairCount & Chr(10) & _
           "Lignes ajoutees : " & totalAdded & Chr(10) & _
           "Lignes supprimees : " & totalRemoved & Chr(10) & _
           "Lignes modifiees : " & totalChangedRows & Chr(10) & _
           "Cellules modifiees : " & totalChangedCells, 64, "CompareFramework V" & CF_VERSION
End Sub

Public Sub ComparerToutesLesFeuilles()
    CF_CompareAllSheetsInMemory
End Sub

Public Sub CF_RunMilestoneA()
    On Error GoTo ErrHandler
    CF_AuditBegin "MilestoneA-V3.0"
    CF_ContextBeginRun "MilestoneA-V3.0"
    CF_AuditSet "Engine", "MEMORY"
    CF_CompareAllSheetsInMemory
    CF_AuditEnd "DONE"
    CF_ContextEndRun "DONE"
    Exit Sub
ErrHandler:
    CF_AuditFail Err, Error$
    CF_AuditEnd "ERROR"
    CF_ContextEndRun "ERROR"
    MsgBox "Erreur Jalon A : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
End Sub

Public Function CompareDetectedPairs(oDoc As Object, oReport As Object, ByRef reportRow As Long, oStats As Object, ByRef statsRow As Long, ByRef totalAdded As Long, ByRef totalRemoved As Long, ByRef totalChangedRows As Long, ByRef totalChangedCells As Long, ByRef totalDuplicates As Long, ByRef totalIssues As Long) As Long
    Dim oSheets As Object, names As Variant
    Dim i As Long, sheetName As String, baseName As String, newName As String
    Dim count As Long

    oSheets = oDoc.Sheets
    names = oSheets.getElementNames()
    count = 0

    For i = LBound(names) To UBound(names)
        sheetName = CStr(names(i))
        If IsReportOrStatsSheet(sheetName) = False Then
            baseName = PairBaseName(sheetName)
            If baseName <> "" And IsOldSheetName(sheetName) Then
                newName = FindNewSheetForBase(oSheets, baseName)
                If newName <> "" Then
                    CompareSheetPair oSheets.getByName(sheetName), oSheets.getByName(newName), oReport, reportRow, oStats, statsRow, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues
                    count = count + 1
                End If
            End If
        End If
    Next i

    CompareDetectedPairs = count
End Function

Public Function CompareFallbackTwoSheets(oDoc As Object, oReport As Object, ByRef reportRow As Long, oStats As Object, ByRef statsRow As Long, ByRef totalAdded As Long, ByRef totalRemoved As Long, ByRef totalChangedRows As Long, ByRef totalChangedCells As Long, ByRef totalDuplicates As Long, ByRef totalIssues As Long) As Long
    Dim oSheets As Object, names() As String, allNames As Variant
    Dim i As Long, n As Long, sheetName As String

    oSheets = oDoc.Sheets
    allNames = oSheets.getElementNames()
    ReDim names(1)
    n = 0

    For i = LBound(allNames) To UBound(allNames)
        sheetName = CStr(allNames(i))
        If IsReportOrStatsSheet(sheetName) = False Then
            If n <= 1 Then names(n) = sheetName
            n = n + 1
        End If
    Next i

    If n = 2 Then
        CompareSheetPair oSheets.getByName(names(0)), oSheets.getByName(names(1)), oReport, reportRow, oStats, statsRow, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues
        CompareFallbackTwoSheets = 1
    Else
        WriteReportRow oReport, reportRow, "SYSTEME", "", CF_STATUS_ERROR, "", "", "", "", "", "Aucune paire detectee. Utiliser _OLD/_NEW, _REF/_NEW ou _AVANT/_APRES."
        reportRow = reportRow + 1
        totalIssues = totalIssues + 1
        CompareFallbackTwoSheets = 0
    End If
End Function

Public Sub CompareSheetPair(oOld As Object, oNew As Object, oReport As Object, ByRef reportRow As Long, oStats As Object, ByRef statsRow As Long, ByRef totalAdded As Long, ByRef totalRemoved As Long, ByRef totalChangedRows As Long, ByRef totalChangedCells As Long, ByRef totalDuplicates As Long, ByRef totalIssues As Long)
    Dim oldHeaders As Variant, newHeaders As Variant
    Dim oldIdCol As Long, newIdCol As Long
    Dim oldLastRow As Long, newLastRow As Long, oldLastCol As Long, newLastCol As Long
    Dim oldIds As Variant, oldRows As Variant, newIds As Variant, newRows As Variant
    Dim oldCount As Long, newCount As Long
    Dim i As Long, foundRow As Long, idValue As String, pairName As String
    Dim pairAdded As Long, pairRemoved As Long, pairChangedRows As Long
    Dim pairChangedCells As Long, pairDuplicates As Long, pairIssues As Long
    Dim changedInRow As Long

    pairName = oOld.Name & " -> " & oNew.Name

    oldLastRow = LastUsedRow(oOld)
    newLastRow = LastUsedRow(oNew)
    oldLastCol = LastUsedCol(oOld)
    newLastCol = LastUsedCol(oNew)

    oldHeaders = ReadHeaders(oOld, oldLastCol)
    newHeaders = ReadHeaders(oNew, newLastCol)

    oldIdCol = FindIdColumn(oldHeaders)
    newIdCol = FindIdColumn(newHeaders)

    If oldIdCol < 0 Or newIdCol < 0 Then
        WriteReportRow oReport, reportRow, pairName, "", CF_STATUS_ERROR, "ID", "", "", "", "", "Colonne ID introuvable. Verifier ID_ALIASES dans Compare_Config."
        reportRow = reportRow + 1
        pairIssues = pairIssues + 1
        totalIssues = totalIssues + 1
        WriteStatsRow oStats, statsRow, pairName, 0, 0, 0, 0, 0, 0, pairIssues
        statsRow = statsRow + 1
        Exit Sub
    End If

    BuildIdIndex oOld, oldIdCol, oldLastRow, oldIds, oldRows, oldCount
    BuildIdIndex oNew, newIdCol, newLastRow, newIds, newRows, newCount

    If oldCount > 1 Then QuickSortIndex oldIds, oldRows, 0, oldCount - 1
    If newCount > 1 Then QuickSortIndex newIds, newRows, 0, newCount - 1

    pairDuplicates = ReportDuplicateIds(oldIds, oldRows, oldCount, oReport, reportRow, pairName, "ANCIENNE")
    pairDuplicates = pairDuplicates + ReportDuplicateIds(newIds, newRows, newCount, oReport, reportRow, pairName, "NOUVELLE")

    ReportColumnDifferences oldHeaders, newHeaders, oReport, reportRow, pairName, pairIssues

    For i = 0 To oldCount - 1
        idValue = CStr(oldIds(i))
        foundRow = FindRowInIndex(newIds, newRows, newCount, idValue)
        If foundRow < 0 Then
            WriteReportRow oReport, reportRow, pairName, idValue, CF_STATUS_REMOVED, "LIGNE", RowNumberText(oldRows(i)), "", FullRowText(oOld, oldHeaders, CLng(oldRows(i))), "", "Ligne presente dans l'ancienne feuille uniquement."
            reportRow = reportRow + 1
            pairRemoved = pairRemoved + 1
        Else
            changedInRow = CompareRowCellsDetailed(oOld, oNew, oldHeaders, newHeaders, CLng(oldRows(i)), foundRow, idValue, pairName, oReport, reportRow)
            If changedInRow > 0 Then
                pairChangedRows = pairChangedRows + 1
                pairChangedCells = pairChangedCells + changedInRow
            End If
        End If
    Next i

    For i = 0 To newCount - 1
        idValue = CStr(newIds(i))
        foundRow = FindRowInIndex(oldIds, oldRows, oldCount, idValue)
        If foundRow < 0 Then
            WriteReportRow oReport, reportRow, pairName, idValue, CF_STATUS_ADDED, "LIGNE", "", RowNumberText(newRows(i)), "", FullRowText(oNew, newHeaders, CLng(newRows(i))), "Ligne presente dans la nouvelle feuille uniquement."
            reportRow = reportRow + 1
            pairAdded = pairAdded + 1
        End If
    Next i

    WriteStatsRow oStats, statsRow, pairName, pairAdded, pairRemoved, pairChangedRows, pairChangedCells, pairDuplicates, oldCount, newCount, pairIssues
    statsRow = statsRow + 1

    totalAdded = totalAdded + pairAdded
    totalRemoved = totalRemoved + pairRemoved
    totalChangedRows = totalChangedRows + pairChangedRows
    totalChangedCells = totalChangedCells + pairChangedCells
    totalDuplicates = totalDuplicates + pairDuplicates
    totalIssues = totalIssues + pairIssues
End Sub

Public Function FrameworkManifest() As String
    FrameworkManifest = "Main,Context,Audit,Profiles,Config,Index,Rules,EngineMemory,Report,Validation,Performance,Tests,Utils"
End Function

Public Function GetFrameworkVersion() As String
    GetFrameworkVersion = CF_VERSION
End Function

Public Sub DiagnosticFramework()
    MsgBox "CompareFramework V3.5" & Chr(10) & _
           "Modules: " & FrameworkManifest(), 64, "Diagnostic"
End Sub



'=========================================================
' V2.5 - Context-aware wrappers
'=========================================================

Public Sub ComparerToutesLesFeuilles_Contextualisee()
    On Error GoTo ErrHandler

    CF_ContextBeginRun "ComparerToutesLesFeuilles"
    CF_ContextSet "EntryPoint", "ComparerToutesLesFeuilles_Contextualisee"

    ComparerToutesLesFeuilles

    CF_ContextEndRun "DONE"
    Exit Sub

ErrHandler:
    CF_ContextSet "ErrorNumber", CStr(Err)
    CF_ContextSet "ErrorMessage", Error$
    CF_ContextEndRun "ERROR"
    MsgBox "Erreur comparaison contextualisée : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
End Sub

Public Sub DiagnosticFramework_Contextualise()
    CF_ContextBeginRun "DiagnosticFramework"
    CF_ContextSet "Modules", FrameworkManifest()
    CF_ContextSet "Version", GetFrameworkVersion()
    CF_ContextEndRun "DONE"
    CF_ContextDumpToSheet
End Sub


'=========================================================
' V2.8 - Audited entry point
'=========================================================

Public Sub CF_RunAudited()
    On Error GoTo ErrHandler

    CF_AuditBegin "CF_RunAudited"
    CF_ContextBeginRun "CF_RunAudited"

    CF_AuditSet "FrameworkVersion", GetFrameworkVersion()
    CF_AuditSet "ValidationEnabled", "TRUE"

    If Not CF_ValidateFramework(False) Then
        CF_AuditSet "ValidationResult", "FAILED"
        CF_AuditEnd "VALIDATION_FAILED"
        CF_ContextEndRun "VALIDATION_FAILED"
        MsgBox "Validation échouée. Consulte la feuille Compare_Validation.", 48, "CompareFramework V3.5"
        Exit Sub
    End If

    CF_AuditSet "ValidationResult", "OK"

    ComparerToutesLesFeuilles

    CF_AuditSet "ComparisonResult", "DONE"
    CF_AuditEnd "DONE"
    CF_ContextEndRun "DONE"
    Exit Sub

ErrHandler:
    CF_AuditFail Err, Error$
    CF_AuditEnd "ERROR"

    On Error Resume Next
    CF_ContextSet "ErrorNumber", CStr(Err)
    CF_ContextSet "ErrorMessage", Error$
    CF_ContextEndRun "ERROR"

    MsgBox "Erreur CF_RunAudited : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
End Sub


'=========================================================
' V2.9 - Performance-profiled entry point
'=========================================================
Public Sub CF_RunPerformanceProfiled()
    On Error GoTo ErrHandler
    CF_PerfReset
    CF_PerfStart "Total"
    CF_AuditBegin "CF_RunPerformanceProfiled"
    CF_ContextBeginRun "CF_RunPerformanceProfiled"

    CF_PerfStart "Validation"
    If Not CF_ValidateFramework(False) Then
        CF_PerfStop "Validation"
        CF_PerfStop "Total"
        CF_PerfWriteReport
        CF_AuditEnd "VALIDATION_FAILED"
        CF_ContextEndRun "VALIDATION_FAILED"
        MsgBox "Validation échouée. Consulte Compare_Validation.", 48, "CompareFramework V3.5"
        Exit Sub
    End If
    CF_PerfStop "Validation"

    CF_PerfStart "Comparaison"
    ComparerToutesLesFeuilles
    CF_PerfStop "Comparaison"
    CF_PerfStop "Total"
    CF_PerfWriteReport

    CF_AuditSet "PerformanceReport", "Compare_Performance"
    CF_AuditEnd "DONE"
    CF_ContextEndRun "DONE"
    Exit Sub
ErrHandler:
    CF_PerfStop "Total"
    CF_PerfWriteReport
    CF_AuditFail Err, Error$
    CF_AuditEnd "ERROR"
    CF_ContextEndRun "ERROR"
    MsgBox "Erreur CF_RunPerformanceProfiled : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
End Sub


Public Sub CF_RunMilestoneB()
    On Error GoTo ErrHandler
    CF_AuditBegin "JalonB_V3.1"
    CF_ContextBeginRun "JalonB_V3.1"
    CF_AuditSet "Engine", "MEMORY_TYPED"
    CF_CompareAllSheetsInMemory
    CF_AuditEnd "DONE"
    CF_ContextEndRun "DONE"
    Exit Sub
ErrHandler:
    CF_AuditFail Err, Error$
    CF_AuditEnd "ERROR"
    CF_ContextEndRun "ERROR"
    MsgBox "Erreur Jalon B : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
End Sub


'=========================================================
' V3.2 - Jalon B configurable comparators
'=========================================================

Public Sub CF_RunMilestoneB_Configured()
    On Error GoTo ErrHandler

    CF_AuditBegin "JalonB_V3.2"
    CF_ContextBeginRun "JalonB_V3.2"
    CF_LoadComparatorConfig ThisComponent
    CF_AuditSet "ComparatorRules", CF_ContextGet("ComparatorConfigRows", "0")

    CF_CompareAllSheetsInMemory

    CF_AuditEnd "DONE"
    CF_ContextEndRun "DONE"
    Exit Sub

ErrHandler:
    CF_AuditFail Err, Error$
    CF_AuditEnd "ERROR"
    CF_ContextEndRun "ERROR"
    MsgBox "Erreur CF_RunMilestoneB_Configured : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
End Sub

Public Sub CF_RunMilestoneB_ConfigTests()
    CF_RunTypedComparatorTests
    CF_RunComparatorConfigTests
End Sub


'=========================================================
' V3.3 - Jalon B final entry point
'=========================================================

Public Sub CF_RunMilestoneB_Final()
    On Error GoTo ErrHandler

    CF_AuditBegin "CF_RunMilestoneB_Final"
    CF_ContextBeginRun "CF_RunMilestoneB_Final"

    CF_ValidateComparatorRules
    CF_RunMilestoneB_Configured

    CF_AuditSet "Milestone", "B"
    CF_AuditSet "TypedComparators", "ENABLED"
    CF_AuditSet "ComparatorConfiguration", "ENABLED"
    CF_AuditSet "RegressionSuite", "AVAILABLE"
    CF_AuditEnd "DONE"
    CF_ContextEndRun "DONE"
    Exit Sub

ErrHandler:
    CF_AuditFail Err, Error$
    CF_AuditEnd "ERROR"
    CF_ContextEndRun "ERROR"
    MsgBox "Erreur CF_RunMilestoneB_Final : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
End Sub


'=========================================================
' V3.4 - Milestone C entry point
'=========================================================

Public Sub CF_RunMilestoneC()
    On Error GoTo ErrHandler

    CF_AuditBegin "CF_RunMilestoneC"
    CF_ContextBeginRun "CF_RunMilestoneC"

    CF_RunGlobalRegression
    CF_AuditSet "Milestone", "C"
    CF_AuditSet "QualitySuite", "ENABLED"
    CF_AuditEnd "DONE"
    CF_ContextEndRun "DONE"
    Exit Sub

ErrHandler:
    CF_AuditFail Err, Error$
    CF_AuditEnd "ERROR"
    CF_ContextEndRun "ERROR"
    MsgBox "Erreur CF_RunMilestoneC : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
End Sub


'=========================================================
' V3.5 - Milestone C final entry point
'=========================================================

Public Sub CF_RunMilestoneC_Final()
    On Error GoTo ErrHandler

    CF_AuditBegin "CF_RunMilestoneC_Final"
    CF_ContextBeginRun "CF_RunMilestoneC_Final"

    CF_RunGlobalRegression
    CF_RunAllBusinessScenarios
    CF_BuildReleaseReadiness

    CF_AuditSet "Milestone", "C"
    CF_AuditSet "BusinessScenarios", "FINANCE,RH,ERP"
    CF_AuditSet "ReleaseReadiness", "AVAILABLE"
    CF_AuditEnd "DONE"
    CF_ContextEndRun "DONE"
    Exit Sub

ErrHandler:
    CF_AuditFail Err, Error$
    CF_AuditEnd "ERROR"
    CF_ContextEndRun "ERROR"
    MsgBox "Erreur CF_RunMilestoneC_Final : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
End Sub
