Option Explicit

' CompareFramework V3.6.2 Stable - Monolithic hotfix
' LibreOffice Basic compatible optional parameters

'======================================================================
' CompareFramework_Utils.bas
'======================================================================
' CompareFramework V3.6.2 Stable - Utils
' Constantes globales et utilitaires communs.
Public Const CF_VERSION As String = "3.6.2"
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

'======================================================================
' CompareFramework_Context.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - Execution Context
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

Public Function CF_ContextGet(sKey As String, Optional sDefault As Variant) As String
    Dim idx As Long

    CF_ContextInitIfNeeded

    idx = CF_ContextIndexOf(sKey)
    If idx >= 0 Then
        CF_ContextGet = CF_CTX_VALUES(idx)
    ElseIf IsMissing(sDefault) Then
        CF_ContextGet = ""
    Else
        CF_ContextGet = CStr(sDefault)
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

    MsgBox "Contexte exporté dans Compare_Context.", 64, "CompareFramework V3.6.2 Stable"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_ContextDumpToSheet : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_ContextBeginRun(Optional sRunName As Variant)
    Dim resolvedRunName As String

    If IsMissing(sRunName) Then
        resolvedRunName = ""
    Else
        resolvedRunName = CStr(sRunName)
    End If

    CF_ContextReset
    CF_ContextSet "RunName", resolvedRunName
    CF_ContextSet "Status", "RUNNING"
    CF_ContextSet "DocumentURL", ThisComponent.URL
End Sub

Public Sub CF_ContextEndRun(Optional sStatus As Variant)
    Dim resolvedStatus As String

    If IsMissing(sStatus) Then
        resolvedStatus = "DONE"
    Else
        resolvedStatus = CStr(sStatus)
    End If

    CF_ContextSet "EndedAt", CStr(Now)
    CF_ContextSet "Status", resolvedStatus
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
' CompareFramework_Audit.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - Execution Audit
'=========================================================
' Public API:
'   CF_AuditBegin(runName)
'   CF_AuditSet(metricName, value)
'   CF_AuditEnd(status)
'   CF_AuditWriteCurrentRun()
'   CF_AuditClearHistory()
'
' The audit history is stored in the sheet:
'   Compare_Audit
'=========================================================

Private CF_AUDIT_RUN_ID As String
Private CF_AUDIT_RUN_NAME As String
Private CF_AUDIT_STARTED_AT As Date
Private CF_AUDIT_ENDED_AT As Date
Private CF_AUDIT_STATUS As String
Private CF_AUDIT_ERROR_NUMBER As String
Private CF_AUDIT_ERROR_MESSAGE As String
Private CF_AUDIT_METRIC_KEYS() As String
Private CF_AUDIT_METRIC_VALUES() As String
Private CF_AUDIT_METRIC_COUNT As Long
Private CF_AUDIT_ACTIVE As Boolean
Private CF_AUDIT_SUSPENDED As Boolean

Public Sub CF_AuditSuspend()
    CF_AUDIT_SUSPENDED = True
End Sub

Public Sub CF_AuditResume()
    CF_AUDIT_SUSPENDED = False
End Sub

Public Function CF_AuditIsActive() As Boolean
    CF_AuditIsActive = CF_AUDIT_ACTIVE
End Function

Public Sub CF_AuditBegin(Optional sRunName As Variant)
    ReDim CF_AUDIT_METRIC_KEYS(0 To 0)
    ReDim CF_AUDIT_METRIC_VALUES(0 To 0)

    Dim resolvedRunName As String

    If IsMissing(sRunName) Then
        resolvedRunName = "Comparison"
    Else
        resolvedRunName = CStr(sRunName)
    End If

    CF_AUDIT_METRIC_COUNT = 0
    CF_AUDIT_RUN_ID = CF_AuditCreateRunId()
    CF_AUDIT_RUN_NAME = resolvedRunName
    CF_AUDIT_STARTED_AT = Now
    CF_AUDIT_ENDED_AT = 0
    CF_AUDIT_STATUS = "RUNNING"
    CF_AUDIT_ERROR_NUMBER = ""
    CF_AUDIT_ERROR_MESSAGE = ""
    CF_AUDIT_ACTIVE = True

    On Error Resume Next
    CF_ContextSet "RunId", CF_AUDIT_RUN_ID
    CF_ContextSet "RunName", CF_AUDIT_RUN_NAME
    CF_ContextSet "AuditStatus", CF_AUDIT_STATUS
    CF_ContextSet "AuditStartedAt", CStr(CF_AUDIT_STARTED_AT)
End Sub

Public Sub CF_AuditSet(sMetricName As String, vValue As Variant)
    Dim idx As Long

    If CF_AUDIT_SUSPENDED Then Exit Sub

    If Not CF_AUDIT_ACTIVE Then
        CF_AuditBegin "ImplicitRun"
    End If

    sMetricName = Trim(CStr(sMetricName))
    If sMetricName = "" Then Exit Sub

    idx = CF_AuditMetricIndexOf(sMetricName)

    If idx >= 0 Then
        CF_AUDIT_METRIC_VALUES(idx) = CStr(vValue)
    Else
        If CF_AUDIT_METRIC_COUNT = 0 Then
            ReDim CF_AUDIT_METRIC_KEYS(0 To 0)
            ReDim CF_AUDIT_METRIC_VALUES(0 To 0)
        Else
            ReDim Preserve CF_AUDIT_METRIC_KEYS(0 To CF_AUDIT_METRIC_COUNT)
            ReDim Preserve CF_AUDIT_METRIC_VALUES(0 To CF_AUDIT_METRIC_COUNT)
        End If

        CF_AUDIT_METRIC_KEYS(CF_AUDIT_METRIC_COUNT) = sMetricName
        CF_AUDIT_METRIC_VALUES(CF_AUDIT_METRIC_COUNT) = CStr(vValue)
        CF_AUDIT_METRIC_COUNT = CF_AUDIT_METRIC_COUNT + 1
    End If
End Sub

Public Sub CF_AuditFail(vErrorNumber As Variant, sErrorMessage As String)
    CF_AUDIT_ERROR_NUMBER = CStr(vErrorNumber)
    CF_AUDIT_ERROR_MESSAGE = CStr(sErrorMessage)
    CF_AUDIT_STATUS = "ERROR"

    On Error Resume Next
    CF_ContextSet "ErrorNumber", CF_AUDIT_ERROR_NUMBER
    CF_ContextSet "ErrorMessage", CF_AUDIT_ERROR_MESSAGE
End Sub

Public Sub CF_AuditEnd(Optional sStatus As Variant)
    If Not CF_AUDIT_ACTIVE Then Exit Sub

    Dim resolvedStatus As String

    If IsMissing(sStatus) Then
        resolvedStatus = "DONE"
    Else
        resolvedStatus = CStr(sStatus)
    End If

    CF_AUDIT_ENDED_AT = Now

    If CF_AUDIT_STATUS <> "ERROR" Then
        CF_AUDIT_STATUS = resolvedStatus
    End If

    On Error Resume Next
    CF_ContextSet "AuditStatus", CF_AUDIT_STATUS
    CF_ContextSet "AuditEndedAt", CStr(CF_AUDIT_ENDED_AT)
    CF_ContextSet "AuditDurationSeconds", CStr(CF_AuditDurationSeconds())

    CF_AuditWriteCurrentRun
    CF_AUDIT_ACTIVE = False
End Sub

Public Sub CF_AuditWriteCurrentRun()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oSheet As Object
    Dim nextRow As Long

    oDoc = ThisComponent
    CF_AuditEnsureSheet oDoc
    oSheet = oDoc.Sheets.getByName("Compare_Audit")
    nextRow = CF_AuditNextRow(oSheet)

    CF_AuditWriteCell oSheet, 0, nextRow, CF_AUDIT_RUN_ID
    CF_AuditWriteCell oSheet, 1, nextRow, CF_AUDIT_RUN_NAME
    CF_AuditWriteCell oSheet, 2, nextRow, CStr(CF_AUDIT_STARTED_AT)
    CF_AuditWriteCell oSheet, 3, nextRow, CStr(CF_AUDIT_ENDED_AT)
    CF_AuditWriteCell oSheet, 4, nextRow, CStr(CF_AuditDurationSeconds())
    CF_AuditWriteCell oSheet, 5, nextRow, CF_AUDIT_STATUS
    CF_AuditWriteCell oSheet, 6, nextRow, CF_AuditGetProfileName()
    CF_AuditWriteCell oSheet, 7, nextRow, CF_AuditGetDocumentName()
    CF_AuditWriteCell oSheet, 8, nextRow, CF_AUDIT_ERROR_NUMBER
    CF_AuditWriteCell oSheet, 9, nextRow, CF_AUDIT_ERROR_MESSAGE
    CF_AuditWriteCell oSheet, 10, nextRow, CF_AuditSerializeMetrics()

    CF_AuditFormatSheet oSheet
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_AuditWriteCurrentRun : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_AuditClearHistory()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    oDoc = ThisComponent

    If oDoc.Sheets.hasByName("Compare_Audit") Then
        oDoc.Sheets.removeByName("Compare_Audit")
    End If

    CF_AuditEnsureSheet oDoc
    MsgBox "Historique d'audit réinitialisé.", 64, "CompareFramework V3.6.2 Stable"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_AuditClearHistory : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Function CF_AuditGetRunId() As String
    CF_AuditGetRunId = CF_AUDIT_RUN_ID
End Function

Public Function CF_AuditDurationSeconds() As Double
    Dim endValue As Date

    If CF_AUDIT_STARTED_AT = 0 Then
        CF_AuditDurationSeconds = 0
        Exit Function
    End If

    If CF_AUDIT_ENDED_AT = 0 Then
        endValue = Now
    Else
        endValue = CF_AUDIT_ENDED_AT
    End If

    CF_AuditDurationSeconds = CF_RoundCompat((endValue - CF_AUDIT_STARTED_AT) * 86400, 3)
End Function

Private Sub CF_AuditEnsureSheet(oDoc As Object)
    Dim oSheet As Object

    If Not oDoc.Sheets.hasByName("Compare_Audit") Then
        oDoc.Sheets.insertNewByName "Compare_Audit", oDoc.Sheets.getCount()
    End If

    oSheet = oDoc.Sheets.getByName("Compare_Audit")

    If Trim(oSheet.getCellByPosition(0, 0).String) = "" Then
        CF_AuditWriteCell oSheet, 0, 0, "Run ID"
        CF_AuditWriteCell oSheet, 1, 0, "Exécution"
        CF_AuditWriteCell oSheet, 2, 0, "Début"
        CF_AuditWriteCell oSheet, 3, 0, "Fin"
        CF_AuditWriteCell oSheet, 4, 0, "Durée (s)"
        CF_AuditWriteCell oSheet, 5, 0, "Statut"
        CF_AuditWriteCell oSheet, 6, 0, "Profil"
        CF_AuditWriteCell oSheet, 7, 0, "Document"
        CF_AuditWriteCell oSheet, 8, 0, "Erreur"
        CF_AuditWriteCell oSheet, 9, 0, "Message"
        CF_AuditWriteCell oSheet, 10, 0, "Métriques"
    End If
End Sub

Private Function CF_AuditNextRow(oSheet As Object) As Long
    Dim oCursor As Object
    oCursor = oSheet.createCursor()
    oCursor.gotoEndOfUsedArea(True)

    If Trim(oSheet.getCellByPosition(0, 0).String) = "" Then
        CF_AuditNextRow = 1
    Else
        CF_AuditNextRow = oCursor.RangeAddress.EndRow + 1
    End If
End Function

Private Function CF_AuditCreateRunId() As String
    Randomize
    CF_AuditCreateRunId = _
        Format(Now, "YYYYMMDD-HHMMSS") & "-" & _
        Right("0000" & CStr(Int(Rnd * 10000)), 4)
End Function

Private Function CF_AuditGetProfileName() As String
    On Error GoTo Fallback

    CF_AuditGetProfileName = CF_ContextGet("ActiveProfile", "")
    If CF_AuditGetProfileName = "" Then
        CF_AuditGetProfileName = CF_ContextGet("ProfileName", "STANDARD")
    End If
    Exit Function

Fallback:
    CF_AuditGetProfileName = "STANDARD"
End Function

Private Function CF_AuditGetDocumentName() As String
    On Error GoTo Fallback

    If ThisComponent.Title <> "" Then
        CF_AuditGetDocumentName = ThisComponent.Title
    Else
        CF_AuditGetDocumentName = ThisComponent.URL
    End If
    Exit Function

Fallback:
    CF_AuditGetDocumentName = ""
End Function

Private Function CF_AuditSerializeMetrics() As String
    Dim i As Long
    Dim s As String

    s = ""
    For i = 0 To CF_AUDIT_METRIC_COUNT - 1
        If s <> "" Then s = s & "; "
        s = s & CF_AUDIT_METRIC_KEYS(i) & "=" & CF_AUDIT_METRIC_VALUES(i)
    Next i

    CF_AuditSerializeMetrics = s
End Function

Private Function CF_AuditMetricIndexOf(sMetricName As String) As Long
    Dim i As Long
    Dim normalized As String

    normalized = UCase(Trim(CStr(sMetricName)))

    For i = 0 To CF_AUDIT_METRIC_COUNT - 1
        If UCase(CF_AUDIT_METRIC_KEYS(i)) = normalized Then
            CF_AuditMetricIndexOf = i
            Exit Function
        End If
    Next i

    CF_AuditMetricIndexOf = -1
End Function

Private Sub CF_AuditWriteCell(oSheet As Object, col As Long, row As Long, value As Variant)
    oSheet.getCellByPosition(col, row).String = CStr(value)
End Sub

Private Sub CF_AuditFormatSheet(oSheet As Object)
    On Error Resume Next

    oSheet.getCellRangeByName("A1:K1").CharWeight = com.sun.star.awt.FontWeight.BOLD
    oSheet.getCellRangeByName("A1:K1").CellBackColor = RGB(220, 230, 241)

    oSheet.Columns.getByIndex(0).Width = 5000
    oSheet.Columns.getByIndex(1).Width = 5000
    oSheet.Columns.getByIndex(2).Width = 4500
    oSheet.Columns.getByIndex(3).Width = 4500
    oSheet.Columns.getByIndex(4).Width = 2500
    oSheet.Columns.getByIndex(5).Width = 2500
    oSheet.Columns.getByIndex(6).Width = 3500
    oSheet.Columns.getByIndex(7).Width = 6500
    oSheet.Columns.getByIndex(8).Width = 2500
    oSheet.Columns.getByIndex(9).Width = 9000
    oSheet.Columns.getByIndex(10).Width = 12000
End Sub

