Option Explicit

'=========================================================
' CompareFramework V3.3 - Typed comparators
' Jalon B: fiabilite des comparaisons
'=========================================================

Public Const CF_TYPE_AUTO As String = "AUTO"
Public Const CF_TYPE_TEXT As String = "TEXT"
Public Const CF_TYPE_NUMBER As String = "NUMBER"
Public Const CF_TYPE_DATE As String = "DATE"
Public Const CF_TYPE_BOOLEAN As String = "BOOLEAN"
Public Const CF_TYPE_PERCENT As String = "PERCENT"
Public Const CF_TYPE_CURRENCY As String = "CURRENCY"

Public Function CF_TypedValuesEqual(oldRaw As Variant, newRaw As Variant, headerName As String, ByRef comparatorUsed As String, ByRef detail As String) As Boolean
    Dim requestedType As String
    Dim configuredType As String
    Dim tolerance As Double
    Dim hasTolerance As Boolean
    Dim configSource As String
    Dim hasConfig As Boolean

    hasConfig = CF_ResolveComparatorConfig(headerName, configuredType, tolerance, hasTolerance, configSource)

    If hasConfig And configuredType <> "" And configuredType <> CF_TYPE_AUTO Then
        requestedType = configuredType
    Else
        requestedType = CF_ComparatorTypeForHeader(headerName, oldRaw, newRaw)
    End If

    comparatorUsed = requestedType
    If hasConfig Then comparatorUsed = comparatorUsed & " [" & configSource & "]"
    detail = ""

    Select Case requestedType
        Case CF_TYPE_BOOLEAN
            CF_TypedValuesEqual = CF_BooleanEqual(oldRaw, newRaw, detail)
        Case CF_TYPE_NUMBER
            If Not hasTolerance Then tolerance = CF_GetNumericTolerance()
            CF_TypedValuesEqual = CF_NumberEqual(oldRaw, newRaw, tolerance, detail)
        Case CF_TYPE_PERCENT
            If Not hasTolerance Then tolerance = CF_GetPercentTolerance()
            CF_TypedValuesEqual = CF_NumberEqual(CF_PercentToNumber(oldRaw), CF_PercentToNumber(newRaw), tolerance, detail)
        Case CF_TYPE_CURRENCY
            If Not hasTolerance Then tolerance = CF_GetCurrencyTolerance()
            CF_TypedValuesEqual = CF_NumberEqual(CF_CurrencyToNumber(oldRaw), CF_CurrencyToNumber(newRaw), tolerance, detail)
        Case CF_TYPE_DATE
            If Not hasTolerance Then tolerance = CF_GetDateToleranceDays()
            CF_TypedValuesEqual = CF_DateEqual(oldRaw, newRaw, tolerance, detail)
        Case Else
            comparatorUsed = CF_TYPE_TEXT
            If hasConfig Then comparatorUsed = comparatorUsed & " [" & configSource & "]"
            CF_TypedValuesEqual = CF_TextEqual(oldRaw, newRaw, detail)
    End Select
End Function

Public Function CF_ComparatorTypeForHeader(headerName As String, oldRaw As Variant, newRaw As Variant) As String
    Dim h As String
    h = UCase(Trim(headerName))

    If InStr(h, "%") > 0 Or InStr(h, "PERCENT") > 0 Or InStr(h, "TAUX") > 0 Then
        CF_ComparatorTypeForHeader = CF_TYPE_PERCENT
    ElseIf InStr(h, "DATE") > 0 Or InStr(h, "ECHEANCE") > 0 Or InStr(h, "ÉCHÉANCE") > 0 Then
        CF_ComparatorTypeForHeader = CF_TYPE_DATE
    ElseIf InStr(h, "MONTANT") > 0 Or InStr(h, "PRIX") > 0 Or InStr(h, "COUT") > 0 Or InStr(h, "COÛT") > 0 Or InStr(h, "DEVISE") > 0 Or InStr(h, "AMOUNT") > 0 Or InStr(h, "PRICE") > 0 Then
        CF_ComparatorTypeForHeader = CF_TYPE_CURRENCY
    ElseIf InStr(h, "ACTIF") > 0 Or InStr(h, "ACTIVE") > 0 Or InStr(h, "BOOLEAN") > 0 Or Left(h, 3) = "IS_" Or Left(h, 4) = "HAS_" Then
        CF_ComparatorTypeForHeader = CF_TYPE_BOOLEAN
    ElseIf CF_LooksBoolean(oldRaw) And CF_LooksBoolean(newRaw) Then
        CF_ComparatorTypeForHeader = CF_TYPE_BOOLEAN
    ElseIf CF_LooksDate(oldRaw) And CF_LooksDate(newRaw) Then
        CF_ComparatorTypeForHeader = CF_TYPE_DATE
    ElseIf CF_LooksNumeric(oldRaw) And CF_LooksNumeric(newRaw) Then
        CF_ComparatorTypeForHeader = CF_TYPE_NUMBER
    Else
        CF_ComparatorTypeForHeader = CF_TYPE_TEXT
    End If
