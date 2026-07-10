Option Explicit

'=========================================================
' CompareFramework V3.2 - Reusable Profiles
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
        MsgBox "Profil introuvable : " & sProfileName, 48, "CompareFramework V3.2"
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

    MsgBox "Profil appliqué : " & UCase(Trim(sProfileName)), 64, "CompareFramework V3.2"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_ApplyProfile : " & Err & " - " & Error$, 16, "CompareFramework V3.2"
End Sub

Public Sub CF_SaveCurrentConfigAsProfile(sProfileName As String)
    On Error GoTo ErrHandler

    Dim oDoc As Object, oProfiles As Object, oConfig As Object
    Dim rowIndex As Long

    sProfileName = UCase(Trim(sProfileName))
    If sProfileName = "" Then
        MsgBox "Le nom du profil est obligatoire.", 48, "CompareFramework V3.2"
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

    MsgBox "Profil enregistré : " & sProfileName, 64, "CompareFramework V3.2"
    Exit Sub

ErrHandler:
    MsgBox "Erreur CF_SaveCurrentConfigAsProfile : " & Err & " - " & Error$, 16, "CompareFramework V3.2"
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
    MsgBox "Erreur CF_RunWithProfile : " & Err & " - " & Error$, 16, "CompareFramework V3.2"
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
