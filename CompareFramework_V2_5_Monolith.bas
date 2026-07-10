'======================================================================

' CompareFramework_Utils.bas

'======================================================================

' CompareFramework V2.5 - Utils
' Constantes globales et utilitaires communs.
Option Explicit

Public Const CF_VERSION As String = "2.3"
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
        LCase(sheetName) = LCase(CF_AUDIT_SHEET))
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


'======================================================================

' CompareFramework_Context.bas

'======================================================================

Option Explicit

'=========================================================
' CompareFramework V2.5 - Execution Context
'=========================================================
' Goal:
'   Centralize runtime state in one context structure
'   instead of spreading global variables across modules.
'
' Public API:
'   CF_ContextReset()
'   CF_ContextSet()
'   CF_ContextGet()
'   CF_ContextHas()
'   CF_ContextDumpToSheet()
'=========================================================

Private CF_CTX_KEYS() As String
Private CF_CTX_VALUES() As String
Private CF_CTX_COUNT As Long
Private CF_CTX_READY As Boolean

Public Sub CF_ContextReset()
    ReDim CF_CTX_KEYS(0 To 0)
    ReDim CF_CTX_VALUES(0 To 0)
    CF_CTX_COUNT = 0
    CF_CTX_READY = True

    CF_ContextSet "FrameworkVersion", "2.5"
    CF_ContextSet "StartedAt", CStr(Now)
    CF_ContextSet "Status", "INITIALIZED"
End Sub

Public Sub CF_ContextInitIfNeeded()
    If Not CF_CTX_READY Then
        CF_ContextReset
    End If
End Sub

Public Sub CF_ContextSet(sKey As String, vValue As Variant)
    Dim idx As Long

    CF_ContextInitIfNeeded

    sKey = Trim(CStr(sKey))
    If sKey = "" Then Exit Sub

    idx = CF_ContextIndexOf(sKey)
    If idx >= 0 Then
        CF_CTX_VALUES(idx) = CStr(vValue)
    Else
        If CF_CTX_COUNT = 0 Then
            ReDim CF_CTX_KEYS(0 To 0)
            ReDim CF_CTX_VALUES(0 To 0)
        Else
            ReDim Preserve CF_CTX_KEYS(0 To CF_CTX_COUNT)
            ReDim Preserve CF_CTX_VALUES(0 To CF_CTX_COUNT)
        End If

        CF_CTX_KEYS(CF_CTX_COUNT) = sKey
        CF_CTX_VALUES(CF_CTX_COUNT) = CStr(vValue)
        CF_CTX_COUNT = CF_CTX_COUNT + 1
    End If
End Sub

Public Function CF_ContextGet(sKey As String, Optional sDefault As String = "") As String
    Dim idx As Long

    CF_ContextInitIfNeeded

    idx = CF_ContextIndexOf(sKey)
    If idx >= 0 Then
        CF_ContextGet = CF_CTX_VALUES(idx)
    Else
        CF_ContextGet = sDefault
    End If
End Function

Public Function CF_ContextHas(sKey As String) As Boolean
    CF_ContextInitIfNeeded
    CF_ContextHas = (CF_ContextIndexOf(sKey) >= 0)
End Function

Public Function CF_ContextCount() As Long
    CF_ContextInitIfNeeded
    CF_ContextCount = CF_CTX_COUNT
End Function

Public Sub CF_ContextDumpToSheet()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oSheet As Object
    Dim i As Long

    CF_ContextInitIfNeeded

    oDoc = ThisComponent
    CF_DeleteSheetIfExists_Context oDoc, "Compare_Context"
    oDoc.Sheets.insertNewByName "Compare_Context", oDoc.Sheets.getCount()
    oSheet = oDoc.Sheets.getByName("Compare_Context")

    oSheet.getCellByPosition(0, 0).String = "Clé"
    oSheet.getCellByPosition(1, 0).String = "Valeur"

    For i = 0 To CF_CTX_COUNT - 1
        oSheet.getCellByPosition(0, i + 1).String = CF_CTX_KEYS(i)
        oSheet.getCellByPosition(1, i + 1).String = CF_CTX_VALUES(i)
    Next i

    On Error Resume Next
    oSheet.getCellRangeByName("A1:B1").CharWeight = com.sun.star.awt.FontWeight.BOLD
    oSheet.Columns.getByIndex(0).Width = 6500
    oSheet.Columns.getByIndex(1).Width = 11000

    MsgBox "Contexte exporté dans Compare_Context.", 64, "CompareFramework V2.5"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_ContextDumpToSheet : " & Err & " - " & Error$, 16, "CompareFramework V2.5"
End Sub

Public Sub CF_ContextBeginRun(Optional sRunName As String = "")
    CF_ContextReset
    CF_ContextSet "RunName", sRunName
    CF_ContextSet "Status", "RUNNING"
    CF_ContextSet "DocumentURL", ThisComponent.URL
End Sub

Public Sub CF_ContextEndRun(Optional sStatus As String = "DONE")
    CF_ContextSet "EndedAt", CStr(Now)
    CF_ContextSet "Status", sStatus
End Sub

Private Function CF_ContextIndexOf(sKey As String) As Long
    Dim i As Long

    sKey = UCase(Trim(CStr(sKey)))

    If CF_CTX_COUNT <= 0 Then
        CF_ContextIndexOf = -1
        Exit Function
    End If

    For i = 0 To CF_CTX_COUNT - 1
        If UCase(CF_CTX_KEYS(i)) = sKey Then
            CF_ContextIndexOf = i
            Exit Function
        End If
    Next i

    CF_ContextIndexOf = -1
End Function

Private Sub CF_DeleteSheetIfExists_Context(oDoc As Object, sName As String)
    If oDoc.Sheets.hasByName(sName) Then
        oDoc.Sheets.removeByName(sName)
    End If
End Sub


'======================================================================

' CompareFramework_Config.bas

'======================================================================

' CompareFramework V2.5 - Config
' Chargement configuration, profils et normalisation.
Option Explicit

Public Sub LoadCompareConfig(oDoc As Object)
    Dim oSheet As Object
    Dim lastRow As Long, r As Long
    Dim keyName As String, keyValue As String

    gIgnoreColumns = ""
    gIdAliases = "id;identifiant;code;reference;ref;cle;key"
    gIgnoreCase = False
    gNormalizeSpaces = True
    gIgnoreEmptyChanges = False

    oSheet = EnsureConfigSheet(oDoc)
    EnsureRulesSheet oDoc
    lastRow = LastUsedRow(oSheet)

    For r = 1 To lastRow
        keyName = UCase(Trim(CellText(oSheet, 0, r)))
        keyValue = Trim(CellText(oSheet, 1, r))
        Select Case keyName
            Case "IGNORE_COLUMNS"
                gIgnoreColumns = keyValue
            Case "ID_ALIASES"
                If keyValue <> "" Then gIdAliases = NormalizeList(keyValue)
            Case "IGNORE_CASE"
                gIgnoreCase = ToBoolean(keyValue)
            Case "NORMALIZE_SPACES"
                gNormalizeSpaces = ToBoolean(keyValue)
            Case "IGNORE_EMPTY_CHANGES"
                gIgnoreEmptyChanges = ToBoolean(keyValue)
        End Select
    Next r

    LoadCompareRules oDoc
