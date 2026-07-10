Option Explicit

'=========================================================
' CompareFramework V3.5 - Typed Comparator Reliability
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

    If passed = total Then
        MsgBox "Régression typée OK : " & passed & "/" & total, 64, "CompareFramework V3.5"
    Else
        MsgBox "Régression typée à contrôler : " & passed & "/" & total, 48, "CompareFramework V3.5"
    End If
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_RunTypedRegressionSuite : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
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
    Dim profileName As String
    Dim columnName As String
    Dim comparatorType As String
    Dim toleranceValue As String
    Dim statusText As String
    Dim messageText As String

    oDoc = ThisComponent
    CF_ReliabilityRecreateSheet oDoc, "CF_Comparator_Validation"
    oSheet = oDoc.Sheets.getByName("CF_Comparator_Validation")

    oSheet.getCellByPosition(0, 0).String = "Ligne"
    oSheet.getCellByPosition(1, 0).String = "Profil"
    oSheet.getCellByPosition(2, 0).String = "Colonne"
    oSheet.getCellByPosition(3, 0).String = "Type"
    oSheet.getCellByPosition(4, 0).String = "Tolérance"
    oSheet.getCellByPosition(5, 0).String = "Statut"
    oSheet.getCellByPosition(6, 0).String = "Message"

    If Not oDoc.Sheets.hasByName("Compare_Comparators") Then
        oSheet.getCellByPosition(5, 1).String = "KO"
        oSheet.getCellByPosition(6, 1).String = "Feuille Compare_Comparators absente"
        CF_ReliabilityFormat oSheet
        Exit Sub
    End If

    oRules = oDoc.Sheets.getByName("Compare_Comparators")
    oCursor = oRules.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow
    outRow = 1

    For row = 1 To lastRow
        profileName = Trim(oRules.getCellByPosition(0, row).String)
        columnName = Trim(oRules.getCellByPosition(1, row).String)
        comparatorType = UCase(Trim(oRules.getCellByPosition(2, row).String))
        toleranceValue = Trim(oRules.getCellByPosition(3, row).String)

        statusText = "OK"
        messageText = ""

        If profileName = "" Then
            statusText = "KO"
            messageText = "Profil vide"
        ElseIf columnName = "" Then
            statusText = "KO"
            messageText = "Colonne vide"
        ElseIf Not CF_ReliabilityIsSupportedType(comparatorType) Then
            statusText = "KO"
            messageText = "Type non supporté"
        ElseIf toleranceValue <> "" And Not IsNumeric(Replace(toleranceValue, ",", ".")) Then
            statusText = "KO"
            messageText = "Tolérance non numérique"
        End If

        oSheet.getCellByPosition(0, outRow).String = CStr(row + 1)
        oSheet.getCellByPosition(1, outRow).String = profileName
        oSheet.getCellByPosition(2, outRow).String = columnName
        oSheet.getCellByPosition(3, outRow).String = comparatorType
        oSheet.getCellByPosition(4, outRow).String = toleranceValue
        oSheet.getCellByPosition(5, outRow).String = statusText
        oSheet.getCellByPosition(6, outRow).String = messageText
        outRow = outRow + 1
    Next row

    CF_ReliabilityFormat oSheet
    MsgBox "Validation des comparateurs terminée.", 64, "CompareFramework V3.5"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_ValidateComparatorRules : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
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
    MsgBox "Rapport de couverture généré.", 64, "CompareFramework V3.5"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_BuildComparatorCoverageReport : " & Err & " - " & Error$, 16, "CompareFramework V3.5"
End Sub

Public Sub CF_RunMilestoneB_FinalTests()
    CF_RunTypedComparatorTests
    CF_RunComparatorConfigTests
    CF_RunTypedRegressionSuite
    CF_ValidateComparatorRules
    CF_BuildComparatorCoverageReport

    MsgBox "Jalon B V3.3 terminé. Consulte les feuilles de test et validation.", 64, "CompareFramework V3.5"
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
