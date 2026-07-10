' CompareFramework V3.1 - Utils
' Constantes globales et utilitaires communs.
Option Explicit

Public Const CF_VERSION As String = "3.1"
Public Const CF_REPORT_SHEET As String = "Rapport_Comparaison"
Public Const CF_STATS_SHEET As String = "Stats_Comparaison"
Public Const CF_CONFIG_SHEET As String = "Compare_Config"
Public Const CF_DASHBOARD_SHEET As String = "Synthese_Comparaison"
Public Const CF_ACTION_SHEET As String = "Plan_Action_Comparaison"
Public Const CF_AUDIT_SHEET As String = "Journal_Comparaison"
Public Const CF_RULES_SHEET As String = "Compare_Rules"
Public Const CF_HEADER_ROW As Long = 0
Public Const CF_FIRST_DATA_ROW As Long = 1
Public Const CF_STATUS_ADDED As String = "AJOUTE"
Public Const CF_STATUS_REMOVED As String = "SUPPRIME"
Public Const CF_STATUS_CHANGED As String = "MODIFIE"
Public Const CF_STATUS_DUPLICATE As String = "DOUBLON"
Public Const CF_STATUS_INFO As String = "INFO"
Public Const CF_STATUS_ERROR As String = "ERREUR"
Public Const CF_COL_VERSION As Long = 0
Public Const CF_COL_PAIR As Long = 1
Public Const CF_COL_ID As Long = 2
Public Const CF_COL_TYPE As Long = 3
Public Const CF_COL_COLUMN As Long = 4
Public Const CF_COL_OLD_ROW As Long = 5
Public Const CF_COL_NEW_ROW As Long = 6
Public Const CF_COL_OLD_VALUE As Long = 7
Public Const CF_COL_NEW_VALUE As Long = 8
Public Const CF_COL_MESSAGE As Long = 9
Public Const CF_LAST_REPORT_COL As Long = 9
Public gIgnoreColumns As String
Public gIdAliases As String
Public gIgnoreCase As Boolean
Public gNormalizeSpaces As Boolean
Public gIgnoreEmptyChanges As Boolean

' V2.3 - Rule engine storage
Public gRuleCount As Long
Public gRuleEnabled() As Boolean
Public gRuleScope() As String
Public gRuleColumn() As String
Public gRuleType() As String
Public gRuleParam1() As String
Public gRuleParam2() As String
Public gRuleComment() As String

Public Function FullRowText(oSheet As Object, headers As Variant, rowIndex As Long) As String
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

Public Function LastUsedRow(oSheet As Object) As Long
    Dim cursor As Object
    cursor = oSheet.createCursor()
    cursor.gotoEndOfUsedArea(True)
    LastUsedRow = cursor.RangeAddress.EndRow
End Function

Public Function LastUsedCol(oSheet As Object) As Long
    Dim cursor As Object
    cursor = oSheet.createCursor()
    cursor.gotoEndOfUsedArea(True)
    LastUsedCol = cursor.RangeAddress.EndColumn
End Function

Public Function CellText(oSheet As Object, col As Long, row As Long) As String
    Dim oCell As Object
    oCell = oSheet.getCellByPosition(col, row)
    If oCell.Type = com.sun.star.table.CellContentType.EMPTY Then
        CellText = ""
    Else
        CellText = Trim(oCell.String)
    End If
End Function

Public Sub SetCell(oSheet As Object, col As Long, row As Long, valueText As String)
    oSheet.getCellByPosition(col, row).String = valueText
End Sub

Public Function RowNumberText(rowIndex As Variant) As String
    RowNumberText = CStr(CLng(rowIndex) + 1)
End Function

Public Function NormalizeHeader(valueText As String) As String
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

