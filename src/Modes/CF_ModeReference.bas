Option Explicit

'=========================================================
' CompareFramework V3.7.0-D1
' Mode Reference unique -> N feuilles cibles
'=========================================================
'
' Public API:
'   CF_RunAgainstReference(referenceSheetName, keyColumnName)
'   CF_RunReferenceMode()
'   CF_RunAgainstReference_MODELE()
'
' Feuille de plan:
'   Compare_Reference_Plan
'=========================================================

Public Const CF_REFERENCE_PLAN_SHEET As String = "Compare_Reference_Plan"

Public Sub CF_RunReferenceMode()
    Dim referenceName As String
    Dim keyColumnName As String

    referenceName = InputBox( _
        "Nom de la feuille de référence :", _
        "CompareFramework - Mode référence", _
        "MODELE")

    If Trim(referenceName) = "" Then Exit Sub

    keyColumnName = InputBox( _
        "Nom exact de la colonne identifiant :", _
        "CompareFramework - Mode référence", _
        "ref_scat_abs")

    If Trim(keyColumnName) = "" Then Exit Sub

    CF_RunAgainstReference referenceName, keyColumnName
End Sub

Public Sub CF_RunAgainstReference_MODELE()
    CF_RunAgainstReference "MODELE", "ref_scat_abs"
End Sub

