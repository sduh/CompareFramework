Option Explicit

' CompareFramework V0.5
' LibreOffice Basic module
'
' Main macro:
'   ComparerToutesLesFeuilles
'
' V0.5:
'   - keeps V0.4 detailed report and statistics
'   - adds optional Compare_Config sheet support
'   - supports ignored columns through config key IGNORE_COLUMNS
'   - supports comparison options IGNORE_CASE, NORMALIZE_SPACES and IGNORE_EMPTY_CHANGES
'   - supports custom ID aliases through config key ID_ALIASES
'   - writes the active configuration in the statistics sheet
'
' Expected conventions:
'   - header row is row 1
'   - data starts row 2
'   - ID column can be named: ID, Identifiant, Code, Reference, Ref, Cle, Key
'   - old/reference sheets may end with _OLD, _REF or _AVANT
'   - new/current sheets may end with _NEW, _NOUVEAU or _APRES
'   - if no pair is found and the document has exactly two non-report sheets,
'     those two sheets are compared.

Const CF_VERSION As String = "0.5"
Const CF_REPORT_SHEET As String = "Rapport_Comparaison"
Const CF_STATS_SHEET As String = "Stats_Comparaison"
Const CF_CONFIG_SHEET As String = "Compare_Config"
Const CF_HEADER_ROW As Long = 0
Const CF_FIRST_DATA_ROW As Long = 1

Const CF_STATUS_ADDED As String = "AJOUTE"
Const CF_STATUS_REMOVED As String = "SUPPRIME"
Const CF_STATUS_CHANGED As String = "MODIFIE"
Const CF_STATUS_DUPLICATE As String = "DOUBLON"
Const CF_STATUS_INFO As String = "INFO"
Const CF_STATUS_ERROR As String = "ERREUR"

Const CF_COL_VERSION As Long = 0
Const CF_COL_PAIR As Long = 1
Const CF_COL_ID As Long = 2
Const CF_COL_TYPE As Long = 3
Const CF_COL_COLUMN As Long = 4
Const CF_COL_OLD_ROW As Long = 5
Const CF_COL_NEW_ROW As Long = 6
Const CF_COL_OLD_VALUE As Long = 7
Const CF_COL_NEW_VALUE As Long = 8
Const CF_COL_MESSAGE As Long = 9
Const CF_LAST_REPORT_COL As Long = 9

Sub ComparerToutesLesFeuilles()
    Dim oDoc As Object, oReport As Object, oStats As Object
    Dim reportRow As Long, statsRow As Long, pairCount As Long
    Dim totalAdded As Long, totalRemoved As Long, totalChangedRows As Long
    Dim totalChangedCells As Long, totalDuplicates As Long, totalIssues As Long

    oDoc = ThisComponent

    oReport = PrepareSheet(oDoc, CF_REPORT_SHEET)
    oStats = PrepareSheet(oDoc, CF_STATS_SHEET)

    reportRow = 0
    statsRow = 0
    WriteReportHeader oReport, reportRow
    WriteStatsHeader oStats, statsRow
    EnsureDefaultConfigSheet oDoc
    reportRow = reportRow + 1
    statsRow = statsRow + 1

    pairCount = CompareDetectedPairs(oDoc, oReport, reportRow, oStats, statsRow, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues)

    If pairCount = 0 Then
        pairCount = CompareFallbackTwoSheets(oDoc, oReport, reportRow, oStats, statsRow, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues)
    End If

    WriteGlobalSummary oStats, statsRow, pairCount, totalAdded, totalRemoved, totalChangedRows, totalChangedCells, totalDuplicates, totalIssues
    WriteActiveConfig oStats, statsRow
    FormatReport oReport, reportRow - 1
    FormatStats oStats, statsRow + 8

    MsgBox "Comparaison terminee." & Chr(10) & _
           "Paires comparees : " & pairCount & Chr(10) & _
           "Lignes ajoutees : " & totalAdded & Chr(10) & _
           "Lignes supprimees : " & totalRemoved & Chr(10) & _
           "Lignes modifiees : " & totalChangedRows & Chr(10) & _
           "Cellules modifiees : " & totalChangedCells, 64, "CompareFramework V" & CF_VERSION
