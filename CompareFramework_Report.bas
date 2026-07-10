' CompareFramework V3.2 - Report
' Rapports Calc, synthèse, plan d'action, journal et export HTML.
Option Explicit

Public Function PrepareSheet(oDoc As Object, sheetName As String) As Object
    Dim oSheets As Object
    oSheets = oDoc.Sheets

    If oSheets.hasByName(sheetName) Then
        oSheets.removeByName(sheetName)
    End If

    oSheets.insertNewByName(sheetName, oSheets.Count)
    PrepareSheet = oSheets.getByName(sheetName)
End Function

Public Sub WriteReportHeader(oSheet As Object, rowIndex As Long)
    SetCell oSheet, CF_COL_VERSION, rowIndex, "Framework"
    SetCell oSheet, CF_COL_PAIR, rowIndex, "Paire"
    SetCell oSheet, CF_COL_ID, rowIndex, "ID"
    SetCell oSheet, CF_COL_TYPE, rowIndex, "Type"
    SetCell oSheet, CF_COL_COLUMN, rowIndex, "Colonne"
    SetCell oSheet, CF_COL_OLD_ROW, rowIndex, "Ligne ancienne"
    SetCell oSheet, CF_COL_NEW_ROW, rowIndex, "Ligne nouvelle"
    SetCell oSheet, CF_COL_OLD_VALUE, rowIndex, "Ancienne valeur"
    SetCell oSheet, CF_COL_NEW_VALUE, rowIndex, "Nouvelle valeur"
    SetCell oSheet, CF_COL_MESSAGE, rowIndex, "Message"
End Sub

Public Sub WriteReportRow(oSheet As Object, ByRef rowIndex As Long, pairName As String, idValue As String, statusValue As String, colName As String, oldRow As String, newRow As String, oldValue As String, newValue As String, messageText As String)
    SetCell oSheet, CF_COL_VERSION, rowIndex, "V" & CF_VERSION
    SetCell oSheet, CF_COL_PAIR, rowIndex, pairName
    SetCell oSheet, CF_COL_ID, rowIndex, idValue
    SetCell oSheet, CF_COL_TYPE, rowIndex, statusValue
    SetCell oSheet, CF_COL_COLUMN, rowIndex, colName
    SetCell oSheet, CF_COL_OLD_ROW, rowIndex, oldRow
    SetCell oSheet, CF_COL_NEW_ROW, rowIndex, newRow
    SetCell oSheet, CF_COL_OLD_VALUE, rowIndex, oldValue
    SetCell oSheet, CF_COL_NEW_VALUE, rowIndex, newValue
    SetCell oSheet, CF_COL_MESSAGE, rowIndex, messageText
End Sub

Public Sub WriteStatsHeader(oSheet As Object, rowIndex As Long)
    SetCell oSheet, 0, rowIndex, "Paire"
    SetCell oSheet, 1, rowIndex, "Lignes ajoutees"
    SetCell oSheet, 2, rowIndex, "Lignes supprimees"
    SetCell oSheet, 3, rowIndex, "Lignes modifiees"
    SetCell oSheet, 4, rowIndex, "Cellules modifiees"
    SetCell oSheet, 5, rowIndex, "ID doublons"
    SetCell oSheet, 6, rowIndex, "Lignes anciennes indexees"
    SetCell oSheet, 7, rowIndex, "Lignes nouvelles indexees"
    SetCell oSheet, 8, rowIndex, "Alertes structure"
End Sub

Public Sub WriteStatsRow(oSheet As Object, ByRef rowIndex As Long, pairName As String, addedRows As Long, removedRows As Long, changedRows As Long, changedCells As Long, duplicates As Long, oldCount As Long, newCount As Long, issues As Long)
    SetCell oSheet, 0, rowIndex, pairName
    SetCell oSheet, 1, rowIndex, CStr(addedRows)
    SetCell oSheet, 2, rowIndex, CStr(removedRows)
    SetCell oSheet, 3, rowIndex, CStr(changedRows)
    SetCell oSheet, 4, rowIndex, CStr(changedCells)
    SetCell oSheet, 5, rowIndex, CStr(duplicates)
    SetCell oSheet, 6, rowIndex, CStr(oldCount)
    SetCell oSheet, 7, rowIndex, CStr(newCount)
    SetCell oSheet, 8, rowIndex, CStr(issues)