Public Sub CF_RunAgainstReference(referenceSheetName As String, keyColumnName As String)
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oSheets As Object
    Dim oReference As Object
    Dim oReport As Object
    Dim oStats As Object
    Dim oDash As Object
    Dim oAction As Object
    Dim oAudit As Object
    Dim names As Variant
    Dim i As Long
    Dim targetName As String
    Dim reportRow As Long
    Dim statsRow As Long
    Dim targetCount As Long
    Dim totalAdded As Long
    Dim totalRemoved As Long
    Dim totalChangedRows As Long
    Dim totalChangedCells As Long
    Dim totalDuplicates As Long
    Dim totalIssues As Long
    Dim previousAliases As String

    referenceSheetName = Trim(CStr(referenceSheetName))
    keyColumnName = Trim(CStr(keyColumnName))

    If referenceSheetName = "" Then
        MsgBox "Le nom de la feuille de référence est obligatoire.", 48, "CompareFramework D1"
        Exit Sub
    End If

    If keyColumnName = "" Then
        MsgBox "Le nom de la colonne identifiant est obligatoire.", 48, "CompareFramework D1"
        Exit Sub
    End If

    oDoc = ThisComponent
    oSheets = oDoc.Sheets

    If Not oSheets.hasByName(referenceSheetName) Then
        MsgBox "Feuille de référence introuvable : " & referenceSheetName, 16, "CompareFramework D1"
        Exit Sub
    End If

    oReference = oSheets.getByName(referenceSheetName)

    LoadCompareConfig oDoc
    LoadCompareRules oDoc
    CF_LoadComparatorConfig oDoc

    previousAliases = gIdAliases
    gIdAliases = NormalizeList(keyColumnName)

    If Not CF_ReferenceSheetHasKey(oReference, keyColumnName) Then
        gIdAliases = previousAliases
        MsgBox "La colonne identifiant '" & keyColumnName & _
               "' est absente de la feuille " & referenceSheetName & ".", _
               16, "CompareFramework D1"
        Exit Sub
    End If

    CF_BuildReferencePlan referenceSheetName, keyColumnName

    oReport = PrepareSheet(oDoc, CF_REPORT_SHEET)
    oStats = PrepareSheet(oDoc, CF_STATS_SHEET)
    oDash = PrepareSheet(oDoc, CF_DASHBOARD_SHEET)
    oAction = PrepareSheet(oDoc, CF_ACTION_SHEET)
    oAudit = PrepareSheet(oDoc, CF_AUDIT_SHEET)

    reportRow = 0
    statsRow = 0
    WriteReportHeader oReport, reportRow
    WriteStatsHeader oStats, statsRow
    reportRow = reportRow + 1
    statsRow = statsRow + 1

    names = oSheets.getElementNames()

    For i = LBound(names) To UBound(names)
        targetName = CStr(names(i))

        If CF_ReferenceIsTargetSheet(targetName, referenceSheetName) Then
            If CF_ReferenceSheetHasKey(oSheets.getByName(targetName), keyColumnName) Then
                CF_CompareSheetPairMemory _
                    oReference, _
                    oSheets.getByName(targetName), _
                    oReport, _
                    reportRow, _
                    oStats, _
                    statsRow, _
                    totalAdded, _
                    totalRemoved, _
                    totalChangedRows, _
                    totalChangedCells, _
                    totalDuplicates, _
                    totalIssues

                targetCount = targetCount + 1
                CF_ReferencePlanSetStatus targetName, "COMPAREE", ""
            Else
                WriteReportRow _
                    oReport, _
                    reportRow, _
                    referenceSheetName & " -> " & targetName, _
                    "", _
                    CF_STATUS_ERROR, _
                    keyColumnName, _
                    "", _
                    "", _
                    "", _
                    "", _
                    "Colonne identifiant absente de la feuille cible."

                reportRow = reportRow + 1
                totalIssues = totalIssues + 1
                CF_ReferencePlanSetStatus targetName, "IGNOREE", _
                    "Colonne identifiant absente"
            End If
        End If
    Next i

    If targetCount = 0 Then
        WriteReportRow _
            oReport, _
            reportRow, _
            referenceSheetName, _
            "", _
            CF_STATUS_ERROR, _
            "", _
            "", _
            "", _
            "", _
            "", _
            "Aucune feuille cible éligible avec la colonne " & keyColumnName & "."

        reportRow = reportRow + 1
        totalIssues = totalIssues + 1
    End If

    WriteGlobalSummary _
        oStats, _
        statsRow, _
        targetCount, _
        totalAdded, _
        totalRemoved, _
        totalChangedRows, _
        totalChangedCells, _
        totalDuplicates, _
        totalIssues

    WriteDashboard _
        oDash, _
        targetCount, _
        totalAdded, _
        totalRemoved, _
        totalChangedRows, _
        totalChangedCells, _
        totalDuplicates, _
        totalIssues

    BuildActionPlan oReport, oAction, reportRow - 1
    WriteAuditLog _
        oAudit, _
        targetCount, _
        totalAdded, _
        totalRemoved, _
        totalChangedRows, _
        totalChangedCells, _
        totalDuplicates, _
        totalIssues, _
        reportRow - 1

    FormatReport oReport, reportRow - 1
    FormatStats oStats, statsRow + 8
    FormatDashboard oDash
    FormatActionPlan oAction
    FormatAuditLog oAudit
    CF_ReferenceFormatPlan

    On Error Resume Next
    CF_ContextSet "Mode", "REFERENCE"
    CF_ContextSet "ReferenceSheet", referenceSheetName
    CF_ContextSet "KeyColumn", keyColumnName
    CF_ContextSet "Targets", CStr(targetCount)
    CF_AuditSet "Mode", "REFERENCE"
    CF_AuditSet "ReferenceSheet", referenceSheetName
    CF_AuditSet "KeyColumn", keyColumnName
    CF_AuditSet "Targets", CStr(targetCount)
    On Error GoTo 0

    gIdAliases = previousAliases

    MsgBox _
        "Comparaison par référence terminée." & Chr(10) & _
        "Référence : " & referenceSheetName & Chr(10) & _
        "Clé : " & keyColumnName & Chr(10) & _
        "Feuilles comparées : " & targetCount & Chr(10) & _
        "Ajouts : " & totalAdded & Chr(10) & _
        "Suppressions : " & totalRemoved & Chr(10) & _
        "Lignes modifiées : " & totalChangedRows, _
        64, _
        "CompareFramework V3.7.0-D1"

    Exit Sub

ErrHandler:
    On Error Resume Next
    gIdAliases = previousAliases
    CF_AuditFail Err, Error$
    On Error GoTo 0

    MsgBox _
        "Erreur CF_RunAgainstReference : " & Err & " - " & Error$, _
        16, _
        "CompareFramework V3.7.0-D1"
End Sub