End Sub

Function CompareDetectedPairs(oDoc As Object, oReport As Object, ByRef reportRow As Long, oStats As Object, ByRef statsRow As Long, ByRef totalAdded As Long, ByRef totalRemoved As Long, ByRef totalChangedRows As Long, ByRef totalChangedCells As Long, ByRef totalDuplicates As Long, ByRef totalIssues As Long) As Long
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

Function CompareFallbackTwoSheets(oDoc As Object, oReport As Object, ByRef reportRow As Long, oStats As Object, ByRef statsRow As Long, ByRef totalAdded As Long, ByRef totalRemoved As Long, ByRef totalChangedRows As Long, ByRef totalChangedCells As Long, ByRef totalDuplicates As Long, ByRef totalIssues As Long) As Long
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

Sub CompareSheetPair(oOld As Object, oNew As Object, oReport As Object, ByRef reportRow As Long, oStats As Object, ByRef statsRow As Long, ByRef totalAdded As Long, ByRef totalRemoved As Long, ByRef totalChangedRows As Long, ByRef totalChangedCells As Long, ByRef totalDuplicates As Long, ByRef totalIssues As Long)
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
        WriteReportRow oReport, reportRow, pairName, "", CF_STATUS_ERROR, "ID", "", "", "", "", "Colonne ID introuvable. Noms acceptes : ID, Identifiant, Code, Reference, Ref, Cle, Key."
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

Function CompareRowCellsDetailed(oOld As Object, oNew As Object, oldHeaders As Variant, newHeaders As Variant, oldRow As Long, newRow As Long, idValue As String, pairName As String, oReport As Object, ByRef reportRow As Long) As Long
    Dim i As Long, newCol As Long
    Dim headerName As String, oldValue As String, newValue As String
    Dim changedCells As Long

    changedCells = 0

    For i = LBound(oldHeaders) To UBound(oldHeaders)
        headerName = Trim(CStr(oldHeaders(i)))
        If headerName <> "" Then
            If IsIgnoredColumn(headerName) = False Then
                newCol = HeaderIndex(newHeaders, headerName)
                If newCol >= 0 Then
                    oldValue = CellText(oOld, i, oldRow)
                    newValue = CellText(oNew, newCol, newRow)
                    If ValuesAreDifferent(oldValue, newValue) Then
                        WriteReportRow oReport, reportRow, pairName, idValue, CF_STATUS_CHANGED, headerName, RowNumberText(oldRow), RowNumberText(newRow), oldValue, newValue, "Valeur differente."
                        reportRow = reportRow + 1
                        changedCells = changedCells + 1
                    End If
                End If
            End If
        End If
    Next i

    CompareRowCellsDetailed = changedCells
End Function

Sub ReportColumnDifferences(oldHeaders As Variant, newHeaders As Variant, oReport As Object, ByRef reportRow As Long, pairName As String, ByRef pairIssues As Long)
    Dim i As Long, headerName As String

    For i = LBound(oldHeaders) To UBound(oldHeaders)
        headerName = Trim(CStr(oldHeaders(i)))
        If headerName <> "" Then
            If IsIgnoredColumn(headerName) = False Then
                If HeaderIndex(newHeaders, headerName) < 0 Then
                    WriteReportRow oReport, reportRow, pairName, "", CF_STATUS_REMOVED, headerName, "", "", "Colonne presente", "", "Colonne absente dans la nouvelle feuille."
                    reportRow = reportRow + 1
                    pairIssues = pairIssues + 1
                End If
            End If
        End If
    Next i

    For i = LBound(newHeaders) To UBound(newHeaders)
        headerName = Trim(CStr(newHeaders(i)))
        If headerName <> "" Then
            If IsIgnoredColumn(headerName) = False Then
                If HeaderIndex(oldHeaders, headerName) < 0 Then
                    WriteReportRow oReport, reportRow, pairName, "", CF_STATUS_ADDED, headerName, "", "", "", "Colonne presente", "Colonne absente dans l'ancienne feuille."
                    reportRow = reportRow + 1
                    pairIssues = pairIssues + 1
                End If
            End If
        End If
    Next i