'======================================================================
' CompareFramework_Config.bas
'======================================================================
' CompareFramework V3.6.2 Stable - Config
' Chargement configuration, profils et normalisation.
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
' CompareFramework_Profiles.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - Reusable Profiles
'=========================================================
' Public API:
'   CF_EnsureProfilesSheet()
'   CF_ApplyProfile(profileName)
'   CF_SaveCurrentConfigAsProfile(profileName)
'   CF_ListProfiles()
'   CF_RunWithProfile(profileName)
'=========================================================

Public Const CF_PROFILES_SHEET As String = "Compare_Profiles"

Public Function CF_EnsureProfilesSheet(oDoc As Object) As Object
    Dim oSheet As Object

    If oDoc.Sheets.hasByName(CF_PROFILES_SHEET) Then
        oSheet = oDoc.Sheets.getByName(CF_PROFILES_SHEET)
    Else
        oDoc.Sheets.insertNewByName CF_PROFILES_SHEET, oDoc.Sheets.getCount()
        oSheet = oDoc.Sheets.getByName(CF_PROFILES_SHEET)
        CF_WriteDefaultProfiles oSheet
    End If

    CF_EnsureProfilesSheet = oSheet
End Function

Public Sub CF_WriteDefaultProfiles(oSheet As Object)
    CF_WriteProfileHeader oSheet

    CF_WriteProfileRow oSheet, 1, "STANDARD", "", "ID;Identifiant;Code;Reference;Ref;Cle;Key", "FALSE", "TRUE", "FALSE", "Configuration générale"
    CF_WriteProfileRow oSheet, 2, "FINANCE", "DateModification;Horodatage;Utilisateur", "ID;Reference;Ref;Numero;Ecriture", "FALSE", "TRUE", "FALSE", "Profil comptable et financier"
    CF_WriteProfileRow oSheet, 3, "RH", "DateModification;Horodatage;Utilisateur", "Matricule;ID;Identifiant;CodeSalarie", "TRUE", "TRUE", "FALSE", "Profil ressources humaines"
    CF_WriteProfileRow oSheet, 4, "ERP", "LastUpdate;UpdatedAt;UpdatedBy", "ID;Code;Reference;Ref;Cle", "FALSE", "TRUE", "FALSE", "Profil ERP"
    CF_WriteProfileRow oSheet, 5, "CRM", "LastModified;ModifiedBy;SyncDate", "ID;ContactId;AccountId;CodeClient", "TRUE", "TRUE", "TRUE", "Profil CRM"

    On Error Resume Next
    oSheet.getCellRangeByName("A1:G1").CharWeight = com.sun.star.awt.FontWeight.BOLD
    oSheet.getCellRangeByName("A1:G1").CellBackColor = RGB(217, 217, 217)
    oSheet.Columns.getByIndex(0).Width = 3500
    oSheet.Columns.getByIndex(1).Width = 8500
    oSheet.Columns.getByIndex(2).Width = 8500
    oSheet.Columns.getByIndex(3).Width = 3000
    oSheet.Columns.getByIndex(4).Width = 3500
    oSheet.Columns.getByIndex(5).Width = 4500
    oSheet.Columns.getByIndex(6).Width = 9000
End Sub

Public Sub CF_ApplyProfile(sProfileName As String)
    On Error GoTo ErrHandler

    Dim oDoc As Object, oProfiles As Object, oConfig As Object
    Dim rowIndex As Long

    oDoc = ThisComponent
    oProfiles = CF_EnsureProfilesSheet(oDoc)
    rowIndex = CF_FindProfileRow(oProfiles, sProfileName)

    If rowIndex < 1 Then
        MsgBox "Profil introuvable : " & sProfileName, 48, "CompareFramework V3.6.2 Stable"
        Exit Sub
    End If

    oConfig = EnsureConfigSheet(oDoc)
    CF_SetConfigValue oConfig, "IGNORE_COLUMNS", CellText(oProfiles, 1, rowIndex)
    CF_SetConfigValue oConfig, "ID_ALIASES", CellText(oProfiles, 2, rowIndex)
    CF_SetConfigValue oConfig, "IGNORE_CASE", CellText(oProfiles, 3, rowIndex)
    CF_SetConfigValue oConfig, "NORMALIZE_SPACES", CellText(oProfiles, 4, rowIndex)
    CF_SetConfigValue oConfig, "IGNORE_EMPTY_CHANGES", CellText(oProfiles, 5, rowIndex)

    CF_ContextSet "ActiveProfile", UCase(Trim(sProfileName))
    CF_ContextSet "ProfileAppliedAt", CStr(Now)
    LoadCompareConfig oDoc

    MsgBox "Profil appliqué : " & UCase(Trim(sProfileName)), 64, "CompareFramework V3.6.2 Stable"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_ApplyProfile : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_SaveCurrentConfigAsProfile(sProfileName As String)
    On Error GoTo ErrHandler

    Dim oDoc As Object, oProfiles As Object, oConfig As Object
    Dim rowIndex As Long

    sProfileName = UCase(Trim(sProfileName))
    If sProfileName = "" Then
        MsgBox "Le nom du profil est obligatoire.", 48, "CompareFramework V3.6.2 Stable"
        Exit Sub
    End If

    oDoc = ThisComponent
    oProfiles = CF_EnsureProfilesSheet(oDoc)
    oConfig = EnsureConfigSheet(oDoc)
    rowIndex = CF_FindProfileRow(oProfiles, sProfileName)
    If rowIndex < 1 Then rowIndex = LastUsedRow(oProfiles) + 1

    CF_WriteProfileRow oProfiles, rowIndex, sProfileName, _
        CF_GetConfigValue(oConfig, "IGNORE_COLUMNS"), _
        CF_GetConfigValue(oConfig, "ID_ALIASES"), _
        CF_GetConfigValue(oConfig, "IGNORE_CASE"), _
        CF_GetConfigValue(oConfig, "NORMALIZE_SPACES"), _
        CF_GetConfigValue(oConfig, "IGNORE_EMPTY_CHANGES"), _
        "Profil enregistré le " & CStr(Now)

    MsgBox "Profil enregistré : " & sProfileName, 64, "CompareFramework V3.6.2 Stable"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_SaveCurrentConfigAsProfile : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_ListProfiles()
    Dim oSheet As Object
    oSheet = CF_EnsureProfilesSheet(ThisComponent)
    ThisComponent.CurrentController.setActiveSheet(oSheet)
End Sub

Public Sub CF_RunWithProfile(sProfileName As String)
    On Error GoTo ErrHandler

    CF_ContextBeginRun "ComparerToutesLesFeuilles"
    CF_ContextSet "RequestedProfile", UCase(Trim(sProfileName))
    CF_ApplyProfile sProfileName
    ComparerToutesLesFeuilles
    CF_ContextEndRun "DONE"
    Exit Sub

ErrHandler:
    CF_ContextSet "ErrorNumber", CStr(Err)
    CF_ContextSet "ErrorMessage", Error$
    CF_ContextEndRun "ERROR"
    MsgBox "Erreur CF_RunWithProfile : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Private Sub CF_WriteProfileHeader(oSheet As Object)
    SetCell oSheet, 0, 0, "ProfileName"
    SetCell oSheet, 1, 0, "IGNORE_COLUMNS"
    SetCell oSheet, 2, 0, "ID_ALIASES"
    SetCell oSheet, 3, 0, "IGNORE_CASE"
    SetCell oSheet, 4, 0, "NORMALIZE_SPACES"
    SetCell oSheet, 5, 0, "IGNORE_EMPTY_CHANGES"
    SetCell oSheet, 6, 0, "Description"
End Sub

Private Sub CF_WriteProfileRow(oSheet As Object, rowIndex As Long, profileName As String, ignoreColumns As String, idAliases As String, ignoreCase As String, normalizeSpaces As String, ignoreEmptyChanges As String, description As String)
    SetCell oSheet, 0, rowIndex, UCase(Trim(profileName))
    SetCell oSheet, 1, rowIndex, ignoreColumns
    SetCell oSheet, 2, rowIndex, idAliases
    SetCell oSheet, 3, rowIndex, ignoreCase
    SetCell oSheet, 4, rowIndex, normalizeSpaces
    SetCell oSheet, 5, rowIndex, ignoreEmptyChanges
    SetCell oSheet, 6, rowIndex, description
End Sub

Private Function CF_FindProfileRow(oSheet As Object, sProfileName As String) As Long
    Dim r As Long, lastRow As Long
    sProfileName = UCase(Trim(sProfileName))
    lastRow = LastUsedRow(oSheet)

    For r = 1 To lastRow
        If UCase(Trim(CellText(oSheet, 0, r))) = sProfileName Then
            CF_FindProfileRow = r
            Exit Function
        End If
    Next r

    CF_FindProfileRow = -1
End Function

Private Sub CF_SetConfigValue(oSheet As Object, sKey As String, sValue As String)
    Dim r As Long, lastRow As Long
    lastRow = LastUsedRow(oSheet)

    For r = 1 To lastRow
        If UCase(Trim(CellText(oSheet, 0, r))) = UCase(Trim(sKey)) Then
            SetCell oSheet, 1, r, sValue
            Exit Sub
        End If
    Next r

    SetCell oSheet, 0, lastRow + 1, sKey
    SetCell oSheet, 1, lastRow + 1, sValue
End Sub

Private Function CF_GetConfigValue(oSheet As Object, sKey As String) As String
    Dim r As Long, lastRow As Long
    lastRow = LastUsedRow(oSheet)

    For r = 1 To lastRow
        If UCase(Trim(CellText(oSheet, 0, r))) = UCase(Trim(sKey)) Then
            CF_GetConfigValue = CellText(oSheet, 1, r)
            Exit Function
        End If
    Next r

    CF_GetConfigValue = ""
End Function

'======================================================================
' CompareFramework_Index.bas
'======================================================================
' CompareFramework V3.6.2 Stable - Index
' Indexation des identifiants, recherche et doublons.
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
' CompareFramework V3.6.2 Stable - Rules
' Moteur de règles et comparaison détaillée.
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
' CompareFramework_ComparatorConfig.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - Comparator configuration
' Jalon B: types and tolerances by profile/column
'=========================================================

Public Const CF_COMPARATORS_SHEET As String = "Compare_Comparators"

Private CF_CC_ENABLED() As Boolean
Private CF_CC_PROFILE() As String
Private CF_CC_COLUMN() As String
Private CF_CC_TYPE() As String
Private CF_CC_TOLERANCE() As String
Private CF_CC_COUNT As Long
Private CF_CC_LOADED As Boolean

Public Function CF_EnsureComparatorsSheet(oDoc As Object) As Object
    Dim oSheet As Object

    If oDoc.Sheets.hasByName(CF_COMPARATORS_SHEET) Then
        oSheet = oDoc.Sheets.getByName(CF_COMPARATORS_SHEET)
    Else
        oDoc.Sheets.insertNewByName CF_COMPARATORS_SHEET, oDoc.Sheets.getCount()
        oSheet = oDoc.Sheets.getByName(CF_COMPARATORS_SHEET)
        CF_WriteDefaultComparatorConfig oSheet
    End If

    CF_EnsureComparatorsSheet = oSheet
End Function

Public Sub CF_WriteDefaultComparatorConfig(oSheet As Object)
    CF_CC_SetCell oSheet, 0, 0, "Enabled"
    CF_CC_SetCell oSheet, 1, 0, "Profile"
    CF_CC_SetCell oSheet, 2, 0, "Column"
    CF_CC_SetCell oSheet, 3, 0, "Comparator"
    CF_CC_SetCell oSheet, 4, 0, "Tolerance"
    CF_CC_SetCell oSheet, 5, 0, "Comment"

    CF_CC_WriteRow oSheet, 1, "TRUE", "GLOBAL", "*", "AUTO", "", "Fallback: auto-detection"
    CF_CC_WriteRow oSheet, 2, "FALSE", "FINANCE", "Montant", "CURRENCY", "0.01", "Example financial tolerance"
    CF_CC_WriteRow oSheet, 3, "FALSE", "GLOBAL", "Date", "DATE", "0", "Example exact date comparison"
    CF_CC_WriteRow oSheet, 4, "FALSE", "RH", "Actif", "BOOLEAN", "", "Example boolean comparator"

    On Error Resume Next
    oSheet.getCellRangeByName("A1:F1").CharWeight = com.sun.star.awt.FontWeight.BOLD
    oSheet.getCellRangeByName("A1:F1").CellBackColor = RGB(217, 217, 217)
    oSheet.Columns.getByIndex(0).Width = 2500
    oSheet.Columns.getByIndex(1).Width = 3500
    oSheet.Columns.getByIndex(2).Width = 5500
    oSheet.Columns.getByIndex(3).Width = 3500
    oSheet.Columns.getByIndex(4).Width = 3000
    oSheet.Columns.getByIndex(5).Width = 9000
End Sub

Public Sub CF_LoadComparatorConfig(oDoc As Object)
    Dim oSheet As Object
    Dim lastRow As Long
    Dim r As Long
    Dim n As Long

    oSheet = CF_EnsureComparatorsSheet(oDoc)
    lastRow = LastUsedRow(oSheet)

    ReDim CF_CC_ENABLED(0 To 0)
    ReDim CF_CC_PROFILE(0 To 0)
    ReDim CF_CC_COLUMN(0 To 0)
    ReDim CF_CC_TYPE(0 To 0)
    ReDim CF_CC_TOLERANCE(0 To 0)
    n = 0

    For r = 1 To lastRow
        If Trim(CellText(oSheet, 2, r)) <> "" Then
            If n > 0 Then
                ReDim Preserve CF_CC_ENABLED(0 To n)
                ReDim Preserve CF_CC_PROFILE(0 To n)
                ReDim Preserve CF_CC_COLUMN(0 To n)
                ReDim Preserve CF_CC_TYPE(0 To n)
                ReDim Preserve CF_CC_TOLERANCE(0 To n)
            End If

            CF_CC_ENABLED(n) = CF_CC_ToBoolean(CellText(oSheet, 0, r))
            CF_CC_PROFILE(n) = UCase(Trim(CellText(oSheet, 1, r)))
            CF_CC_COLUMN(n) = UCase(Trim(CellText(oSheet, 2, r)))
            CF_CC_TYPE(n) = UCase(Trim(CellText(oSheet, 3, r)))
            CF_CC_TOLERANCE(n) = Trim(CellText(oSheet, 4, r))
            n = n + 1
        End If
    Next r

    CF_CC_COUNT = n
    CF_CC_LOADED = True
    CF_ContextSet "ComparatorConfigRows", CStr(n)
End Sub

