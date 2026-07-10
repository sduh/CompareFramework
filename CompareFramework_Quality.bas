Option Explicit

'=========================================================
' CompareFramework V3.5.1 - Milestone C Quality Suite
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
    MsgBox "Erreur CF_RunEndToEndScenario : " & Err & " - " & Error$, 16, "CompareFramework V3.5.1"
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
        MsgBox "Feuille CF_Expected absente.", 48, "CompareFramework V3.5.1"
        Exit Sub
    End If

    If Not oDoc.Sheets.hasByName("Rapport_Comparaison") Then
        MsgBox "Feuille Rapport_Comparaison absente.", 48, "CompareFramework V3.5.1"
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
        MsgBox "Scénario de bout en bout validé : " & passed & "/" & total, 64, "CompareFramework V3.5.1"
    Else
        MsgBox "Scénario à contrôler : " & passed & "/" & total, 48, "CompareFramework V3.5.1"
    End If
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_ValidateExpectedReport : " & Err & " - " & Error$, 16, "CompareFramework V3.5.1"
End Sub

Public Sub CF_RunGlobalRegression()
    On Error GoTo ErrHandler

    CF_RunMilestoneB_FinalTests
    CF_RunContextTests
    CF_RunProfileTests
    CF_RunValidationTests
    CF_RunAuditTests
    CF_RunPerformanceTests
    CF_RunMemoryEngineTests
    CF_RunEndToEndScenario

    MsgBox "Régression globale terminée. Consulte CF_Quality_Dashboard.", 64, "CompareFramework V3.5.1"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunGlobalRegression : " & Err & " - " & Error$, 16, "CompareFramework V3.5.1"
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
    MsgBox "Erreur CF_BuildQualityDashboard : " & Err & " - " & Error$, 16, "CompareFramework V3.5.1"
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
    Dim lastCol As Long
    Dim row As Long
    Dim col As Long
    Dim rowText As String
    Dim valueText As String

    oCursor = oReport.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow
    lastCol = oCursor.RangeAddress.EndColumn

    For row = 1 To lastRow
        rowText = ""
        For col = 0 To lastCol
            valueText = UCase(Trim(oReport.getCellByPosition(col, row).String))
            rowText = rowText & "|" & valueText
        Next col

        If InStr(rowText, UCase(expectedType)) > 0 And InStr(rowText, UCase(expectedId)) > 0 Then
            If expectedColumn = "" Or InStr(rowText, UCase(expectedColumn)) > 0 Then
                CF_QualityFindReportEntry = True
                Exit Function
            End If
        End If
    Next row

    CF_QualityFindReportEntry = False
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
        CF_QualitySheetStatus = "ABSENT"
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
    For row = 1 To 6
        If UCase(oSheet.getCellByPosition(1, row).String) <> "OK" Then
            CF_QualityGlobalStatus = "A CONTROLER"
            Exit Function
        End If
    Next row
    CF_QualityGlobalStatus = "OK"
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