End Sub

Function PrepareSheet(oDoc As Object, sheetName As String) As Object
    Dim oSheets As Object
    oSheets = oDoc.Sheets

    If oSheets.hasByName(sheetName) Then
        oSheets.removeByName(sheetName)
    End If

    oSheets.insertNewByName(sheetName, oSheets.Count)
    PrepareSheet = oSheets.getByName(sheetName)
End Function

Sub WriteReportHeader(oSheet As Object, rowIndex As Long)
    SetCell oSheet, CF_COL_VERSION, rowIndex, "Framework"
    SetCell oSheet, CF_COL_PAIR, rowIndex, "Paire"
    SetCell oSheet, CF_COL_ID, rowIndex, "ID"
    SetCell oSheet, CF_COL_TYPE, rowIndex, "Type"
    SetCell oSheet, CF_COL_COLUMN, rowIndex, "Colonne"
    SetCell oSheet, CF_COL_OLD_ROW, rowIndex, "Ligne ancienne"
    SetCell oSheet, CF_COL_NEW_ROW, rowIndex, "Ligne nouvelle"
    SetCell oSheet, CF_COL_OLD_VALUE, rowIndex, "Ancienne valeur"
    SetCell oSheet, CF_COL_NEW_VALUE, rowIndex, "Nouvelle valeur"
    SetCell oSheet, CF_COL_MESSAGE, rowIndex, "Message"
End Sub

Sub WriteReportRow(oSheet As Object, ByRef rowIndex As Long, pairName As String, idValue As String, statusValue As String, colName As String, oldRow As String, newRow As String, oldValue As String, newValue As String, messageText As String)
    SetCell oSheet, CF_COL_VERSION, rowIndex, "V" & CF_VERSION
    SetCell oSheet, CF_COL_PAIR, rowIndex, pairName
    SetCell oSheet, CF_COL_ID, rowIndex, idValue
    SetCell oSheet, CF_COL_TYPE, rowIndex, statusValue
    SetCell oSheet, CF_COL_COLUMN, rowIndex, colName
    SetCell oSheet, CF_COL_OLD_ROW, rowIndex, oldRow
    SetCell oSheet, CF_COL_NEW_ROW, rowIndex, newRow
    SetCell oSheet, CF_COL_OLD_VALUE, rowIndex, oldValue
    SetCell oSheet, CF_COL_NEW_VALUE, rowIndex, newValue
    SetCell oSheet, CF_COL_MESSAGE, rowIndex, messageText
End Sub

Sub WriteStatsHeader(oSheet As Object, rowIndex As Long)
    SetCell oSheet, 0, rowIndex, "Paire"
    SetCell oSheet, 1, rowIndex, "Lignes ajoutees"
    SetCell oSheet, 2, rowIndex, "Lignes supprimees"
    SetCell oSheet, 3, rowIndex, "Lignes modifiees"
    SetCell oSheet, 4, rowIndex, "Cellules modifiees"
    SetCell oSheet, 5, rowIndex, "ID doublons"
    SetCell oSheet, 6, rowIndex, "Lignes anciennes indexees"
    SetCell oSheet, 7, rowIndex, "Lignes nouvelles indexees"
    SetCell oSheet, 8, rowIndex, "Alertes structure"
End Sub