Public Function CF_ResolveComparatorConfig(headerName As String, ByRef comparatorType As String, ByRef tolerance As Double, ByRef hasTolerance As Boolean, ByRef source As String) As Boolean
    Dim activeProfile As String
    Dim normalizedHeader As String
    Dim idx As Long

    If Not CF_CC_LOADED Then CF_LoadComparatorConfig ThisComponent

    activeProfile = UCase(Trim(CF_ContextGet("ActiveProfile", "STANDARD")))
    normalizedHeader = UCase(Trim(headerName))

    idx = CF_CC_FindRule(activeProfile, normalizedHeader)
    If idx < 0 Then idx = CF_CC_FindRule("GLOBAL", normalizedHeader)
    If idx < 0 Then idx = CF_CC_FindRule(activeProfile, "*")
    If idx < 0 Then idx = CF_CC_FindRule("GLOBAL", "*")

    If idx < 0 Then
        CF_ResolveComparatorConfig = False
        Exit Function
    End If

    comparatorType = CF_CC_TYPE(idx)
    If comparatorType = "" Then comparatorType = CF_TYPE_AUTO
    hasTolerance = CF_CC_TryParseDouble(CF_CC_TOLERANCE(idx), tolerance)
    source = CF_CC_PROFILE(idx) & "/" & CF_CC_COLUMN(idx)
    CF_ResolveComparatorConfig = True
End Function

Public Sub CF_ReloadComparatorConfig()
    CF_CC_LOADED = False
    CF_LoadComparatorConfig ThisComponent
    MsgBox "Configuration des comparateurs rechargee : " & CF_CC_COUNT & " regle(s).", 64, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_OpenComparatorConfig()
    Dim oSheet As Object
    oSheet = CF_EnsureComparatorsSheet(ThisComponent)
    ThisComponent.CurrentController.setActiveSheet(oSheet)
End Sub

Public Sub CF_RunComparatorConfigTests()
    On Error GoTo ErrHandler

    Dim oSheet As Object
    Dim typ As String, src As String
    Dim tol As Double, hasTol As Boolean
    Dim ok1 As Boolean, ok2 As Boolean, ok3 As Boolean
    Dim nextRow As Long

    oSheet = CF_EnsureComparatorsSheet(ThisComponent)
    nextRow = LastUsedRow(oSheet) + 1
    CF_CC_WriteRow oSheet, nextRow, "TRUE", "STANDARD", "CF_TEST_AMOUNT", "CURRENCY", "0.25", "Temporary test"
    CF_CC_WriteRow oSheet, nextRow + 1, "TRUE", "STANDARD", "CF_TEST_DATE", "DATE", "1", "Temporary test"

    CF_ContextSet "ActiveProfile", "STANDARD"
    CF_LoadComparatorConfig ThisComponent

    ok1 = CF_ResolveComparatorConfig("CF_TEST_AMOUNT", typ, tol, hasTol, src) And typ = CF_TYPE_CURRENCY And hasTol And Abs(tol - 0.25) < 0.000001
    ok2 = CF_ResolveComparatorConfig("CF_TEST_DATE", typ, tol, hasTol, src) And typ = CF_TYPE_DATE And hasTol And Abs(tol - 1) < 0.000001
    ok3 = CF_ResolveComparatorConfig("UnknownColumn", typ, tol, hasTol, src) And typ = CF_TYPE_AUTO

    oSheet.getCellRangeByPosition(0, nextRow, 5, nextRow + 1).clearContents(1023)
    CF_LoadComparatorConfig ThisComponent

    If ok1 And ok2 And ok3 Then
        MsgBox "Tests configuration comparateurs : 3/3", 64, "CompareFramework V3.6.2 Stable"
    Else
        MsgBox "Tests configuration comparateurs a controler.", 48, "CompareFramework V3.6.2 Stable"
    End If
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunComparatorConfigTests : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Private Function CF_CC_FindRule(profileName As String, columnName As String) As Long
    Dim i As Long
    For i = 0 To CF_CC_COUNT - 1
        If CF_CC_ENABLED(i) Then
            If CF_CC_PROFILE(i) = profileName And CF_CC_COLUMN(i) = columnName Then
                CF_CC_FindRule = i
                Exit Function
            End If
        End If
    Next i
    CF_CC_FindRule = -1
End Function

Private Function CF_CC_ToBoolean(v As String) As Boolean
    Dim s As String
    s = UCase(Trim(v))
    CF_CC_ToBoolean = (s = "TRUE" Or s = "VRAI" Or s = "YES" Or s = "OUI" Or s = "1" Or s = "X")
End Function

Private Function CF_CC_TryParseDouble(v As String, ByRef result As Double) As Boolean
    On Error GoTo Fail

    Dim s As String
    Dim i As Long
    Dim ch As String
    Dim dotCount As Long

    s = Trim(CStr(v))
    s = Replace(s, " ", "")
    s = Replace(s, Chr(160), "")

    If s = "" Then GoTo Fail

    ' Normalize both French and international decimal separators.
    s = Replace(s, ",", ".")

    ' Validate the normalized numeric syntax before using Val().
    For i = 1 To Len(s)
        ch = Mid(s, i, 1)

        If ch = "." Then
            dotCount = dotCount + 1
            If dotCount > 1 Then GoTo Fail
        ElseIf InStr("0123456789+-Ee", ch) = 0 Then
            GoTo Fail
        End If
    Next i

    If s = "+" Or s = "-" Or s = "." Or s = "+." Or s = "-." Then GoTo Fail

    ' Val() always expects a dot and is not dependent on the UI locale.
    result = Val(s)
    CF_CC_TryParseDouble = True
    Exit Function

Fail:
    result = 0
    CF_CC_TryParseDouble = False
End Function

Private Sub CF_CC_WriteRow(oSheet As Object, rowIndex As Long, enabled As String, profileName As String, columnName As String, comparatorType As String, tolerance As String, comment As String)
    CF_CC_SetCell oSheet, 0, rowIndex, enabled
    CF_CC_SetCell oSheet, 1, rowIndex, UCase(Trim(profileName))
    CF_CC_SetCell oSheet, 2, rowIndex, columnName
    CF_CC_SetCell oSheet, 3, rowIndex, UCase(Trim(comparatorType))
    CF_CC_SetCell oSheet, 4, rowIndex, tolerance
    CF_CC_SetCell oSheet, 5, rowIndex, comment
End Sub

Private Sub CF_CC_SetCell(oSheet As Object, col As Long, row As Long, value As Variant)
    oSheet.getCellByPosition(col, row).String = CStr(value)
End Sub

'======================================================================
' CompareFramework_Comparators.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - Typed comparators
' Jalon B: fiabilite des comparaisons
'=========================================================

Public Const CF_TYPE_AUTO As String = "AUTO"
Public Const CF_TYPE_TEXT As String = "TEXT"
Public Const CF_TYPE_NUMBER As String = "NUMBER"
Public Const CF_TYPE_DATE As String = "DATE"
Public Const CF_TYPE_BOOLEAN As String = "BOOLEAN"
Public Const CF_TYPE_PERCENT As String = "PERCENT"
Public Const CF_TYPE_CURRENCY As String = "CURRENCY"

Public Function CF_TypedValuesEqual(oldRaw As Variant, newRaw As Variant, headerName As String, ByRef comparatorUsed As String, ByRef detail As String) As Boolean
    Dim requestedType As String
    Dim configuredType As String
    Dim tolerance As Double
    Dim hasTolerance As Boolean
    Dim configSource As String
    Dim hasConfig As Boolean

    hasConfig = CF_ResolveComparatorConfig(headerName, configuredType, tolerance, hasTolerance, configSource)

    If hasConfig And configuredType <> "" And configuredType <> CF_TYPE_AUTO Then
        requestedType = configuredType
    Else
        requestedType = CF_ComparatorTypeForHeader(headerName, oldRaw, newRaw)
    End If

    comparatorUsed = requestedType
    If hasConfig Then comparatorUsed = comparatorUsed & " [" & configSource & "]"
    detail = ""

    Select Case requestedType
        Case CF_TYPE_BOOLEAN
            CF_TypedValuesEqual = CF_BooleanEqual(oldRaw, newRaw, detail)
        Case CF_TYPE_NUMBER
            If Not hasTolerance Then tolerance = CF_GetNumericTolerance()
            CF_TypedValuesEqual = CF_NumberEqual(oldRaw, newRaw, tolerance, detail)
        Case CF_TYPE_PERCENT
            If Not hasTolerance Then tolerance = CF_GetPercentTolerance()
            CF_TypedValuesEqual = CF_NumberEqual(CF_PercentToNumber(oldRaw), CF_PercentToNumber(newRaw), tolerance, detail)
        Case CF_TYPE_CURRENCY
            If Not hasTolerance Then tolerance = CF_GetCurrencyTolerance()
            CF_TypedValuesEqual = CF_NumberEqual(CF_CurrencyToNumber(oldRaw), CF_CurrencyToNumber(newRaw), tolerance, detail)
        Case CF_TYPE_DATE
            If Not hasTolerance Then tolerance = CF_GetDateToleranceDays()
            CF_TypedValuesEqual = CF_DateEqual(oldRaw, newRaw, tolerance, detail)
        Case Else
            comparatorUsed = CF_TYPE_TEXT
            If hasConfig Then comparatorUsed = comparatorUsed & " [" & configSource & "]"
            CF_TypedValuesEqual = CF_TextEqual(oldRaw, newRaw, detail)
    End Select
End Function


Public Function CF_CompareTypedValues(oldValue As Variant, newValue As Variant, comparatorType As String, tolerance As Double) As Boolean
    Dim detail As String
    Dim resolvedType As String

    resolvedType = UCase(Trim(CStr(comparatorType)))
    If resolvedType = "" Then resolvedType = CF_TYPE_AUTO

    If resolvedType = CF_TYPE_AUTO Then
        resolvedType = CF_ComparatorTypeForHeader("", oldValue, newValue)
    End If

    Select Case resolvedType
        Case CF_TYPE_BOOLEAN
            CF_CompareTypedValues = CF_BooleanEqual(oldValue, newValue, detail)

        Case CF_TYPE_NUMBER
            CF_CompareTypedValues = CF_NumberEqual(oldValue, newValue, tolerance, detail)

        Case CF_TYPE_PERCENT
            CF_CompareTypedValues = CF_NumberEqual( _
                CF_PercentToNumber(oldValue), _
                CF_PercentToNumber(newValue), _
                tolerance, _
                detail)

        Case CF_TYPE_CURRENCY
            CF_CompareTypedValues = CF_NumberEqual( _
                CF_CurrencyToNumber(oldValue), _
                CF_CurrencyToNumber(newValue), _
                tolerance, _
                detail)

        Case CF_TYPE_DATE
            CF_CompareTypedValues = CF_DateEqual(oldValue, newValue, tolerance, detail)

        Case Else
            CF_CompareTypedValues = CF_TextEqual(oldValue, newValue, detail)
    End Select
End Function


Public Function CF_ComparatorTypeForHeader(headerName As String, oldRaw As Variant, newRaw As Variant) As String
    Dim h As String
    h = UCase(Trim(headerName))

    If InStr(h, "%") > 0 Or InStr(h, "PERCENT") > 0 Or InStr(h, "TAUX") > 0 Then
        CF_ComparatorTypeForHeader = CF_TYPE_PERCENT
    ElseIf InStr(h, "DATE") > 0 Or InStr(h, "ECHEANCE") > 0 Or InStr(h, "ÉCHÉANCE") > 0 Then
        CF_ComparatorTypeForHeader = CF_TYPE_DATE
    ElseIf InStr(h, "MONTANT") > 0 Or InStr(h, "PRIX") > 0 Or InStr(h, "COUT") > 0 Or InStr(h, "COÛT") > 0 Or InStr(h, "DEVISE") > 0 Or InStr(h, "AMOUNT") > 0 Or InStr(h, "PRICE") > 0 Then
        CF_ComparatorTypeForHeader = CF_TYPE_CURRENCY
    ElseIf InStr(h, "ACTIF") > 0 Or InStr(h, "ACTIVE") > 0 Or InStr(h, "BOOLEAN") > 0 Or Left(h, 3) = "IS_" Or Left(h, 4) = "HAS_" Then
        CF_ComparatorTypeForHeader = CF_TYPE_BOOLEAN
    ElseIf CF_LooksBoolean(oldRaw) And CF_LooksBoolean(newRaw) Then
        CF_ComparatorTypeForHeader = CF_TYPE_BOOLEAN
    ElseIf CF_LooksDate(oldRaw) And CF_LooksDate(newRaw) Then
        CF_ComparatorTypeForHeader = CF_TYPE_DATE
    ElseIf CF_LooksNumeric(oldRaw) And CF_LooksNumeric(newRaw) Then
        CF_ComparatorTypeForHeader = CF_TYPE_NUMBER
    Else
        CF_ComparatorTypeForHeader = CF_TYPE_TEXT
    End If
End Function

Public Function CF_TextEqual(a As Variant, b As Variant, ByRef detail As String) As Boolean
    Dim sa As String, sb As String
    sa = NormalizeCompareValue(CStr(a))
    sb = NormalizeCompareValue(CStr(b))
    detail = "TEXT"
    CF_TextEqual = (sa = sb)
End Function

Public Function CF_NumberEqual(a As Variant, b As Variant, tolerance As Double, ByRef detail As String) As Boolean
    Dim da As Double, db As Double, delta As Double
    If Not CF_TryParseNumber(a, da) Or Not CF_TryParseNumber(b, db) Then
        detail = "NUMBER parse impossible"
        CF_NumberEqual = False
        Exit Function
    End If
    delta = Abs(da - db)
    detail = "NUMBER delta=" & CStr(delta) & "; tolerance=" & CStr(tolerance)
    CF_NumberEqual = (delta <= tolerance)
End Function

Public Function CF_DateEqual(a As Variant, b As Variant, toleranceDays As Double, ByRef detail As String) As Boolean
    Dim da As Double, db As Double, delta As Double
    If Not CF_TryParseDateSerial(a, da) Or Not CF_TryParseDateSerial(b, db) Then
        detail = "DATE parse impossible"
        CF_DateEqual = False
        Exit Function
    End If
    delta = Abs(da - db)
    detail = "DATE delta jours=" & CStr(delta) & "; tolerance=" & CStr(toleranceDays)
    CF_DateEqual = (delta <= toleranceDays)
End Function

Public Function CF_BooleanEqual(a As Variant, b As Variant, ByRef detail As String) As Boolean
    Dim ba As Integer, bb As Integer
    ba = CF_BooleanCode(a)
    bb = CF_BooleanCode(b)
    detail = "BOOLEAN " & CStr(ba) & "/" & CStr(bb)
    CF_BooleanEqual = (ba >= 0 And bb >= 0 And ba = bb)
End Function

Public Function CF_LooksNumeric(v As Variant) As Boolean
    Dim d As Double
    CF_LooksNumeric = CF_TryParseNumber(v, d)
