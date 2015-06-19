#include <Timers.au3>
#include <Constants.au3>

HotKeySet("{ESC}","_Exit")

Global $count


$iBruteLenght=3
$count=0
for $i=1 to $iBruteLenght
		$count+=62^$i
next
$count-=1
$icount=$count
ProgressOn("Progress Meter", "Increments every second")

_BruteForce('__BruteFunc',$iBruteLenght)

while 1
	sleep(100)
wend

Func _BruteForce($sFunktionName = "__BruteFunc", $iBruteLenght = 4, $sCharSet = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

	Local $aBruteArray[$iBruteLenght]
	Local $aCharSet = StringSplit($sCharSet, "", 2)
	Local $iCharSetCount = UBound($aCharSet) - 1
	Local $sBruteString = ""
	__InitBruteArray($aBruteArray)
	ConsoleWrite("Beginne mit Bruteforce" & @CRLF)
	Do
		$sBruteString = ""
		$aBruteArray[0] += 1
		For $i = 0 To $iBruteLenght - 1
			If $aBruteArray[$i] > $iCharSetCount Then
				$aBruteArray[$i] = 0
				$aBruteArray[$i + 1] += 1
			ElseIf $aBruteArray[$i] = -1 Then
				ExitLoop (1)
			EndIf
		Next
		For $i = 0 To $iBruteLenght - 1
			If $aBruteArray[$i] > -1 Then
				$sBruteString &= $aCharSet[$aBruteArray[$i]]
			Else
				ExitLoop 1
			EndIf
		Next
		Call($sFunktionName, $sBruteString,$iBruteLenght)
	Until StringRegExp($sBruteString, "\Q" & $aCharSet[$iCharSetCount] & "\E{" & $iBruteLenght & "}")
	ConsoleWrite("Brute Fore abgeschlossen" & @CRLF)

EndFunc   ;==>_BruteForce

Func __BruteFunc($sString,$iBruteLenght)

ProgressSet(100/$icount*($icount-$count), 'Processed: '&$icount-$count& '/'&$icount&'  current: ' &$sString)

$count-=1

EndFunc   ;==>__BruteFunc


Func __InitBruteArray(ByRef $aBruteArray)
	Dim $sCharSet
	For $i = 0 To UBound($aBruteArray) - 1
		$aBruteArray[$i] = -1
	Next
EndFunc   ;==>__InitBruteArray


Func _Exit()
	Exit
EndFunc