Sub WriteStatsRow(oSheet As Object, ByRef rowIndex As Long, pairName As String, addedRows As Long, removedRows As Long, changedRows As Long, changedCells As Long, duplicates As Long, oldCount As Long, newCount As Long, issues As Long)
    SetCell oSheet, 0, rowIndex, pairName
    SetCell oSheet, 1, rowIndex, CStr(addedRows)
    SetCell oSheet, 2, rowIndex, CStr(removedRows)
    SetCell oSheet, 3, rowIndex, CStr(changedRows)
    SetCell oSheet, 4, rowIndex, CStr(changedCells)
    SetCell oSheet, 5, rowIndex, CStr(duplicates)
    SetCell oSheet, 6, rowIndex, CStr(oldCount)
    SetCell oSheet, 7, rowIndex, CStr(newCount)
    SetCell oSheet, 8, rowIndex, CStr(issues)
End Sub

Sub WriteGlobalSummary(oSheet As Object, ByRef rowIndex As Long, pairCount As Long, totalAdded As Long, totalRemoved As Long, totalChangedRows As Long, totalChangedCells As Long, totalDuplicates As Long, totalIssues As Long)
    rowIndex = rowIndex + 2
    SetCell oSheet, 0, rowIndex, "Resume global"
    SetCell oSheet, 1, rowIndex, "Valeur"

    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Version"
    SetCell oSheet, 1, rowIndex, "V" & CF_VERSION
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Paires comparees"
    SetCell oSheet, 1, rowIndex, CStr(pairCount)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Lignes ajoutees"
    SetCell oSheet, 1, rowIndex, CStr(totalAdded)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Lignes supprimees"
    SetCell oSheet, 1, rowIndex, CStr(totalRemoved)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Lignes modifiees"
    SetCell oSheet, 1, rowIndex, CStr(totalChangedRows)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Cellules modifiees"
    SetCell oSheet, 1, rowIndex, CStr(totalChangedCells)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "ID doublons"
    SetCell oSheet, 1, rowIndex, CStr(totalDuplicates)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Alertes structure"
    SetCell oSheet, 1, rowIndex, CStr(totalIssues)
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
        If h = "id" Or h = "identifiant" Or h = "code" Or h = "reference" Or h = "ref" Or h = "cle" Or h = "key" Or IsConfiguredIdAlias(h) Then
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

Sub BuildIdIndex(oSheet As Object, idCol As Long, lastRow As Long, ByRef ids As Variant, ByRef rows As Variant, ByRef count As Long)
    Dim r As Long, idValue As String, cap As Long

    cap = lastRow - CF_FIRST_DATA_ROW + 1
    If cap < 1 Then cap = 1
    ReDim ids(cap - 1)
    ReDim rows(cap - 1)
    count = 0

    For r = CF_FIRST_DATA_ROW To lastRow
        idValue = CellText(oSheet, idCol, r)
        If idValue <> "" Then
            ids(count) = idValue
            rows(count) = r
            count = count + 1
        End If
    Next r

    If count = 0 Then
        ReDim ids(0)
        ReDim rows(0)
    Else
        ReDim Preserve ids(count - 1)
        ReDim Preserve rows(count - 1)
    End If
End Sub

Function FindRowInIndex(ids As Variant, rows As Variant, count As Long, idValue As String) As Long
    Dim lo As Long, hi As Long, mid As Long, currentId As String

    If count <= 0 Then
        FindRowInIndex = -1
        Exit Function
    End If

    lo = 0
    hi = count - 1

    Do While lo <= hi
        mid = (lo + hi) \ 2
        currentId = CStr(ids(mid))
        If currentId = idValue Then
            FindRowInIndex = CLng(rows(mid))
            Exit Function
        ElseIf currentId < idValue Then
            lo = mid + 1
        Else
            hi = mid - 1
        End If
    Loop

    FindRowInIndex = -1
End Function

Sub QuickSortIndex(ByRef ids As Variant, ByRef rows As Variant, ByVal first As Long, ByVal last As Long)
    Dim i As Long, j As Long, pivot As String
    Dim tmpId As Variant, tmpRow As Variant

    i = first
    j = last
    pivot = CStr(ids((first + last) \ 2))

    Do While i <= j
        Do While CStr(ids(i)) < pivot
            i = i + 1
        Loop
        Do While CStr(ids(j)) > pivot
            j = j - 1
        Loop
        If i <= j Then
            tmpId = ids(i)
            ids(i) = ids(j)
            ids(j) = tmpId
            tmpRow = rows(i)
            rows(i) = rows(j)
            rows(j) = tmpRow
            i = i + 1
            j = j - 1
        End If
    Loop

    If first < j Then QuickSortIndex ids, rows, first, j
    If i < last Then QuickSortIndex ids, rows, i, last
