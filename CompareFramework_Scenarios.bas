Option Explicit

'=========================================================
' CompareFramework V3.5 - Milestone C Stabilisation
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

    MsgBox "Scénarios métier terminés. Consulte CF_Scenario_Results et CF_Release_Readiness.", 64, "CompareFramework V3.5"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunAllBusinessScenarios : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
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

    oDoc = ThisComponent
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
    CF_ScenarioReadinessRow oSheet, 5, "Décision", releaseStatus, "CompareFramework V3.5"

    CF_ScenarioFormat oSheet
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_BuildReleaseReadiness : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
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
    Dim lastCol As Long
    Dim row As Long
    Dim col As Long
    Dim rowText As String

    oDoc = ThisComponent
    If Not oDoc.Sheets.hasByName("Rapport_Comparaison") Then
        CF_ScenarioReportContains = False
        Exit Function
    End If

    oReport = oDoc.Sheets.getByName("Rapport_Comparaison")
    oCursor = oReport.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow
    lastCol = oCursor.RangeAddress.EndColumn

    For row = 1 To lastRow
        rowText = ""
        For col = 0 To lastCol
            rowText = rowText & "|" & UCase(Trim(oReport.getCellByPosition(col, row).String))
        Next col

        If InStr(rowText, UCase(expectedType)) > 0 And InStr(rowText, UCase(expectedId)) > 0 Then
            If expectedColumn = "" Or InStr(rowText, UCase(expectedColumn)) > 0 Then
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
