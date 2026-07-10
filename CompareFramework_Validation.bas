Option Explicit

'=========================================================
' CompareFramework V3.3 - Validation and Preflight
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
        MsgBox "Validation échouée. Consulte la feuille Compare_Validation.", 48, "CompareFramework V3.3"
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
    MsgBox "Erreur CF_RunValidated : " & Err & " - " & Error$, 16, "CompareFramework V3.3"
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