End Sub

Function ReportDuplicateIds(ids As Variant, rows As Variant, count As Long, oReport As Object, ByRef reportRow As Long, pairName As String, sideName As String) As Long
    Dim i As Long, duplicateCount As Long, idValue As String

    duplicateCount = 0
    If count <= 1 Then
        ReportDuplicateIds = 0
        Exit Function
    End If

    For i = 1 To count - 1
        If CStr(ids(i)) = CStr(ids(i - 1)) Then
            idValue = CStr(ids(i))
            WriteReportRow oReport, reportRow, pairName, idValue, CF_STATUS_DUPLICATE, "ID", RowNumberText(rows(i - 1)), RowNumberText(rows(i)), "", "", "ID en double dans la feuille " & sideName & "."
            reportRow = reportRow + 1
            duplicateCount = duplicateCount + 1
        End If
    Next i

    ReportDuplicateIds = duplicateCount
End Function

Function FullRowText(oSheet As Object, headers As Variant, rowIndex As Long) As String
    Dim i As Long, h As String, v As String, result As String
    result = ""

    For i = LBound(headers) To UBound(headers)
        h = Trim(CStr(headers(i)))
        If h <> "" Then
            v = CellText(oSheet, i, rowIndex)
            If result <> "" Then result = result & " | "
            result = result & h & "=" & v
        End If
    Next i

    FullRowText = result
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

Function RowNumberText(rowIndex As Variant) As String
    RowNumberText = CStr(CLng(rowIndex) + 1)
End Function

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
    s = Replace(s, "ë", "e")
    s = Replace(s, "à", "a")
    s = Replace(s, "â", "a")
    s = Replace(s, "î", "i")
    s = Replace(s, "ï", "i")
    s = Replace(s, "ô", "o")
    s = Replace(s, "ù", "u")
    s = Replace(s, "û", "u")
    s = Replace(s, "ç", "c")
    NormalizeHeader = s
End Function

Function IsReportOrStatsSheet(sheetName As String) As Boolean
    IsReportOrStatsSheet = (LCase(sheetName) = LCase(CF_REPORT_SHEET) Or LCase(sheetName) = LCase(CF_STATS_SHEET) Or LCase(sheetName) = LCase(CF_CONFIG_SHEET))
End Function

Function IsOldSheetName(sheetName As String) As Boolean
    Dim s As String
    s = UCase(sheetName)
    IsOldSheetName = EndsWith(s, "_OLD") Or EndsWith(s, "_REF") Or EndsWith(s, "_AVANT")
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


Function ValuesAreDifferent(oldValue As String, newValue As String) As Boolean
    Dim leftValue As String, rightValue As String

    If ConfigFlag("IGNORE_EMPTY_CHANGES", False) Then
        If Trim(oldValue) = "" Or Trim(newValue) = "" Then
            ValuesAreDifferent = False
            Exit Function
        End If
    End If

    leftValue = NormalizeValueForCompare(oldValue)
    rightValue = NormalizeValueForCompare(newValue)
    ValuesAreDifferent = (leftValue <> rightValue)
End Function

Function NormalizeValueForCompare(valueText As String) As String
    Dim s As String
    s = valueText

    If ConfigFlag("NORMALIZE_SPACES", True) Then
        s = CleanSpaces(s)
    End If

    If ConfigFlag("IGNORE_CASE", False) Then
        s = LCase(s)
    End If

    NormalizeValueForCompare = s
End Function

Function CleanSpaces(valueText As String) As String
    Dim s As String
    s = Trim(valueText)
    Do While InStr(s, "  ") > 0
        s = Replace(s, "  ", " ")
    Loop
    CleanSpaces = s