Public Sub CF_BuildReferencePlan(referenceSheetName As String, keyColumnName As String)
    Dim oDoc As Object
    Dim oSheets As Object
    Dim oPlan As Object
    Dim names As Variant
    Dim i As Long
    Dim row As Long
    Dim sheetName As String

    oDoc = ThisComponent
    oSheets = oDoc.Sheets
    oPlan = PrepareSheet(oDoc, CF_REFERENCE_PLAN_SHEET)

    oPlan.getCellByPosition(0, 0).String = "Référence"
    oPlan.getCellByPosition(1, 0).String = "Cible"
    oPlan.getCellByPosition(2, 0).String = "Clé"
    oPlan.getCellByPosition(3, 0).String = "Statut"
    oPlan.getCellByPosition(4, 0).String = "Message"

    names = oSheets.getElementNames()
    row = 1

    For i = LBound(names) To UBound(names)
        sheetName = CStr(names(i))

        If CF_ReferenceIsTargetSheet(sheetName, referenceSheetName) Then
            oPlan.getCellByPosition(0, row).String = referenceSheetName
            oPlan.getCellByPosition(1, row).String = sheetName
            oPlan.getCellByPosition(2, row).String = keyColumnName
            oPlan.getCellByPosition(3, row).String = "PLANIFIEE"
            oPlan.getCellByPosition(4, row).String = ""
            row = row + 1
        End If
    Next i

    CF_ReferenceFormatPlan
End Sub

Public Function CF_ReferenceIsTargetSheet(sheetName As String, referenceSheetName As String) As Boolean
    Dim normalized As String

    normalized = LCase(Trim(CStr(sheetName)))

    If normalized = LCase(Trim(referenceSheetName)) Then
        CF_ReferenceIsTargetSheet = False
        Exit Function
    End If

    If IsReportOrStatsSheet(sheetName) Then
        CF_ReferenceIsTargetSheet = False
        Exit Function
    End If

    If normalized = LCase(CF_REFERENCE_PLAN_SHEET) Then
        CF_ReferenceIsTargetSheet = False
        Exit Function
    End If

    If Left(normalized, 3) = "cf_" Then
        CF_ReferenceIsTargetSheet = False
        Exit Function
    End If

    If Left(normalized, 8) = "compare_" Then
        CF_ReferenceIsTargetSheet = False
        Exit Function
    End If

    CF_ReferenceIsTargetSheet = True
End Function

Public Function CF_ReferenceSheetHasKey(oSheet As Object, keyColumnName As String) As Boolean
    Dim data As Variant
    Dim headers As Variant
    Dim keyIndex As Long

    On Error GoTo NotFound

    data = CF_ReadUsedData(oSheet)
    headers = CF_MemoryHeaders(data)
    keyIndex = HeaderIndex(headers, keyColumnName)

    CF_ReferenceSheetHasKey = (keyIndex >= LBound(headers) And keyIndex <= UBound(headers))
    Exit Function

NotFound:
    CF_ReferenceSheetHasKey = False
End Function

Public Sub CF_ReferencePlanSetStatus(targetName As String, statusText As String, messageText As String)
    Dim oDoc As Object
    Dim oPlan As Object
    Dim lastRow As Long
    Dim row As Long

    oDoc = ThisComponent

    If Not oDoc.Sheets.hasByName(CF_REFERENCE_PLAN_SHEET) Then Exit Sub

    oPlan = oDoc.Sheets.getByName(CF_REFERENCE_PLAN_SHEET)
    lastRow = LastUsedRow(oPlan)

    For row = 1 To lastRow
        If LCase(Trim(oPlan.getCellByPosition(1, row).String)) = _
           LCase(Trim(targetName)) Then

            oPlan.getCellByPosition(3, row).String = statusText
            oPlan.getCellByPosition(4, row).String = messageText
            Exit Sub
        End If
    Next row
End Sub

Public Sub CF_ReferenceFormatPlan()
    On Error Resume Next

    Dim oDoc As Object
    Dim oPlan As Object

    oDoc = ThisComponent

    If Not oDoc.Sheets.hasByName(CF_REFERENCE_PLAN_SHEET) Then Exit Sub

    oPlan = oDoc.Sheets.getByName(CF_REFERENCE_PLAN_SHEET)
    oPlan.getCellRangeByName("A1:E1").CharWeight = 150
    oPlan.getCellRangeByName("A1:E1").CellBackColor = RGB(217, 217, 217)
    oPlan.Columns.getByIndex(0).Width = 5000
    oPlan.Columns.getByIndex(1).Width = 5000
    oPlan.Columns.getByIndex(2).Width = 4500
    oPlan.Columns.getByIndex(3).Width = 3500
    oPlan.Columns.getByIndex(4).Width = 9000
End Sub