End Sub

Public Sub WriteGlobalSummary(oSheet As Object, ByRef rowIndex As Long, pairCount As Long, totalAdded As Long, totalRemoved As Long, totalChangedRows As Long, totalChangedCells As Long, totalDuplicates As Long, totalIssues As Long)
    rowIndex = rowIndex + 2
    SetCell oSheet, 0, rowIndex, "Resume global"
    SetCell oSheet, 1, rowIndex, "Valeur"

    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Version"
    SetCell oSheet, 1, rowIndex, "V" & CF_VERSION
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Paires comparees"
    SetCell oSheet, 1, rowIndex, CStr(pairCount)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Lignes ajoutees"
    SetCell oSheet, 1, rowIndex, CStr(totalAdded)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Lignes supprimees"
    SetCell oSheet, 1, rowIndex, CStr(totalRemoved)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Lignes modifiees"
    SetCell oSheet, 1, rowIndex, CStr(totalChangedRows)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Cellules modifiees"
    SetCell oSheet, 1, rowIndex, CStr(totalChangedCells)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "ID doublons"
    SetCell oSheet, 1, rowIndex, CStr(totalDuplicates)
    rowIndex = rowIndex + 1
    SetCell oSheet, 0, rowIndex, "Alertes structure"
    SetCell oSheet, 1, rowIndex, CStr(totalIssues)
End Sub

Public Sub WriteDashboard(oSheet As Object, pairCount As Long, totalAdded As Long, totalRemoved As Long, totalChangedRows As Long, totalChangedCells As Long, totalDuplicates As Long, totalIssues As Long)
    Dim r As Long, decisionText As String

    r = 0
    SetCell oSheet, 0, r, "Synthese CompareFramework"
    SetCell oSheet, 1, r, "V" & CF_VERSION

    r = r + 2
    SetCell oSheet, 0, r, "Decision"
    If totalAdded = 0 And totalRemoved = 0 And totalChangedCells = 0 And totalDuplicates = 0 And totalIssues = 0 Then
        decisionText = "OK - aucune difference detectee"
    Else
        decisionText = "A CONTROLER - differences ou alertes detectees"
    End If
    SetCell oSheet, 1, r, decisionText

    r = r + 2
    SetCell oSheet, 0, r, "Indicateur"
    SetCell oSheet, 1, r, "Valeur"

    r = r + 1
    SetCell oSheet, 0, r, "Paires comparees"
    SetCell oSheet, 1, r, CStr(pairCount)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes ajoutees"
    SetCell oSheet, 1, r, CStr(totalAdded)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes supprimees"
    SetCell oSheet, 1, r, CStr(totalRemoved)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes modifiees"
    SetCell oSheet, 1, r, CStr(totalChangedRows)
    r = r + 1
    SetCell oSheet, 0, r, "Cellules modifiees"
    SetCell oSheet, 1, r, CStr(totalChangedCells)
    r = r + 1
    SetCell oSheet, 0, r, "ID doublons"
    SetCell oSheet, 1, r, CStr(totalDuplicates)
    r = r + 1
    SetCell oSheet, 0, r, "Alertes structure"
    SetCell oSheet, 1, r, CStr(totalIssues)

    r = r + 2
    SetCell oSheet, 0, r, "Configuration active"
    r = r + 1
    SetCell oSheet, 0, r, "IGNORE_COLUMNS"
    SetCell oSheet, 1, r, gIgnoreColumns
    r = r + 1
    SetCell oSheet, 0, r, "ID_ALIASES"
    SetCell oSheet, 1, r, gIdAliases
    r = r + 1
    SetCell oSheet, 0, r, "IGNORE_CASE"
    SetCell oSheet, 1, r, CStr(gIgnoreCase)
    r = r + 1
    SetCell oSheet, 0, r, "NORMALIZE_SPACES"
    SetCell oSheet, 1, r, CStr(gNormalizeSpaces)
    r = r + 1
    SetCell oSheet, 0, r, "IGNORE_EMPTY_CHANGES"
    SetCell oSheet, 1, r, CStr(gIgnoreEmptyChanges)
End Sub

