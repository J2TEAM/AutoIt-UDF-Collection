#include <Array.au3>
Dim $reg1[1]
Global $reg1
_RegSubKeysSubVals("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", $reg1)

$reg1[0] = UBound($reg1) - 1
_ArrayDisplay($reg1, $reg1[0])
;~   For $i = 1 To $reg1[0] ; Loop through the array returned by StringSplit to display the individual values.
;~         MsgBox(0, "", "$aArray[" & $i & "] - " & $reg1[$i])
;~     Next
Func _RegSubKeysSubVals($startkey, ByRef $array)
    $line=0
    While 1
        $line += 1
        $reg = RegEnumVal($startkey, $line)
        If @error Then ExitLoop
        $data = RegRead($startkey, $reg)
        _ArrayAdd($array, $reg & "=" & $data)
    WEnd
    $line=0
    While 1
        $line += 1
        $reg = RegEnumKey($startkey, $line)
        If @error Then ExitLoop
        _ArrayAdd($array, "[" & $startkey & "\" & $reg & "]")
        _RegSubkeys($startkey & "\" & $reg, $array)
    WEnd
EndFunc
Func _RegSubkeys($startkey, ByRef $array)
    $line=1
    While 1
        $reg = RegEnumKey($startkey, $line)
        If @error = -1 Then ExitLoop
        _ArrayAdd($array, $reg)
        _RegSubkeys($startkey & "\" & $reg, $array)
        $line += 1
    WEnd
EndFunc