End Function

Function IsIgnoredColumn(headerName As String) As Boolean
    IsIgnoredColumn = ValueInConfigList("IGNORE_COLUMNS", headerName)
End Function

Function IsConfiguredIdAlias(normalizedHeader As String) As Boolean
    IsConfiguredIdAlias = ValueInConfigList("ID_ALIASES", normalizedHeader)
End Function

Function ValueInConfigList(keyName As String, valueText As String) As Boolean
    Dim rawList As String, parts As Variant
    Dim i As Long, target As String, item As String

    rawList = GetConfigValue(keyName, "")
    target = NormalizeHeader(valueText)
    ValueInConfigList = False

    If Trim(rawList) = "" Then Exit Function

    parts = Split(rawList, ";")
    For i = LBound(parts) To UBound(parts)
        item = NormalizeHeader(CStr(parts(i)))
        If item = target Then
            ValueInConfigList = True
            Exit Function
        End If
    Next i
End Function

Function ConfigFlag(keyName As String, defaultValue As Boolean) As Boolean
    Dim rawValue As String, fallback As String

    If defaultValue Then
        fallback = "TRUE"
    Else
        fallback = "FALSE"
    End If

    rawValue = LCase(Trim(GetConfigValue(keyName, fallback)))

    ConfigFlag = defaultValue
    If rawValue = "true" Or rawValue = "yes" Or rawValue = "oui" Or rawValue = "1" Or rawValue = "vrai" Then ConfigFlag = True
    If rawValue = "false" Or rawValue = "no" Or rawValue = "non" Or rawValue = "0" Or rawValue = "faux" Then ConfigFlag = False
End Function

Function GetConfigValue(keyName As String, defaultValue As String) As String
    On Error GoTo MissingConfig
    Dim oDoc As Object, oSheet As Object
    Dim lastRow As Long, r As Long, currentKey As String

    oDoc = ThisComponent
    If oDoc.Sheets.hasByName(CF_CONFIG_SHEET) = False Then
        GetConfigValue = defaultValue
        Exit Function
    End If

    oSheet = oDoc.Sheets.getByName(CF_CONFIG_SHEET)
    lastRow = LastUsedRow(oSheet)

    For r = 1 To lastRow
        currentKey = UCase(Trim(CellText(oSheet, 0, r)))
        If currentKey = UCase(Trim(keyName)) Then
            GetConfigValue = CellText(oSheet, 1, r)
            Exit Function
        End If
    Next r

MissingConfig:
    GetConfigValue = defaultValue
    On Error GoTo 0
End Function

Sub EnsureDefaultConfigSheet(oDoc As Object)
    Dim oSheet As Object

    If oDoc.Sheets.hasByName(CF_CONFIG_SHEET) Then Exit Sub

    oDoc.Sheets.insertNewByName(CF_CONFIG_SHEET, oDoc.Sheets.Count)
    oSheet = oDoc.Sheets.getByName(CF_CONFIG_SHEET)

    SetCell oSheet, 0, 0, "Cle"
    SetCell oSheet, 1, 0, "Valeur"
    SetCell oSheet, 2, 0, "Description"

    SetCell oSheet, 0, 1, "IGNORE_COLUMNS"
    SetCell oSheet, 1, 1, ""
    SetCell oSheet, 2, 1, "Colonnes a ignorer, separees par des points-virgules. Exemple : Date_Modif;Commentaire"

    SetCell oSheet, 0, 2, "IGNORE_CASE"
    SetCell oSheet, 1, 2, "FALSE"
    SetCell oSheet, 2, 2, "TRUE pour ignorer les differences majuscules/minuscules."

    SetCell oSheet, 0, 3, "NORMALIZE_SPACES"
    SetCell oSheet, 1, 3, "TRUE"
    SetCell oSheet, 2, 3, "TRUE pour reduire les espaces multiples et ignorer les espaces en debut/fin."

    SetCell oSheet, 0, 4, "IGNORE_EMPTY_CHANGES"
    SetCell oSheet, 1, 4, "FALSE"
    SetCell oSheet, 2, 4, "TRUE pour ignorer les differences ou l'une des deux valeurs est vide."

    SetCell oSheet, 0, 5, "ID_ALIASES"
    SetCell oSheet, 1, 5, ""
    SetCell oSheet, 2, 5, "Noms supplementaires acceptes pour la colonne ID, separes par des points-virgules."

    oSheet.getCellRangeByPosition(0, 0, 2, 0).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 0, 2, 0).CellBackColor = RGB(217, 217, 217)
    oSheet.Columns.getByIndex(0).OptimalWidth = True
    oSheet.Columns.getByIndex(1).OptimalWidth = True
    oSheet.Columns.getByIndex(2).OptimalWidth = True