End Sub

Public Function EnsureConfigSheet(oDoc As Object) As Object
    Dim oSheets As Object, oSheet As Object
    oSheets = oDoc.Sheets

    If oSheets.hasByName(CF_CONFIG_SHEET) Then
        oSheet = oSheets.getByName(CF_CONFIG_SHEET)
    Else
        oSheets.insertNewByName(CF_CONFIG_SHEET, oSheets.getCount())
        oSheet = oSheets.getByName(CF_CONFIG_SHEET)
        WriteDefaultConfig oSheet
    End If

    EnsureConfigSheet = oSheet
End Function

Public Sub WriteDefaultConfig(oSheet As Object)
    SetCell oSheet, 0, 0, "Parametre"
    SetCell oSheet, 1, 0, "Valeur"
    SetCell oSheet, 2, 0, "Description"

    SetCell oSheet, 0, 1, "IGNORE_COLUMNS"
    SetCell oSheet, 1, 1, ""
    SetCell oSheet, 2, 1, "Colonnes a ignorer, separees par ; ou ,"

    SetCell oSheet, 0, 2, "IGNORE_CASE"
    SetCell oSheet, 1, 2, "FALSE"
    SetCell oSheet, 2, 2, "TRUE pour ignorer majuscules/minuscules"

    SetCell oSheet, 0, 3, "NORMALIZE_SPACES"
    SetCell oSheet, 1, 3, "TRUE"
    SetCell oSheet, 2, 3, "TRUE pour reduire les espaces multiples"

    SetCell oSheet, 0, 4, "IGNORE_EMPTY_CHANGES"
    SetCell oSheet, 1, 4, "FALSE"
    SetCell oSheet, 2, 4, "TRUE pour ignorer les changements vide/non vide"

    SetCell oSheet, 0, 5, "ID_ALIASES"
    SetCell oSheet, 1, 5, "ID;Identifiant;Code;Reference;Ref;Cle;Key"
    SetCell oSheet, 2, 5, "Noms possibles de la colonne d'identifiant"

    oSheet.getCellRangeByPosition(0, 0, 2, 0).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 0, 2, 0).CellBackColor = RGB(217, 217, 217)
    oSheet.Columns.getByIndex(0).OptimalWidth = True
    oSheet.Columns.getByIndex(1).OptimalWidth = True
    oSheet.Columns.getByIndex(2).OptimalWidth = True
End Sub


Public Function EnsureRulesSheet(oDoc As Object) As Object
    Dim oSheets As Object, oSheet As Object
    oSheets = oDoc.Sheets

    If oSheets.hasByName(CF_RULES_SHEET) Then
        oSheet = oSheets.getByName(CF_RULES_SHEET)
    Else
        oSheets.insertNewByName(CF_RULES_SHEET, oSheets.getCount())
        oSheet = oSheets.getByName(CF_RULES_SHEET)
        WriteDefaultRulesSheet oSheet
    End If

    EnsureRulesSheet = oSheet
End Function

Public Sub WriteDefaultRulesSheet(oSheet As Object)
    SetCell oSheet, 0, 0, "RuleId"
    SetCell oSheet, 1, 0, "Enabled"
    SetCell oSheet, 2, 0, "Scope"
    SetCell oSheet, 3, 0, "Column"
    SetCell oSheet, 4, 0, "RuleType"
    SetCell oSheet, 5, 0, "Param1"
    SetCell oSheet, 6, 0, "Param2"
    SetCell oSheet, 7, 0, "Comment"

    SetCell oSheet, 0, 1, "R001"
    SetCell oSheet, 1, 1, "FALSE"
    SetCell oSheet, 2, 1, "GLOBAL"
    SetCell oSheet, 3, 1, "Statut"
    SetCell oSheet, 4, 1, "EQUIVALENT_VALUES"
    SetCell oSheet, 5, 1, "NULL;N/A;NA;"
    SetCell oSheet, 6, 1, ""
    SetCell oSheet, 7, 1, "Exemple : considere ces valeurs comme equivalentes. Activer si necessaire."

    SetCell oSheet, 0, 2, "R002"
    SetCell oSheet, 1, 2, "FALSE"
    SetCell oSheet, 2, 2, "GLOBAL"
    SetCell oSheet, 3, 2, "Montant"
    SetCell oSheet, 4, 2, "NUMERIC_TOLERANCE"
    SetCell oSheet, 5, 2, "0.01"
    SetCell oSheet, 6, 2, ""
    SetCell oSheet, 7, 2, "Exemple : ignore les ecarts numeriques inferieurs ou egaux a la tolerance."

    SetCell oSheet, 0, 3, "R003"
    SetCell oSheet, 1, 3, "FALSE"
    SetCell oSheet, 2, 3, "GLOBAL"
    SetCell oSheet, 3, 3, "Commentaire"
    SetCell oSheet, 4, 3, "IGNORE_IF_ONE_EMPTY"
    SetCell oSheet, 5, 3, ""
    SetCell oSheet, 6, 3, ""
    SetCell oSheet, 7, 3, "Exemple : ignore si une seule valeur est vide."

    oSheet.getCellRangeByPosition(0, 0, 7, 0).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 0, 7, 0).CellBackColor = RGB(217, 217, 217)
    Dim i As Long
    For i = 0 To 7
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i
End Sub

Public Function NormalizeCompareValue(valueText As String) As String
    Dim result As String
    result = CStr(valueText)

    If gNormalizeSpaces Then
        result = NormalizeSpaces(result)
    End If

    If gIgnoreCase Then
        result = LCase(result)
    End If

    NormalizeCompareValue = result
End Function

Public Function NormalizeSpaces(valueText As String) As String
    Dim result As String
    result = Trim(CStr(valueText))
    Do While InStr(result, "  ") > 0
        result = Replace(result, "  ", " ")
    Loop
    NormalizeSpaces = result
End Function

Public Function IgnoreThisEmptyChange(oldCompare As String, newCompare As String) As Boolean
    If gIgnoreEmptyChanges = False Then
        IgnoreThisEmptyChange = False
    Else
        IgnoreThisEmptyChange = (oldCompare = "" Or newCompare = "")
    End If
End Function

Public Function ColumnIsIgnored(headerName As String) As Boolean
    ColumnIsIgnored = TokenInList(NormalizeHeader(headerName), gIgnoreColumns)
End Function