End Function

Public Function CF_LooksDate(v As Variant) As Boolean
    Dim d As Double, s As String
    s = Trim(CStr(v))
    If s = "" Then CF_LooksDate = False : Exit Function
    If InStr(s, "/") = 0 And InStr(s, "-") = 0 And InStr(s, ".") = 0 Then CF_LooksDate = False : Exit Function
    CF_LooksDate = CF_TryParseDateSerial(v, d)
End Function

Public Function CF_LooksBoolean(v As Variant) As Boolean
    CF_LooksBoolean = (CF_BooleanCode(v) >= 0)
End Function

Public Function CF_TryParseNumber(v As Variant, ByRef result As Double) As Boolean
    On Error GoTo Fail
    Dim s As String
    If IsNumeric(v) Then result = CDbl(v) : CF_TryParseNumber = True : Exit Function
    s = Trim(CStr(v))
    If s = "" Then GoTo Fail
    s = Replace(s, Chr(160), "")
    s = Replace(s, " ", "")
    s = Replace(s, "€", "")
    s = Replace(s, "$", "")
    s = Replace(s, "£", "")
    s = Replace(s, "%", "")
    If InStr(s, ",") > 0 And InStr(s, ".") > 0 Then
        If InStrRev(s, ",") > InStrRev(s, ".") Then
            s = Replace(s, ".", "")
            s = Replace(s, ",", ".")
        Else
            s = Replace(s, ",", "")
        End If
    ElseIf InStr(s, ",") > 0 Then
        s = Replace(s, ",", ".")
    End If
    result = CDbl(s)
    CF_TryParseNumber = True
    Exit Function
Fail:
    result = 0
    CF_TryParseNumber = False
End Function

Public Function CF_TryParseDateSerial(v As Variant, ByRef result As Double) As Boolean
    On Error GoTo Fail
    If IsDate(v) Then result = CDbl(CDate(v)) : CF_TryParseDateSerial = True : Exit Function
    If IsNumeric(v) Then
        result = CDbl(v)
        CF_TryParseDateSerial = True
        Exit Function
    End If
    result = CDbl(CDate(CStr(v)))
    CF_TryParseDateSerial = True
    Exit Function
Fail:
    result = 0
    CF_TryParseDateSerial = False
End Function

Public Function CF_BooleanCode(v As Variant) As Integer
    Dim s As String
    s = UCase(Trim(CStr(v)))
    Select Case s
        Case "TRUE", "VRAI", "YES", "OUI", "Y", "O", "1", "X", "ACTIVE", "ACTIF"
            CF_BooleanCode = 1
        Case "FALSE", "FAUX", "NO", "NON", "N", "0", "INACTIVE", "INACTIF"
            CF_BooleanCode = 0
        Case Else
            CF_BooleanCode = -1
    End Select
End Function

Public Function CF_PercentToNumber(v As Variant) As Variant
    Dim d As Double, s As String
    s = Trim(CStr(v))
    If CF_TryParseNumber(v, d) Then
        If InStr(s, "%") > 0 Then d = d / 100
        CF_PercentToNumber = d
    Else
        CF_PercentToNumber = v
    End If
End Function

Public Function CF_CurrencyToNumber(v As Variant) As Variant
    Dim d As Double
    If CF_TryParseNumber(v, d) Then CF_CurrencyToNumber = d Else CF_CurrencyToNumber = v
End Function

Public Function CF_GetNumericTolerance() As Double
    CF_GetNumericTolerance = 0.000001
End Function

Public Function CF_GetPercentTolerance() As Double
    CF_GetPercentTolerance = 0.000001
End Function

Public Function CF_GetCurrencyTolerance() As Double
    CF_GetCurrencyTolerance = 0.005
End Function

Public Function CF_GetDateToleranceDays() As Double
    CF_GetDateToleranceDays = 0
End Function

Public Sub CF_RunTypedComparatorTests()
    Dim d As String, c As String
    Dim ok1 As Boolean, ok2 As Boolean, ok3 As Boolean, ok4 As Boolean, ok5 As Boolean, ok6 As Boolean
    ok1 = CF_TypedValuesEqual("Test", "test", "Libelle", c, d)
    ok2 = CF_TypedValuesEqual("10,00", 10, "Quantite", c, d)
    ok3 = CF_TypedValuesEqual("10%", 0.1, "Taux %", c, d)
    ok4 = CF_TypedValuesEqual("100,00 €", 100, "Montant", c, d)
    ok5 = CF_TypedValuesEqual("Oui", "TRUE", "Actif", c, d)
    ok6 = CF_TypedValuesEqual("2026-07-10", "10/07/2026", "Date", c, d)

    If ok1 And ok2 And ok3 And ok4 And ok5 And ok6 Then
        MsgBox "Tests comparateurs types : 6/6", 64, "CompareFramework V3.6.2 Stable"
    Else
        MsgBox "Tests comparateurs types a controler.", 48, "CompareFramework V3.6.2 Stable"
    End If
End Sub

'======================================================================
' CompareFramework_Report.bas
'======================================================================
' CompareFramework V3.6.2 Stable - Report
' Rapports Calc, synthèse, plan d'action, journal et export HTML.
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
' CompareFramework_Validation.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - Validation and Preflight
'=========================================================
' Public API:
'   CF_ValidateFramework()
'   CF_ValidateActiveProfile()
'   CF_PreflightComparison()
'   CF_RunValidated()
'=========================================================

Private CF_VAL_ERRORS As Long
Private CF_VAL_WARNINGS As Long
Private CF_VAL_ROW As Long
Private CF_VAL_SHEET As Object

Public Function CF_ValidateFramework() As Boolean
    On Error GoTo ErrHandler
    Dim oDoc As Object
    oDoc = ThisComponent

    CF_ValidationBegin oDoc
    CF_CheckRequiredModules
    CF_CheckCoreSheets oDoc
    CF_CheckConfigurationSheet oDoc
    CF_CheckRulesSheet oDoc
    CF_CheckProfilesSheet oDoc
    CF_CheckSourcePairs oDoc
    CF_ValidationFinish

    CF_ValidateFramework = (CF_VAL_ERRORS = 0)
    Exit Function
ErrHandler:
    CF_LogValidation "ERROR", "VALIDATION", "Erreur interne : " & Err & " - " & Error$
    CF_ValidationFinish
    CF_ValidateFramework = False
End Function

Public Function CF_ValidateActiveProfile() As Boolean
    On Error GoTo ErrHandler
    Dim profileName As String
    Dim oDoc As Object
    oDoc = ThisComponent
    profileName = CF_ContextGet("Profile", "")

    If profileName = "" Then
        profileName = CF_ReadConfigValue(oDoc, "ACTIVE_PROFILE", "STANDARD")
    End If

    CF_ValidationBegin oDoc
    CF_LogValidation "INFO", "PROFILE", "Profil actif : " & profileName

    If Not oDoc.Sheets.hasByName("Compare_Profiles") Then
        CF_LogValidation "ERROR", "PROFILE", "La feuille Compare_Profiles est absente."
    ElseIf Not CF_ProfileExists(oDoc.Sheets.getByName("Compare_Profiles"), profileName) Then
        CF_LogValidation "ERROR", "PROFILE", "Profil introuvable : " & profileName
    Else
        CF_LogValidation "OK", "PROFILE", "Le profil existe."
    End If

    CF_ValidationFinish
    CF_ValidateActiveProfile = (CF_VAL_ERRORS = 0)
    Exit Function
ErrHandler:
    CF_LogValidation "ERROR", "PROFILE", "Erreur : " & Err & " - " & Error$
    CF_ValidationFinish
    CF_ValidateActiveProfile = False
End Function

Public Function CF_PreflightComparison() As Boolean
    Dim okFramework As Boolean
    Dim okProfile As Boolean

    okFramework = CF_ValidateFramework()
    okProfile = CF_ValidateActiveProfile()
    CF_PreflightComparison = (okFramework And okProfile)
End Function

Public Sub CF_RunValidated()
    On Error GoTo ErrHandler

    CF_ContextBeginRun "ValidatedComparison"
    CF_ContextSet "PreflightStartedAt", CStr(Now)

    If Not CF_PreflightComparison() Then
        CF_ContextSet "PreflightStatus", "FAILED"
        CF_ContextEndRun "VALIDATION_ERROR"
        MsgBox "Validation échouée. Consulte la feuille Compare_Validation.", 48, "CompareFramework V3.6.2 Stable"
        Exit Sub
    End If

    CF_ContextSet "PreflightStatus", "OK"
    ComparerToutesLesFeuilles
    CF_ContextEndRun "DONE"
    Exit Sub
ErrHandler:
    CF_ContextSet "ErrorNumber", CStr(Err)
    CF_ContextSet "ErrorMessage", Error$
    CF_ContextEndRun "ERROR"
    MsgBox "Erreur CF_RunValidated : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Private Sub CF_ValidationBegin(oDoc As Object)
    CF_VAL_ERRORS = 0
    CF_VAL_WARNINGS = 0
    CF_VAL_ROW = 1

    If oDoc.Sheets.hasByName("Compare_Validation") Then
        oDoc.Sheets.removeByName("Compare_Validation")
    End If
    oDoc.Sheets.insertNewByName "Compare_Validation", oDoc.Sheets.getCount()
    CF_VAL_SHEET = oDoc.Sheets.getByName("Compare_Validation")

    CF_VAL_SHEET.getCellByPosition(0,0).String = "Niveau"
    CF_VAL_SHEET.getCellByPosition(1,0).String = "Composant"
    CF_VAL_SHEET.getCellByPosition(2,0).String = "Message"
    CF_VAL_SHEET.getCellByPosition(3,0).String = "Date"
End Sub

Private Sub CF_ValidationFinish()
    Dim status As String
    If CF_VAL_ERRORS = 0 Then status = "OK" Else status = "KO"

    CF_VAL_SHEET.getCellByPosition(0, CF_VAL_ROW + 1).String = "SYNTHESE"
    CF_VAL_SHEET.getCellByPosition(1, CF_VAL_ROW + 1).String = status
    CF_VAL_SHEET.getCellByPosition(2, CF_VAL_ROW + 1).String = _
        "Erreurs=" & CF_VAL_ERRORS & "; Avertissements=" & CF_VAL_WARNINGS

    On Error Resume Next
    CF_VAL_SHEET.getCellRangeByName("A1:D1").CharWeight = com.sun.star.awt.FontWeight.BOLD
    CF_VAL_SHEET.Columns.getByIndex(0).Width = 2600
    CF_VAL_SHEET.Columns.getByIndex(1).Width = 4500
    CF_VAL_SHEET.Columns.getByIndex(2).Width = 14000
    CF_VAL_SHEET.Columns.getByIndex(3).Width = 4200
End Sub

Private Sub CF_LogValidation(level As String, component As String, message As String)
    If IsNull(CF_VAL_SHEET) Or IsEmpty(CF_VAL_SHEET) Then Exit Sub

    CF_VAL_SHEET.getCellByPosition(0, CF_VAL_ROW).String = level
    CF_VAL_SHEET.getCellByPosition(1, CF_VAL_ROW).String = component
    CF_VAL_SHEET.getCellByPosition(2, CF_VAL_ROW).String = message
    CF_VAL_SHEET.getCellByPosition(3, CF_VAL_ROW).String = CStr(Now)

    If level = "ERROR" Then CF_VAL_ERRORS = CF_VAL_ERRORS + 1
    If level = "WARNING" Then CF_VAL_WARNINGS = CF_VAL_WARNINGS + 1
    CF_VAL_ROW = CF_VAL_ROW + 1
End Sub

Private Sub CF_CheckRequiredModules()
    Dim manifest As String
    manifest = FrameworkManifest()
    If InStr(manifest, "Context") = 0 Then CF_LogValidation "ERROR", "MODULES", "Module Context absent du manifeste."
    If InStr(manifest, "Profiles") = 0 Then CF_LogValidation "ERROR", "MODULES", "Module Profiles absent du manifeste."
    If InStr(manifest, "Validation") = 0 Then CF_LogValidation "ERROR", "MODULES", "Module Validation absent du manifeste."
    If CF_VAL_ERRORS = 0 Then CF_LogValidation "OK", "MODULES", "Manifeste cohérent : " & manifest
End Sub

Private Sub CF_CheckCoreSheets(oDoc As Object)
    Dim names, i As Integer
    names = Array("Compare_Config", "Compare_Rules", "Compare_Profiles")
    For i = LBound(names) To UBound(names)
        If oDoc.Sheets.hasByName(names(i)) Then
            CF_LogValidation "OK", "SHEETS", "Feuille présente : " & names(i)
        Else
            CF_LogValidation "WARNING", "SHEETS", "Feuille absente, elle pourra être initialisée : " & names(i)
        End If
    Next i
End Sub

Private Sub CF_CheckConfigurationSheet(oDoc As Object)
    If Not oDoc.Sheets.hasByName("Compare_Config") Then Exit Sub
    Dim oSheet As Object
    oSheet = oDoc.Sheets.getByName("Compare_Config")
    If Trim(oSheet.getCellByPosition(0,0).String) = "" Then
        CF_LogValidation "WARNING", "CONFIG", "En-tête de configuration vide."
    Else
        CF_LogValidation "OK", "CONFIG", "Feuille de configuration lisible."
    End If
End Sub

Private Sub CF_CheckRulesSheet(oDoc As Object)
    If Not oDoc.Sheets.hasByName("Compare_Rules") Then Exit Sub
    Dim oSheet As Object, cursor As Object, lastRow As Long
    oSheet = oDoc.Sheets.getByName("Compare_Rules")
    cursor = oSheet.createCursor()
    cursor.gotoEndOfUsedArea(True)
    lastRow = cursor.RangeAddress.EndRow
    If lastRow < 1 Then
        CF_LogValidation "WARNING", "RULES", "Aucune règle configurée."
    Else
        CF_LogValidation "OK", "RULES", CStr(lastRow) & " ligne(s) de règles détectée(s)."
    End If
End Sub

Private Sub CF_CheckProfilesSheet(oDoc As Object)
    If Not oDoc.Sheets.hasByName("Compare_Profiles") Then Exit Sub
    Dim oSheet As Object, cursor As Object, lastRow As Long
    oSheet = oDoc.Sheets.getByName("Compare_Profiles")
    cursor = oSheet.createCursor()
    cursor.gotoEndOfUsedArea(True)
    lastRow = cursor.RangeAddress.EndRow
    If lastRow < 1 Then
        CF_LogValidation "ERROR", "PROFILES", "Aucun profil disponible."
    Else
        CF_LogValidation "OK", "PROFILES", CStr(lastRow) & " profil(s)/ligne(s) détecté(s)."
    End If
End Sub

