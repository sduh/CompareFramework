Option Explicit

'=========================================================
' CompareFramework - In-memory comparison engine
' Jalon A: lecture -> indexation -> comparaison -> rapport
'=========================================================

Public Sub CF_CompareAllSheetsInMemory()
    On Error GoTo ErrHandler

    Dim oDoc As Object, oReport As Object, oStats As Object
    Dim oDash As Object, oAction As Object, oAudit As Object
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
    LoadCompareRules oDoc
    CF_LoadComparatorConfig oDoc

    reportRow = 0
    statsRow = 0
    WriteReportHeader oReport, reportRow
    WriteStatsHeader oStats, statsRow
    reportRow = reportRow + 1
    statsRow = statsRow + 1

    pairCount = CF_CompareDetectedPairsMemory(oDoc, oReport, reportRow, oStats, statsRow, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues)

    If pairCount = 0 Then
        pairCount = CF_CompareFallbackMemory(oDoc, oReport, reportRow, oStats, statsRow, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues)
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

    On Error Resume Next
    CF_ContextSet "Engine", "MEMORY"
    CF_ContextSet "Pairs", CStr(pairCount)
    CF_ContextSet "AddedRows", CStr(totalAdded)
    CF_ContextSet "RemovedRows", CStr(totalRemoved)
    CF_ContextSet "ChangedRows", CStr(totalChangedRows)
    CF_ContextSet "ChangedCells", CStr(totalChangedCells)
    CF_AuditSet "Engine", "MEMORY"
    CF_AuditSet "Pairs", CStr(pairCount)
    CF_AuditSet "ChangedCells", CStr(totalChangedCells)
    On Error GoTo 0

    MsgBox "Comparaison en memoire terminee." & Chr(10) & _
           "Paires comparees : " & pairCount & Chr(10) & _
           "Lignes ajoutees : " & totalAdded & Chr(10) & _
           "Lignes supprimees : " & totalRemoved & Chr(10) & _
           "Lignes modifiees : " & totalChangedRows & Chr(10) & _
           "Cellules modifiees : " & totalChangedCells, 64, "CompareFramework V" & CF_VERSION
    Exit Sub

ErrHandler:
    On Error Resume Next
    CF_ContextSet "EngineError", CStr(Err) & " - " & Error$
    CF_AuditFail Err, Error$
    On Error GoTo 0
    MsgBox "Erreur moteur en memoire : " & Err & " - " & Error$, 16, "CompareFramework V" & CF_VERSION
End Sub

Public Function CF_CompareDetectedPairsMemory(oDoc As Object, oReport As Object, ByRef reportRow As Long, oStats As Object, ByRef statsRow As Long, ByRef totalAdded As Long, ByRef totalRemoved As Long, ByRef totalChangedRows As Long, ByRef totalChangedCells As Long, ByRef totalDuplicates As Long, ByRef totalIssues As Long) As Long
    Dim oSheets As Object, names As Variant
    Dim i As Long, sheetName As String, baseName As String, newName As String
    Dim count As Long

    oSheets = oDoc.Sheets
    names = oSheets.getElementNames()

    For i = LBound(names) To UBound(names)
        sheetName = CStr(names(i))
        If Not IsReportOrStatsSheet(sheetName) Then
            baseName = PairBaseName(sheetName)
            If baseName <> "" And IsOldSheetName(sheetName) Then
                newName = FindNewSheetForBase(oSheets, baseName)
                If newName <> "" Then
                    CF_CompareSheetPairMemory oSheets.getByName(sheetName), oSheets.getByName(newName), oReport, reportRow, oStats, statsRow, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues
                    count = count + 1
                End If
            End If
        End If
    Next i

    CF_CompareDetectedPairsMemory = count
End Function

