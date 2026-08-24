Option Explicit

'=========================================================
' CompareFramework - Typed comparators
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

Private Function CF_ComparatorTypeForHeader(headerName As String, oldRaw As Variant, newRaw As Variant) As String
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

Private Function CF_TextEqual(a As Variant, b As Variant, ByRef detail As String) As Boolean
    Dim sa As String, sb As String
    sa = NormalizeCompareValue(CStr(a))
    sb = NormalizeCompareValue(CStr(b))
    detail = "TEXT"
    CF_TextEqual = (sa = sb)
End Function

Private Function CF_NumberEqual(a As Variant, b As Variant, tolerance As Double, ByRef detail As String) As Boolean
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

Private Function CF_DateEqual(a As Variant, b As Variant, toleranceDays As Double, ByRef detail As String) As Boolean
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

Private Function CF_BooleanEqual(a As Variant, b As Variant, ByRef detail As String) As Boolean
    Dim ba As Integer, bb As Integer
    ba = CF_BooleanCode(a)
    bb = CF_BooleanCode(b)
    detail = "BOOLEAN " & CStr(ba) & "/" & CStr(bb)
    CF_BooleanEqual = (ba >= 0 And bb >= 0 And ba = bb)
End Function

Private Function CF_LooksNumeric(v As Variant) As Boolean
    Dim d As Double
    CF_LooksNumeric = CF_TryParseNumber(v, d)
End Function

Private Function CF_LooksDate(v As Variant) As Boolean
    Dim d As Double, s As String
    s = Trim(CStr(v))
    If s = "" Then CF_LooksDate = False : Exit Function
    If InStr(s, "/") = 0 And InStr(s, "-") = 0 And InStr(s, ".") = 0 Then CF_LooksDate = False : Exit Function
    CF_LooksDate = CF_TryParseDateSerial(v, d)
End Function

Private Function CF_LooksBoolean(v As Variant) As Boolean
    CF_LooksBoolean = (CF_BooleanCode(v) >= 0)
End Function

Private Function CF_TryParseNumber(v As Variant, ByRef result As Double) As Boolean
    On Error GoTo Fail
    If CF_TryParseCanonicalNumber(Trim(CStr(v)), result) Then
        CF_TryParseNumber = True
        Exit Function
    End If
    If CF_TryParseLegacyPrefixMarkerNumber(Trim(CStr(v)), result) Then
        CF_TryParseNumber = True
        Exit Function
    End If
    If CF_TryParseStrictLegacyScientificNumber(Trim(CStr(v)), result) Then
        CF_TryParseNumber = True
        Exit Function
    End If
    If CF_HasInvalidPreFallbackNumberSyntax(Trim(CStr(v))) Then GoTo Fail
    If IsNumeric(v) Then
        result = CDbl(v)
        CF_TryParseNumber = True
        Exit Function
    End If
    result = CDbl(CF_NormalizeLegacyNumber(Trim(CStr(v))))
    CF_TryParseNumber = True
    Exit Function
Fail:
    result = 0
    CF_TryParseNumber = False
End Function

Private Function CF_TryParseDateSerial(v As Variant, ByRef result As Double) As Boolean
    On Error GoTo Fail
    If CF_TryParseCanonicalDate(Trim(CStr(v)), result) Then
        CF_TryParseDateSerial = True
        Exit Function
    End If
    If CF_HasCanonicalDateShape(Trim(CStr(v))) Then GoTo Fail
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

Private Function CF_TryParseDigits(valueText As String, ByRef result As Double) As Boolean
    Dim i As Long, digit As Long

    If valueText = "" Then Exit Function
    result = 0
    For i = 1 To Len(valueText)
        digit = Asc(Mid(valueText, i, 1)) - Asc("0")
        If digit < 0 Or digit > 9 Then Exit Function
        result = result * 10 + digit
    Next i
    CF_TryParseDigits = True
End Function