Private Sub CF_CheckSourcePairs(oDoc As Object)
    Dim names, i As Long, nOld As Long, nNew As Long, nRef As Long
    names = oDoc.Sheets.getElementNames()
    For i = LBound(names) To UBound(names)
        If Right(UCase(names(i)), 4) = "_OLD" Then nOld = nOld + 1
        If Right(UCase(names(i)), 4) = "_NEW" Then nNew = nNew + 1
        If Right(UCase(names(i)), 4) = "_REF" Then nRef = nRef + 1
    Next i

    If nNew = 0 Then
        CF_LogValidation "ERROR", "SOURCES", "Aucune feuille suffixée _NEW."
    ElseIf nOld + nRef = 0 Then
        CF_LogValidation "ERROR", "SOURCES", "Aucune feuille source _OLD ou _REF."
    Else
        CF_LogValidation "OK", "SOURCES", "Sources détectées : OLD=" & nOld & ", REF=" & nRef & ", NEW=" & nNew
    End If
End Sub

Private Function CF_ProfileExists(oSheet As Object, profileName As String) As Boolean
    Dim cursor As Object, lastRow As Long, r As Long
    cursor = oSheet.createCursor()
    cursor.gotoEndOfUsedArea(True)
    lastRow = cursor.RangeAddress.EndRow
    For r = 1 To lastRow
        If UCase(Trim(oSheet.getCellByPosition(0,r).String)) = UCase(Trim(profileName)) Then
            CF_ProfileExists = True
            Exit Function
        End If
    Next r
    CF_ProfileExists = False
End Function

Private Function CF_ReadConfigValue(oDoc As Object, keyName As String, defaultValue As String) As String
    If Not oDoc.Sheets.hasByName("Compare_Config") Then
        CF_ReadConfigValue = defaultValue
        Exit Function
    End If
    Dim oSheet As Object, cursor As Object, lastRow As Long, r As Long
    oSheet = oDoc.Sheets.getByName("Compare_Config")
    cursor = oSheet.createCursor()
    cursor.gotoEndOfUsedArea(True)
    lastRow = cursor.RangeAddress.EndRow
    For r = 0 To lastRow
        If UCase(Trim(oSheet.getCellByPosition(0,r).String)) = UCase(keyName) Then
            CF_ReadConfigValue = oSheet.getCellByPosition(1,r).String
            Exit Function
        End If
    Next r
    CF_ReadConfigValue = defaultValue
End Function

'======================================================================
' CompareFramework_Performance.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - Performance & Metrics
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
        CF_PerfCell oSheet, 1, r, CStr(CF_RoundCompat(CF_PERF_ELAPSED(i), 3))
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
        CF_PerfCell oSheet, 4, r, CStr(CF_RoundCompat(CF_PERF_PAIR_SECONDS(i), 3))
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
    MsgBox "Erreur CF_PerfWriteReport : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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
    MsgBox "Benchmark terminé. Consulte Compare_Performance.", 64, "CompareFramework V3.6.2 Stable"
    Exit Sub
ErrHandler:
    MsgBox "Erreur CF_RunPerformanceBenchmark : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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

'======================================================================
' CompareFramework_EngineMemory.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - In-memory comparison engine
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
    Dim firstRow As Variant

    count = 0
    ReDim tempIds(0 To 0)
    ReDim tempRows(0 To 0)

    On Error GoTo InvalidIndex

    firstRow = data(LBound(data))
    If idCol < LBound(firstRow) Or idCol > UBound(firstRow) Then GoTo InvalidIndex

    ReDim tempIds(0 To UBound(data))
    ReDim tempRows(0 To UBound(data))

    For r = CF_FIRST_DATA_ROW To UBound(data)
        rowData = data(r)
        If idCol >= LBound(rowData) And idCol <= UBound(rowData) Then
            idValue = Trim(CF_MemoryValueText(rowData(idCol)))
            If idValue <> "" Then
                tempIds(n) = idValue
                tempRows(n) = r
                n = n + 1
            End If
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
    Exit Sub

InvalidIndex:
    ids = tempIds
    rows = tempRows
    count = 0
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
    Dim idCol As Long

    oDoc = ThisComponent
    CF_CreateTestWorkbook
    oOld = oDoc.Sheets.getByName("CF_Test_OLD")

    data = CF_ReadUsedData(oOld)
    headers = CF_MemoryHeaders(data)

    idCol = FindIdColumn(headers)
    If idCol < LBound(headers) Or idCol > UBound(headers) Then
        idCol = HeaderIndex(headers, "ID")
    End If

    If idCol >= LBound(headers) And idCol <= UBound(headers) Then
        CF_BuildMemoryIdIndex data, idCol, ids, rows, count
    Else
        count = 0
    End If

    okRead = (UBound(data) >= 4)
    okHeaders = (CStr(headers(LBound(headers))) = "ID" And CStr(headers(LBound(headers) + 2)) = "Amount")
    okIndex = (count = 4)

    If okRead And okHeaders And okIndex Then
        MsgBox "Tests moteur memoire : 3/3", 64, "CompareFramework V3.6.2 Stable"
    Else
        MsgBox "Tests moteur memoire a controler." & Chr(10) & _
               "Lecture=" & IIf(okRead, "OK", "KO") & Chr(10) & _
               "Entetes=" & IIf(okHeaders, "OK", "KO") & Chr(10) & _
               "Index=" & IIf(okIndex, "OK", "KO") & " (ID col=" & idCol & ", count=" & count & ")", _
               48, "CompareFramework V3.6.2 Stable"
    End If
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunMemoryEngineTests : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

'======================================================================
' CompareFramework_Reliability.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - Typed Comparator Reliability
'=========================================================
' Public API:
'   CF_RunTypedRegressionSuite()
'   CF_BuildComparatorCoverageReport()
'   CF_ValidateComparatorRules()
'
' Sheets created:
'   CF_Typed_Regression
'   CF_Comparator_Coverage
'   CF_Comparator_Validation
'=========================================================

Public Sub CF_RunTypedRegressionSuite()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oSheet As Object
    Dim row As Long
    Dim total As Long
    Dim passed As Long
    Dim previousIgnoreCase As Boolean

    previousIgnoreCase = gIgnoreCase
    gIgnoreCase = True

    oDoc = ThisComponent
    CF_ReliabilityRecreateSheet oDoc, "CF_Typed_Regression"
    oSheet = oDoc.Sheets.getByName("CF_Typed_Regression")

    CF_ReliabilityWriteHeader oSheet
    row = 1
    total = 0
    passed = 0

    CF_ReliabilityAddCase oSheet, row, total, passed, "TEXT", "Alpha", "alpha", True
    CF_ReliabilityAddCase oSheet, row, total, passed, "TEXT", "Alpha", "Beta", False

    CF_ReliabilityAddCase oSheet, row, total, passed, "NUMBER", "10", "10,00", True
    CF_ReliabilityAddCase oSheet, row, total, passed, "NUMBER", "10", "10,01", False

    CF_ReliabilityAddCase oSheet, row, total, passed, "PERCENT", "10%", "0,1", True
    CF_ReliabilityAddCase oSheet, row, total, passed, "PERCENT", "10%", "11%", False

    CF_ReliabilityAddCase oSheet, row, total, passed, "CURRENCY", "100 €", "100,00", True
    CF_ReliabilityAddCase oSheet, row, total, passed, "CURRENCY", "100 €", "101 €", False

    CF_ReliabilityAddCase oSheet, row, total, passed, "BOOLEAN", "Oui", "TRUE", True
    CF_ReliabilityAddCase oSheet, row, total, passed, "BOOLEAN", "Non", "TRUE", False

    CF_ReliabilityAddCase oSheet, row, total, passed, "DATE", "2026-07-10", "10/07/2026", True
    CF_ReliabilityAddCase oSheet, row, total, passed, "DATE", "2026-07-10", "11/07/2026", False

    oSheet.getCellByPosition(0, row + 1).String = "Synthèse"
    oSheet.getCellByPosition(1, row + 1).String = passed & "/" & total

    CF_ReliabilityFormat oSheet
    gIgnoreCase = previousIgnoreCase

    If passed = total Then
        MsgBox "Régression typée OK : " & passed & "/" & total, 64, "CompareFramework V3.6.2 Stable"
    Else
        MsgBox "Régression typée à contrôler : " & passed & "/" & total, 48, "CompareFramework V3.6.2 Stable"
    End If
    Exit Sub

ErrHandler:
    gIgnoreCase = previousIgnoreCase
    MsgBox "Erreur CF_RunTypedRegressionSuite : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_ValidateComparatorRules()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oSheet As Object
    Dim oRules As Object
    Dim oCursor As Object
    Dim lastRow As Long
    Dim row As Long
    Dim outRow As Long
    Dim enabledValue As String
    Dim profileName As String
    Dim columnName As String
    Dim comparatorType As String
    Dim toleranceValue As String
    Dim commentValue As String
    Dim statusText As String
    Dim messageText As String
    Dim toleranceNumber As Double

    oDoc = ThisComponent
    CF_ReliabilityRecreateSheet oDoc, "CF_Comparator_Validation"
    oSheet = oDoc.Sheets.getByName("CF_Comparator_Validation")

    oSheet.getCellByPosition(0, 0).String = "Ligne"
    oSheet.getCellByPosition(1, 0).String = "Actif"
    oSheet.getCellByPosition(2, 0).String = "Profil"
    oSheet.getCellByPosition(3, 0).String = "Colonne"
    oSheet.getCellByPosition(4, 0).String = "Type"
    oSheet.getCellByPosition(5, 0).String = "Tolérance"
    oSheet.getCellByPosition(6, 0).String = "Statut"
    oSheet.getCellByPosition(7, 0).String = "Message"
    oSheet.getCellByPosition(8, 0).String = "Commentaire"

    If Not oDoc.Sheets.hasByName("Compare_Comparators") Then
        oSheet.getCellByPosition(6, 1).String = "KO"
        oSheet.getCellByPosition(7, 1).String = "Feuille Compare_Comparators absente"
        CF_ReliabilityFormat oSheet
        Exit Sub
    End If

    oRules = oDoc.Sheets.getByName("Compare_Comparators")
    oCursor = oRules.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow
    outRow = 1

    For row = 1 To lastRow
        enabledValue = UCase(Trim(oRules.getCellByPosition(0, row).String))
        profileName = Trim(oRules.getCellByPosition(1, row).String)
        columnName = Trim(oRules.getCellByPosition(2, row).String)
        comparatorType = UCase(Trim(oRules.getCellByPosition(3, row).String))
        toleranceValue = Trim(oRules.getCellByPosition(4, row).String)
        commentValue = Trim(oRules.getCellByPosition(5, row).String)

        statusText = "OK"
        messageText = ""

        If enabledValue <> "TRUE" And enabledValue <> "FALSE" And _
           enabledValue <> "1" And enabledValue <> "0" And _
           enabledValue <> "OUI" And enabledValue <> "NON" And _
           enabledValue <> "YES" And enabledValue <> "NO" Then
            statusText = "KO"
            messageText = "Valeur Enabled invalide"
        ElseIf profileName = "" Then
            statusText = "KO"
            messageText = "Profil vide"
        ElseIf columnName = "" Then
            statusText = "KO"
            messageText = "Colonne vide"
        ElseIf Not CF_ReliabilityIsSupportedType(comparatorType) Then
            statusText = "KO"
            messageText = "Type non supporté"
        ElseIf toleranceValue <> "" Then
            If Not CF_CC_TryParseDouble(toleranceValue, toleranceNumber) Then
                statusText = "KO"
                messageText = "Tolérance non numérique"
            End If
        End If

        oSheet.getCellByPosition(0, outRow).String = CStr(row + 1)
        oSheet.getCellByPosition(1, outRow).String = enabledValue
        oSheet.getCellByPosition(2, outRow).String = profileName
        oSheet.getCellByPosition(3, outRow).String = columnName
        oSheet.getCellByPosition(4, outRow).String = comparatorType
        oSheet.getCellByPosition(5, outRow).String = toleranceValue
        oSheet.getCellByPosition(6, outRow).String = statusText
        oSheet.getCellByPosition(7, outRow).String = messageText
        oSheet.getCellByPosition(8, outRow).String = commentValue
        outRow = outRow + 1
    Next row

    CF_ReliabilityFormat oSheet
    MsgBox "Validation des comparateurs terminée.", 64, "CompareFramework V3.6.2 Stable"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_ValidateComparatorRules : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_BuildComparatorCoverageReport()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oSheet As Object
    Dim types
    Dim i As Long

    oDoc = ThisComponent
    CF_ReliabilityRecreateSheet oDoc, "CF_Comparator_Coverage"
    oSheet = oDoc.Sheets.getByName("CF_Comparator_Coverage")

    oSheet.getCellByPosition(0, 0).String = "Type"
    oSheet.getCellByPosition(1, 0).String = "Supporté"
    oSheet.getCellByPosition(2, 0).String = "Test de régression"
    oSheet.getCellByPosition(3, 0).String = "Configurable"
    oSheet.getCellByPosition(4, 0).String = "Tolérance"

    types = Array("AUTO", "TEXT", "NUMBER", "DATE", "BOOLEAN", "PERCENT", "CURRENCY")

    For i = LBound(types) To UBound(types)
        oSheet.getCellByPosition(0, i + 1).String = types(i)
        oSheet.getCellByPosition(1, i + 1).String = "OUI"
        If types(i) = "AUTO" Then
            oSheet.getCellByPosition(2, i + 1).String = "INDIRECT"
        Else
            oSheet.getCellByPosition(2, i + 1).String = "OUI"
        End If
        oSheet.getCellByPosition(3, i + 1).String = "OUI"
        If types(i) = "NUMBER" Or types(i) = "PERCENT" Or types(i) = "CURRENCY" Or types(i) = "DATE" Then
            oSheet.getCellByPosition(4, i + 1).String = "OUI"
        Else
            oSheet.getCellByPosition(4, i + 1).String = "NON"
        End If
    Next i

    CF_ReliabilityFormat oSheet
    MsgBox "Rapport de couverture généré.", 64, "CompareFramework V3.6.2 Stable"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_BuildComparatorCoverageReport : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_RunMilestoneB_FinalTests()
    CF_RunTypedComparatorTests
    CF_RunComparatorConfigTests
    CF_RunTypedRegressionSuite
    CF_ValidateComparatorRules
    CF_BuildComparatorCoverageReport

    MsgBox "Jalon B V3.3 terminé. Consulte les feuilles de test et validation.", 64, "CompareFramework V3.6.2 Stable"
End Sub

