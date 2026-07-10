Option Explicit

'=========================================================
' CompareFramework V3.5.1 - Performance & Metrics
'=========================================================
' Public API:
'   CF_PerfReset()
'   CF_PerfStart(label)
'   CF_PerfStop(label)
'   CF_PerfRecordPair(...)
'   CF_PerfWriteReport()
'   CF_ReadSheetDataArray(sheet)
'   CF_RunPerformanceBenchmark()
'=========================================================

Private CF_PERF_LABELS() As String
Private CF_PERF_STARTED() As Double
Private CF_PERF_ELAPSED() As Double
Private CF_PERF_COUNT As Long
Private CF_PERF_PAIR_NAMES() As String
Private CF_PERF_PAIR_OLD_ROWS() As Long
Private CF_PERF_PAIR_NEW_ROWS() As Long
Private CF_PERF_PAIR_COLUMNS() As Long
Private CF_PERF_PAIR_SECONDS() As Double
Private CF_PERF_PAIR_COUNT As Long

Public Sub CF_PerfReset()
    ReDim CF_PERF_LABELS(0 To 0)
    ReDim CF_PERF_STARTED(0 To 0)
    ReDim CF_PERF_ELAPSED(0 To 0)
    ReDim CF_PERF_PAIR_NAMES(0 To 0)
    ReDim CF_PERF_PAIR_OLD_ROWS(0 To 0)
    ReDim CF_PERF_PAIR_NEW_ROWS(0 To 0)
    ReDim CF_PERF_PAIR_COLUMNS(0 To 0)
    ReDim CF_PERF_PAIR_SECONDS(0 To 0)
    CF_PERF_COUNT = 0
    CF_PERF_PAIR_COUNT = 0
End Sub

Public Sub CF_PerfStart(sLabel As String)
    Dim idx As Long
    idx = CF_PerfIndexOf(sLabel)
    If idx < 0 Then
        idx = CF_PerfAddLabel(sLabel)
    End If
    CF_PERF_STARTED(idx) = Timer
End Sub

Public Function CF_PerfStop(sLabel As String) As Double
    Dim idx As Long, elapsed As Double
    idx = CF_PerfIndexOf(sLabel)
    If idx < 0 Then
        CF_PerfStop = 0
        Exit Function
    End If
    elapsed = Timer - CF_PERF_STARTED(idx)
    If elapsed < 0 Then elapsed = elapsed + 86400
    CF_PERF_ELAPSED(idx) = CF_PERF_ELAPSED(idx) + elapsed
    CF_PerfStop = elapsed
End Function

Public Sub CF_PerfRecordPair(sPairName As String, oldRows As Long, newRows As Long, columnCount As Long, elapsedSeconds As Double)
    If CF_PERF_PAIR_COUNT = 0 Then
        ReDim CF_PERF_PAIR_NAMES(0 To 0)
        ReDim CF_PERF_PAIR_OLD_ROWS(0 To 0)
        ReDim CF_PERF_PAIR_NEW_ROWS(0 To 0)
        ReDim CF_PERF_PAIR_COLUMNS(0 To 0)
        ReDim CF_PERF_PAIR_SECONDS(0 To 0)
    Else
        ReDim Preserve CF_PERF_PAIR_NAMES(0 To CF_PERF_PAIR_COUNT)
        ReDim Preserve CF_PERF_PAIR_OLD_ROWS(0 To CF_PERF_PAIR_COUNT)
        ReDim Preserve CF_PERF_PAIR_NEW_ROWS(0 To CF_PERF_PAIR_COUNT)
        ReDim Preserve CF_PERF_PAIR_COLUMNS(0 To CF_PERF_PAIR_COUNT)
        ReDim Preserve CF_PERF_PAIR_SECONDS(0 To CF_PERF_PAIR_COUNT)
    End If
    CF_PERF_PAIR_NAMES(CF_PERF_PAIR_COUNT) = sPairName
    CF_PERF_PAIR_OLD_ROWS(CF_PERF_PAIR_COUNT) = oldRows
    CF_PERF_PAIR_NEW_ROWS(CF_PERF_PAIR_COUNT) = newRows
    CF_PERF_PAIR_COLUMNS(CF_PERF_PAIR_COUNT) = columnCount
    CF_PERF_PAIR_SECONDS(CF_PERF_PAIR_COUNT) = elapsedSeconds
    CF_PERF_PAIR_COUNT = CF_PERF_PAIR_COUNT + 1
End Sub