Public Sub BuildActionPlan(oReport As Object, oAction As Object, lastReportRow As Long)
    Dim r As Long, outRow As Long
    Dim statusValue As String, pairName As String, idValue As String, colName As String
    Dim oldValue As String, newValue As String, messageText As String

    WriteActionHeader oAction, 0
    outRow = 1

    For r = 1 To lastReportRow
        statusValue = CellText(oReport, CF_COL_TYPE, r)
        If statusValue <> "" Then
            pairName = CellText(oReport, CF_COL_PAIR, r)
            idValue = CellText(oReport, CF_COL_ID, r)
            colName = CellText(oReport, CF_COL_COLUMN, r)
            oldValue = CellText(oReport, CF_COL_OLD_VALUE, r)
            newValue = CellText(oReport, CF_COL_NEW_VALUE, r)
            messageText = CellText(oReport, CF_COL_MESSAGE, r)

            If IsActionableStatus(statusValue) Then
                SetCell oAction, 0, outRow, ActionPriority(statusValue, colName)
                SetCell oAction, 1, outRow, pairName
                SetCell oAction, 2, outRow, idValue
                SetCell oAction, 3, outRow, statusValue
                SetCell oAction, 4, outRow, colName
                SetCell oAction, 5, outRow, ActionRecommendation(statusValue, colName, messageText)
                SetCell oAction, 6, outRow, oldValue
                SetCell oAction, 7, outRow, newValue
                SetCell oAction, 8, outRow, "A traiter"
                SetCell oAction, 9, outRow, ""
                outRow = outRow + 1
            End If
        End If
    Next r

    If outRow = 1 Then
        SetCell oAction, 0, outRow, "OK"
        SetCell oAction, 1, outRow, ""
        SetCell oAction, 2, outRow, ""
        SetCell oAction, 3, outRow, CF_STATUS_INFO
        SetCell oAction, 4, outRow, ""
        SetCell oAction, 5, outRow, "Aucune action requise"
        SetCell oAction, 8, outRow, "Clos"
    End If
End Sub

Public Sub WriteActionHeader(oSheet As Object, rowIndex As Long)
    SetCell oSheet, 0, rowIndex, "Priorite"
    SetCell oSheet, 1, rowIndex, "Paire"
    SetCell oSheet, 2, rowIndex, "ID"
    SetCell oSheet, 3, rowIndex, "Type"
    SetCell oSheet, 4, rowIndex, "Colonne"
    SetCell oSheet, 5, rowIndex, "Action recommandee"
    SetCell oSheet, 6, rowIndex, "Ancienne valeur"
    SetCell oSheet, 7, rowIndex, "Nouvelle valeur"
    SetCell oSheet, 8, rowIndex, "Statut traitement"
    SetCell oSheet, 9, rowIndex, "Commentaire"
End Sub

Public Function IsActionableStatus(statusValue As String) As Boolean
    IsActionableStatus = (statusValue = CF_STATUS_ADDED Or statusValue = CF_STATUS_REMOVED Or statusValue = CF_STATUS_CHANGED Or statusValue = CF_STATUS_DUPLICATE Or statusValue = CF_STATUS_ERROR)
End Function

Public Function ActionPriority(statusValue As String, colName As String) As String
    Select Case statusValue
        Case CF_STATUS_ERROR
            ActionPriority = "P1"
        Case CF_STATUS_DUPLICATE
            ActionPriority = "P1"
        Case CF_STATUS_REMOVED
            ActionPriority = "P1"
        Case CF_STATUS_ADDED
            ActionPriority = "P2"
        Case CF_STATUS_CHANGED
            If NormalizeHeader(colName) = "id" Or NormalizeHeader(colName) = "identifiant" Or NormalizeHeader(colName) = "code" Then
                ActionPriority = "P1"
            Else
                ActionPriority = "P3"
            End If
        Case Else
            ActionPriority = "P3"
    End Select
End Function

Public Function ActionRecommendation(statusValue As String, colName As String, messageText As String) As String
    Select Case statusValue
        Case CF_STATUS_ERROR
            ActionRecommendation = "Corriger la structure avant d'exploiter la comparaison"
        Case CF_STATUS_DUPLICATE
            ActionRecommendation = "Verifier les identifiants en doublon puis dedoublonner la source"
        Case CF_STATUS_REMOVED
            ActionRecommendation = "Verifier si la suppression est attendue et documenter la cause"
        Case CF_STATUS_ADDED
            ActionRecommendation = "Verifier si l'ajout est attendu et valider la creation"
        Case CF_STATUS_CHANGED
            ActionRecommendation = "Controler la modification de la colonne '" & colName & "'"
        Case Else
            If messageText <> "" Then
                ActionRecommendation = messageText
            Else
                ActionRecommendation = "Controler l'ecart"
            End If
    End Select