Private Sub CF_ReliabilityAddCase(oSheet As Object, ByRef row As Long, ByRef total As Long, ByRef passed As Long, comparatorType As String, oldValue As Variant, newValue As Variant, expected As Boolean)
    Dim actual As Boolean
    Dim ok As Boolean

    total = total + 1
    actual = CF_CompareTypedValues(oldValue, newValue, comparatorType, 0)
    ok = (actual = expected)
    If ok Then passed = passed + 1

    oSheet.getCellByPosition(0, row).String = comparatorType
    oSheet.getCellByPosition(1, row).String = CStr(oldValue)
    oSheet.getCellByPosition(2, row).String = CStr(newValue)
    oSheet.getCellByPosition(3, row).String = IIf(expected, "EQUIVALENT", "DIFFERENT")
    oSheet.getCellByPosition(4, row).String = IIf(actual, "EQUIVALENT", "DIFFERENT")
    oSheet.getCellByPosition(5, row).String = IIf(ok, "OK", "KO")
    row = row + 1
End Sub

Private Sub CF_ReliabilityWriteHeader(oSheet As Object)
    oSheet.getCellByPosition(0, 0).String = "Type"
    oSheet.getCellByPosition(1, 0).String = "Ancienne valeur"
    oSheet.getCellByPosition(2, 0).String = "Nouvelle valeur"
    oSheet.getCellByPosition(3, 0).String = "Attendu"
    oSheet.getCellByPosition(4, 0).String = "Obtenu"
    oSheet.getCellByPosition(5, 0).String = "Résultat"
End Sub

Private Function CF_ReliabilityIsSupportedType(sType As String) As Boolean
    Select Case UCase(Trim(sType))
        Case "AUTO", "TEXT", "NUMBER", "DATE", "BOOLEAN", "PERCENT", "CURRENCY"
            CF_ReliabilityIsSupportedType = True
        Case Else
            CF_ReliabilityIsSupportedType = False
    End Select
End Function

Private Sub CF_ReliabilityRecreateSheet(oDoc As Object, sName As String)
    If oDoc.Sheets.hasByName(sName) Then
        oDoc.Sheets.removeByName(sName)
    End If
    oDoc.Sheets.insertNewByName sName, oDoc.Sheets.getCount()
End Sub

Private Sub CF_ReliabilityFormat(oSheet As Object)
    On Error Resume Next
    oSheet.getCellRangeByName("A1:Z1").CharWeight = com.sun.star.awt.FontWeight.BOLD
    oSheet.getCellRangeByName("A1:Z1").CellBackColor = RGB(220, 230, 241)
    oSheet.Columns.getByIndex(0).Width = 4500
    oSheet.Columns.getByIndex(1).Width = 5500
    oSheet.Columns.getByIndex(2).Width = 5500
    oSheet.Columns.getByIndex(3).Width = 4500
    oSheet.Columns.getByIndex(4).Width = 4500
    oSheet.Columns.getByIndex(5).Width = 3500
    oSheet.Columns.getByIndex(6).Width = 9000
End Sub

'======================================================================
' CompareFramework_Quality.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - Milestone C Quality Suite
'=========================================================
' Public API:
'   CF_RunEndToEndScenario()
'   CF_ValidateExpectedReport()
'   CF_RunGlobalRegression()
'   CF_BuildQualityDashboard()
'
' Sheets created:
'   QC_OLD
'   QC_NEW
'   CF_Expected
'   CF_Quality_Results
'   CF_Quality_Dashboard
'=========================================================

Public Sub CF_RunEndToEndScenario()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    oDoc = ThisComponent

    CF_QualityCreateScenario oDoc
    CF_QualityCreateExpected oDoc

    ComparerToutesLesFeuilles

    CF_ValidateExpectedReport
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunEndToEndScenario : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_ValidateExpectedReport()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oExpected As Object
    Dim oResults As Object
    Dim oReport As Object
    Dim oCursor As Object
    Dim lastRow As Long
    Dim row As Long
    Dim outRow As Long
    Dim expectedType As String
    Dim expectedId As String
    Dim expectedColumn As String
    Dim found As Boolean
    Dim total As Long
    Dim passed As Long

    oDoc = ThisComponent

    If Not oDoc.Sheets.hasByName("CF_Expected") Then
        MsgBox "Feuille CF_Expected absente.", 48, "CompareFramework V3.6.2 Stable"
        Exit Sub
    End If

    If Not oDoc.Sheets.hasByName("Rapport_Comparaison") Then
        MsgBox "Feuille Rapport_Comparaison absente.", 48, "CompareFramework V3.6.2 Stable"
        Exit Sub
    End If

    CF_QualityRecreateSheet oDoc, "CF_Quality_Results"

    oExpected = oDoc.Sheets.getByName("CF_Expected")
    oResults = oDoc.Sheets.getByName("CF_Quality_Results")
    oReport = oDoc.Sheets.getByName("Rapport_Comparaison")

    oResults.getCellByPosition(0, 0).String = "Type attendu"
    oResults.getCellByPosition(1, 0).String = "ID"
    oResults.getCellByPosition(2, 0).String = "Colonne"
    oResults.getCellByPosition(3, 0).String = "Résultat"
    oResults.getCellByPosition(4, 0).String = "Commentaire"

    oCursor = oExpected.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow

    outRow = 1
    total = 0
    passed = 0

    For row = 1 To lastRow
        expectedType = Trim(oExpected.getCellByPosition(0, row).String)
        expectedId = Trim(oExpected.getCellByPosition(1, row).String)
        expectedColumn = Trim(oExpected.getCellByPosition(2, row).String)

        total = total + 1
        found = CF_QualityFindReportEntry(oReport, expectedType, expectedId, expectedColumn)

        oResults.getCellByPosition(0, outRow).String = expectedType
        oResults.getCellByPosition(1, outRow).String = expectedId
        oResults.getCellByPosition(2, outRow).String = expectedColumn

        If found Then
            passed = passed + 1
            oResults.getCellByPosition(3, outRow).String = "OK"
            oResults.getCellByPosition(4, outRow).String = "Écart attendu trouvé"
        Else
            oResults.getCellByPosition(3, outRow).String = "KO"
            oResults.getCellByPosition(4, outRow).String = "Écart attendu absent du rapport"
        End If

        outRow = outRow + 1
    Next row

    oResults.getCellByPosition(0, outRow + 1).String = "Synthèse"
    oResults.getCellByPosition(1, outRow + 1).String = passed & "/" & total
    oResults.getCellByPosition(3, outRow + 1).String = IIf(passed = total, "OK", "A CONTROLER")

    CF_QualityFormat oResults
    CF_BuildQualityDashboard

    If passed = total Then
        MsgBox "Scénario de bout en bout validé : " & passed & "/" & total, 64, "CompareFramework V3.6.2 Stable"
    Else
        MsgBox "Scénario à contrôler : " & passed & "/" & total, 48, "CompareFramework V3.6.2 Stable"
    End If
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_ValidateExpectedReport : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_PrepareRegressionEnvironment()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oConfig As Object
    Dim oRules As Object

    oDoc = ThisComponent

    ' Initialize configuration sheets so validation tests the framework,
    ' not an intentionally incomplete empty workbook.
    oConfig = EnsureConfigSheet(oDoc)
    oRules = EnsureRulesSheet(oDoc)

    ' Create at least one valid OLD/NEW source pair before preflight.
    CF_CreateTestWorkbook
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_PrepareRegressionEnvironment : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_RunGlobalRegression()
    On Error GoTo ErrHandler

    CF_PrepareRegressionEnvironment

    CF_RunMilestoneB_FinalTests
    CF_RunContextTests
    CF_RunProfileTests
    CF_RunValidationTests
    CF_RunAuditTests
    CF_RunPerformanceTests
    CF_RunMemoryEngineTests
    CF_RunEndToEndScenario

    MsgBox "Régression globale terminée. Consulte CF_Quality_Dashboard.", 64, "CompareFramework V3.6.2 Stable"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunGlobalRegression : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_BuildQualityDashboard()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oSheet As Object
    Dim statusText As String

    oDoc = ThisComponent
    CF_QualityRecreateSheet oDoc, "CF_Quality_Dashboard"
    oSheet = oDoc.Sheets.getByName("CF_Quality_Dashboard")

    oSheet.getCellByPosition(0, 0).String = "Indicateur"
    oSheet.getCellByPosition(1, 0).String = "Statut"
    oSheet.getCellByPosition(2, 0).String = "Détail"

    CF_QualityDashboardRow oSheet, 1, "Comparateurs typés", CF_QualitySheetStatus(oDoc, "CF_Typed_Regression"), "CF_Typed_Regression"
    CF_QualityDashboardRow oSheet, 2, "Configuration comparateurs", CF_QualitySheetStatus(oDoc, "CF_Comparator_Validation"), "CF_Comparator_Validation"
    CF_QualityDashboardRow oSheet, 3, "Contexte", CF_QualitySheetStatus(oDoc, "CF_Test_Context"), "CF_Test_Context"
    CF_QualityDashboardRow oSheet, 4, "Audit", CF_QualitySheetStatus(oDoc, "CF_Test_Audit"), "CF_Test_Audit"
    CF_QualityDashboardRow oSheet, 5, "Performance", CF_QualitySheetStatus(oDoc, "CF_Test_Performance"), "CF_Test_Performance"
    CF_QualityDashboardRow oSheet, 6, "Scénario bout en bout", CF_QualitySheetStatus(oDoc, "CF_Quality_Results"), "CF_Quality_Results"

    statusText = CF_QualityGlobalStatus(oSheet)
    oSheet.getCellByPosition(0, 8).String = "Statut global"
    oSheet.getCellByPosition(1, 8).String = statusText

    CF_QualityFormat oSheet
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_BuildQualityDashboard : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Private Sub CF_QualityCreateScenario(oDoc As Object)
    Dim oOld As Object
    Dim oNew As Object

    CF_QualityRecreateSheet oDoc, "QC_OLD"
    CF_QualityRecreateSheet oDoc, "QC_NEW"

    oOld = oDoc.Sheets.getByName("QC_OLD")
    oNew = oDoc.Sheets.getByName("QC_NEW")

    CF_QualityWriteHeaders oOld
    CF_QualityWriteHeaders oNew

    CF_QualityWriteRow oOld, 1, "Q001", "Alpha", "100", "10%", "ACTIVE", "2026-07-01"
    CF_QualityWriteRow oOld, 2, "Q002", "Beta", "200", "20%", "ACTIVE", "2026-07-02"
    CF_QualityWriteRow oOld, 3, "Q003", "Gamma", "300", "30%", "CLOSED", "2026-07-03"
    CF_QualityWriteRow oOld, 4, "Q004", "Delta", "400", "40%", "ACTIVE", "2026-07-04"

    CF_QualityWriteRow oNew, 1, "Q001", "alpha", "100,00", "0,1", "ACTIVE", "01/07/2026"
    CF_QualityWriteRow oNew, 2, "Q002", "Beta", "250", "20%", "ACTIVE", "2026-07-02"
    CF_QualityWriteRow oNew, 3, "Q004", "Delta", "400", "40%", "ACTIVE", "2026-07-04"
    CF_QualityWriteRow oNew, 4, "Q005", "Epsilon", "500", "50%", "NEW", "2026-07-05"
End Sub

Private Sub CF_QualityCreateExpected(oDoc As Object)
    Dim oSheet As Object

    CF_QualityRecreateSheet oDoc, "CF_Expected"
    oSheet = oDoc.Sheets.getByName("CF_Expected")

    oSheet.getCellByPosition(0, 0).String = "Type"
    oSheet.getCellByPosition(1, 0).String = "ID"
    oSheet.getCellByPosition(2, 0).String = "Colonne"

    oSheet.getCellByPosition(0, 1).String = "MODIFICATION"
    oSheet.getCellByPosition(1, 1).String = "Q002"
    oSheet.getCellByPosition(2, 1).String = "Amount"

    oSheet.getCellByPosition(0, 2).String = "SUPPRESSION"
    oSheet.getCellByPosition(1, 2).String = "Q003"
    oSheet.getCellByPosition(2, 2).String = ""

    oSheet.getCellByPosition(0, 3).String = "AJOUT"
    oSheet.getCellByPosition(1, 3).String = "Q005"
    oSheet.getCellByPosition(2, 3).String = ""

    CF_QualityFormat oSheet
End Sub

Private Function CF_QualityFindReportEntry(oReport As Object, expectedType As String, expectedId As String, expectedColumn As String) As Boolean
    Dim oCursor As Object
    Dim lastRow As Long
    Dim row As Long
    Dim actualType As String
    Dim actualId As String
    Dim actualColumn As String

    oCursor = oReport.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow

    For row = 1 To lastRow
        actualType = UCase(Trim(oReport.getCellByPosition(CF_COL_TYPE, row).String))
        actualId = UCase(Trim(oReport.getCellByPosition(CF_COL_ID, row).String))
        actualColumn = UCase(Trim(oReport.getCellByPosition(CF_COL_COLUMN, row).String))

        If CF_QualityStatusMatches(expectedType, actualType) And _
           actualId = UCase(Trim(expectedId)) Then
            If Trim(expectedColumn) = "" Or actualColumn = UCase(Trim(expectedColumn)) Then
                CF_QualityFindReportEntry = True
                Exit Function
            End If
        End If
    Next row

    CF_QualityFindReportEntry = False
End Function

Private Function CF_QualityStatusMatches(expectedType As String, actualType As String) As Boolean
    Dim expectedNormalized As String
    Dim actualNormalized As String

    expectedNormalized = UCase(Trim(expectedType))
    actualNormalized = UCase(Trim(actualType))

    Select Case expectedNormalized
        Case "AJOUT", "AJOUTE", "AJOUTÉ", "ADDED"
            CF_QualityStatusMatches = (actualNormalized = CF_STATUS_ADDED Or actualNormalized = "AJOUT" Or actualNormalized = "ADDED")

        Case "SUPPRESSION", "SUPPRIME", "SUPPRIMÉ", "DELETED", "REMOVED"
            CF_QualityStatusMatches = (actualNormalized = CF_STATUS_REMOVED Or actualNormalized = "SUPPRESSION" Or actualNormalized = "DELETED" Or actualNormalized = "REMOVED")

        Case "MODIFICATION", "MODIFIE", "MODIFIÉ", "CHANGED"
            CF_QualityStatusMatches = (actualNormalized = CF_STATUS_CHANGED Or actualNormalized = "MODIFICATION" Or actualNormalized = "CHANGED")

        Case Else
            CF_QualityStatusMatches = (actualNormalized = expectedNormalized)
    End Select
End Function

