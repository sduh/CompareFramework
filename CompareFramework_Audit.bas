Option Explicit

'=========================================================
' CompareFramework V3.5 - Execution Audit
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

Public Sub CF_AuditBegin(Optional sRunName As String = "Comparison")
    ReDim CF_AUDIT_METRIC_KEYS(0 To 0)
    ReDim CF_AUDIT_METRIC_VALUES(0 To 0)

    CF_AUDIT_METRIC_COUNT = 0
    CF_AUDIT_RUN_ID = CF_AuditCreateRunId()
    CF_AUDIT_RUN_NAME = sRunName
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

Public Sub CF_AuditEnd(Optional sStatus As String = "DONE")
    If Not CF_AUDIT_ACTIVE Then Exit Sub

    CF_AUDIT_ENDED_AT = Now

    If CF_AUDIT_STATUS <> "ERROR" Then
        CF_AUDIT_STATUS = sStatus
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
    MsgBox "Erreur CF_AuditWriteCurrentRun : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
End Sub

Public Sub CF_AuditClearHistory()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    oDoc = ThisComponent

    If oDoc.Sheets.hasByName("Compare_Audit") Then
        oDoc.Sheets.removeByName("Compare_Audit")
    End If

    CF_AuditEnsureSheet oDoc
    MsgBox "Historique d'audit réinitialisé.", 64, "CompareFramework V3.5"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_AuditClearHistory : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
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

    CF_AuditDurationSeconds = Round((endValue - CF_AUDIT_STARTED_AT) * 86400, 3)
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