End Function

Public Sub WriteAuditLog(oSheet As Object, pairCount As Long, totalAdded As Long, totalRemoved As Long, totalChangedRows As Long, totalChangedCells As Long, totalDuplicates As Long, totalIssues As Long, lastReportRow As Long)
    Dim r As Long
    r = 0
    SetCell oSheet, 0, r, "Journal CompareFramework"
    SetCell oSheet, 1, r, "V" & CF_VERSION

    r = r + 2
    SetCell oSheet, 0, r, "Date execution"
    SetCell oSheet, 1, r, CStr(Now)
    r = r + 1
    SetCell oSheet, 0, r, "Document"
    SetCell oSheet, 1, r, ThisComponent.Title
    r = r + 1
    SetCell oSheet, 0, r, "Lignes rapport"
    SetCell oSheet, 1, r, CStr(lastReportRow)
    r = r + 1
    SetCell oSheet, 0, r, "Paires comparees"
    SetCell oSheet, 1, r, CStr(pairCount)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes ajoutees"
    SetCell oSheet, 1, r, CStr(totalAdded)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes supprimees"
    SetCell oSheet, 1, r, CStr(totalRemoved)
    r = r + 1
    SetCell oSheet, 0, r, "Lignes modifiees"
    SetCell oSheet, 1, r, CStr(totalChangedRows)
    r = r + 1
    SetCell oSheet, 0, r, "Cellules modifiees"
    SetCell oSheet, 1, r, CStr(totalChangedCells)
    r = r + 1
    SetCell oSheet, 0, r, "Doublons"
    SetCell oSheet, 1, r, CStr(totalDuplicates)
    r = r + 1
    SetCell oSheet, 0, r, "Alertes structure"
    SetCell oSheet, 1, r, CStr(totalIssues)
End Sub

Public Sub FormatActionPlan(oSheet As Object)
    On Error Resume Next
    Dim lastRow As Long, r As Long, i As Long
    Dim priority As String
    lastRow = LastUsedRow(oSheet)
    oSheet.getCellRangeByPosition(0, 0, 9, 0).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 0, 9, 0).CellBackColor = RGB(217, 217, 217)

    For r = 1 To lastRow
        priority = CellText(oSheet, 0, r)
        Select Case priority
            Case "P1"
                oSheet.getCellRangeByPosition(0, r, 9, r).CellBackColor = RGB(255, 199, 206)
            Case "P2"
                oSheet.getCellRangeByPosition(0, r, 9, r).CellBackColor = RGB(255, 242, 204)
            Case "P3"
                oSheet.getCellRangeByPosition(0, r, 9, r).CellBackColor = RGB(226, 239, 218)
        End Select
    Next r

    For i = 0 To 9
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i
    ApplyOptionalAutoFilter oSheet, 9, lastRow
    On Error GoTo 0
End Sub

Public Sub FormatAuditLog(oSheet As Object)
    On Error Resume Next
    Dim i As Long
    oSheet.getCellRangeByPosition(0, 0, 1, 0).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 0, 1, 0).CellBackColor = RGB(217, 217, 217)
    For i = 0 To 1
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i
    On Error GoTo 0
End Sub

Public Sub FormatDashboard(oSheet As Object)
    On Error Resume Next
    Dim i As Long
    oSheet.getCellRangeByPosition(0, 0, 1, 0).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 0, 1, 0).CellBackColor = RGB(180, 198, 231)
    oSheet.getCellRangeByPosition(0, 2, 1, 2).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 4, 1, 4).CharWeight = 150
    oSheet.getCellRangeByPosition(0, 13, 1, 13).CharWeight = 150
    For i = 0 To 1
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i
    On Error GoTo 0
End Sub