Public Sub CF_PerfWriteReport()
    On Error GoTo ErrHandler
    Dim oDoc As Object, oSheet As Object, i As Long, r As Long
    oDoc = ThisComponent
    If oDoc.Sheets.hasByName("Compare_Performance") Then oDoc.Sheets.removeByName("Compare_Performance")
    oDoc.Sheets.insertNewByName "Compare_Performance", oDoc.Sheets.getCount()
    oSheet = oDoc.Sheets.getByName("Compare_Performance")

    CF_PerfCell oSheet, 0, 0, "Mesure"
    CF_PerfCell oSheet, 1, 0, "Durée (s)"
    r = 1
    For i = 0 To CF_PERF_COUNT - 1
        CF_PerfCell oSheet, 0, r, CF_PERF_LABELS(i)
        CF_PerfCell oSheet, 1, r, CStr(Round(CF_PERF_ELAPSED(i), 3))
        r = r + 1
    Next i

    r = r + 2
    CF_PerfCell oSheet, 0, r, "Paire"
    CF_PerfCell oSheet, 1, r, "Lignes OLD"
    CF_PerfCell oSheet, 2, r, "Lignes NEW"
    CF_PerfCell oSheet, 3, r, "Colonnes"
    CF_PerfCell oSheet, 4, r, "Durée (s)"
    r = r + 1
    For i = 0 To CF_PERF_PAIR_COUNT - 1
        CF_PerfCell oSheet, 0, r, CF_PERF_PAIR_NAMES(i)
        CF_PerfCell oSheet, 1, r, CStr(CF_PERF_PAIR_OLD_ROWS(i))
        CF_PerfCell oSheet, 2, r, CStr(CF_PERF_PAIR_NEW_ROWS(i))
        CF_PerfCell oSheet, 3, r, CStr(CF_PERF_PAIR_COLUMNS(i))
        CF_PerfCell oSheet, 4, r, CStr(Round(CF_PERF_PAIR_SECONDS(i), 3))
        r = r + 1
    Next i

    On Error Resume Next
    oSheet.getCellRangeByName("A1:E1").CharWeight = com.sun.star.awt.FontWeight.BOLD
    oSheet.Columns.getByIndex(0).Width = 9000
    oSheet.Columns.getByIndex(1).Width = 3000
    oSheet.Columns.getByIndex(2).Width = 3000
    oSheet.Columns.getByIndex(3).Width = 3000
    oSheet.Columns.getByIndex(4).Width = 3000
    Exit Sub
ErrHandler:
    MsgBox "Erreur CF_PerfWriteReport : " & Err & " - " & Error$, 16, "CompareFramework V3.5.1"
End Sub

Public Function CF_ReadSheetDataArray(oSheet As Object) As Variant
    Dim lastRow As Long, lastCol As Long, oRange As Object
    lastRow = LastUsedRow(oSheet)
    lastCol = LastUsedCol(oSheet)
    oRange = oSheet.getCellRangeByPosition(0, 0, lastCol, lastRow)
    CF_ReadSheetDataArray = oRange.getDataArray()
End Function

Public Sub CF_RunPerformanceBenchmark()
    On Error GoTo ErrHandler
    Dim oDoc As Object, names As Variant, i As Long, oSheet As Object
    Dim data As Variant, elapsed As Double, rows As Long, cols As Long
    oDoc = ThisComponent
    CF_PerfReset
    names = oDoc.Sheets.getElementNames()
    For i = LBound(names) To UBound(names)
        If Not IsReportOrStatsSheet(CStr(names(i))) Then
            oSheet = oDoc.Sheets.getByName(CStr(names(i)))
            CF_PerfStart "Lecture mémoire: " & CStr(names(i))
            data = CF_ReadSheetDataArray(oSheet)
            elapsed = CF_PerfStop("Lecture mémoire: " & CStr(names(i)))
            rows = UBound(data) - LBound(data) + 1
            cols = UBound(data(0)) - LBound(data(0)) + 1
            CF_PerfRecordPair CStr(names(i)), rows, rows, cols, elapsed
        End If
    Next i
    CF_PerfWriteReport
    MsgBox "Benchmark terminé. Consulte Compare_Performance.", 64, "CompareFramework V3.5.1"
    Exit Sub
ErrHandler:
    MsgBox "Erreur CF_RunPerformanceBenchmark : " & Err & " - " & Error$, 16, "CompareFramework V3.5.1"
End Sub

Private Function CF_PerfIndexOf(sLabel As String) As Long
    Dim i As Long
    For i = 0 To CF_PERF_COUNT - 1
        If UCase(CF_PERF_LABELS(i)) = UCase(Trim(sLabel)) Then CF_PerfIndexOf = i: Exit Function
    Next i
    CF_PerfIndexOf = -1
End Function

Private Function CF_PerfAddLabel(sLabel As String) As Long
    If CF_PERF_COUNT = 0 Then
        ReDim CF_PERF_LABELS(0 To 0)
        ReDim CF_PERF_STARTED(0 To 0)
        ReDim CF_PERF_ELAPSED(0 To 0)
    Else
        ReDim Preserve CF_PERF_LABELS(0 To CF_PERF_COUNT)
        ReDim Preserve CF_PERF_STARTED(0 To CF_PERF_COUNT)
        ReDim Preserve CF_PERF_ELAPSED(0 To CF_PERF_COUNT)
    End If
    CF_PERF_LABELS(CF_PERF_COUNT) = Trim(sLabel)
    CF_Perf_STARTED(CF_PERF_COUNT) = 0
    CF_Perf_ELAPSED(CF_PERF_COUNT) = 0
    CF_PerfAddLabel = CF_PERF_COUNT
    CF_PERF_COUNT = CF_PERF_COUNT + 1
End Function

Private Sub CF_PerfCell(oSheet As Object, col As Long, row As Long, v As Variant)
    oSheet.getCellByPosition(col, row).String = CStr(v)
End Sub
