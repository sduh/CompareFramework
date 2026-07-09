Option Explicit

' CompareFramework V0.1
' LibreOffice Basic module
' Goal: compare two sheets, or automatic pairs of sheets, using an ID column.
'
' Default conventions:
'   - old/reference sheets may end with _OLD, _REF or _AVANT
'   - new/current sheets may end with _NEW, _NOUVEAU or _APRES
'   - if no pair is found and the document has exactly two non-report sheets,
'     those two sheets are compared.
'
' Main macro to run:
'   ComparerToutesLesFeuilles
'
' Output:
'   a sheet named Rapport_Comparaison

Const CF_VERSION As String = "0.1"
Const CF_REPORT_SHEET As String = "Rapport_Comparaison"
Const CF_HEADER_ROW As Long = 0          ' zero-based row index: 0 means row 1
Const CF_FIRST_DATA_ROW As Long = 1      ' zero-based row index: 1 means row 2
Const CF_MAX_EMPTY_ROWS As Long = 50
Const CF_STATUS_OK As String = "OK"
Const CF_STATUS_ADDED As String = "AJOUTE"
Const CF_STATUS_REMOVED As String = "SUPPRIME"
Const CF_STATUS_CHANGED As String = "MODIFIE"

Sub ComparerToutesLesFeuilles()
    Dim oDoc As Object, oSheets As Object, oReport As Object
    Dim reportRow As Long, pairCount As Long

    oDoc = ThisComponent
    oSheets = oDoc.Sheets

    oReport = PrepareReportSheet(oDoc)
    reportRow = 0
    WriteReportHeader oReport, reportRow
    reportRow = reportRow + 1

    pairCount = CompareDetectedPairs(oDoc, oReport, reportRow)

    If pairCount = 0 Then
        pairCount = CompareFallbackTwoSheets(oDoc, oReport, reportRow)
    End If

    WriteSummary oReport, reportRow, pairCount
    FormatReport oReport

    MsgBox "Comparaison terminee. Paires comparees : " & pairCount, 64, "CompareFramework V" & CF_VERSION
End Sub

Function CompareDetectedPairs(oDoc As Object, oReport As Object, ByRef reportRow As Long) As Long
    Dim oSheets As Object
    Dim i As Long, sheetName As String, baseName As String, newName As String
    Dim count As Long

    oSheets = oDoc.Sheets
    count = 0

    For i = 0 To oSheets.Count - 1
        sheetName = oSheets.getElementNames()(i)

        If IsReportSheet(sheetName) = False Then
            baseName = PairBaseName(sheetName)
            If baseName <> "" Then
                If IsOldSheetName(sheetName) Then
                    newName = FindNewSheetForBase(oSheets, baseName)
                    If newName <> "" Then
                        CompareSheetPair oSheets.getByName(sheetName), oSheets.getByName(newName), oReport, reportRow
                        count = count + 1
                    End If
                End If
            End If
        End If
    Next i

    CompareDetectedPairs = count
End Function

Function CompareFallbackTwoSheets(oDoc As Object, oReport As Object, ByRef reportRow As Long) As Long
    Dim oSheets As Object, names() As String
    Dim i As Long, n As Long, sheetName As String

    oSheets = oDoc.Sheets
    ReDim names(1)
    n = 0

    For i = 0 To oSheets.Count - 1
        sheetName = oSheets.getElementNames()(i)
        If IsReportSheet(sheetName) = False Then
            If n <= 1 Then names(n) = sheetName
            n = n + 1
        End If
    Next i

    If n = 2 Then
        CompareSheetPair oSheets.getByName(names(0)), oSheets.getByName(names(1)), oReport, reportRow
        CompareFallbackTwoSheets = 1
    Else
        WriteIssue oReport, reportRow, "SYSTEME", "", "", "", "Aucune paire detectee. Utiliser des suffixes _OLD/_NEW, _REF/_NEW ou _AVANT/_APRES."
        reportRow = reportRow + 1
        CompareFallbackTwoSheets = 0
    End If
End Function

