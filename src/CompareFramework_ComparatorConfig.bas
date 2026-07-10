Option Explicit

'=========================================================
' CompareFramework V3.5.1 - Comparator configuration
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
    MsgBox "Configuration des comparateurs rechargee : " & CF_CC_COUNT & " regle(s).", 64, "CompareFramework V3.5.1"
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
        MsgBox "Tests configuration comparateurs : 3/3", 64, "CompareFramework V3.5.1"
    Else
        MsgBox "Tests configuration comparateurs a controler.", 48, "CompareFramework V3.5.1"
    End If
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunComparatorConfigTests : " & Err & " - " & Error$, 16, "CompareFramework V3.5.1"
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
    s = Trim(v)
    If s = "" Then GoTo Fail
    s = Replace(s, ",", ".")
    result = CDbl(s)
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