Public Function TokenInList(token As String, listText As String) As Boolean
    Dim normalizedToken As String, normalizedList As String
    normalizedToken = NormalizeHeader(token)
    normalizedList = ";" & NormalizeList(listText) & ";"
    TokenInList = (InStr(normalizedList, ";" & normalizedToken & ";") > 0)
End Function

Public Function NormalizeList(listText As String) As String
    Dim result As String
    result = CStr(listText)
    result = Replace(result, ",", ";")
    result = Replace(result, "|", ";")
    result = Replace(result, Chr(10), ";")
    result = Replace(result, Chr(13), ";")
    result = LCase(result)
    result = Replace(result, " ", "")
    NormalizeList = result
End Function

Public Function ToBoolean(valueText As String) As Boolean
    Dim v As String
    v = UCase(Trim(CStr(valueText)))
    ToBoolean = (v = "TRUE" Or v = "VRAI" Or v = "YES" Or v = "OUI" Or v = "1")
End Function

Public Function FindIdColumn(headers As Variant) As Long
    Dim i As Long, h As String
    For i = LBound(headers) To UBound(headers)
        h = NormalizeHeader(CStr(headers(i)))
        If TokenInList(h, gIdAliases) Then
            FindIdColumn = i
            Exit Function
        End If
    Next i
    FindIdColumn = -1
End Function



'======================================================================

' CompareFramework_Index.bas

'======================================================================

' CompareFramework V2.5 - Index
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



'======================================================================

' CompareFramework_Rules.bas

'======================================================================

' CompareFramework V2.5 - Rules
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


'======================================================================

' CompareFramework_Report.bas

'======================================================================

' CompareFramework V2.5 - Report
' Rapports Calc, synthèse, plan d'action, journal et export HTML.
Option Explicit

Public Function PrepareSheet(oDoc As Object, sheetName As String) As Object
    Dim oSheets As Object
    oSheets = oDoc.Sheets

    If oSheets.hasByName(sheetName) Then
        oSheets.removeByName(sheetName)
    End If

    oSheets.insertNewByName(sheetName, oSheets.Count)
    PrepareSheet = oSheets.getByName(sheetName)
End Function

Public Sub WriteReportHeader(oSheet As Object, rowIndex As Long)
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

Public Sub WriteReportRow(oSheet As Object, ByRef rowIndex As Long, pairName As String, idValue As String, statusValue As String, colName As String, oldRow As String, newRow As String, oldValue As String, newValue As String, messageText As String)
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

Public Sub WriteStatsHeader(oSheet As Object, rowIndex As Long)
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

Public Sub WriteStatsRow(oSheet As Object, ByRef rowIndex As Long, pairName As String, addedRows As Long, removedRows As Long, changedRows As Long, changedCells As Long, duplicates As Long, oldCount As Long, newCount As Long, issues As Long)
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

Public Sub WriteGlobalSummary(oSheet As Object, ByRef rowIndex As Long, pairCount As Long, totalAdded As Long, totalRemoved As Long, totalChangedRows As Long, totalChangedCells As Long, totalDuplicates As Long, totalIssues As Long)
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

Public Sub WriteDashboard(oSheet As Object, pairCount As Long, totalAdded As Long, totalRemoved As Long, totalChangedRows As Long, totalChangedCells As Long, totalDuplicates As Long, totalIssues As Long)
    Dim r As Long, decisionText As String

    r = 0
    SetCell oSheet, 0, r, "Synthese CompareFramework"
    SetCell oSheet, 1, r, "V" & CF_VERSION

    r = r + 2
    SetCell oSheet, 0, r, "Decision"
    If totalAdded = 0 And totalRemoved = 0 And totalChangedCells = 0 And totalDuplicates = 0 And totalIssues = 0 Then
        decisionText = "OK - aucune difference detectee"
    Else
        decisionText = "A CONTROLER - differences ou alertes detectees"
    End If
    SetCell oSheet, 1, r, decisionText

    r = r + 2
    SetCell oSheet, 0, r, "Indicateur"
    SetCell oSheet, 1, r, "Valeur"

    r = r + 1
    SetCell oSheet, 0, r, "Paires comparees"
    SetCell oSheet, 1, r, CStr(pairCount)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes ajoutees"
    SetCell oSheet, 1, r, CStr(totalAdded)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes supprimees"
    SetCell oSheet, 1, r, CStr(totalRemoved)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes modifiees"
    SetCell oSheet, 1, r, CStr(totalChangedRows)
    r = r + 1
    SetCell oSheet, 0, r, "Cellules modifiees"
    SetCell oSheet, 1, r, CStr(totalChangedCells)
    r = r + 1
    SetCell oSheet, 0, r, "ID doublons"
    SetCell oSheet, 1, r, CStr(totalDuplicates)
    r = r + 1
    SetCell oSheet, 0, r, "Alertes structure"
    SetCell oSheet, 1, r, CStr(totalIssues)

    r = r + 2
    SetCell oSheet, 0, r, "Configuration active"
    r = r + 1
    SetCell oSheet, 0, r, "IGNORE_COLUMNS"
    SetCell oSheet, 1, r, gIgnoreColumns
    r = r + 1
    SetCell oSheet, 0, r, "ID_ALIASES"
    SetCell oSheet, 1, r, gIdAliases
    r = r + 1
    SetCell oSheet, 0, r, "IGNORE_CASE"
    SetCell oSheet, 1, r, CStr(gIgnoreCase)
    r = r + 1
    SetCell oSheet, 0, r, "NORMALIZE_SPACES"
    SetCell oSheet, 1, r, CStr(gNormalizeSpaces)
    r = r + 1
    SetCell oSheet, 0, r, "IGNORE_EMPTY_CHANGES"
    SetCell oSheet, 1, r, CStr(gIgnoreEmptyChanges)
End Sub

Public Sub BuildActionPlan(oReport As Object, oAction As Object, lastReportRow As Long)
    Dim r As Long, outRow As Long
    Dim statusValue As String, pairName As String, idValue As String, colName As String
    Dim oldValue As String, newValue As String, messageText As String

    WriteActionHeader oAction, 0
    outRow = 1

    For r = 1 To lastReportRow
        statusValue = CellText(oReport, CF_COL_TYPE, r)
        If statusValue <> "" Then
            pairName = CellText(oReport, CF_COL_PAIR, r)
            idValue = CellText(oReport, CF_COL_ID, r)
            colName = CellText(oReport, CF_COL_COLUMN, r)
            oldValue = CellText(oReport, CF_COL_OLD_VALUE, r)
            newValue = CellText(oReport, CF_COL_NEW_VALUE, r)
            messageText = CellText(oReport, CF_COL_MESSAGE, r)

            If IsActionableStatus(statusValue) Then
                SetCell oAction, 0, outRow, ActionPriority(statusValue, colName)
                SetCell oAction, 1, outRow, pairName
                SetCell oAction, 2, outRow, idValue
                SetCell oAction, 3, outRow, statusValue
                SetCell oAction, 4, outRow, colName
                SetCell oAction, 5, outRow, ActionRecommendation(statusValue, colName, messageText)
                SetCell oAction, 6, outRow, oldValue
                SetCell oAction, 7, outRow, newValue
                SetCell oAction, 8, outRow, "A traiter"
                SetCell oAction, 9, outRow, ""
                outRow = outRow + 1
            End If
        End If
    Next r

    If outRow = 1 Then
        SetCell oAction, 0, outRow, "OK"
        SetCell oAction, 1, outRow, ""
        SetCell oAction, 2, outRow, ""
        SetCell oAction, 3, outRow, CF_STATUS_INFO
        SetCell oAction, 4, outRow, ""
        SetCell oAction, 5, outRow, "Aucune action requise"
        SetCell oAction, 8, outRow, "Clos"
    End If