Private Function CF_TryParseCanonicalNumber(valueText As String, ByRef result As Double) As Boolean
    Dim s As String, wholeText As String, fractionText As String
    Dim decimalAt As Long, wholeValue As Double, fractionValue As Double
    Dim scale As Double, signValue As Double, i As Long, ch As String

    s = Replace(Replace(Trim(valueText), Chr(160), ""), " ", "")
    If s = "" Then Exit Function
    If CF_IsNumericMarker(Right(s, 1)) Then s = Left(s, Len(s) - 1)
    If s = "" Then Exit Function

    signValue = 1
    If Left(s, 1) = "-" Then
        signValue = -1
        s = Mid(s, 2)
    ElseIf Left(s, 1) = "+" Then
        s = Mid(s, 2)
    End If
    If s = "" Then Exit Function

    For i = 1 To Len(s)
        ch = Mid(s, i, 1)
        If ch = "." Or ch = "," Then
            If decimalAt > 0 Then Exit Function
            decimalAt = i
        ElseIf ch < "0" Or ch > "9" Then
            Exit Function
        End If
    Next i

    wholeText = s
    fractionText = ""
    If decimalAt > 0 Then
        wholeText = Left(s, decimalAt - 1)
        fractionText = Mid(s, decimalAt + 1)
    End If
    If Not CF_TryParseDigits(wholeText, wholeValue) Then Exit Function
    scale = 1
    If fractionText <> "" Then
        If Not CF_TryParseDigits(fractionText, fractionValue) Then Exit Function
        For i = 1 To Len(fractionText)
            scale = scale * 10
        Next i
    ElseIf decimalAt > 0 Then
        Exit Function
    End If

    result = signValue * (wholeValue + fractionValue / scale)
    CF_TryParseCanonicalNumber = True
End Function

Private Function CF_NormalizeLegacyNumber(valueText As String) As String
    Dim s As String
    s = Replace(Replace(Trim(valueText), Chr(160), ""), " ", "")
    s = Replace(s, "€", "")
    s = Replace(s, "$", "")
    s = Replace(s, "£", "")
    s = Replace(s, "%", "")
    If InStr(s, ",") > 0 And InStr(s, ".") > 0 Then
        If CF_LastCharacterPosition(s, ",") > CF_LastCharacterPosition(s, ".") Then
            s = Replace(s, ".", "")
            s = Replace(s, ",", ".")
        Else
            s = Replace(s, ",", "")
        End If
    ElseIf InStr(s, ",") > 0 Then
        s = Replace(s, ",", ".")
    End If
    CF_NormalizeLegacyNumber = s
End Function

Private Function CF_IsNumericMarker(valueText As String) As Boolean
    CF_IsNumericMarker = (valueText = "€" Or valueText = "$" Or valueText = "£" Or valueText = "%")
End Function

Private Function CF_HasInvalidPreFallbackNumberSyntax(valueText As String) As Boolean
    Dim s As String, parsedValue As Double

    s = Replace(Replace(Trim(valueText), Chr(160), ""), " ", "")
    If Not CF_HasValidNumericMarkers(s) Then
        CF_HasInvalidPreFallbackNumberSyntax = True
        Exit Function
    End If
    If s <> "" And CF_IsNumericMarker(Left(s, 1)) Then s = Mid(s, 2)
    If s <> "" And CF_IsNumericMarker(Right(s, 1)) Then s = Left(s, Len(s) - 1)
    If CF_TryParseCanonicalNumber(s, parsedValue) Then Exit Function
    If CF_TryParseStrictLegacyScientificNumber(s, parsedValue) Then Exit Function
    If InStr(s, "E") > 0 Or InStr(s, "e") > 0 Then
        CF_HasInvalidPreFallbackNumberSyntax = True
        Exit Function
    End If
    If s <> "" And (Left(s, 1) = "-" Or Left(s, 1) = "+") Then s = Mid(s, 2)
    If s = "" Then
        CF_HasInvalidPreFallbackNumberSyntax = True
    ElseIf InStr(s, ".") > 0 Or InStr(s, ",") > 0 Then
        CF_HasInvalidPreFallbackNumberSyntax = Not CF_HasValidLegacyGrouping(s)
    End If
End Function

Private Function CF_HasValidNumericMarkers(valueText As String) As Boolean
    Dim i As Long, markerCount As Long

    For i = 1 To Len(valueText)
        If CF_IsNumericMarker(Mid(valueText, i, 1)) Then
            markerCount = markerCount + 1
            If i <> 1 And i <> Len(valueText) Then Exit Function
        End If
    Next i
    CF_HasValidNumericMarkers = (markerCount <= 1)
End Function

