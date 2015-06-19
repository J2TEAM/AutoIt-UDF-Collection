#NoTrayIcon
HotKeySet("{ESC}", "ExitAuto")
HotKeySet("p", "PauseAuto")
Global $pause = 0
Global $checkpos
Global $istrap = 0
Global $message = ""
$left = 100
$top = 100
$right = 300
$bottom = 300

While 1
	Sleep(77)
	$checkpos = MouseGetPos()
	ToolTip(@SEC & @MSEC & " - " & $checkpos[0] & "/" & $checkpos[1] & $message, 0, 0)
	If $checkpos[0] > $left And $checkpos[1] > $top And $checkpos[0] < $right And $checkpos[1] < $bottom Then $istrap = 1
	If $istrap Then
		$message = " Dính Bẫy"
		If $checkpos[0] < $left Or $checkpos[1] < $top Or $checkpos[0] > $right Or $checkpos[1] > $bottom Then
			$message &= @LF & "Cố thoát"
			If $checkpos[0] < $left Then MouseMove($left, $checkpos[1], 1)
			If $checkpos[1] < $top Then MouseMove($checkpos[0], $top, 1)
			If $checkpos[0] > $right Then MouseMove($right, $checkpos[1], 1)
			If $checkpos[1] > $bottom Then MouseMove($checkpos[0], $bottom, 1)
		EndIf
	Else
		$message = " Tự Do"
	EndIf
WEnd

Func pauseauto()
	$pause = Not $pause
	While $pause
		ToolTip("Pause", 0, 0)
	WEnd
	$istrap = 0
EndFunc   ;==>pauseauto

Func exitauto()
	Exit
EndFunc   ;==>exitauto
