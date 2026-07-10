' CompareFramework V3.5 - Rules
' Moteur de règles et comparaison détaillée.
Option Explicit

Public Sub LoadCompareRules(oDoc As Object)
    Dim oSheet As Object
    Dim lastRow As Long, r As Long, n As Long

    gRuleCount = 0
    ReDim gRuleEnabled(0)
    ReDim gRuleScope(0)
    ReDim gRuleColumn(0)
    ReDim gRuleType(0)
    ReDim gRuleParam1(0)
    ReDim gRuleParam2(0)
    ReDim gRuleComment(0)

    If Not oDoc.Sheets.hasByName(CF_RULES_SHEET) Then Exit Sub
    oSheet = oDoc.Sheets.getByName(CF_RULES_SHEET)
    lastRow = LastUsedRow(oSheet)
    If lastRow < 1 Then Exit Sub

    For r = 1 To lastRow
        If Trim(CellText(oSheet, 0, r)) <> "" Or Trim(CellText(oSheet, 4, r)) <> "" Then
            n = gRuleCount
            ReDim Preserve gRuleEnabled(n)
            ReDim Preserve gRuleScope(n)
            ReDim Preserve gRuleColumn(n)
            ReDim Preserve gRuleType(n)
            ReDim Preserve gRuleParam1(n)
            ReDim Preserve gRuleParam2(n)
            ReDim Preserve gRuleComment(n)

            gRuleEnabled(n) = ToBoolean(CellText(oSheet, 1, r))
            gRuleScope(n) = UCase(Trim(CellText(oSheet, 2, r)))
            If gRuleScope(n) = "" Then gRuleScope(n) = "GLOBAL"
            gRuleColumn(n) = NormalizeHeader(CellText(oSheet, 3, r))
            gRuleType(n) = UCase(Trim(CellText(oSheet, 4, r)))
            gRuleParam1(n) = CellText(oSheet, 5, r)
            gRuleParam2(n) = CellText(oSheet, 6, r)
            gRuleComment(n) = CellText(oSheet, 7, r)
            gRuleCount = gRuleCount + 1
        End If
    Next r
End Sub

Public Function ShouldIgnoreDifference(pairName As String, idValue As String, headerName As String, oldValue As String, newValue As String, oldCompare As String, newCompare As String) As Boolean
    Dim i As Long
    ShouldIgnoreDifference = False

    If gRuleCount <= 0 Then Exit Function

    For i = 0 To gRuleCount - 1
        If gRuleEnabled(i) Then
            If RuleAppliesToColumn(i, headerName) Then
                If RuleAppliesToScope(i, pairName) Then
                    If EvaluateDifferenceRule(i, oldValue, newValue, oldCompare, newCompare) Then
                        ShouldIgnoreDifference = True
                        Exit Function
                    End If
                End If
            End If
        End If
    Next i
End Function

Public Function RuleAppliesToColumn(ruleIndex As Long, headerName As String) As Boolean
    Dim colRule As String
    colRule = gRuleColumn(ruleIndex)
    RuleAppliesToColumn = (colRule = "" Or colRule = "*" Or colRule = NormalizeHeader(headerName))
End Function

Public Function RuleAppliesToScope(ruleIndex As Long, pairName As String) As Boolean
    Dim scopeText As String
    scopeText = UCase(Trim(gRuleScope(ruleIndex)))
    RuleAppliesToScope = (scopeText = "" Or scopeText = "GLOBAL" Or InStr(UCase(pairName), scopeText) > 0)
End Function

Public Function EvaluateDifferenceRule(ruleIndex As Long, oldValue As String, newValue As String, oldCompare As String, newCompare As String) As Boolean
    Dim ruleType As String
    Dim p1 As String

    ruleType = UCase(Trim(gRuleType(ruleIndex)))
    p1 = gRuleParam1(ruleIndex)
    EvaluateDifferenceRule = False

    Select Case ruleType
        Case "EQUIVALENT_VALUES"
            EvaluateDifferenceRule = ValuesAreEquivalentByList(oldCompare, newCompare, p1)
        Case "NUMERIC_TOLERANCE"
            EvaluateDifferenceRule = ValuesAreWithinNumericTolerance(oldCompare, newCompare, p1)
        Case "IGNORE_IF_ONE_EMPTY"
            EvaluateDifferenceRule = (oldCompare = "" Or newCompare = "")
        Case "IGNORE_IF_BOTH_EMPTY_OR_MARKERS"
            EvaluateDifferenceRule = ValuesAreEquivalentByList(oldCompare, newCompare, p1)
        Case "IGNORE_EXACT_PAIR"
            EvaluateDifferenceRule = (oldCompare = NormalizeCompareValue(p1) And newCompare = NormalizeCompareValue(gRuleParam2(ruleIndex)))
        Case "CONTAINS_BOTH"
            EvaluateDifferenceRule = (InStr(oldCompare, NormalizeCompareValue(p1)) > 0 And InStr(newCompare, NormalizeCompareValue(p1)) > 0)
    End Select