Private Function CF_TryParseLegacyPrefixMarkerNumber(valueText As String, ByRef result As Double) As Boolean
    Dim s As String

    s = Replace(Replace(Trim(valueText), Chr(160), ""), " ", "")
    If s = "" Or Not CF_IsNumericMarker(Left(s, 1)) Then Exit Function
    If Not CF_HasValidNumericMarkers(s) Then Exit Function
    CF_TryParseLegacyPrefixMarkerNumber = CF_TryParseCanonicalNumber(Mid(s, 2), result)
End Function

Private Function CF_TryParseStrictLegacyScientificNumber(valueText As String, ByRef result As Double) As Boolean
    On Error GoTo Fail
    Dim s As String, mantissaText As String, exponentText As String
    Dim exponentAt As Long, i As Long, ch As String
    Dim mantissaValue As Double, exponentValue As Double, exponentNegative As Boolean

    s = Replace(Replace(Trim(valueText), Chr(160), ""), " ", "")
    If Not CF_HasValidNumericMarkers(s) Then Exit Function
    If s <> "" And CF_IsNumericMarker(Left(s, 1)) Then s = Mid(s, 2)
    If s <> "" And CF_IsNumericMarker(Right(s, 1)) Then s = Left(s, Len(s) - 1)
    For i = 1 To Len(s)
        ch = Mid(s, i, 1)
        If ch = "E" Or ch = "e" Then
            If exponentAt > 0 Then GoTo Fail
            exponentAt = i
        End If
    Next i
    If exponentAt = 0 Then GoTo Fail

    mantissaText = Left(s, exponentAt - 1)
    exponentText = Mid(s, exponentAt + 1)
    If exponentText <> "" And Left(exponentText, 1) = "-" Then
        exponentNegative = True
        exponentText = Mid(exponentText, 2)
    ElseIf exponentText <> "" And Left(exponentText, 1) = "+" Then
        exponentText = Mid(exponentText, 2)
    End If
    If Not CF_TryParseDigits(exponentText, exponentValue) Then GoTo Fail
    If exponentValue > 308 Then GoTo Fail

    If Not CF_TryParseCanonicalNumber(mantissaText, mantissaValue) Then GoTo Fail
    result = mantissaValue
    For i = 1 To exponentValue
        If exponentNegative Then
            result = result / 10
        Else
            result = result * 10
        End If
    Next i
    CF_TryParseStrictLegacyScientificNumber = True
    Exit Function
Fail:
    result = 0
End Function

Private Function CF_HasValidLegacyGrouping(valueText As String) As Boolean
    Dim lastDot As Long, lastComma As Long
    Dim integerText As String, fractionText As String, groupingSeparator As String
    Dim fractionValue As Double

    lastDot = CF_LastCharacterPosition(valueText, ".")
    lastComma = CF_LastCharacterPosition(valueText, ",")
    If lastDot > 0 And lastComma > 0 Then
        If lastDot > lastComma Then
            integerText = Left(valueText, lastDot - 1)
            fractionText = Mid(valueText, lastDot + 1)
            groupingSeparator = ","
        Else
            integerText = Left(valueText, lastComma - 1)
            fractionText = Mid(valueText, lastComma + 1)
            groupingSeparator = "."
        End If
        If Not CF_TryParseDigits(fractionText, fractionValue) Then Exit Function
    ElseIf lastDot > 0 Then
        integerText = valueText
        groupingSeparator = "."
    Else
        integerText = valueText
        groupingSeparator = ","
    End If
    CF_HasValidLegacyGrouping = CF_HasValidGroupedInteger(integerText, groupingSeparator)
End Function

Private Function CF_HasValidGroupedInteger(valueText As String, groupingSeparator As String) As Boolean
    Dim parts As Variant, partValue As Double, i As Long

    parts = Split(valueText, groupingSeparator)
    If UBound(parts) < 1 Then Exit Function
    If Len(parts(0)) < 1 Or Len(parts(0)) > 3 Then Exit Function
    If Not CF_TryParseDigits(parts(0), partValue) Then Exit Function
    For i = 1 To UBound(parts)
        If Len(parts(i)) <> 3 Then Exit Function
        If Not CF_TryParseDigits(parts(i), partValue) Then Exit Function
    Next i
    CF_HasValidGroupedInteger = True
End Function

Private Function CF_LastCharacterPosition(valueText As String, character As String) As Long
    Dim i As Long

    For i = Len(valueText) To 1 Step -1
        If Mid(valueText, i, 1) = character Then
            CF_LastCharacterPosition = i
            Exit Function
        End If
    Next i