Sub CompareSheetPair(oOld As Object, oNew As Object, oReport As Object, ByRef reportRow As Long)
    Dim oldHeaders As Variant, newHeaders As Variant
    Dim oldIdCol As Long, newIdCol As Long
    Dim oldLastRow As Long, newLastRow As Long, oldLastCol As Long, newLastCol As Long
    Dim r As Long, newRow As Long, oldRow As Long, idValue As String

    oldLastRow = LastUsedRow(oOld)
    newLastRow = LastUsedRow(oNew)
    oldLastCol = LastUsedCol(oOld)
    newLastCol = LastUsedCol(oNew)

    oldHeaders = ReadHeaders(oOld, oldLastCol)
    newHeaders = ReadHeaders(oNew, newLastCol)

    oldIdCol = FindIdColumn(oldHeaders)
    newIdCol = FindIdColumn(newHeaders)

    If oldIdCol < 0 Or newIdCol < 0 Then
        WriteIssue oReport, reportRow, oOld.Name & " / " & oNew.Name, "", "", "", "Colonne ID introuvable. Noms acceptes : ID, Identifiant, Code, Reference, Ref, Cle, Key."
        reportRow = reportRow + 1
        Exit Sub
    End If

    ' Removed or changed rows
    For r = CF_FIRST_DATA_ROW To oldLastRow
        idValue = CellText(oOld, oldIdCol, r)
        If idValue <> "" Then
            newRow = FindRowById(oNew, newIdCol, newLastRow, idValue)
            If newRow < 0 Then
                WriteIssue oReport, reportRow, oOld.Name & " -> " & oNew.Name, idValue, "", CF_STATUS_REMOVED, "Ligne presente dans l'ancienne feuille uniquement."
                reportRow = reportRow + 1
            Else
                CompareRowCells oOld, oNew, oldHeaders, newHeaders, r, newRow, idValue, oReport, reportRow
            End If
        End If
    Next r

    ' Added rows
    For r = CF_FIRST_DATA_ROW To newLastRow
        idValue = CellText(oNew, newIdCol, r)
        If idValue <> "" Then
            oldRow = FindRowById(oOld, oldIdCol, oldLastRow, idValue)
            If oldRow < 0 Then
                WriteIssue oReport, reportRow, oOld.Name & " -> " & oNew.Name, idValue, "", CF_STATUS_ADDED, "Ligne presente dans la nouvelle feuille uniquement."
                reportRow = reportRow + 1
            End If
        End If
    Next r
End Sub

Sub CompareRowCells(oOld As Object, oNew As Object, oldHeaders As Variant, newHeaders As Variant, oldRow As Long, newRow As Long, idValue As String, oReport As Object, ByRef reportRow As Long)
    Dim i As Long, oldCol As Long, newCol As Long
    Dim headerName As String, oldValue As String, newValue As String

    For i = LBound(oldHeaders) To UBound(oldHeaders)
        headerName = Trim(CStr(oldHeaders(i)))
        If headerName <> "" Then
            oldCol = i
            newCol = HeaderIndex(newHeaders, headerName)
            If newCol >= 0 Then
                oldValue = CellText(oOld, oldCol, oldRow)
                newValue = CellText(oNew, newCol, newRow)
                If oldValue <> newValue Then
                    WriteDiff oReport, reportRow, oOld.Name & " -> " & oNew.Name, idValue, headerName, oldValue, newValue
                    reportRow = reportRow + 1
                End If
            Else
                WriteIssue oReport, reportRow, oOld.Name & " -> " & oNew.Name, idValue, headerName, CF_STATUS_REMOVED, "Colonne absente dans la nouvelle feuille."
                reportRow = reportRow + 1
            End If
        End If
    Next i

    For i = LBound(newHeaders) To UBound(newHeaders)
        headerName = Trim(CStr(newHeaders(i)))
        If headerName <> "" Then
            oldCol = HeaderIndex(oldHeaders, headerName)
            If oldCol < 0 Then
                WriteIssue oReport, reportRow, oOld.Name & " -> " & oNew.Name, idValue, headerName, CF_STATUS_ADDED, "Colonne absente dans l'ancienne feuille."
                reportRow = reportRow + 1
            End If
        End If
    Next i
End Sub