Public Function IsReportOrStatsSheet(sheetName As String) As Boolean
    IsReportOrStatsSheet = (LCase(sheetName) = LCase(CF_REPORT_SHEET) Or _
        LCase(sheetName) = LCase(CF_STATS_SHEET) Or _
        LCase(sheetName) = LCase(CF_CONFIG_SHEET) Or _
        LCase(sheetName) = LCase(CF_RULES_SHEET) Or _
        LCase(sheetName) = LCase(CF_DASHBOARD_SHEET) Or _
        LCase(sheetName) = LCase(CF_ACTION_SHEET) Or _
        LCase(sheetName) = LCase(CF_AUDIT_SHEET) Or _
        LCase(sheetName) = LCase("Compare_Audit") Or _
        LCase(sheetName) = LCase("Compare_Validation") Or _
        LCase(sheetName) = LCase("Compare_Performance") Or _
        LCase(sheetName) = LCase("Compare_Context") Or _
        LCase(sheetName) = LCase("Compare_Profiles"))
End Function

Public Function IsOldSheetName(sheetName As String) As Boolean
    Dim s As String
    s = UCase(sheetName)
    IsOldSheetName = EndsWith(s, "_OLD") Or EndsWith(s, "_REF") Or EndsWith(s, "_AVANT")
End Function

Public Function PairBaseName(sheetName As String) As String
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

Public Function FindNewSheetForBase(oSheets As Object, baseName As String) As String
    If oSheets.hasByName(baseName & "_NEW") Then FindNewSheetForBase = baseName & "_NEW": Exit Function
    If oSheets.hasByName(baseName & "_NOUVEAU") Then FindNewSheetForBase = baseName & "_NOUVEAU": Exit Function
    If oSheets.hasByName(baseName & "_APRES") Then FindNewSheetForBase = baseName & "_APRES": Exit Function
    FindNewSheetForBase = ""
End Function

Public Function EndsWith(valueText As String, suffixText As String) As Boolean
    If Len(valueText) < Len(suffixText) Then
        EndsWith = False
    Else
        EndsWith = (Right(valueText, Len(suffixText)) = suffixText)
    End If
End Function

Public Function HtmlEscape(v As Variant) As String
    Dim s As String
    s = CStr(v)
    s = Replace(s, "&", "&amp;")
    s = Replace(s, "<", "&lt;")
    s = Replace(s, ">", "&gt;")
    s = Replace(s, """", "&quot;")
    s = Replace(s, "'", "&#39;")
    HtmlEscape = s
End Function

Public Function GetDocumentFolderPath() As String
    Dim sUrl As String
    Dim i As Long

    sUrl = ThisComponent.URL
    If sUrl = "" Then
        GetDocumentFolderPath = ""
        Exit Function
    End If

    i = Len(sUrl)
    Do While i > 0
        If Mid(sUrl, i, 1) = "/" Then
            GetDocumentFolderPath = Left(sUrl, i - 1)
            Exit Function
        End If
        i = i - 1
    Loop

    GetDocumentFolderPath = ""
End Function

Public Sub WriteTextFile(sUrl As String, sText As String)
    Dim oSFA As Object
    Dim oStream As Object

    oSFA = createUnoService("com.sun.star.ucb.SimpleFileAccess")
    oStream = createUnoService("com.sun.star.io.TextOutputStream")
    oStream.setEncoding("UTF-8")
    oStream.setOutputStream(oSFA.openFileWrite(sUrl))
    oStream.writeString(sText)
    oStream.closeOutput()
End Sub



Public Function IsNumericText(valueText As String) As Boolean
    Dim s As String
    s = Trim(CStr(valueText))
    s = Replace(s, ",", ".")
    IsNumericText = IsNumeric(s)
End Function

Public Function ToNumber(valueText As String) As Double
    Dim s As String
    s = Trim(CStr(valueText))
    s = Replace(s, ",", ".")
    If IsNumeric(s) Then
        ToNumber = CDbl(s)
    Else
        ToNumber = 0
    End If
End Function

Public Function AbsDiff(a As Double, b As Double) As Double
    If a >= b Then
        AbsDiff = a - b
    Else
        AbsDiff = b - a
    End If
End Function