End Function

Private Function CF_TryParseCanonicalDate(valueText As String, ByRef result As Double) As Boolean
    On Error GoTo Fail
    Dim parts As Variant
    Dim yearValue As Double, monthValue As Double, dayValue As Double
    Dim parsedDate As Date

    If InStr(valueText, "-") > 0 Then
        parts = Split(valueText, "-")
        If UBound(parts) <> 2 Then GoTo Fail
        If Len(parts(0)) <> 4 Or Len(parts(1)) <> 2 Or Len(parts(2)) <> 2 Then GoTo Fail
        If Not CF_TryParseDigits(parts(0), yearValue) Then GoTo Fail
        If Not CF_TryParseDigits(parts(1), monthValue) Then GoTo Fail
        If Not CF_TryParseDigits(parts(2), dayValue) Then GoTo Fail
    ElseIf InStr(valueText, "/") > 0 Then
        parts = Split(valueText, "/")
        If UBound(parts) <> 2 Then GoTo Fail
        If Len(parts(0)) <> 2 Or Len(parts(1)) <> 2 Or Len(parts(2)) <> 4 Then GoTo Fail
        If Not CF_TryParseDigits(parts(0), dayValue) Then GoTo Fail
        If Not CF_TryParseDigits(parts(1), monthValue) Then GoTo Fail
        If Not CF_TryParseDigits(parts(2), yearValue) Then GoTo Fail
    Else
        GoTo Fail
    End If

    parsedDate = DateSerial(CLng(yearValue), CLng(monthValue), CLng(dayValue))
    If Year(parsedDate) <> CLng(yearValue) Or Month(parsedDate) <> CLng(monthValue) Or Day(parsedDate) <> CLng(dayValue) Then GoTo Fail
    result = CDbl(parsedDate)
    CF_TryParseCanonicalDate = True
    Exit Function
Fail:
    result = 0
    CF_TryParseCanonicalDate = False
End Function

Private Function CF_HasCanonicalDateShape(valueText As String) As Boolean
    Dim parts As Variant
    Dim partValue As Double
    If InStr(valueText, "-") > 0 Then
        parts = Split(valueText, "-")
        If UBound(parts) <> 2 Then Exit Function
        If Len(parts(0)) <> 4 Or Len(parts(1)) <> 2 Or Len(parts(2)) <> 2 Then Exit Function
    ElseIf InStr(valueText, "/") > 0 Then
        parts = Split(valueText, "/")
        If UBound(parts) <> 2 Then Exit Function
        If Len(parts(0)) <> 2 Or Len(parts(1)) <> 2 Or Len(parts(2)) <> 4 Then Exit Function
    Else
        Exit Function
    End If
    If Not CF_TryParseDigits(parts(0), partValue) Then Exit Function
    If Not CF_TryParseDigits(parts(1), partValue) Then Exit Function
    If Not CF_TryParseDigits(parts(2), partValue) Then Exit Function
    CF_HasCanonicalDateShape = True
End Function

Private Function CF_BooleanCode(v As Variant) As Integer
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

Private Function CF_PercentToNumber(v As Variant) As Variant
    Dim d As Double, s As String
    s = Trim(CStr(v))
    If CF_TryParseNumber(v, d) Then
        If InStr(s, "%") > 0 Then d = d / 100
        CF_PercentToNumber = d
    Else
        CF_PercentToNumber = v
    End If
End Function

Private Function CF_CurrencyToNumber(v As Variant) As Variant
    Dim d As Double
    If CF_TryParseNumber(v, d) Then CF_CurrencyToNumber = d Else CF_CurrencyToNumber = v
End Function

Private Function CF_GetNumericTolerance() As Double
    CF_GetNumericTolerance = 0.000001
End Function

Private Function CF_GetPercentTolerance() As Double
    CF_GetPercentTolerance = 0.000001
End Function

Private Function CF_GetCurrencyTolerance() As Double
    CF_GetCurrencyTolerance = 0.005
End Function

Private Function CF_GetDateToleranceDays() As Double
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
        MsgBox "Tests comparateurs types : 6/6", 64, "CompareFramework V" & CF_VERSION
    Else
        MsgBox "Tests comparateurs types a controler.", 48, "CompareFramework V" & CF_VERSION
    End If
End Sub