Public Function CF_CompareFallbackMemory(oDoc As Object, oReport As Object, ByRef reportRow As Long, oStats As Object, ByRef statsRow As Long, ByRef totalAdded As Long, ByRef totalRemoved As Long, ByRef totalChangedRows As Long, ByRef totalChangedCells As Long, ByRef totalDuplicates As Long, ByRef totalIssues As Long) As Long
    Dim oSheets As Object, allNames As Variant
    Dim names(1) As String
    Dim i As Long, n As Long, sheetName As String

    oSheets = oDoc.Sheets
    allNames = oSheets.getElementNames()

    For i = LBound(allNames) To UBound(allNames)
        sheetName = CStr(allNames(i))
        If Not IsReportOrStatsSheet(sheetName) Then
            If n <= 1 Then names(n) = sheetName
            n = n + 1
        End If
    Next i

    If n = 2 Then
        CF_CompareSheetPairMemory oSheets.getByName(names(0)), oSheets.getByName(names(1)), oReport, reportRow, oStats, statsRow, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues
        CF_CompareFallbackMemory = 1
    Else
        WriteReportRow oReport, reportRow, "SYSTEME", "", CF_STATUS_ERROR, "", "", "", "", "", "Aucune paire detectee. Utiliser _OLD/_NEW, _REF/_NEW ou _AVANT/_APRES."
        reportRow = reportRow + 1
        totalIssues = totalIssues + 1
        CF_CompareFallbackMemory = 0
    End If
End Function

Public Sub CF_CompareSheetPairMemory(oOld As Object, oNew As Object, oReport As Object, ByRef reportRow As Long, oStats As Object, ByRef statsRow As Long, ByRef totalAdded As Long, ByRef totalRemoved As Long, ByRef totalChangedRows As Long, ByRef totalChangedCells As Long, ByRef totalDuplicates As Long, ByRef totalIssues As Long)
    Dim oldData As Variant, newData As Variant
    Dim oldHeaders As Variant, newHeaders As Variant
    Dim oldIdCol As Long, newIdCol As Long
    Dim oldIds As Variant, oldRows As Variant, newIds As Variant, newRows As Variant
    Dim oldCount As Long, newCount As Long
    Dim i As Long, foundRow As Long, idValue As String, pairName As String
    Dim pairAdded As Long, pairRemoved As Long, pairChangedRows As Long
    Dim pairChangedCells As Long, pairDuplicates As Long, pairIssues As Long
    Dim changedInRow As Long

    pairName = oOld.Name & " -> " & oNew.Name
    oldData = CF_ReadUsedData(oOld)
    newData = CF_ReadUsedData(oNew)

    oldHeaders = CF_MemoryHeaders(oldData)
    newHeaders = CF_MemoryHeaders(newData)
    oldIdCol = FindIdColumn(oldHeaders)
    newIdCol = FindIdColumn(newHeaders)

    If oldIdCol < 0 Or newIdCol < 0 Then
        WriteReportRow oReport, reportRow, pairName, "", CF_STATUS_ERROR, "ID", "", "", "", "", "Colonne ID introuvable. Verifier ID_ALIASES dans Compare_Config."
        reportRow = reportRow + 1
        pairIssues = pairIssues + 1
        totalIssues = totalIssues + 1
        WriteStatsRow oStats, statsRow, pairName, 0, 0, 0, 0, 0, 0, 0, pairIssues
        statsRow = statsRow + 1
        Exit Sub
    End If

    CF_BuildMemoryIdIndex oldData, oldIdCol, oldIds, oldRows, oldCount
    CF_BuildMemoryIdIndex newData, newIdCol, newIds, newRows, newCount

    If oldCount > 1 Then QuickSortIndex oldIds, oldRows, 0, oldCount - 1
    If newCount > 1 Then QuickSortIndex newIds, newRows, 0, newCount - 1

    pairDuplicates = CF_ReportMemoryDuplicates(oldIds, oldRows, oldCount, oReport, reportRow, pairName, "ANCIENNE")
    pairDuplicates = pairDuplicates + CF_ReportMemoryDuplicates(newIds, newRows, newCount, oReport, reportRow, pairName, "NOUVELLE")
    ReportColumnDifferences oldHeaders, newHeaders, oReport, reportRow, pairName, pairIssues

    For i = 0 To oldCount - 1
        idValue = CStr(oldIds(i))
        foundRow = FindRowInIndex(newIds, newRows, newCount, idValue)
        If foundRow < 0 Then
            WriteReportRow oReport, reportRow, pairName, idValue, CF_STATUS_REMOVED, "LIGNE", RowNumberText(oldRows(i)), "", CF_MemoryFullRow(oldData, oldHeaders, CLng(oldRows(i))), "", "Ligne presente dans l'ancienne feuille uniquement."
            reportRow = reportRow + 1
            pairRemoved = pairRemoved + 1
        Else
            changedInRow = CF_CompareMemoryRows(oldData, newData, oldHeaders, newHeaders, CLng(oldRows(i)), foundRow, idValue, pairName, oReport, reportRow)
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
            WriteReportRow oReport, reportRow, pairName, idValue, CF_STATUS_ADDED, "LIGNE", "", RowNumberText(newRows(i)), "", CF_MemoryFullRow(newData, newHeaders, CLng(newRows(i))), "Ligne presente dans la nouvelle feuille uniquement."
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

