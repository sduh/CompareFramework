' CompareFramework V2.4 - Config
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