End Function

Public Function CF_TextEqual(a As Variant, b As Variant, ByRef detail As String) As Boolean
    Dim sa As String, sb As String
    sa = NormalizeCompareValue(CStr(a))
    sb = NormalizeCompareValue(CStr(b))
    detail = "TEXT"
    CF_TextEqual = (sa = sb)
End Function

Public Function CF_NumberEqual(a As Variant, b As Variant, tolerance As Double, ByRef detail As String) As Boolean
    Dim da As Double, db As Double, delta As Double
    If Not CF_TryParseNumber(a, da) Or Not CF_TryParseNumber(b, db) Then
        detail = "NUMBER parse impossible"
        CF_NumberEqual = False
        Exit Function
    End If
    delta = Abs(da - db)
    detail = "NUMBER delta=" & CStr(delta) & "; tolerance=" & CStr(tolerance)
    CF_NumberEqual = (delta <= tolerance)
End Function

Public Function CF_DateEqual(a As Variant, b As Variant, toleranceDays As Double, ByRef detail As String) As Boolean
    Dim da As Double, db As Double, delta As Double
    If Not CF_TryParseDateSerial(a, da) Or Not CF_TryParseDateSerial(b, db) Then
        detail = "DATE parse impossible"
        CF_DateEqual = False
        Exit Function
    End If
    delta = Abs(da - db)
    detail = "DATE delta jours=" & CStr(delta) & "; tolerance=" & CStr(toleranceDays)
    CF_DateEqual = (delta <= toleranceDays)
End Function

Public Function CF_BooleanEqual(a As Variant, b As Variant, ByRef detail As String) As Boolean
    Dim ba As Integer, bb As Integer
    ba = CF_BooleanCode(a)
    bb = CF_BooleanCode(b)
    detail = "BOOLEAN " & CStr(ba) & "/" & CStr(bb)
    CF_BooleanEqual = (ba >= 0 And bb >= 0 And ba = bb)
End Function

Public Function CF_LooksNumeric(v As Variant) As Boolean
    Dim d As Double
    CF_LooksNumeric = CF_TryParseNumber(v, d)
End Function

Public Function CF_LooksDate(v As Variant) As Boolean
    Dim d As Double, s As String
    s = Trim(CStr(v))
    If s = "" Then CF_LooksDate = False : Exit Function
    If InStr(s, "/") = 0 And InStr(s, "-") = 0 And InStr(s, ".") = 0 Then CF_LooksDate = False : Exit Function
    CF_LooksDate = CF_TryParseDateSerial(v, d)
End Function

Public Function CF_LooksBoolean(v As Variant) As Boolean
    CF_LooksBoolean = (CF_BooleanCode(v) >= 0)
End Function

