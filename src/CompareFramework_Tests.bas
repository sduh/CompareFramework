Option Explicit

'=========================================================
' CompareFramework - Test Suite
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

    MsgBox "Jeu de test créé : " & CF_TEST_SHEET_OLD & " / " & CF_TEST_SHEET_NEW, 64, "CompareFramework V" & CF_VERSION
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_CreateTestWorkbook : " & Err & " - " & Error$, 16, "CompareFramework V" & CF_VERSION
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
        MsgBox "Tests OK : " & passed & "/" & total, 64, "CompareFramework V" & CF_VERSION
    Else
        MsgBox "Tests à contrôler : " & passed & "/" & total, 48, "CompareFramework V" & CF_VERSION
    End If

    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunAllTests : " & Err & " - " & Error$, 16, "CompareFramework V" & CF_VERSION
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

    MsgBox "Tests contexte : " & passed & "/" & total, 64, "CompareFramework V" & CF_VERSION
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunContextTests : " & Err & " - " & Error$, 16, "CompareFramework V" & CF_VERSION
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
        MsgBox "Tests profils : 3/3", 64, "CompareFramework V" & CF_VERSION
    Else
        MsgBox "Tests profils incomplets.", 48, "CompareFramework V" & CF_VERSION
    End If
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunProfileTests : " & Err & " - " & Error$, 16, "CompareFramework V" & CF_VERSION
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
        MsgBox "Validation exécutée. Résultat global : " & IIf(ok, "OK", "KO"), 64, "CompareFramework V" & CF_VERSION
    Else
        MsgBox "Echec : feuille Compare_Validation absente.", 16, "CompareFramework V" & CF_VERSION
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
        MsgBox "Tests audit : 3/3", 64, "CompareFramework V" & CF_VERSION
    Else
        MsgBox "Tests audit à contrôler.", 48, "CompareFramework V" & CF_VERSION
    End If

    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunAuditTests : " & Err & " - " & Error$, 16, "CompareFramework V" & CF_VERSION
End Sub


Public Sub CF_RunPerformanceTests()
    On Error GoTo ErrHandler
    Dim oDoc As Object, oSheet As Object, data As Variant, ok As Boolean
    oDoc = ThisComponent
    If Not oDoc.Sheets.hasByName("CF_Test_OLD") Then CF_CreateTestWorkbook
    oSheet = oDoc.Sheets.getByName("CF_Test_OLD")
    data = CF_ReadSheetDataArray(oSheet)
    ok = (UBound(data) >= 4 And UBound(data(0)) >= 3)
    CF_PerfReset
    CF_PerfStart "Test"
    CF_PerfStop "Test"
    CF_PerfWriteReport
    If ok Then
        MsgBox "Tests performance : OK", 64, "CompareFramework V" & CF_VERSION
    Else
        MsgBox "Tests performance : KO", 48, "CompareFramework V" & CF_VERSION
    End If
    Exit Sub
ErrHandler:
    MsgBox "Erreur CF_RunPerformanceTests : " & Err & " - " & Error$, 16, "CompareFramework V" & CF_VERSION
End Sub


Public Sub CF_RunMilestoneBTests()
    CF_RunTypedComparatorTests
    CF_RunMemoryEngineTests
End Sub