End Sub

Sub WriteActiveConfig(oSheet As Object, ByRef rowIndex As Long)
    rowIndex = rowIndex + 2
    SetCell oSheet, 0, rowIndex, "Configuration active"
    SetCell oSheet, 1, rowIndex, "Valeur"

    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "IGNORE_COLUMNS"
    SetCell oSheet, 1, rowIndex, GetConfigValue("IGNORE_COLUMNS", "")
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "IGNORE_CASE"
    SetCell oSheet, 1, rowIndex, GetConfigValue("IGNORE_CASE", "FALSE")
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "NORMALIZE_SPACES"
    SetCell oSheet, 1, rowIndex, GetConfigValue("NORMALIZE_SPACES", "TRUE")
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "IGNORE_EMPTY_CHANGES"
    SetCell oSheet, 1, rowIndex, GetConfigValue("IGNORE_EMPTY_CHANGES", "FALSE")
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "ID_ALIASES"
    SetCell oSheet, 1, rowIndex, GetConfigValue("ID_ALIASES", "")
End Sub

Sub FormatReport(oSheet As Object, lastRow As Long)
    Dim oHeader As Object, oRange As Object
    Dim r As Long, statusValue As String
    Dim i As Long

    If lastRow < 0 Then lastRow = 0

    oHeader = oSheet.getCellRangeByPosition(0, 0, CF_LAST_REPORT_COL, 0)
    oHeader.CharWeight = 150
    oHeader.CellBackColor = RGB(217, 217, 217)

    For r = 1 To lastRow
        statusValue = CellText(oSheet, CF_COL_TYPE, r)
        oRange = oSheet.getCellRangeByPosition(0, r, CF_LAST_REPORT_COL, r)
        Select Case statusValue
            Case CF_STATUS_ADDED
                oRange.CellBackColor = RGB(226, 239, 218)
            Case CF_STATUS_REMOVED
                oRange.CellBackColor = RGB(252, 228, 214)
            Case CF_STATUS_CHANGED
                oRange.CellBackColor = RGB(255, 242, 204)
            Case CF_STATUS_DUPLICATE
                oRange.CellBackColor = RGB(248, 203, 173)
            Case CF_STATUS_ERROR
                oRange.CellBackColor = RGB(255, 199, 206)
        End Select
    Next r

    For i = 0 To CF_LAST_REPORT_COL
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i

    ApplyOptionalAutoFilter oSheet, CF_LAST_REPORT_COL, lastRow
End Sub

Sub FormatStats(oSheet As Object, lastRow As Long)
    Dim oHeader As Object
    Dim i As Long

    oHeader = oSheet.getCellRangeByPosition(0, 0, 8, 0)
    oHeader.CharWeight = 150
    oHeader.CellBackColor = RGB(217, 217, 217)

    For i = 0 To 8
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i
End Sub

Sub ApplyOptionalAutoFilter(oSheet As Object, lastCol As Long, lastRow As Long)
    On Error GoTo SkipFilter
    Dim oRange As Object
    oRange = oSheet.getCellRangeByPosition(0, 0, lastCol, lastRow)
    oRange.AutoFilter = True
SkipFilter:
    On Error GoTo 0
End Sub