Public Function CF_TryParseNumber(v As Variant, ByRef result As Double) As Boolean
    On Error GoTo Fail
    Dim s As String
    If IsNumeric(v) Then result = CDbl(v) : CF_TryParseNumber = True : Exit Function
    s = Trim(CStr(v))
    If s = "" Then GoTo Fail
    s = Replace(s, Chr(160), "")
    s = Replace(s, " ", "")
    s = Replace(s, "€", "")
    s = Replace(s, "$", "")
    s = Replace(s, "£", "")
    s = Replace(s, "%", "")
    If InStr(s, ",") > 0 And InStr(s, ".") > 0 Then
        If InStrRev(s, ",") > InStrRev(s, ".") Then
            s = Replace(s, ".", "")
            s = Replace(s, ",", ".")
        Else
            s = Replace(s, ",", "")
        End If
    ElseIf InStr(s, ",") > 0 Then
        s = Replace(s, ",", ".")
    End If
    result = CDbl(s)
    CF_TryParseNumber = True
    Exit Function
Fail:
    result = 0
    CF_TryParseNumber = False
End Function

Public Function CF_TryParseDateSerial(v As Variant, ByRef result As Double) As Boolean
    On Error GoTo Fail
    If IsDate(v) Then result = CDbl(CDate(v)) : CF_TryParseDateSerial = True : Exit Function
    If IsNumeric(v) Then
        result = CDbl(v)
        CF_TryParseDateSerial = True
        Exit Function
    End If
    result = CDbl(CDate(CStr(v)))
    CF_TryParseDateSerial = True
    Exit Function
Fail:
    result = 0
    CF_TryParseDateSerial = False
End Function

Public Function CF_BooleanCode(v As Variant) As Integer
    Dim s As String
    s = UCase(Trim(CStr(v)))
    Select Case s
        Case "TRUE", "VRAI", "YES", "OUI", "Y", "O", "1", "X", "ACTIVE", "ACTIF"
            CF_BooleanCode = 1
        Case "FALSE", "FAUX", "NO", "NON", "N", "0", "INACTIVE", "INACTIF"
            CF_BooleanCode = 0
        Case Else
            CF_BooleanCode = -1
    End Select
End Function

Public Function CF_PercentToNumber(v As Variant) As Variant
    Dim d As Double, s As String
    s = Trim(CStr(v))
    If CF_TryParseNumber(v, d) Then
        If InStr(s, "%") > 0 Then d = d / 100
        CF_PercentToNumber = d
    Else
        CF_PercentToNumber = v
    End If
End Function

Public Function CF_CurrencyToNumber(v As Variant) As Variant
    Dim d As Double
    If CF_TryParseNumber(v, d) Then CF_CurrencyToNumber = d Else CF_CurrencyToNumber = v
End Function

Public Function CF_GetNumericTolerance() As Double
    CF_GetNumericTolerance = 0.000001
End Function

Public Function CF_GetPercentTolerance() As Double
    CF_GetPercentTolerance = 0.000001
End Function

Public Function CF_GetCurrencyTolerance() As Double
    CF_GetCurrencyTolerance = 0.005
End Function

Public Function CF_GetDateToleranceDays() As Double
    CF_GetDateToleranceDays = 0
End Function

Public Sub CF_RunTypedComparatorTests()
    Dim d As String, c As String
    Dim ok1 As Boolean, ok2 As Boolean, ok3 As Boolean, ok4 As Boolean, ok5 As Boolean, ok6 As Boolean
    ok1 = CF_TypedValuesEqual("Test", "test", "Libelle", c, d)
    ok2 = CF_TypedValuesEqual("10,00", 10, "Quantite", c, d)
    ok3 = CF_TypedValuesEqual("10%", 0.1, "Taux %", c, d)
    ok4 = CF_TypedValuesEqual("100,00 €", 100, "Montant", c, d)
    ok5 = CF_TypedValuesEqual("Oui", "TRUE", "Actif", c, d)
    ok6 = CF_TypedValuesEqual("2026-07-10", "10/07/2026", "Date", c, d)

    If ok1 And ok2 And ok3 And ok4 And ok5 And ok6 Then
        MsgBox "Tests comparateurs types : 6/6", 64, "CompareFramework V3.3"
    Else
        MsgBox "Tests comparateurs types a controler.", 48, "CompareFramework V3.3"
    End If
End Sub
