Option Explicit

'=========================================================
' CompareFramework V2.7 - Execution Context
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

    MsgBox "Contexte exporté dans Compare_Context.", 64, "CompareFramework V2.7"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_ContextDumpToSheet : " & Err & " - " & Error$, 16, "CompareFramework V2.7"
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