End Function

Public Function ValuesAreEquivalentByList(oldCompare As String, newCompare As String, listText As String) As Boolean
    Dim normalizedList As String
    Dim oldToken As String, newToken As String

    oldToken = NormalizeHeader(oldCompare)
    newToken = NormalizeHeader(newCompare)
    normalizedList = ";" & NormalizeList(listText) & ";"

    ValuesAreEquivalentByList = (InStr(normalizedList, ";" & oldToken & ";") > 0 And InStr(normalizedList, ";" & newToken & ";") > 0)
End Function

Public Function ValuesAreWithinNumericTolerance(oldCompare As String, newCompare As String, toleranceText As String) As Boolean
    Dim tolerance As Double

    ValuesAreWithinNumericTolerance = False
    If Not IsNumericText(oldCompare) Then Exit Function
    If Not IsNumericText(newCompare) Then Exit Function
    If Not IsNumericText(toleranceText) Then Exit Function

    tolerance = ToNumber(toleranceText)
    ValuesAreWithinNumericTolerance = (AbsDiff(ToNumber(oldCompare), ToNumber(newCompare)) <= tolerance)
End Function

Public Function CompareRowCellsDetailed(oOld As Object, oNew As Object, oldHeaders As Variant, newHeaders As Variant, oldRow As Long, newRow As Long, idValue As String, pairName As String, oReport As Object, ByRef reportRow As Long) As Long
    Dim i As Long, newCol As Long
    Dim headerName As String, oldValue As String, newValue As String
    Dim oldCompare As String, newCompare As String
    Dim changedCells As Long

    changedCells = 0

    For i = LBound(oldHeaders) To UBound(oldHeaders)
        headerName = Trim(CStr(oldHeaders(i)))
        If headerName <> "" Then
            If ColumnIsIgnored(headerName) = False Then
                newCol = HeaderIndex(newHeaders, headerName)
                If newCol >= 0 Then
                    oldValue = CellText(oOld, i, oldRow)
                    newValue = CellText(oNew, newCol, newRow)
                    oldCompare = NormalizeCompareValue(oldValue)
                    newCompare = NormalizeCompareValue(newValue)
                    If oldCompare <> newCompare Then
                        If IgnoreThisEmptyChange(oldCompare, newCompare) = False Then
                            If ShouldIgnoreDifference(pairName, idValue, headerName, oldValue, newValue, oldCompare, newCompare) = False Then
                                WriteReportRow oReport, reportRow, pairName, idValue, CF_STATUS_CHANGED, headerName, RowNumberText(oldRow), RowNumberText(newRow), oldValue, newValue, "Valeur differente."
                                reportRow = reportRow + 1
                                changedCells = changedCells + 1
                            End If
                        End If
                    End If
                End If
            End If
        End If
    Next i

    CompareRowCellsDetailed = changedCells
End Function

Public Sub ReportColumnDifferences(oldHeaders As Variant, newHeaders As Variant, oReport As Object, ByRef reportRow As Long, pairName As String, ByRef pairIssues As Long)
    Dim i As Long, headerName As String

    For i = LBound(oldHeaders) To UBound(oldHeaders)
        headerName = Trim(CStr(oldHeaders(i)))
        If headerName <> "" Then
            If ColumnIsIgnored(headerName) = False And HeaderIndex(newHeaders, headerName) < 0 Then
                WriteReportRow oReport, reportRow, pairName, "", CF_STATUS_REMOVED, headerName, "", "", "Colonne presente", "", "Colonne absente dans la nouvelle feuille."
                reportRow = reportRow + 1
                pairIssues = pairIssues + 1
            End If
        End If
    Next i

    For i = LBound(newHeaders) To UBound(newHeaders)
        headerName = Trim(CStr(newHeaders(i)))
        If headerName <> "" Then
            If ColumnIsIgnored(headerName) = False And HeaderIndex(oldHeaders, headerName) < 0 Then
                WriteReportRow oReport, reportRow, pairName, "", CF_STATUS_ADDED, headerName, "", "", "", "Colonne presente", "Colonne absente dans l'ancienne feuille."
                reportRow = reportRow + 1
                pairIssues = pairIssues + 1
            End If
        End If
    Next i
End Sub
