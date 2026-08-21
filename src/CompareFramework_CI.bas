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
