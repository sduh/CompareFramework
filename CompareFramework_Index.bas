' CompareFramework V2.4 - Index
' Indexation des identifiants, recherche et doublons.
Option Explicit

Public Sub BuildIdIndex(oSheet As Object, idCol As Long, lastRow As Long, ByRef ids As Variant, ByRef rows As Variant, ByRef count As Long)
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

Public Function FindRowInIndex(ids As Variant, rows As Variant, count As Long, idValue As String) As Long
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

Public Sub QuickSortIndex(ByRef ids As Variant, ByRef rows As Variant, ByVal first As Long, ByVal last As Long)
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

Public Function ReportDuplicateIds(ids As Variant, rows As Variant, count As Long, oReport As Object, ByRef reportRow As Long, pairName As String, sideName As String) As Long
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

Public Function ReadHeaders(oSheet As Object, lastCol As Long) As Variant
    Dim headers() As String, c As Long
    If lastCol < 0 Then lastCol = 0
    ReDim headers(lastCol)

    For c = 0 To lastCol
        headers(c) = Trim(CellText(oSheet, c, CF_HEADER_ROW))
    Next c

    ReadHeaders = headers
End Function

Public Function HeaderIndex(headers As Variant, headerName As String) As Long
    Dim i As Long
    For i = LBound(headers) To UBound(headers)
        If NormalizeHeader(CStr(headers(i))) = NormalizeHeader(headerName) Then
            HeaderIndex = i
            Exit Function
        End If
    Next i
    HeaderIndex = -1
End Function