End Sub

Public Sub WriteActionHeader(oSheet As Object, rowIndex As Long)
    SetCell oSheet, 0, rowIndex, "Priorite"
    SetCell oSheet, 1, rowIndex, "Paire"
    SetCell oSheet, 2, rowIndex, "ID"
    SetCell oSheet, 3, rowIndex, "Type"
    SetCell oSheet, 4, rowIndex, "Colonne"
    SetCell oSheet, 5, rowIndex, "Action recommandee"
    SetCell oSheet, 6, rowIndex, "Ancienne valeur"
    SetCell oSheet, 7, rowIndex, "Nouvelle valeur"
    SetCell oSheet, 8, rowIndex, "Statut traitement"
    SetCell oSheet, 9, rowIndex, "Commentaire"
End Sub

Public Function IsActionableStatus(statusValue As String) As Boolean
    IsActionableStatus = (statusValue = CF_STATUS_ADDED Or statusValue = CF_STATUS_REMOVED Or statusValue = CF_STATUS_CHANGED Or statusValue = CF_STATUS_DUPLICATE Or statusValue = CF_STATUS_ERROR)
End Function

Public Function ActionPriority(statusValue As String, colName As String) As String
    Select Case statusValue
        Case CF_STATUS_ERROR
            ActionPriority = "P1"
        Case CF_STATUS_DUPLICATE
            ActionPriority = "P1"
        Case CF_STATUS_REMOVED
            ActionPriority = "P1"
        Case CF_STATUS_ADDED
            ActionPriority = "P2"
        Case CF_STATUS_CHANGED
            If NormalizeHeader(colName) = "id" Or NormalizeHeader(colName) = "identifiant" Or NormalizeHeader(colName) = "code" Then
                ActionPriority = "P1"
            Else
                ActionPriority = "P3"
            End If
        Case Else
            ActionPriority = "P3"
    End Select
End Function

Public Function ActionRecommendation(statusValue As String, colName As String, messageText As String) As String
    Select Case statusValue
        Case CF_STATUS_ERROR
            ActionRecommendation = "Corriger la structure avant d'exploiter la comparaison"
        Case CF_STATUS_DUPLICATE
            ActionRecommendation = "Verifier les identifiants en doublon puis dedoublonner la source"
        Case CF_STATUS_REMOVED
            ActionRecommendation = "Verifier si la suppression est attendue et documenter la cause"
        Case CF_STATUS_ADDED
            ActionRecommendation = "Verifier si l'ajout est attendu et valider la creation"
        Case CF_STATUS_CHANGED
            ActionRecommendation = "Controler la modification de la colonne '" & colName & "'"
        Case Else
            If messageText <> "" Then
                ActionRecommendation = messageText
            Else
                ActionRecommendation = "Controler l'ecart"
            End If
    End Select
End Function

Public Sub WriteAuditLog(oSheet As Object, pairCount As Long, totalAdded As Long, totalRemoved As Long, totalChangedRows As Long, totalChangedCells As Long, totalDuplicates As Long, totalIssues As Long, lastReportRow As Long)
    Dim r As Long
    r = 0
    SetCell oSheet, 0, r, "Journal CompareFramework"
    SetCell oSheet, 1, r, "V" & CF_VERSION

    r = r + 2
    SetCell oSheet, 0, r, "Date execution"
    SetCell oSheet, 1, r, CStr(Now)
    r = r + 1
    SetCell oSheet, 0, r, "Document"
    SetCell oSheet, 1, r, ThisComponent.Title
    r = r + 1
    SetCell oSheet, 0, r, "Lignes rapport"
    SetCell oSheet, 1, r, CStr(lastReportRow)
    r = r + 1
    SetCell oSheet, 0, r, "Paires comparees"
    SetCell oSheet, 1, r, CStr(pairCount)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes ajoutees"
    SetCell oSheet, 1, r, CStr(totalAdded)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes supprimees"
    SetCell oSheet, 1, r, CStr(totalRemoved)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes modifiees"
    SetCell oSheet, 1, r, CStr(totalChangedRows)
    r = r + 1
    SetCell oSheet, 0, r, "Cellules modifiees"
    SetCell oSheet, 1, r, CStr(totalChangedCells)
    r = r + 1
    SetCell oSheet, 0, r, "Doublons"
    SetCell oSheet, 1, r, CStr(totalDuplicates)
    r = r + 1
    SetCell oSheet, 0, r, "Alertes structure"
    SetCell oSheet, 1, r, CStr(totalIssues)
End Sub

Public Sub FormatActionPlan(oSheet As Object)
    On Error Resume Next
    Dim lastRow As Long, r As Long, i As Long
    Dim priority As String
    lastRow = LastUsedRow(oSheet)
    oSheet.getCellRangeByPosition(0, 0, 9, 0).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 0, 9, 0).CellBackColor = RGB(217, 217, 217)

    For r = 1 To lastRow
        priority = CellText(oSheet, 0, r)
        Select Case priority
            Case "P1"
                oSheet.getCellRangeByPosition(0, r, 9, r).CellBackColor = RGB(255, 199, 206)
            Case "P2"
                oSheet.getCellRangeByPosition(0, r, 9, r).CellBackColor = RGB(255, 242, 204)
            Case "P3"
                oSheet.getCellRangeByPosition(0, r, 9, r).CellBackColor = RGB(226, 239, 218)
        End Select
    Next r

    For i = 0 To 9
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i
    ApplyOptionalAutoFilter oSheet, 9, lastRow
    On Error GoTo 0
End Sub

Public Sub FormatAuditLog(oSheet As Object)
    On Error Resume Next
    Dim i As Long
    oSheet.getCellRangeByPosition(0, 0, 1, 0).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 0, 1, 0).CellBackColor = RGB(217, 217, 217)
    For i = 0 To 1
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i
    On Error GoTo 0
End Sub