Public Sub FormatReport(oSheet As Object, lastRow As Long)
    Dim oHeader As Object, oRange As Object
    Dim r As Long, statusValue As String
    Dim i As Long

    If lastRow < 0 Then lastRow = 0

    oHeader = oSheet.getCellRangeByPosition(0, 0, CF_LAST_REPORT_COL, 0)
    oHeader.CharWeight = 150
    oHeader.CellBackColor = RGB(217, 217, 217)

    For r = 1 To lastRow
        statusValue = CellText(oSheet, CF_COL_TYPE, r)
        oRange = oSheet.getCellRangeByPosition(0, r, CF_LAST_REPORT_COL, r)
        Select Case statusValue
            Case CF_STATUS_ADDED
                oRange.CellBackColor = RGB(226, 239, 218)
            Case CF_STATUS_REMOVED
                oRange.CellBackColor = RGB(252, 228, 214)
            Case CF_STATUS_CHANGED
                oRange.CellBackColor = RGB(255, 242, 204)
            Case CF_STATUS_DUPLICATE
                oRange.CellBackColor = RGB(248, 203, 173)
            Case CF_STATUS_ERROR
                oRange.CellBackColor = RGB(255, 199, 206)
        End Select
    Next r

    For i = 0 To CF_LAST_REPORT_COL
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i

    ApplyOptionalAutoFilter oSheet, CF_LAST_REPORT_COL, lastRow
End Sub

Public Sub FormatStats(oSheet As Object, lastRow As Long)
    Dim oHeader As Object
    Dim i As Long

    oHeader = oSheet.getCellRangeByPosition(0, 0, 8, 0)
    oHeader.CharWeight = 150
    oHeader.CellBackColor = RGB(217, 217, 217)

    For i = 0 To 8
        oSheet.Columns.getByIndex(i).OptimalWidth = True
    Next i
End Sub

Public Sub ApplyOptionalAutoFilter(oSheet As Object, lastCol As Long, lastRow As Long)
    On Error GoTo SkipFilter
    Dim oRange As Object
    oRange = oSheet.getCellRangeByPosition(0, 0, lastCol, lastRow)
    oRange.AutoFilter = True
SkipFilter:
    On Error GoTo 0
End Sub

'=========================================================
' V1.3 - HTML REPORT EXPORT
'=========================================================

Public Sub ExporterRapportHTML()
    On Error GoTo ErrHandler

    Dim oDoc As Object
    Dim sUrl As String
    Dim sPath As String
    Dim sHtml As String

    oDoc = ThisComponent
    sPath = GetDocumentFolderPath()
    If sPath = "" Then
        MsgBox "Impossible de déterminer le dossier du classeur. Enregistre d'abord le fichier LibreOffice.", 48, "CompareFramework"
        Exit Sub
    End If

    sUrl = sPath & "/Rapport_Comparaison.html"

    sHtml = BuildHtmlReport(oDoc)
    WriteTextFile sUrl, sHtml

    MsgBox "Rapport HTML généré :" & Chr(10) & ConvertFromURL(sUrl), 64, "CompareFramework V1.3"
    Exit Sub

ErrHandler:
    MsgBox "Erreur ExporterRapportHTML : " & Err & " - " & Error$, 16, "CompareFramework"
End Sub

Public Function BuildHtmlReport(oDoc As Object) As String
    Dim s As String

    s = ""
    s = s & "<!DOCTYPE html>" & Chr(10)
    s = s & "<html lang=""fr"">" & Chr(10)
    s = s & "<head>" & Chr(10)
    s = s & "<meta charset=""utf-8"">" & Chr(10)
    s = s & "<meta name=""viewport"" content=""width=device-width, initial-scale=1"">" & Chr(10)
    s = s & "<title>Rapport de comparaison</title>" & Chr(10)
    s = s & HtmlStyleBlock()
    s = s & HtmlScriptBlock()
    s = s & "</head>" & Chr(10)
    s = s & "<body>" & Chr(10)
    s = s & "<header>" & Chr(10)
    s = s & "<h1>Rapport de comparaison</h1>" & Chr(10)
    s = s & "<p>Généré par CompareFramework V1.3 le " & HtmlEscape(Now) & "</p>" & Chr(10)
    s = s & "</header>" & Chr(10)

    s = s & "<nav>" & Chr(10)
    s = s & "<a href=""#synthese"">Synthèse</a>" & Chr(10)
    s = s & "<a href=""#stats"">Statistiques</a>" & Chr(10)
    s = s & "<a href=""#rapport"">Détail</a>" & Chr(10)
    s = s & "<a href=""#actions"">Plan d'action</a>" & Chr(10)
    s = s & "<a href=""#journal"">Journal</a>" & Chr(10)
    s = s & "</nav>" & Chr(10)

    s = s & SheetToHtmlSection(oDoc, "Synthese_Comparaison", "synthese", "Synthèse globale", False)
    s = s & SheetToHtmlSection(oDoc, "Stats_Comparaison", "stats", "Statistiques", False)

    s = s & "<section id=""rapport"">" & Chr(10)
    s = s & "<h2>Détail des différences</h2>" & Chr(10)
    s = s & "<div class=""toolbar"">" & Chr(10)
    s = s & "<input id=""filterInput"" type=""search"" placeholder=""Filtrer dans le rapport..."" onkeyup=""filterTable('rapportTable', this.value)"">" & Chr(10)
    s = s & "</div>" & Chr(10)
    s = s & SheetToHtmlTableOnly(oDoc, "Rapport_Comparaison", "rapportTable", True)
    s = s & "</section>" & Chr(10)

    s = s & SheetToHtmlSection(oDoc, "Plan_Action_Comparaison", "actions", "Plan d'action", True)
    s = s & SheetToHtmlSection(oDoc, "Journal_Comparaison", "journal", "Journal", False)

    s = s & "<footer>CompareFramework V1.3</footer>" & Chr(10)
    s = s & "</body>" & Chr(10)
    s = s & "</html>" & Chr(10)

    BuildHtmlReport = s