Function PrepareReportSheet(oDoc As Object) As Object
    Dim oSheets As Object
    oSheets = oDoc.Sheets

    If oSheets.hasByName(CF_REPORT_SHEET) Then
        oSheets.removeByName(CF_REPORT_SHEET)
    End If

    oSheets.insertNewByName(CF_REPORT_SHEET, oSheets.Count)
    PrepareReportSheet = oSheets.getByName(CF_REPORT_SHEET)
End Function

Sub WriteReportHeader(oSheet As Object, rowIndex As Long)
    SetCell oSheet, 0, rowIndex, "Framework"
    SetCell oSheet, 1, rowIndex, "Paire"
    SetCell oSheet, 2, rowIndex, "ID"
    SetCell oSheet, 3, rowIndex, "Colonne"
    SetCell oSheet, 4, rowIndex, "Statut"
    SetCell oSheet, 5, rowIndex, "Ancienne valeur"
    SetCell oSheet, 6, rowIndex, "Nouvelle valeur"
    SetCell oSheet, 7, rowIndex, "Message"
End Sub

Sub WriteDiff(oSheet As Object, ByRef rowIndex As Long, pairName As String, idValue As String, colName As String, oldValue As String, newValue As String)
    SetCell oSheet, 0, rowIndex, "V" & CF_VERSION
    SetCell oSheet, 1, rowIndex, pairName
    SetCell oSheet, 2, rowIndex, idValue
    SetCell oSheet, 3, rowIndex, colName
    SetCell oSheet, 4, rowIndex, CF_STATUS_CHANGED
    SetCell oSheet, 5, rowIndex, oldValue
    SetCell oSheet, 6, rowIndex, newValue
    SetCell oSheet, 7, rowIndex, "Valeur differente."
End Sub

Sub WriteIssue(oSheet As Object, ByRef rowIndex As Long, pairName As String, idValue As String, colName As String, statusValue As String, messageText As String)
    SetCell oSheet, 0, rowIndex, "V" & CF_VERSION
    SetCell oSheet, 1, rowIndex, pairName
    SetCell oSheet, 2, rowIndex, idValue
    SetCell oSheet, 3, rowIndex, colName
    SetCell oSheet, 4, rowIndex, statusValue
    SetCell oSheet, 5, rowIndex, ""
    SetCell oSheet, 6, rowIndex, ""
    SetCell oSheet, 7, rowIndex, messageText
End Sub

Sub WriteSummary(oSheet As Object, ByRef rowIndex As Long, pairCount As Long)
    rowIndex = rowIndex + 2
    SetCell oSheet, 0, rowIndex, "Resume"
    SetCell oSheet, 1, rowIndex, "Paires comparees"
    SetCell oSheet, 2, rowIndex, CStr(pairCount)
End Sub

Sub FormatReport(oSheet As Object)
    Dim oRange As Object
    oRange = oSheet.getCellRangeByPosition(0, 0, 7, 0)
    oRange.CharWeight = 150

    Dim i As Long
    For i = 0 To 7
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i
End Sub

Function ReadHeaders(oSheet As Object, lastCol As Long) As Variant
    Dim headers() As String, c As Long
    If lastCol < 0 Then lastCol = 0
    ReDim headers(lastCol)

    For c = 0 To lastCol
        headers(c) = Trim(CellText(oSheet, c, CF_HEADER_ROW))
    Next c

    ReadHeaders = headers
End Function

Function FindIdColumn(headers As Variant) As Long
    Dim i As Long, h As String
    For i = LBound(headers) To UBound(headers)
        h = NormalizeHeader(CStr(headers(i)))
        If h = "id" Or h = "identifiant" Or h = "code" Or h = "reference" Or h = "ref" Or h = "cle" Or h = "key" Then
            FindIdColumn = i
            Exit Function
        End If
    Next i
    FindIdColumn = -1
End Function

Function HeaderIndex(headers As Variant, headerName As String) As Long
    Dim i As Long
    For i = LBound(headers) To UBound(headers)
        If NormalizeHeader(CStr(headers(i))) = NormalizeHeader(headerName) Then
            HeaderIndex = i
            Exit Function
        End If
    Next i
    HeaderIndex = -1
End Function