Public Sub FormatDashboard(oSheet As Object)
    On Error Resume Next
    Dim i As Long
    oSheet.getCellRangeByPosition(0, 0, 1, 0).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 0, 1, 0).CellBackColor = RGB(180, 198, 231)
    oSheet.getCellRangeByPosition(0, 2, 1, 2).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 4, 1, 4).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 13, 1, 13).CharWeight = 150
    For i = 0 To 1
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i
    On Error GoTo 0
End Sub

Public Sub FormatReport(oSheet As Object, lastRow As Long)
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

Public Sub FormatStats(oSheet As Object, lastRow As Long)
    Dim oHeader As Object
    Dim i As Long

    oHeader = oSheet.getCellRangeByPosition(0, 0, 8, 0)
    oHeader.CharWeight = 150
    oHeader.CellBackColor = RGB(217, 217, 217)

    For i = 0 To 8
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i
End Sub

Public Sub ApplyOptionalAutoFilter(oSheet As Object, lastCol As Long, lastRow As Long)
    On Error GoTo SkipFilter
    Dim oRange As Object
    oRange = oSheet.getCellRangeByPosition(0, 0, lastCol, lastRow)
    oRange.AutoFilter = True
SkipFilter:
    On Error GoTo 0
End Sub

'=========================================================
' V1.3 - HTML REPORT EXPORT
'=========================================================

Public Sub ExporterRapportHTML()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim sUrl As String
    Dim sPath As String
    Dim sHtml As String

    oDoc = ThisComponent
    sPath = GetDocumentFolderPath()
    If sPath = "" Then
        MsgBox "Impossible de déterminer le dossier du classeur. Enregistre d'abord le fichier LibreOffice.", 48, "CompareFramework"
        Exit Sub
    End If

    sUrl = sPath & "/Rapport_Comparaison.html"

    sHtml = BuildHtmlReport(oDoc)
    WriteTextFile sUrl, sHtml

    MsgBox "Rapport HTML généré :" & Chr(10) & ConvertFromURL(sUrl), 64, "CompareFramework V1.3"
    Exit Sub

ErrHandler:
    MsgBox "Erreur ExporterRapportHTML : " & Err & " - " & Error$, 16, "CompareFramework"
End Sub

Public Function BuildHtmlReport(oDoc As Object) As String
    Dim s As String

    s = ""
    s = s & "<!DOCTYPE html>" & Chr(10)
    s = s & "<html lang=""fr"">" & Chr(10)
    s = s & "<head>" & Chr(10)
    s = s & "<meta charset=""utf-8"">" & Chr(10)
    s = s & "<meta name=""viewport"" content=""width=device-width, initial-scale=1"">" & Chr(10)
    s = s & "<title>Rapport de comparaison</title>" & Chr(10)
    s = s & HtmlStyleBlock()
    s = s & HtmlScriptBlock()
    s = s & "</head>" & Chr(10)
    s = s & "<body>" & Chr(10)
    s = s & "<header>" & Chr(10)
    s = s & "<h1>Rapport de comparaison</h1>" & Chr(10)
    s = s & "<p>Généré par CompareFramework V1.3 le " & HtmlEscape(Now) & "</p>" & Chr(10)
    s = s & "</header>" & Chr(10)

    s = s & "<nav>" & Chr(10)
    s = s & "<a href=""#synthese"">Synthèse</a>" & Chr(10)
    s = s & "<a href=""#stats"">Statistiques</a>" & Chr(10)
    s = s & "<a href=""#rapport"">Détail</a>" & Chr(10)
    s = s & "<a href=""#actions"">Plan d'action</a>" & Chr(10)
    s = s & "<a href=""#journal"">Journal</a>" & Chr(10)
    s = s & "</nav>" & Chr(10)

    s = s & SheetToHtmlSection(oDoc, "Synthese_Comparaison", "synthese", "Synthèse globale", False)
    s = s & SheetToHtmlSection(oDoc, "Stats_Comparaison", "stats", "Statistiques", False)

    s = s & "<section id=""rapport"">" & Chr(10)
    s = s & "<h2>Détail des différences</h2>" & Chr(10)
    s = s & "<div class=""toolbar"">" & Chr(10)
    s = s & "<input id=""filterInput"" type=""search"" placeholder=""Filtrer dans le rapport..."" onkeyup=""filterTable('rapportTable', this.value)"">" & Chr(10)
    s = s & "</div>" & Chr(10)
    s = s & SheetToHtmlTableOnly(oDoc, "Rapport_Comparaison", "rapportTable", True)
    s = s & "</section>" & Chr(10)

    s = s & SheetToHtmlSection(oDoc, "Plan_Action_Comparaison", "actions", "Plan d'action", True)
    s = s & SheetToHtmlSection(oDoc, "Journal_Comparaison", "journal", "Journal", False)

    s = s & "<footer>CompareFramework V1.3</footer>" & Chr(10)
    s = s & "</body>" & Chr(10)
    s = s & "</html>" & Chr(10)

    BuildHtmlReport = s
End Function

Public Function HtmlStyleBlock() As String
    Dim s As String

    s = ""
    s = s & "<style>" & Chr(10)
    s = s & "body{font-family:Arial,sans-serif;margin:0;background:#f6f7fb;color:#1f2937;}" & Chr(10)
    s = s & "header{background:#111827;color:white;padding:24px 32px;}" & Chr(10)
    s = s & "header h1{margin:0 0 8px 0;font-size:28px;}" & Chr(10)
    s = s & "header p{margin:0;color:#d1d5db;}" & Chr(10)
    s = s & "nav{position:sticky;top:0;background:white;border-bottom:1px solid #e5e7eb;padding:10px 32px;z-index:5;}" & Chr(10)
    s = s & "nav a{margin-right:16px;color:#2563eb;text-decoration:none;font-weight:bold;}" & Chr(10)
    s = s & "section{margin:24px 32px;background:white;border:1px solid #e5e7eb;border-radius:10px;padding:18px;box-shadow:0 1px 2px rgba(0,0,0,.04);}" & Chr(10)
    s = s & "h2{margin-top:0;font-size:22px;}" & Chr(10)
    s = s & ".toolbar{margin:0 0 12px 0;}" & Chr(10)
    s = s & "input[type=search]{width:100%;max-width:520px;padding:10px;border:1px solid #d1d5db;border-radius:8px;}" & Chr(10)
    s = s & ".table-wrap{overflow:auto;max-height:70vh;border:1px solid #e5e7eb;border-radius:8px;}" & Chr(10)
    s = s & "table{border-collapse:collapse;width:100%;font-size:13px;}" & Chr(10)
    s = s & "th,td{border-bottom:1px solid #e5e7eb;padding:8px 10px;text-align:left;vertical-align:top;white-space:nowrap;}" & Chr(10)
    s = s & "th{position:sticky;top:0;background:#f3f4f6;z-index:2;}" & Chr(10)
    s = s & "tr:hover td{background:#f9fafb;}" & Chr(10)
    s = s & ".tag-ajout{background:#dcfce7;color:#166534;font-weight:bold;}" & Chr(10)
    s = s & ".tag-suppression{background:#fee2e2;color:#991b1b;font-weight:bold;}" & Chr(10)
    s = s & ".tag-modification{background:#fef3c7;color:#92400e;font-weight:bold;}" & Chr(10)
    s = s & ".tag-p1{background:#fee2e2;color:#991b1b;font-weight:bold;}" & Chr(10)
    s = s & ".tag-p2{background:#fef3c7;color:#92400e;font-weight:bold;}" & Chr(10)
    s = s & ".tag-p3{background:#dbeafe;color:#1e40af;font-weight:bold;}" & Chr(10)
    s = s & ".missing{color:#6b7280;font-style:italic;}" & Chr(10)
    s = s & "footer{margin:24px 32px;color:#6b7280;font-size:12px;}" & Chr(10)
    s = s & "</style>" & Chr(10)

    HtmlStyleBlock = s
