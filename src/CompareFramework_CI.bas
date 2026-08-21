Option Explicit

' Technical CI-only runtime smoke entrypoint.
' This procedure is intentionally outside CompareFramework_API.bas.
Public Sub CF_CI_RuntimeSmoke()
    Dim oDoc As Object
    Dim oSheets As Object
    Dim oSheet As Object

    oDoc = ThisComponent
    oSheets = oDoc.Sheets

    If oSheets.hasByName("CompareFramework_CI") Then
        oSheet = oSheets.getByName("CompareFramework_CI")
    Else
        oSheets.insertNewByName("CompareFramework_CI", oSheets.getCount())
        oSheet = oSheets.getByName("CompareFramework_CI")
    End If

    oSheet.getCellRangeByName("A1").String = "STATUS"
    oSheet.getCellRangeByName("B1").String = "OK"
    oSheet.getCellRangeByName("A2").String = "MARKER"
    oSheet.getCellRangeByName("B2").String = "COMPAREFRAMEWORK_CI_SMOKE_OK"
End Sub

' Technical CI-only functional scenario entrypoint.
' It invokes the real reference-mode comparison path and restores global state.
Public Sub CF_CI_RunScenario()
    Dim previousSilent As Boolean
    Dim previousMode As String
    Dim previousSelected As String

    On Error GoTo Cleanup

    previousSilent = CF_REFERENCE_SILENT
    previousMode = CF_REFERENCE_TARGET_MODE
    previousSelected = CF_REFERENCE_SELECTED_TARGETS

    CF_REFERENCE_SILENT = True
    CF_REFERENCE_TARGET_MODE = "SELECTED"
    CF_REFERENCE_SELECTED_TARGETS = "TARGET"

    CF_RunAgainstReference "MODELE", "ProductId"

Cleanup:
    CF_REFERENCE_SILENT = previousSilent
    CF_REFERENCE_TARGET_MODE = previousMode
    CF_REFERENCE_SELECTED_TARGETS = previousSelected
End Sub