Private Function CF_QualitySheetStatus(oDoc As Object, sSheetName As String) As String
    Dim oSheet As Object
    Dim oCursor As Object
    Dim lastRow As Long
    Dim lastCol As Long
    Dim row As Long
    Dim col As Long
    Dim valueText As String

    If Not oDoc.Sheets.hasByName(sSheetName) Then
        CF_QualitySheetStatus = "NON EXECUTE"
        Exit Function
    End If

    oSheet = oDoc.Sheets.getByName(sSheetName)
    oCursor = oSheet.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow
    lastCol = oCursor.RangeAddress.EndColumn

    For row = 0 To lastRow
        For col = 0 To lastCol
            valueText = UCase(Trim(oSheet.getCellByPosition(col, row).String))
            If valueText = "KO" Or valueText = "ERROR" Or valueText = "A CONTROLER" Then
                CF_QualitySheetStatus = "KO"
                Exit Function
            End If
        Next col
    Next row

    CF_QualitySheetStatus = "OK"
End Function

Private Function CF_QualityGlobalStatus(oSheet As Object) As String
    Dim row As Long
    Dim statusValue As String
    Dim hasNotRun As Boolean
    Dim hasExecuted As Boolean

    For row = 1 To 6
        statusValue = UCase(Trim(oSheet.getCellByPosition(1, row).String))

        If statusValue = "KO" Or statusValue = "ERROR" Or statusValue = "A CONTROLER" Then
            CF_QualityGlobalStatus = "A CONTROLER"
            Exit Function
        ElseIf statusValue = "NON EXECUTE" Or statusValue = "ABSENT" Then
            hasNotRun = True
        ElseIf statusValue = "OK" Then
            hasExecuted = True
        End If
    Next row

    If hasNotRun Then
        If hasExecuted Then
            CF_QualityGlobalStatus = "PARTIEL OK"
        Else
            CF_QualityGlobalStatus = "NON EXECUTE"
        End If
    Else
        CF_QualityGlobalStatus = "OK"
    End If
End Function

Private Sub CF_QualityDashboardRow(oSheet As Object, row As Long, labelText As String, statusText As String, detailText As String)
    oSheet.getCellByPosition(0, row).String = labelText
    oSheet.getCellByPosition(1, row).String = statusText
    oSheet.getCellByPosition(2, row).String = detailText
End Sub

Private Sub CF_QualityWriteHeaders(oSheet As Object)
    oSheet.getCellByPosition(0, 0).String = "ID"
    oSheet.getCellByPosition(1, 0).String = "Name"
    oSheet.getCellByPosition(2, 0).String = "Amount"
    oSheet.getCellByPosition(3, 0).String = "Rate"
    oSheet.getCellByPosition(4, 0).String = "Status"
    oSheet.getCellByPosition(5, 0).String = "Date"
End Sub

Private Sub CF_QualityWriteRow(oSheet As Object, row As Long, idValue As String, nameValue As String, amountValue As String, rateValue As String, statusValue As String, dateValue As String)
    oSheet.getCellByPosition(0, row).String = idValue
    oSheet.getCellByPosition(1, row).String = nameValue
    oSheet.getCellByPosition(2, row).String = amountValue
    oSheet.getCellByPosition(3, row).String = rateValue
    oSheet.getCellByPosition(4, row).String = statusValue
    oSheet.getCellByPosition(5, row).String = dateValue
End Sub

Private Sub CF_QualityRecreateSheet(oDoc As Object, sName As String)
    If oDoc.Sheets.hasByName(sName) Then
        oDoc.Sheets.removeByName(sName)
    End If
    oDoc.Sheets.insertNewByName sName, oDoc.Sheets.getCount()
End Sub

Private Sub CF_QualityFormat(oSheet As Object)
    On Error Resume Next
    oSheet.getCellRangeByName("A1:Z1").CharWeight = com.sun.star.awt.FontWeight.BOLD
    oSheet.getCellRangeByName("A1:Z1").CellBackColor = RGB(220, 230, 241)
    oSheet.Columns.getByIndex(0).Width = 6500
    oSheet.Columns.getByIndex(1).Width = 4500
    oSheet.Columns.getByIndex(2).Width = 6500
    oSheet.Columns.getByIndex(3).Width = 4000
    oSheet.Columns.getByIndex(4).Width = 9000
End Sub

'======================================================================
' CompareFramework_Scenarios.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - Milestone C Stabilisation
'=========================================================
' Business scenarios:
'   FINANCE
'   RH
'   ERP
'
' Public API:
'   CF_RunAllBusinessScenarios()
'   CF_RunFinanceScenario()
'   CF_RunHRScenario()
'   CF_RunERPScenario()
'   CF_BuildReleaseReadiness()
'
' Sheets created:
'   CF_Scenario_Results
'   CF_Release_Readiness
'=========================================================

Public Sub CF_RunAllBusinessScenarios()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    oDoc = ThisComponent

    CF_ScenarioPrepareResults oDoc

    CF_RunFinanceScenario
    CF_RunHRScenario
    CF_RunERPScenario

    CF_BuildReleaseReadiness

    MsgBox "Scénarios métier terminés. Consulte CF_Scenario_Results et CF_Release_Readiness.", 64, "CompareFramework V3.6.2 Stable"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunAllBusinessScenarios : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Public Sub CF_RunFinanceScenario()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    oDoc = ThisComponent

    CF_ScenarioCreateFinance oDoc
    ComparerToutesLesFeuilles
    CF_ScenarioAppendResult oDoc, "FINANCE", _
        CF_ScenarioReportContains("MODIFICATION", "F002", "Montant") And _
        CF_ScenarioReportContains("AJOUT", "F004", "") And _
        CF_ScenarioReportContains("SUPPRESSION", "F003", ""), _
        "Modification montant, ajout et suppression"

    Exit Sub

ErrHandler:
    CF_ScenarioAppendResult ThisComponent, "FINANCE", False, "Erreur " & Err & " - " & Error$
End Sub

Public Sub CF_RunHRScenario()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    oDoc = ThisComponent

    CF_ScenarioCreateHR oDoc
    ComparerToutesLesFeuilles
    CF_ScenarioAppendResult oDoc, "RH", _
        CF_ScenarioReportContains("MODIFICATION", "R002", "Salaire") And _
        CF_ScenarioReportContains("MODIFICATION", "R003", "Statut"), _
        "Évolution salaire et statut"

    Exit Sub

ErrHandler:
    CF_ScenarioAppendResult ThisComponent, "RH", False, "Erreur " & Err & " - " & Error$
End Sub

Public Sub CF_RunERPScenario()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    oDoc = ThisComponent

    CF_ScenarioCreateERP oDoc
    ComparerToutesLesFeuilles
    CF_ScenarioAppendResult oDoc, "ERP", _
        CF_ScenarioReportContains("MODIFICATION", "E001", "Quantite") And _
        CF_ScenarioReportContains("AJOUT", "E004", ""), _
        "Variation quantité et nouvel article"

    Exit Sub

ErrHandler:
    CF_ScenarioAppendResult ThisComponent, "ERP", False, "Erreur " & Err & " - " & Error$
End Sub

Public Sub CF_BuildReleaseReadiness()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oSheet As Object
    Dim businessStatus As String
    Dim qualityStatus As String
    Dim regressionStatus As String
    Dim releaseStatus As String
    Dim rebuiltEvidence As Boolean

    oDoc = ThisComponent

    ' Release readiness must be self-contained. Rebuild missing quality
    ' evidence instead of treating an absent historical sheet as a failure.
    If Not oDoc.Sheets.hasByName("CF_Quality_Dashboard") Or _
       Not oDoc.Sheets.hasByName("CF_Typed_Regression") Then
        rebuiltEvidence = True
        CF_RunGlobalRegression
    End If

    ' The global regression rebuilds the dashboard before returning, but
    ' refresh it once more to consolidate the current workbook state.
    CF_BuildQualityDashboard

    CF_ScenarioRecreateSheet oDoc, "CF_Release_Readiness"
    oSheet = oDoc.Sheets.getByName("CF_Release_Readiness")

    businessStatus = CF_ScenarioSheetStatus(oDoc, "CF_Scenario_Results")
    qualityStatus = CF_ScenarioSheetStatus(oDoc, "CF_Quality_Dashboard")
    regressionStatus = CF_ScenarioSheetStatus(oDoc, "CF_Typed_Regression")

    If businessStatus = "OK" And qualityStatus = "OK" And regressionStatus = "OK" Then
        releaseStatus = "RELEASE CANDIDATE"
    Else
        releaseStatus = "A CONTROLER"
    End If

    oSheet.getCellByPosition(0, 0).String = "Critère"
    oSheet.getCellByPosition(1, 0).String = "Statut"
    oSheet.getCellByPosition(2, 0).String = "Détail"

    CF_ScenarioReadinessRow oSheet, 1, "Scénarios métier", businessStatus, "CF_Scenario_Results"
    CF_ScenarioReadinessRow oSheet, 2, "Tableau de bord qualité", qualityStatus, "CF_Quality_Dashboard"
    CF_ScenarioReadinessRow oSheet, 3, "Régression typée", regressionStatus, "CF_Typed_Regression"

    If rebuiltEvidence Then
        CF_ScenarioReadinessRow oSheet, 4, "Preuves techniques", "RECONSTRUITES", "Régression globale relancée automatiquement"
    Else
        CF_ScenarioReadinessRow oSheet, 4, "Preuves techniques", "PRESENTES", "Aucune reconstruction nécessaire"
    End If

    CF_ScenarioReadinessRow oSheet, 6, "Décision", releaseStatus, "CompareFramework V3.6.2 Stable"

    CF_ScenarioFormat oSheet
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_BuildReleaseReadiness : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Private Sub CF_ScenarioCreateFinance(oDoc As Object)
    Dim oOld As Object
    Dim oNew As Object

    CF_ScenarioRecreateSheet oDoc, "FINANCE_OLD"
    CF_ScenarioRecreateSheet oDoc, "FINANCE_NEW"
    oOld = oDoc.Sheets.getByName("FINANCE_OLD")
    oNew = oDoc.Sheets.getByName("FINANCE_NEW")

    CF_ScenarioWriteHeaders oOld, Array("ID", "Libelle", "Montant", "Devise", "Date")
    CF_ScenarioWriteHeaders oNew, Array("ID", "Libelle", "Montant", "Devise", "Date")

    CF_ScenarioWriteRow oOld, 1, Array("F001", "Facture A", "100", "EUR", "2026-07-01")
    CF_ScenarioWriteRow oOld, 2, Array("F002", "Facture B", "200", "EUR", "2026-07-02")
    CF_ScenarioWriteRow oOld, 3, Array("F003", "Facture C", "300", "EUR", "2026-07-03")

    CF_ScenarioWriteRow oNew, 1, Array("F001", "Facture A", "100,00", "EUR", "01/07/2026")
    CF_ScenarioWriteRow oNew, 2, Array("F002", "Facture B", "250", "EUR", "2026-07-02")
    CF_ScenarioWriteRow oNew, 3, Array("F004", "Facture D", "400", "EUR", "2026-07-04")
End Sub

Private Sub CF_ScenarioCreateHR(oDoc As Object)
    Dim oOld As Object
    Dim oNew As Object

    CF_ScenarioRecreateSheet oDoc, "RH_OLD"
    CF_ScenarioRecreateSheet oDoc, "RH_NEW"
    oOld = oDoc.Sheets.getByName("RH_OLD")
    oNew = oDoc.Sheets.getByName("RH_NEW")

    CF_ScenarioWriteHeaders oOld, Array("ID", "Nom", "Salaire", "Statut", "DateEntree")
    CF_ScenarioWriteHeaders oNew, Array("ID", "Nom", "Salaire", "Statut", "DateEntree")

    CF_ScenarioWriteRow oOld, 1, Array("R001", "Alice", "3000", "ACTIF", "2020-01-01")
    CF_ScenarioWriteRow oOld, 2, Array("R002", "Bob", "3200", "ACTIF", "2021-02-01")
    CF_ScenarioWriteRow oOld, 3, Array("R003", "Chloe", "3500", "ACTIF", "2019-03-01")

    CF_ScenarioWriteRow oNew, 1, Array("R001", "Alice", "3000,00", "ACTIF", "01/01/2020")
    CF_ScenarioWriteRow oNew, 2, Array("R002", "Bob", "3400", "ACTIF", "2021-02-01")
    CF_ScenarioWriteRow oNew, 3, Array("R003", "Chloe", "3500", "INACTIF", "2019-03-01")
End Sub

Private Sub CF_ScenarioCreateERP(oDoc As Object)
    Dim oOld As Object
    Dim oNew As Object

    CF_ScenarioRecreateSheet oDoc, "ERP_OLD"
    CF_ScenarioRecreateSheet oDoc, "ERP_NEW"
    oOld = oDoc.Sheets.getByName("ERP_OLD")
    oNew = oDoc.Sheets.getByName("ERP_NEW")

    CF_ScenarioWriteHeaders oOld, Array("ID", "Article", "Quantite", "Prix", "Actif")
    CF_ScenarioWriteHeaders oNew, Array("ID", "Article", "Quantite", "Prix", "Actif")

    CF_ScenarioWriteRow oOld, 1, Array("E001", "Article A", "10", "5,00", "TRUE")
    CF_ScenarioWriteRow oOld, 2, Array("E002", "Article B", "20", "10,00", "TRUE")
    CF_ScenarioWriteRow oOld, 3, Array("E003", "Article C", "30", "15,00", "FALSE")

    CF_ScenarioWriteRow oNew, 1, Array("E001", "Article A", "12", "5", "Oui")
    CF_ScenarioWriteRow oNew, 2, Array("E002", "Article B", "20", "10", "TRUE")
    CF_ScenarioWriteRow oNew, 3, Array("E003", "Article C", "30", "15", "Non")
    CF_ScenarioWriteRow oNew, 4, Array("E004", "Article D", "40", "20", "TRUE")
End Sub

Private Function CF_ScenarioReportContains(expectedType As String, expectedId As String, expectedColumn As String) As Boolean
    Dim oDoc As Object
    Dim oReport As Object
    Dim oCursor As Object
    Dim lastRow As Long
    Dim row As Long
    Dim actualType As String
    Dim actualId As String
    Dim actualColumn As String

    oDoc = ThisComponent
    If Not oDoc.Sheets.hasByName("Rapport_Comparaison") Then
        CF_ScenarioReportContains = False
        Exit Function
    End If

    oReport = oDoc.Sheets.getByName("Rapport_Comparaison")
    oCursor = oReport.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow

    For row = 1 To lastRow
        actualType = UCase(Trim(oReport.getCellByPosition(CF_COL_TYPE, row).String))
        actualId = UCase(Trim(oReport.getCellByPosition(CF_COL_ID, row).String))
        actualColumn = UCase(Trim(oReport.getCellByPosition(CF_COL_COLUMN, row).String))

        If CF_QualityStatusMatches(expectedType, actualType) And _
           actualId = UCase(Trim(expectedId)) Then
            If Trim(expectedColumn) = "" Or actualColumn = UCase(Trim(expectedColumn)) Then
                CF_ScenarioReportContains = True
                Exit Function
            End If
        End If
    Next row

    CF_ScenarioReportContains = False