End Function

Public Function HtmlScriptBlock() As String
    Dim s As String

    s = ""
    s = s & "<script>" & Chr(10)
    s = s & "function filterTable(id,q){q=q.toLowerCase();var t=document.getElementById(id);if(!t)return;var r=t.getElementsByTagName('tr');for(var i=1;i<r.length;i++){var txt=r[i].innerText.toLowerCase();r[i].style.display=txt.indexOf(q)>=0?'':'none';}}" & Chr(10)
    s = s & "</script>" & Chr(10)

    HtmlScriptBlock = s
End Function

Public Function SheetToHtmlSection(oDoc As Object, sSheetName As String, sAnchor As String, sTitle As String, bFilter As Boolean) As String
    Dim s As String
    s = "<section id=""" & HtmlEscape(sAnchor) & """>" & Chr(10)
    s = s & "<h2>" & HtmlEscape(sTitle) & "</h2>" & Chr(10)

    If bFilter Then
        s = s & "<div class=""toolbar"">" & Chr(10)
        s = s & "<input type=""search"" placeholder=""Filtrer..."" onkeyup=""filterTable('" & HtmlEscape(sAnchor) & "Table', this.value)"">" & Chr(10)
        s = s & "</div>" & Chr(10)
    End If

    s = s & SheetToHtmlTableOnly(oDoc, sSheetName, sAnchor & "Table", True)
    s = s & "</section>" & Chr(10)

    SheetToHtmlSection = s
End Function

Public Function SheetToHtmlTableOnly(oDoc As Object, sSheetName As String, sTableId As String, bHeader As Boolean) As String
    On Error GoTo MissingSheet

    Dim oSheet As Object
    Dim oCursor As Object
    Dim lastRow As Long
    Dim lastCol As Long
    Dim r As Long
    Dim c As Long
    Dim cellText As String
    Dim s As String

    If Not oDoc.Sheets.hasByName(sSheetName) Then GoTo MissingSheet

    oSheet = oDoc.Sheets.getByName(sSheetName)
    oCursor = oSheet.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow
    lastCol = oCursor.RangeAddress.EndColumn

    s = "<div class=""table-wrap"">" & Chr(10)
    s = s & "<table id=""" & HtmlEscape(sTableId) & """>" & Chr(10)

    For r = 0 To lastRow
        s = s & "<tr>"
        For c = 0 To lastCol
            cellText = CStr(oSheet.getCellByPosition(c, r).String)
            If r = 0 And bHeader Then
                s = s & "<th>" & HtmlEscape(cellText) & "</th>"
            Else
                s = s & "<td class=""" & HtmlCssClassForCell(cellText) & """>" & HtmlEscape(cellText) & "</td>"
            End If
        Next c
        s = s & "</tr>" & Chr(10)
    Next r

    s = s & "</table>" & Chr(10)
    s = s & "</div>" & Chr(10)

    SheetToHtmlTableOnly = s
    Exit Function

MissingSheet:
    SheetToHtmlTableOnly = "<p class=""missing"">Feuille absente : " & HtmlEscape(sSheetName) & "</p>" & Chr(10)
End Function

Public Function HtmlCssClassForCell(sValue As String) As String
    Dim s As String
    s = UCase(Trim(sValue))

    If s = "AJOUT" Or s = "AJOUTEE" Or s = "AJOUTÉE" Or s = "ADDED" Then
        HtmlCssClassForCell = "tag-ajout"
    ElseIf s = "SUPPRESSION" Or s = "SUPPRIMEE" Or s = "SUPPRIMÉE" Or s = "DELETED" Then
        HtmlCssClassForCell = "tag-suppression"
    ElseIf s = "MODIFICATION" Or s = "MODIFIEE" Or s = "MODIFIÉE" Or s = "CHANGED" Then
        HtmlCssClassForCell = "tag-modification"
    ElseIf s = "P1" Then
        HtmlCssClassForCell = "tag-p1"
    ElseIf s = "P2" Then
        HtmlCssClassForCell = "tag-p2"
    ElseIf s = "P3" Then
        HtmlCssClassForCell = "tag-p3"
    Else
        HtmlCssClassForCell = ""
    End If
End Function



'======================================================================

' CompareFramework_Tests.bas

'======================================================================

Option Explicit

'=========================================================
' CompareFramework V2.5 - Test Suite
'=========================================================
' Public macros:
'   CF_RunAllTests()
'   CF_CreateTestWorkbook()
'
' Goal:
'   Provide a lightweight validation suite directly usable
'   inside LibreOffice Calc without external dependencies.
'=========================================================

Private Const CF_TEST_SHEET_OLD As String = "CF_Test_OLD"
Private Const CF_TEST_SHEET_NEW As String = "CF_Test_NEW"
Private Const CF_TEST_RESULTS As String = "CF_Test_Resultats"

Public Sub CF_CreateTestWorkbook()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    oDoc = ThisComponent

    CF_DeleteSheetIfExists oDoc, CF_TEST_SHEET_OLD
    CF_DeleteSheetIfExists oDoc, CF_TEST_SHEET_NEW
    CF_DeleteSheetIfExists oDoc, CF_TEST_RESULTS

    CF_CreateSheet oDoc, CF_TEST_SHEET_OLD
    CF_CreateSheet oDoc, CF_TEST_SHEET_NEW

    CF_FillOldTestSheet oDoc.Sheets.getByName(CF_TEST_SHEET_OLD)
    CF_FillNewTestSheet oDoc.Sheets.getByName(CF_TEST_SHEET_NEW)

    MsgBox "Jeu de test créé : " & CF_TEST_SHEET_OLD & " / " & CF_TEST_SHEET_NEW, 64, "CompareFramework V2.5"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_CreateTestWorkbook : " & Err & " - " & Error$, 16, "CompareFramework V2.5"
End Sub

Public Sub CF_RunAllTests()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oRes As Object
    Dim row As Long
    Dim total As Long
    Dim passed As Long

    oDoc = ThisComponent

    CF_CreateTestWorkbook

    CF_DeleteSheetIfExists oDoc, CF_TEST_RESULTS
    CF_CreateSheet oDoc, CF_TEST_RESULTS
    oRes = oDoc.Sheets.getByName(CF_TEST_RESULTS)

    CF_WriteTestHeader oRes
    row = 1
    total = 0
    passed = 0

    CF_AddTestResult oRes, row, "Création feuille OLD", oDoc.Sheets.hasByName(CF_TEST_SHEET_OLD), total, passed
    CF_AddTestResult oRes, row, "Création feuille NEW", oDoc.Sheets.hasByName(CF_TEST_SHEET_NEW), total, passed
    CF_AddTestResult oRes, row, "Colonnes attendues", CF_TestHeaders(oDoc), total, passed
    CF_AddTestResult oRes, row, "Ajout détectable", CF_TestAddedRow(oDoc), total, passed
    CF_AddTestResult oRes, row, "Suppression détectable", CF_TestDeletedRow(oDoc), total, passed
    CF_AddTestResult oRes, row, "Modification détectable", CF_TestModifiedRow(oDoc), total, passed
    CF_AddTestResult oRes, row, "Valeurs identiques stables", CF_TestUnchangedRow(oDoc), total, passed

    CF_WriteTestSummary oRes, row + 1, total, passed
    CF_FormatTestResults oRes

    If passed = total Then
        MsgBox "Tests OK : " & passed & "/" & total, 64, "CompareFramework V2.5"
    Else
        MsgBox "Tests à contrôler : " & passed & "/" & total, 48, "CompareFramework V2.5"
    End If

    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunAllTests : " & Err & " - " & Error$, 16, "CompareFramework V2.5"
End Sub

Private Sub CF_FillOldTestSheet(oSheet As Object)
    CF_SetCell oSheet, 0, 0, "ID"
    CF_SetCell oSheet, 1, 0, "Name"
    CF_SetCell oSheet, 2, 0, "Amount"
    CF_SetCell oSheet, 3, 0, "Status"

    CF_SetCell oSheet, 0, 1, "A001"
    CF_SetCell oSheet, 1, 1, "Alpha"
    CF_SetCell oSheet, 2, 1, "100"
    CF_SetCell oSheet, 3, 1, "ACTIVE"

    CF_SetCell oSheet, 0, 2, "A002"
    CF_SetCell oSheet, 1, 2, "Beta"
    CF_SetCell oSheet, 2, 2, "200"
    CF_SetCell oSheet, 3, 2, "ACTIVE"

    CF_SetCell oSheet, 0, 3, "A003"
    CF_SetCell oSheet, 1, 3, "Gamma"
    CF_SetCell oSheet, 2, 3, "300"
    CF_SetCell oSheet, 3, 3, "CLOSED"

    CF_SetCell oSheet, 0, 4, "A004"
    CF_SetCell oSheet, 1, 4, "Delta"
    CF_SetCell oSheet, 2, 4, "400"
    CF_SetCell oSheet, 3, 4, "ACTIVE"
End Sub

Private Sub CF_FillNewTestSheet(oSheet As Object)
    CF_SetCell oSheet, 0, 0, "ID"
    CF_SetCell oSheet, 1, 0, "Name"
    CF_SetCell oSheet, 2, 0, "Amount"
    CF_SetCell oSheet, 3, 0, "Status"

    CF_SetCell oSheet, 0, 1, "A001"
    CF_SetCell oSheet, 1, 1, "Alpha"
    CF_SetCell oSheet, 2, 1, "100"
    CF_SetCell oSheet, 3, 1, "ACTIVE"

    CF_SetCell oSheet, 0, 2, "A002"
    CF_SetCell oSheet, 1, 2, "Beta"
    CF_SetCell oSheet, 2, 2, "250"
    CF_SetCell oSheet, 3, 2, "ACTIVE"

    CF_SetCell oSheet, 0, 3, "A004"
    CF_SetCell oSheet, 1, 3, "Delta"
    CF_SetCell oSheet, 2, 3, "400"
    CF_SetCell oSheet, 3, 3, "ACTIVE"

    CF_SetCell oSheet, 0, 4, "A005"
    CF_SetCell oSheet, 1, 4, "Epsilon"
    CF_SetCell oSheet, 2, 4, "500"
    CF_SetCell oSheet, 3, 4, "NEW"
End Sub

Private Function CF_TestHeaders(oDoc As Object) As Boolean
    Dim oOld As Object
    Dim oNew As Object
    oOld = oDoc.Sheets.getByName(CF_TEST_SHEET_OLD)
    oNew = oDoc.Sheets.getByName(CF_TEST_SHEET_NEW)

    CF_TestHeaders = _
        oOld.getCellByPosition(0, 0).String = "ID" And _
        oOld.getCellByPosition(1, 0).String = "Name" And _
        oNew.getCellByPosition(2, 0).String = "Amount" And _
        oNew.getCellByPosition(3, 0).String = "Status"
End Function

Private Function CF_TestAddedRow(oDoc As Object) As Boolean
    CF_TestAddedRow = CF_FindIdInSheet(oDoc.Sheets.getByName(CF_TEST_SHEET_NEW), "A005") > 0
End Function

Private Function CF_TestDeletedRow(oDoc As Object) As Boolean
    CF_TestDeletedRow = CF_FindIdInSheet(oDoc.Sheets.getByName(CF_TEST_SHEET_OLD), "A003") > 0 And _
                        CF_FindIdInSheet(oDoc.Sheets.getByName(CF_TEST_SHEET_NEW), "A003") = -1
End Function

Private Function CF_TestModifiedRow(oDoc As Object) As Boolean
    Dim oOld As Object
    Dim oNew As Object
    Dim rOld As Long
    Dim rNew As Long

    oOld = oDoc.Sheets.getByName(CF_TEST_SHEET_OLD)
    oNew = oDoc.Sheets.getByName(CF_TEST_SHEET_NEW)

    rOld = CF_FindIdInSheet(oOld, "A002")
    rNew = CF_FindIdInSheet(oNew, "A002")

    If rOld < 0 Or rNew < 0 Then
        CF_TestModifiedRow = False
    Else
        CF_TestModifiedRow = oOld.getCellByPosition(2, rOld).String <> oNew.getCellByPosition(2, rNew).String
    End If
End Function

Private Function CF_TestUnchangedRow(oDoc As Object) As Boolean
    Dim oOld As Object
    Dim oNew As Object
    Dim rOld As Long
    Dim rNew As Long

    oOld = oDoc.Sheets.getByName(CF_TEST_SHEET_OLD)
    oNew = oDoc.Sheets.getByName(CF_TEST_SHEET_NEW)

    rOld = CF_FindIdInSheet(oOld, "A001")
    rNew = CF_FindIdInSheet(oNew, "A001")

    If rOld < 0 Or rNew < 0 Then
        CF_TestUnchangedRow = False
    Else
        CF_TestUnchangedRow = _
            oOld.getCellByPosition(1, rOld).String = oNew.getCellByPosition(1, rNew).String And _
            oOld.getCellByPosition(2, rOld).String = oNew.getCellByPosition(2, rNew).String And _
            oOld.getCellByPosition(3, rOld).String = oNew.getCellByPosition(3, rNew).String
    End If
End Function

Private Function CF_FindIdInSheet(oSheet As Object, sId As String) As Long
    Dim oCursor As Object
    Dim lastRow As Long
    Dim r As Long

    oCursor = oSheet.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow

    For r = 1 To lastRow
        If Trim(CStr(oSheet.getCellByPosition(0, r).String)) = sId Then
            CF_FindIdInSheet = r
            Exit Function
        End If
    Next r

    CF_FindIdInSheet = -1
End Function

Private Sub CF_WriteTestHeader(oSheet As Object)
    CF_SetCell oSheet, 0, 0, "Test"
    CF_SetCell oSheet, 1, 0, "Résultat"
    CF_SetCell oSheet, 2, 0, "Date"
End Sub

Private Sub CF_AddTestResult(oSheet As Object, ByRef row As Long, sName As String, bOk As Boolean, ByRef total As Long, ByRef passed As Long)
    total = total + 1
    If bOk Then passed = passed + 1

    CF_SetCell oSheet, 0, row, sName
    If bOk Then
        CF_SetCell oSheet, 1, row, "OK"
    Else
        CF_SetCell oSheet, 1, row, "KO"
    End If
    CF_SetCell oSheet, 2, row, Now

    row = row + 1
End Sub

Private Sub CF_WriteTestSummary(oSheet As Object, row As Long, total As Long, passed As Long)
    CF_SetCell oSheet, 0, row, "Synthèse"
    CF_SetCell oSheet, 1, row, passed & "/" & total
    If passed = total Then
        CF_SetCell oSheet, 2, row, "OK"
    Else
        CF_SetCell oSheet, 2, row, "A CONTROLER"
    End If
End Sub

Private Sub CF_FormatTestResults(oSheet As Object)
    On Error Resume Next

    Dim oRange As Object
    oRange = oSheet.getCellRangeByName("A1:C1")
    oRange.CharWeight = com.sun.star.awt.FontWeight.BOLD
    oRange.CellBackColor = RGB(220, 230, 241)

    oSheet.Columns.getByIndex(0).Width = 7000
    oSheet.Columns.getByIndex(1).Width = 2500
    oSheet.Columns.getByIndex(2).Width = 4500
End Sub

Private Sub CF_SetCell(oSheet As Object, col As Long, row As Long, value As Variant)
    oSheet.getCellByPosition(col, row).String = CStr(value)
End Sub

Private Sub CF_CreateSheet(oDoc As Object, sName As String)
    If Not oDoc.Sheets.hasByName(sName) Then
        oDoc.Sheets.insertNewByName(sName, oDoc.Sheets.getCount())
    End If
End Sub

Private Sub CF_DeleteSheetIfExists(oDoc As Object, sName As String)
    If oDoc.Sheets.hasByName(sName) Then
        oDoc.Sheets.removeByName(sName)
    End If
End Sub


'=========================================================
' V2.5 - Context tests
'=========================================================

Public Sub CF_RunContextTests()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oRes As Object
    Dim row As Long
    Dim total As Long
    Dim passed As Long

    oDoc = ThisComponent

    CF_DeleteSheetIfExists_TestContext oDoc, "CF_Test_Context"
    oDoc.Sheets.insertNewByName "CF_Test_Context", oDoc.Sheets.getCount()
    oRes = oDoc.Sheets.getByName("CF_Test_Context")

    oRes.getCellByPosition(0, 0).String = "Test"
    oRes.getCellByPosition(1, 0).String = "Résultat"

    row = 1
    total = 0
    passed = 0

    CF_ContextReset
    CF_AddContextTestResult oRes, row, "Context initialisé", CF_ContextHas("FrameworkVersion"), total, passed
    CF_ContextSet "SampleKey", "SampleValue"
    CF_AddContextTestResult oRes, row, "Set/Get contexte", CF_ContextGet("SampleKey") = "SampleValue", total, passed
    CF_AddContextTestResult oRes, row, "Clé absente avec défaut", CF_ContextGet("MissingKey", "DEFAULT") = "DEFAULT", total, passed
    CF_ContextBeginRun "UnitTest"
    CF_AddContextTestResult oRes, row, "BeginRun status", CF_ContextGet("Status") = "RUNNING", total, passed
    CF_ContextEndRun "DONE"
    CF_AddContextTestResult oRes, row, "EndRun status", CF_ContextGet("Status") = "DONE", total, passed

    oRes.getCellByPosition(0, row + 1).String = "Synthèse"
    oRes.getCellByPosition(1, row + 1).String = passed & "/" & total

    MsgBox "Tests contexte : " & passed & "/" & total, 64, "CompareFramework V2.5"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunContextTests : " & Err & " - " & Error$, 16, "CompareFramework V2.5"
End Sub

Private Sub CF_AddContextTestResult(oSheet As Object, ByRef row As Long, sName As String, bOk As Boolean, ByRef total As Long, ByRef passed As Long)
    total = total + 1
    If bOk Then passed = passed + 1

    oSheet.getCellByPosition(0, row).String = sName
    If bOk Then
        oSheet.getCellByPosition(1, row).String = "OK"
    Else
        oSheet.getCellByPosition(1, row).String = "KO"
    End If

    row = row + 1
End Sub

Private Sub CF_DeleteSheetIfExists_TestContext(oDoc As Object, sName As String)
    If oDoc.Sheets.hasByName(sName) Then
        oDoc.Sheets.removeByName(sName)
    End If
End Sub


'======================================================================

' CompareFramework_Main.bas

'======================================================================

' CompareFramework V2.5 - Main
' Orchestration et API publique.
Option Explicit

Public Sub ComparerToutesLesFeuilles()
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
    FrameworkManifest = "Main,Config,Index,Rules,Report,Utils"
End Function

Public Function GetFrameworkVersion() As String
    GetFrameworkVersion = CF_VERSION
End Function

Public Sub DiagnosticFramework()
    MsgBox "CompareFramework V2.5" & Chr(10) & _
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
    MsgBox "Erreur comparaison contextualisée : " & Err & " - " & Error$, 16, "CompareFramework V2.5"
End Sub

Public Sub DiagnosticFramework_Contextualise()
    CF_ContextBeginRun "DiagnosticFramework"
    CF_ContextSet "Modules", FrameworkManifest()
    CF_ContextSet "Version", GetFrameworkVersion()
    CF_ContextEndRun "DONE"
    CF_ContextDumpToSheet
End Sub