Public Function CF_ReadUsedData(oSheet As Object) As Variant
    Dim lastRow As Long, lastCol As Long
    Dim oRange As Object

    lastRow = LastUsedRow(oSheet)
    lastCol = LastUsedCol(oSheet)
    oRange = oSheet.getCellRangeByPosition(0, 0, lastCol, lastRow)
    CF_ReadUsedData = oRange.getDataArray()
End Function

Public Function CF_MemoryHeaders(data As Variant) As Variant
    Dim rowData As Variant, headers() As String
    Dim c As Long

    rowData = data(LBound(data))
    ReDim headers(LBound(rowData) To UBound(rowData))
    For c = LBound(rowData) To UBound(rowData)
        headers(c) = Trim(CF_MemoryValueText(rowData(c)))
    Next c
    CF_MemoryHeaders = headers
End Function

Public Sub CF_BuildMemoryIdIndex(data As Variant, idCol As Long, ByRef ids As Variant, ByRef rows As Variant, ByRef count As Long)
    Dim tempIds() As String, tempRows() As Long
    Dim r As Long, idValue As String, n As Long
    Dim rowData As Variant

    ReDim tempIds(0 To UBound(data))
    ReDim tempRows(0 To UBound(data))

    For r = CF_FIRST_DATA_ROW To UBound(data)
        rowData = data(r)
        idValue = Trim(CF_MemoryValueText(rowData(idCol)))
        If idValue <> "" Then
            tempIds(n) = idValue
            tempRows(n) = r
            n = n + 1
        End If
    Next r

    If n = 0 Then
        ReDim tempIds(0 To 0)
        ReDim tempRows(0 To 0)
    Else
        ReDim Preserve tempIds(0 To n - 1)
        ReDim Preserve tempRows(0 To n - 1)
    End If

    ids = tempIds
    rows = tempRows
    count = n
End Sub