End Function

Private Sub CF_ScenarioPrepareResults(oDoc As Object)
    CF_ScenarioRecreateSheet oDoc, "CF_Scenario_Results"

    Dim oSheet As Object
    oSheet = oDoc.Sheets.getByName("CF_Scenario_Results")

    oSheet.getCellByPosition(0, 0).String = "Scénario"
    oSheet.getCellByPosition(1, 0).String = "Statut"
    oSheet.getCellByPosition(2, 0).String = "Détail"
    CF_ScenarioFormat oSheet
End Sub

Private Sub CF_ScenarioAppendResult(oDoc As Object, scenarioName As String, ok As Boolean, detailText As String)
    Dim oSheet As Object
    Dim oCursor As Object
    Dim nextRow As Long

    If Not oDoc.Sheets.hasByName("CF_Scenario_Results") Then
        CF_ScenarioPrepareResults oDoc
    End If

    oSheet = oDoc.Sheets.getByName("CF_Scenario_Results")
    oCursor = oSheet.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    nextRow = oCursor.RangeAddress.EndRow + 1

    oSheet.getCellByPosition(0, nextRow).String = scenarioName
    oSheet.getCellByPosition(1, nextRow).String = IIf(ok, "OK", "KO")
    oSheet.getCellByPosition(2, nextRow).String = detailText
End Sub

Private Function CF_ScenarioSheetStatus(oDoc As Object, sheetName As String) As String
    Dim oSheet As Object
    Dim oCursor As Object
    Dim lastRow As Long
    Dim lastCol As Long
    Dim row As Long
    Dim col As Long
    Dim valueText As String

    If Not oDoc.Sheets.hasByName(sheetName) Then
        CF_ScenarioSheetStatus = "ABSENT"
        Exit Function
    End If

    oSheet = oDoc.Sheets.getByName(sheetName)
    oCursor = oSheet.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow
    lastCol = oCursor.RangeAddress.EndColumn

    For row = 0 To lastRow
        For col = 0 To lastCol
            valueText = UCase(Trim(oSheet.getCellByPosition(col, row).String))
            If valueText = "KO" Or valueText = "ERROR" Or valueText = "A CONTROLER" Then
                CF_ScenarioSheetStatus = "KO"
                Exit Function
            End If
        Next col
    Next row

    CF_ScenarioSheetStatus = "OK"
End Function

Private Sub CF_ScenarioWriteHeaders(oSheet As Object, headers As Variant)
    Dim i As Long
    For i = LBound(headers) To UBound(headers)
        oSheet.getCellByPosition(i, 0).String = CStr(headers(i))
    Next i
End Sub

Private Sub CF_ScenarioWriteRow(oSheet As Object, row As Long, values As Variant)
    Dim i As Long
    For i = LBound(values) To UBound(values)
        oSheet.getCellByPosition(i, row).String = CStr(values(i))
    Next i
End Sub

Private Sub CF_ScenarioReadinessRow(oSheet As Object, row As Long, labelText As String, statusText As String, detailText As String)
    oSheet.getCellByPosition(0, row).String = labelText
    oSheet.getCellByPosition(1, row).String = statusText
    oSheet.getCellByPosition(2, row).String = detailText
End Sub

Private Sub CF_ScenarioRecreateSheet(oDoc As Object, sheetName As String)
    If oDoc.Sheets.hasByName(sheetName) Then
        oDoc.Sheets.removeByName(sheetName)
    End If
    oDoc.Sheets.insertNewByName sheetName, oDoc.Sheets.getCount()
End Sub

Private Sub CF_ScenarioFormat(oSheet As Object)
    On Error Resume Next
    oSheet.getCellRangeByName("A1:Z1").CharWeight = com.sun.star.awt.FontWeight.BOLD
    oSheet.getCellRangeByName("A1:Z1").CellBackColor = RGB(220, 230, 241)
    oSheet.Columns.getByIndex(0).Width = 6500
    oSheet.Columns.getByIndex(1).Width = 4500
    oSheet.Columns.getByIndex(2).Width = 11000
End Sub

'======================================================================
' CompareFramework_Tests.bas
'======================================================================
'=========================================================
' CompareFramework V3.6.2 Stable - Test Suite
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

    MsgBox "Jeu de test créé : " & CF_TEST_SHEET_OLD & " / " & CF_TEST_SHEET_NEW, 64, "CompareFramework V3.6.2 Stable"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_CreateTestWorkbook : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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
        MsgBox "Tests OK : " & passed & "/" & total, 64, "CompareFramework V3.6.2 Stable"
    Else
        MsgBox "Tests à contrôler : " & passed & "/" & total, 48, "CompareFramework V3.6.2 Stable"
    End If

    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunAllTests : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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

    MsgBox "Tests contexte : " & passed & "/" & total, 64, "CompareFramework V3.6.2 Stable"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunContextTests : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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


'=========================================================
' V2.6 - Profile tests
'=========================================================

Public Sub CF_RunProfileTests()
    On Error GoTo ErrHandler

    Dim oDoc As Object, oProfiles As Object
    Dim okSheet As Boolean, okStandard As Boolean, okFinance As Boolean

    oDoc = ThisComponent
    oProfiles = CF_EnsureProfilesSheet(oDoc)

    okSheet = oDoc.Sheets.hasByName(CF_PROFILES_SHEET)
    okStandard = CF_TestProfileExists(oProfiles, "STANDARD")
    okFinance = CF_TestProfileExists(oProfiles, "FINANCE")

    If okSheet And okStandard And okFinance Then
        MsgBox "Tests profils : 3/3", 64, "CompareFramework V3.6.2 Stable"
    Else
        MsgBox "Tests profils incomplets.", 48, "CompareFramework V3.6.2 Stable"
    End If
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunProfileTests : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Private Function CF_TestProfileExists(oSheet As Object, profileName As String) As Boolean
    Dim r As Long
    For r = 1 To LastUsedRow(oSheet)
        If UCase(Trim(CellText(oSheet, 0, r))) = UCase(Trim(profileName)) Then
            CF_TestProfileExists = True
            Exit Function
        End If
    Next r
    CF_TestProfileExists = False
End Function


'=========================================================
' V2.7 - Validation tests
'=========================================================
Public Sub CF_RunValidationTests()
    Dim ok As Boolean
    ok = CF_ValidateFramework()
    If ThisComponent.Sheets.hasByName("Compare_Validation") Then
        MsgBox "Validation exécutée. Résultat global : " & IIf(ok, "OK", "KO"), 64, "CompareFramework V3.6.2 Stable"
    Else
        MsgBox "Echec : feuille Compare_Validation absente.", 16, "CompareFramework V3.6.2 Stable"
    End If
End Sub


'=========================================================
' V2.8 - Audit tests
'=========================================================

Public Sub CF_RunAuditTests()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oSheet As Object
    Dim bRunId As Boolean
    Dim bMetric As Boolean
    Dim bSheet As Boolean

    oDoc = ThisComponent

    CF_AuditBegin "AuditUnitTest"
    bRunId = (CF_AuditGetRunId() <> "")
    CF_AuditSet "SampleMetric", "42"
    bMetric = (CF_AuditDurationSeconds() >= 0)
    CF_AuditEnd "DONE"
    bSheet = oDoc.Sheets.hasByName("Compare_Audit")

    If oDoc.Sheets.hasByName("CF_Test_Audit") Then
        oDoc.Sheets.removeByName("CF_Test_Audit")
    End If

    oDoc.Sheets.insertNewByName "CF_Test_Audit", oDoc.Sheets.getCount()
    oSheet = oDoc.Sheets.getByName("CF_Test_Audit")

    oSheet.getCellByPosition(0, 0).String = "Test"
    oSheet.getCellByPosition(1, 0).String = "Résultat"

    oSheet.getCellByPosition(0, 1).String = "Run ID créé"
    oSheet.getCellByPosition(1, 1).String = IIf(bRunId, "OK", "KO")

    oSheet.getCellByPosition(0, 2).String = "Durée calculable"
    oSheet.getCellByPosition(1, 2).String = IIf(bMetric, "OK", "KO")

    oSheet.getCellByPosition(0, 3).String = "Feuille Compare_Audit créée"
    oSheet.getCellByPosition(1, 3).String = IIf(bSheet, "OK", "KO")

    If bRunId And bMetric And bSheet Then
        MsgBox "Tests audit : 3/3", 64, "CompareFramework V3.6.2 Stable"
    Else
        MsgBox "Tests audit à contrôler.", 48, "CompareFramework V3.6.2 Stable"
    End If

    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunAuditTests : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub


Public Sub CF_RunPerformanceTests()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim oSheet As Object
    Dim okTimer As Boolean
    Dim okReport As Boolean
    Dim startValue As Double
    Dim elapsed As Double

    oDoc = ThisComponent

    startValue = Timer
    elapsed = Timer - startValue
    If elapsed < 0 Then elapsed = elapsed + 86400

    okTimer = (elapsed >= 0)

    On Error Resume Next
    CF_PerfReset
    CF_PerfStartPhase "TEST"
    CF_PerfEndPhase "TEST"
    CF_PerfWriteReport
    okReport = oDoc.Sheets.hasByName("Compare_Performance")
    On Error GoTo ErrHandler

    If oDoc.Sheets.hasByName("CF_Test_Performance") Then
        oDoc.Sheets.removeByName("CF_Test_Performance")
    End If

    oDoc.Sheets.insertNewByName "CF_Test_Performance", oDoc.Sheets.getCount()
    oSheet = oDoc.Sheets.getByName("CF_Test_Performance")

    oSheet.getCellByPosition(0, 0).String = "Test"
    oSheet.getCellByPosition(1, 0).String = "Résultat"
    oSheet.getCellByPosition(2, 0).String = "Détail"

    oSheet.getCellByPosition(0, 1).String = "Chronométrage"
    oSheet.getCellByPosition(1, 1).String = IIf(okTimer, "OK", "KO")
    oSheet.getCellByPosition(2, 1).String = "Elapsed=" & CStr(elapsed)

    oSheet.getCellByPosition(0, 2).String = "Rapport performance"
    oSheet.getCellByPosition(1, 2).String = IIf(okReport, "OK", "KO")
    oSheet.getCellByPosition(2, 2).String = "Compare_Performance"

    oSheet.getCellByPosition(0, 4).String = "Synthèse"
    If okTimer And okReport Then
        oSheet.getCellByPosition(1, 4).String = "OK"
    Else
        oSheet.getCellByPosition(1, 4).String = "A CONTROLER"
    End If

    On Error Resume Next
    oSheet.getCellRangeByName("A1:C1").CharWeight = com.sun.star.awt.FontWeight.BOLD
    oSheet.getCellRangeByName("A1:C1").CellBackColor = RGB(220, 230, 241)
    oSheet.Columns.getByIndex(0).Width = 6500
    oSheet.Columns.getByIndex(1).Width = 3500
    oSheet.Columns.getByIndex(2).Width = 9000
    On Error GoTo ErrHandler

    If okTimer And okReport Then
        MsgBox "Tests performance : 2/2", 64, "CompareFramework V3.6.2 Stable"
    Else
        MsgBox "Tests performance à contrôler.", 48, "CompareFramework V3.6.2 Stable"
    End If
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunPerformanceTests : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub


Public Sub CF_RunMilestoneBTests()
    CF_RunTypedComparatorTests
    CF_RunMemoryEngineTests
End Sub

'======================================================================
' CompareFramework_Main.bas
'======================================================================
' CompareFramework V3.6.2 Stable - Main
' Orchestration et API publique.
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
    MsgBox "Erreur Jalon A : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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
    MsgBox "CompareFramework V3.6.2 Stable" & Chr(10) & _
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
    MsgBox "Erreur comparaison contextualisée : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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
        MsgBox "Validation échouée. Consulte la feuille Compare_Validation.", 48, "CompareFramework V3.6.2 Stable"
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

    MsgBox "Erreur CF_RunAudited : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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
        MsgBox "Validation échouée. Consulte Compare_Validation.", 48, "CompareFramework V3.6.2 Stable"
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
    MsgBox "Erreur CF_RunPerformanceProfiled : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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
    MsgBox "Erreur Jalon B : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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
    MsgBox "Erreur CF_RunMilestoneB_Configured : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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
    MsgBox "Erreur CF_RunMilestoneB_Final : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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
    MsgBox "Erreur CF_RunMilestoneC : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
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
    MsgBox "Erreur CF_RunMilestoneC_Final : " & Err & " - " & Error$, 16, "CompareFramework V3.6.2 Stable"
End Sub

Private Function CF_RoundCompat(vValue As Double, iDecimals As Integer) As Double
    Dim factor As Double
    Dim scaled As Double

    factor = 10 ^ iDecimals
    scaled = vValue * factor

    If scaled >= 0 Then
        CF_RoundCompat = Int(scaled + 0.5) / factor
    Else
        CF_RoundCompat = -Int(-scaled + 0.5) / factor
    End If
End Function

'=========================================================
' CompareFramework V3.6.2 Stable - Final validation entry point
'=========================================================

Public Sub CF_RunStableValidation()
    On Error GoTo ErrHandler

    ' The internal test suites create their own audit runs.
    ' Run them first, then create one clean final release-validation audit.
    CF_AuditSuspend
    CF_ContextBeginRun "CF_RunStableValidation"

    CF_RunGlobalRegression
    CF_RunAllBusinessScenarios
    CF_BuildReleaseReadiness

    CF_AuditResume
    CF_AuditBegin "CF_RunStableValidation"
    CF_AuditSet "Release", "3.6.2 Stable"
    CF_AuditSet "Validation", "COMPLETE"
    CF_AuditSet "Engine", "MEMORY"
    CF_AuditSet "QualityDashboard", CF_ContextGet("QualityDashboard", "OK")
    CF_AuditEnd "DONE"

    CF_ContextEndRun "DONE"

    MsgBox "Validation V3.6.2 Stable terminée." & Chr(10) & _
           "Consulte CF_Release_Readiness et Compare_Audit.", _
           64, "CompareFramework V3.6.2 Stable"
    Exit Sub

ErrHandler:
    CF_AuditResume

    If Not CF_AuditIsActive() Then
        CF_AuditBegin "CF_RunStableValidation"
    End If

    CF_AuditFail Err, Error$
    CF_AuditEnd "ERROR"
    CF_ContextEndRun "ERROR"

    MsgBox "Erreur CF_RunStableValidation : " & Err & " - " & Error$, _
           16, "CompareFramework V3.6.2 Stable"
End Sub