End Function

Public Function HtmlStyleBlock() As String
    Dim s As String

    s = ""
    s = s & "<style>" & Chr(10)
    s = s & "body{font-family:Arial,sans-serif;margin:0;background:#f6f7fb;color:#1f2937;}" & Chr(10)
    s = s & "header{background:#111827;color:white;padding:24px 32px;}" & Chr(10)
    s = s & "header h1{margin:0 0 8px 0;font-size:28px;}" & Chr(10)
    s = s & "header p{margin:0;color:#d1d5db;}" & Chr(10)
    s = s & "nav{position:sticky;top:0;background:white;border-bottom:1px solid #e5e7eb;padding:10px 32px;z-index:5;}" & Chr(10)
    s = s & "nav a{margin-right:16px;color:#2563eb;text-decoration:none;font-weight:bold;}" & Chr(10)
    s = s & "section{margin:24px 32px;background:white;border:1px solid #e5e7eb;border-radius:10px;padding:18px;box-shadow:0 1px 2px rgba(0,0,0,.04);}" & Chr(10)
    s = s & "h2{margin-top:0;font-size:22px;}" & Chr(10)
    s = s & ".toolbar{margin:0 0 12px 0;}" & Chr(10)
    s = s & "input[type=search]{width:100%;max-width:520px;padding:10px;border:1px solid #d1d5db;border-radius:8px;}" & Chr(10)
    s = s & ".table-wrap{overflow:auto;max-height:70vh;border:1px solid #e5e7eb;border-radius:8px;}" & Chr(10)
    s = s & "table{border-collapse:collapse;width:100%;font-size:13px;}" & Chr(10)
    s = s & "th,td{border-bottom:1px solid #e5e7eb;padding:8px 10px;text-align:left;vertical-align:top;white-space:nowrap;}" & Chr(10)
    s = s & "th{position:sticky;top:0;background:#f3f4f6;z-index:2;}" & Chr(10)
    s = s & "tr:hover td{background:#f9fafb;}" & Chr(10)
    s = s & ".tag-ajout{background:#dcfce7;color:#166534;font-weight:bold;}" & Chr(10)
    s = s & ".tag-suppression{background:#fee2e2;color:#991b1b;font-weight:bold;}" & Chr(10)
    s = s & ".tag-modification{background:#fef3c7;color:#92400e;font-weight:bold;}" & Chr(10)
    s = s & ".tag-p1{background:#fee2e2;color:#991b1b;font-weight:bold;}" & Chr(10)
    s = s & ".tag-p2{background:#fef3c7;color:#92400e;font-weight:bold;}" & Chr(10)
    s = s & ".tag-p3{background:#dbeafe;color:#1e40af;font-weight:bold;}" & Chr(10)
    s = s & ".missing{color:#6b7280;font-style:italic;}" & Chr(10)
    s = s & "footer{margin:24px 32px;color:#6b7280;font-size:12px;}" & Chr(10)
    s = s & "</style>" & Chr(10)

    HtmlStyleBlock = s