Function FindRowById(oSheet As Object, idCol As Long, lastRow As Long, idValue As String) As Long
    Dim r As Long
    For r = CF_FIRST_DATA_ROW To lastRow
        If CellText(oSheet, idCol, r) = idValue Then
            FindRowById = r
            Exit Function
        End If
    Next r
    FindRowById = -1
End Function

Function LastUsedRow(oSheet As Object) As Long
    Dim cursor As Object
    cursor = oSheet.createCursor()
    cursor.gotoEndOfUsedArea(True)
    LastUsedRow = cursor.RangeAddress.EndRow
End Function

Function LastUsedCol(oSheet As Object) As Long
    Dim cursor As Object
    cursor = oSheet.createCursor()
    cursor.gotoEndOfUsedArea(True)
    LastUsedCol = cursor.RangeAddress.EndColumn
End Function

Function CellText(oSheet As Object, col As Long, row As Long) As String
    Dim oCell As Object
    oCell = oSheet.getCellByPosition(col, row)
    If oCell.Type = com.sun.star.table.CellContentType.EMPTY Then
        CellText = ""
    Else
        CellText = Trim(oCell.String)
    End If
End Function

Sub SetCell(oSheet As Object, col As Long, row As Long, valueText As String)
    oSheet.getCellByPosition(col, row).String = valueText
End Sub

Function NormalizeHeader(valueText As String) As String
    Dim s As String
    s = LCase(Trim(valueText))
    s = Replace(s, " ", "_")
    s = Replace(s, "-", "_")
    s = Replace(s, ".", "")
    s = Replace(s, "'", "")
    s = Replace(s, "é", "e")
    s = Replace(s, "è", "e")
    s = Replace(s, "ê", "e")
    s = Replace(s, "à", "a")
    s = Replace(s, "ç", "c")
    NormalizeHeader = s
End Function

Function IsReportSheet(sheetName As String) As Boolean
    IsReportSheet = (LCase(sheetName) = LCase(CF_REPORT_SHEET))
End Function

Function IsOldSheetName(sheetName As String) As Boolean
    Dim s As String
    s = UCase(sheetName)
    IsOldSheetName = EndsWith(s, "_OLD") Or EndsWith(s, "_REF") Or EndsWith(s, "_AVANT")
End Function

Function IsNewSheetName(sheetName As String) As Boolean
    Dim s As String
    s = UCase(sheetName)
    IsNewSheetName = EndsWith(s, "_NEW") Or EndsWith(s, "_NOUVEAU") Or EndsWith(s, "_APRES")
End Function

Function PairBaseName(sheetName As String) As String
    Dim s As String
    s = sheetName

    If EndsWith(UCase(s), "_OLD") Then PairBaseName = Left(s, Len(s) - 4): Exit Function
    If EndsWith(UCase(s), "_REF") Then PairBaseName = Left(s, Len(s) - 4): Exit Function
    If EndsWith(UCase(s), "_AVANT") Then PairBaseName = Left(s, Len(s) - 6): Exit Function
    If EndsWith(UCase(s), "_NEW") Then PairBaseName = Left(s, Len(s) - 4): Exit Function
    If EndsWith(UCase(s), "_NOUVEAU") Then PairBaseName = Left(s, Len(s) - 8): Exit Function
    If EndsWith(UCase(s), "_APRES") Then PairBaseName = Left(s, Len(s) - 6): Exit Function

    PairBaseName = ""
End Function

Function FindNewSheetForBase(oSheets As Object, baseName As String) As String
    If oSheets.hasByName(baseName & "_NEW") Then FindNewSheetForBase = baseName & "_NEW": Exit Function
    If oSheets.hasByName(baseName & "_NOUVEAU") Then FindNewSheetForBase = baseName & "_NOUVEAU": Exit Function
    If oSheets.hasByName(baseName & "_APRES") Then FindNewSheetForBase = baseName & "_APRES": Exit Function
    FindNewSheetForBase = ""
End Function

Function EndsWith(valueText As String, suffixText As String) As Boolean
    If Len(valueText) < Len(suffixText) Then
        EndsWith = False
    Else
        EndsWith = (Right(valueText, Len(suffixText)) = suffixText)
    End If
End Function