Public Function CF_CompareMemoryRows(oldData As Variant, newData As Variant, oldHeaders As Variant, newHeaders As Variant, oldRow As Long, newRow As Long, idValue As String, pairName As String, oReport As Object, ByRef reportRow As Long) As Long
    Dim i As Long, newCol As Long
    Dim headerName As String, oldValue As String, newValue As String
    Dim oldCompare As String, newCompare As String
    Dim comparatorUsed As String, comparatorDetail As String
    Dim valuesEqual As Boolean
    Dim oldRowData As Variant, newRowData As Variant
    Dim changedCells As Long

    oldRowData = oldData(oldRow)
    newRowData = newData(newRow)

    For i = LBound(oldHeaders) To UBound(oldHeaders)
        headerName = Trim(CStr(oldHeaders(i)))
        If headerName <> "" And Not ColumnIsIgnored(headerName) Then
            newCol = HeaderIndex(newHeaders, headerName)
            If newCol >= 0 Then
                oldValue = CF_MemoryValueText(oldRowData(i))
                newValue = CF_MemoryValueText(newRowData(newCol))
                oldCompare = NormalizeCompareValue(oldValue)
                newCompare = NormalizeCompareValue(newValue)
                valuesEqual = CF_TypedValuesEqual(oldRowData(i), newRowData(newCol), headerName, comparatorUsed, comparatorDetail)

                If Not valuesEqual Then
                    If Not IgnoreThisEmptyChange(oldCompare, newCompare) Then
                        If Not ShouldIgnoreDifference(pairName, idValue, headerName, oldValue, newValue, oldCompare, newCompare) Then
                            WriteReportRow oReport, reportRow, pairName, idValue, CF_STATUS_CHANGED, headerName, RowNumberText(oldRow), RowNumberText(newRow), oldValue, newValue, "Comparateur " & comparatorUsed & " : " & comparatorDetail
                            reportRow = reportRow + 1
                            changedCells = changedCells + 1
                        End If
                    End If
                End If
            End If
        End If
    Next i

    CF_CompareMemoryRows = changedCells
End Function

Public Function CF_MemoryFullRow(data As Variant, headers As Variant, rowIndex As Long) As String
    Dim rowData As Variant
    Dim i As Long, h As String, result As String

    rowData = data(rowIndex)
    For i = LBound(headers) To UBound(headers)
        h = Trim(CStr(headers(i)))
        If h <> "" Then
            If result <> "" Then result = result & " | "
            result = result & h & "=" & CF_MemoryValueText(rowData(i))
        End If
    Next i
    CF_MemoryFullRow = result
End Function

Public Function CF_ReportMemoryDuplicates(ids As Variant, rows As Variant, count As Long, oReport As Object, ByRef reportRow As Long, pairName As String, sideName As String) As Long
    Dim i As Long, duplicateCount As Long

    If count <= 1 Then
        CF_ReportMemoryDuplicates = 0
        Exit Function
    End If

    For i = 1 To count - 1
        If CStr(ids(i)) = CStr(ids(i - 1)) Then
            WriteReportRow oReport, reportRow, pairName, CStr(ids(i)), CF_STATUS_DUPLICATE, "ID", RowNumberText(rows(i - 1)), RowNumberText(rows(i)), "", "", "ID en double dans la feuille " & sideName & "."
            reportRow = reportRow + 1
            duplicateCount = duplicateCount + 1
        End If
    Next i

    CF_ReportMemoryDuplicates = duplicateCount
End Function

Public Function CF_MemoryValueText(value As Variant) As String
    If IsNull(value) Or IsEmpty(value) Then
        CF_MemoryValueText = ""
    Else
        CF_MemoryValueText = Trim(CStr(value))
    End If
End Function

Public Sub CF_RunMemoryEngineTests()
    On Error GoTo ErrHandler

    Dim oDoc As Object, oOld As Object
    Dim data As Variant, headers As Variant
    Dim ids As Variant, rows As Variant, count As Long
    Dim okRead As Boolean, okHeaders As Boolean, okIndex As Boolean

    oDoc = ThisComponent
    CF_CreateTestWorkbook
    oOld = oDoc.Sheets.getByName("CF_Test_OLD")

    data = CF_ReadUsedData(oOld)
    headers = CF_MemoryHeaders(data)
    CF_BuildMemoryIdIndex data, FindIdColumn(headers), ids, rows, count

    okRead = (UBound(data) >= 4)
    okHeaders = (CStr(headers(0)) = "ID" And CStr(headers(2)) = "Amount")
    okIndex = (count = 4)

    If okRead And okHeaders And okIndex Then
        MsgBox "Tests moteur memoire : 3/3", 64, "CompareFramework V" & CF_VERSION
    Else
        MsgBox "Tests moteur memoire a controler.", 48, "CompareFramework V" & CF_VERSION
    End If
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunMemoryEngineTests : " & Err & " - " & Error$, 16, "CompareFramework V" & CF_VERSION
End Sub