End Function

Public Function HtmlScriptBlock() As String
    Dim s As String

    s = ""
    s = s & "<script>" & Chr(10)
    s = s & "function filterTable(id,q){q=q.toLowerCase();var t=document.getElementById(id);if(!t)return;var r=t.getElementsByTagName('tr');for(var i=1;i<r.length;i++){var txt=r[i].innerText.toLowerCase();r[i].style.display=txt.indexOf(q)>=0?'':'none';}}" & Chr(10)
    s = s & "</script>" & Chr(10)

    HtmlScriptBlock = s
End Function

Public Function SheetToHtmlSection(oDoc As Object, sSheetName As String, sAnchor As String, sTitle As String, bFilter As Boolean) As String
    Dim s As String
    s = "<section id=""" & HtmlEscape(sAnchor) & """>" & Chr(10)
    s = s & "<h2>" & HtmlEscape(sTitle) & "</h2>" & Chr(10)

    If bFilter Then
        s = s & "<div class=""toolbar"">" & Chr(10)
        s = s & "<input type=""search"" placeholder=""Filtrer..."" onkeyup=""filterTable('" & HtmlEscape(sAnchor) & "Table', this.value)"">" & Chr(10)
        s = s & "</div>" & Chr(10)
    End If

    s = s & SheetToHtmlTableOnly(oDoc, sSheetName, sAnchor & "Table", True)
    s = s & "</section>" & Chr(10)

    SheetToHtmlSection = s
End Function

Public Function SheetToHtmlTableOnly(oDoc As Object, sSheetName As String, sTableId As String, bHeader As Boolean) As String
    On Error GoTo MissingSheet

    Dim oSheet As Object
    Dim oCursor As Object
    Dim lastRow As Long
    Dim lastCol As Long
    Dim r As Long
    Dim c As Long
    Dim cellText As String
    Dim s As String

    If Not oDoc.Sheets.hasByName(sSheetName) Then GoTo MissingSheet

    oSheet = oDoc.Sheets.getByName(sSheetName)
    oCursor = oSheet.createCursor()
    oCursor.gotoEndOfUsedArea(True)
    lastRow = oCursor.RangeAddress.EndRow
    lastCol = oCursor.RangeAddress.EndColumn

    s = "<div class=""table-wrap"">" & Chr(10)
    s = s & "<table id=""" & HtmlEscape(sTableId) & """>" & Chr(10)

    For r = 0 To lastRow
        s = s & "<tr>"
        For c = 0 To lastCol
            cellText = CStr(oSheet.getCellByPosition(c, r).String)
            If r = 0 And bHeader Then
                s = s & "<th>" & HtmlEscape(cellText) & "</th>"
            Else
                s = s & "<td class=""" & HtmlCssClassForCell(cellText) & """>" & HtmlEscape(cellText) & "</td>"
            End If
        Next c
        s = s & "</tr>" & Chr(10)
    Next r

    s = s & "</table>" & Chr(10)
    s = s & "</div>" & Chr(10)

    SheetToHtmlTableOnly = s
    Exit Function

MissingSheet:
    SheetToHtmlTableOnly = "<p class=""missing"">Feuille absente : " & HtmlEscape(sSheetName) & "</p>" & Chr(10)
End Function

Public Function HtmlCssClassForCell(sValue As String) As String
    Dim s As String
    s = UCase(Trim(sValue))

    If s = "AJOUT" Or s = "AJOUTEE" Or s = "AJOUTÉE" Or s = "ADDED" Then
        HtmlCssClassForCell = "tag-ajout"
    ElseIf s = "SUPPRESSION" Or s = "SUPPRIMEE" Or s = "SUPPRIMÉE" Or s = "DELETED" Then
        HtmlCssClassForCell = "tag-suppression"
    ElseIf s = "MODIFICATION" Or s = "MODIFIEE" Or s = "MODIFIÉE" Or s = "CHANGED" Then
        HtmlCssClassForCell = "tag-modification"
    ElseIf s = "P1" Then
        HtmlCssClassForCell = "tag-p1"
    ElseIf s = "P2" Then
        HtmlCssClassForCell = "tag-p2"
    ElseIf s = "P3" Then
        HtmlCssClassForCell = "tag-p3"
    Else
        HtmlCssClassForCell = ""
    End If
End Function

