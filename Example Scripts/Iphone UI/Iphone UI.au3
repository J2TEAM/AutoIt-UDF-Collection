#include <GDIPlus.au3>
#include <WindowsConstants.au3>
#include <GuiConstantsEx.au3>
#include <StaticConstants.au3>
#include <WinAPISys.au3>
#include "UDFs\GUICtrlPic.au3"
#include "UDFs\NetInfo.au3"
#include "UDFs\GIFAnimation.au3"
#include <winapiex.au3>
#include <WinAPIRes.au3>

Global $SW = 450
Global $SH = 800

Global $Lock = True
Global $Flag
$hold_cursor = _WinAPI_CopyCursor(_WinAPI_LoadCursor(0, $OCR_NORMAL))
$hnew_Cursor = _WinAPI_LoadCursorFromFile(@ScriptDir & "\Resources\game.cur")

$Count = 1

Global $GUI = GUICreate("ControlGUI", 450, 850, -1, -1, $WS_POPUP, $WS_EX_LAYERED + $WS_EX_TOPMOST)
GUISetBkColor(0xFAFAFA)

_GUICtrlPic_Create("Resources\Black.png", 0, 0, 450, 850)
GUICtrlSetState(-1, $GUI_DISABLE)

_GUICtrlPic_Create("Resources\Back.jpg", 32, 118, 388, 615)
GUICtrlSetState(-1, $GUI_DISABLE)

_GUICtrlPic_Create("Resources\glare.png", 180, 8, 260, 550)
GUICtrlSetState(-1, $GUI_DISABLE)


$Time = GUICtrlCreateLabel(@HOUR & ":" & @MIN, 100, 160, 250, 150)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 60, 0, 0, "HelveticaNeueLTStd-UltLt")

$Date = GUICtrlCreateLabel(_GetTodaysDate(), 145, 270, 300, 50)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 12, 500, 0, "HelveticaNeueLTStd-UltLt")

For $i = 0 To 3
	_GUICtrlPic_Create("Resources\SignalFull.png", 45 + $i * 15, 130, 12, 12)
	GUICtrlSetState(-1, $GUI_DISABLE)
Next
_GUICtrlPic_Create("Resources\SignalNull.png", 45 + 4 * 15, 130, 12, 12)
GUICtrlSetState(-1, $GUI_DISABLE)

$ISP = _NetInfo_GetISP()
$ChargeLabel = GUICtrlCreateLabel($ISP, 130, 127, 200, 20)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 10, 100, 0, "HelveticaNeueLTStd-UltLt")


_GUICtrlPic_Create("Resources\wifi.png", 135 + StringLen($ISP) * 10, 128, 20, 15)
GUICtrlSetState(-1, $GUI_DISABLE)



_GUICtrlPic_Create("Resources\Battery.png", 355, 125, 60, 20)
GUICtrlSetState(-1, $GUI_DISABLE)

$Charge = _GUICtrlPic_Create("Resources\charge.png", 356, 125, 42, 20)
GUICtrlSetState(-1, $GUI_DISABLE)

Local $Data = _WinAPI_GetSystemPowerStatus()
$ChargeLabel = GUICtrlCreateLabel("  0%", 310, 125, 50, 20)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 10, 100, 0, "HelveticaNeueLTStd-UltLt")

If $Data[2] < 10 Then
	GUICtrlSetData($ChargeLabel, "  " & $Data[2] & "%")
ElseIf $Data[2] < 100 Then
	GUICtrlSetData($ChargeLabel, " " & $Data[2] & "%")
Else
	GUICtrlSetData($ChargeLabel, $Data[2] & "%")
EndIf



$SlideBack = _GUICtrlPic_Create("Resources\Slide Unlock.png", 31, 643, 389, 90)
GUICtrlSetState(-1, $GUI_DISABLE)

$SlideText = _GUICtrlCreateGIF("Resources\Slide Unlock.gif", "", 152, 678, 180, 20)
GUICtrlSetState(-1, $GUI_DISABLE)

$Slider = _GUICtrlPic_Create("Resources\Slide Button.png", 58, 669, 60, 40)

$HomeButton=_GUICtrlPic_Create("Resources\home btn.png", 189, 752, 75, 70)
GUICtrlSetState(-1, $GUI_DISABLE)




_WinAPI_SetLayeredWindowAttributes($GUI, 0xFAFAFA, 255)
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")



GUISetState()


AdlibRegister("UpdateComponent", 4500)
AdlibRegister("LockScreen", 1000)

While 1

	$MINFO = GUIGetCursorInfo($GUI)
	$msg = GUIGetMsg()
	Switch $msg
		Case $GUI_EVENT_CLOSE
			_WinAPI_SetSystemCursor($hold_cursor, $OCR_NORMAL)
			_WinAPI_DestroyCursor($hnew_Cursor)
			_WinAPI_DestroyCursor($hold_cursor)
			Exit

	EndSwitch

	If _CheckMouseOver() = True Then
		If $Flag Then
			_WinAPI_SetSystemCursor($hnew_Cursor, $OCR_NORMAL, 1)
			$Flag = False
		EndIf
	Else
		If Not $Flag Then
			_WinAPI_SetSystemCursor($hold_cursor, $OCR_NORMAL, 1)
			$Flag = True
		EndIf
	EndIf



	If $MINFO[4] = $Slider Then
		$POS = 1
		$MINFO = GUIGetCursorInfo($GUI)
		While $MINFO[4] = $SLIDER
			$MINFO = GUIGetCursorInfo($GUI)
			If $MINFO[2] = 1 Then

				If GUICtrlGetState($SlideText) <> $GUI_HIDE Then GUICtrlSetState($SlideText, $GUI_HIDE)

				$MINFO = GUIGetCursorInfo($GUI)
				$MPOS = MouseGetPos()
				$CONTROLPOS = $MPOS[0] - 60

				While $MINFO[2] = 1

					$MINFO = GUIGetCursorInfo($GUI)
					$POS = MouseGetPos()
					$POS = $POS[0] - $CONTROLPOS
					If $POS <= 58 Then
						ControlMove($GUI, "", $SLIDER, 58, 669)
					ElseIf $POS >= 330 Then
						$POS = 330
						ControlMove($GUI, "", $SLIDER, 330, 669)
						_SLIDEFULL()
						ExitLoop

					Else
						ControlMove($GUI, "", $SLIDER, $POS, 669)

					EndIf
					Sleep(5)
				WEnd

				Do
					ControlMove($GUI, "", $SLIDER, $POS, 669)
					$POS = $POS - 25
					Sleep(5)
				Until $POS <= 58
				ControlMove($GUI, "", $SLIDER, 58, 669)

				If $Lock = True Then GUICtrlSetState($SlideText, $GUI_SHOW)
			EndIf
			Sleep(10)
		WEnd
	Else

	EndIf

	If $Lock = True Then Lock()
WEnd

Func Lockscreen()
	If $Count > 5 Then $Count = 1
	If $Lock = True Then $Count = 1
	If $Lock = False Then $Count += 1
	If $Count == 5 Then $Lock = True
EndFunc   ;==>Lockscreen


Func _SLIDEFULL()
	$Lock = False
	Unlock()
EndFunc   ;==>_SLIDEFULL

Func Unlock()
	GUICtrlSetState($Slider, $GUI_HIDE)
	GUICtrlSetState($Time, $GUI_HIDE)
	GUICtrlSetState($Date, $GUI_HIDE)
	GUICtrlSetState($SlideBack, $GUI_HIDE)
	GUICtrlSetState($SlideText, $GUI_HIDE)
EndFunc   ;==>Unlock

Func Lock()
	If GUICtrlGetState($Slider) <> 80 Then
		GUICtrlSetState($Slider, $GUI_SHOW)
		GUICtrlSetState($Time, $GUI_SHOW)
		GUICtrlSetState($Date, $GUI_SHOW)
		GUICtrlSetState($SlideBack, $GUI_SHOW)
		GUICtrlSetState($SlideText, $GUI_SHOW)
	EndIf
EndFunc   ;==>Lock

Func _GetTodaysDate()
	Local $aMDay[8] = [7, "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], _
			$aMonth[13] = [12, "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], $aTime[2] = ["", ' ' & @HOUR & ':' & @MIN & ':' & '00']
	Return $aMDay[@WDAY] & ', ' & $aMonth[@MON] & ' ' & @MDAY
EndFunc   ;==>_GetTodaysDate

Func UpdateComponent()
	Local $Data = _WinAPI_GetSystemPowerStatus()
	GUICtrlSetData($Time, @HOUR & ":" & @MIN)
	GUICtrlSetData($Date, _GetTodaysDate())
	_GUICtrlPic_SetImage($Charge, "charge.png", 42 * $Data[2] / 100, 20)
	If $Data[2] < 10 Then
		GUICtrlSetData($ChargeLabel, "  " & $Data[2] & "%")
	ElseIf $Data[2] < 100 Then
		GUICtrlSetData($ChargeLabel, " " & $Data[2] & "%")
	Else
		GUICtrlSetData($ChargeLabel, $Data[2] & "%")
	EndIf

EndFunc   ;==>UpdateComponent

Func _CheckMouseOver()
	Local $RET = False
	If WinActive($GUI) Then
		Local $aMousePos = MouseGetPos()
		Local $aGuiPos = WinGetPos($GUI)
		If ($aMousePos[0] > $aGuiPos[0]) And ($aMousePos[0] < ($aGuiPos[0] + $aGuiPos[2])) And _
				($aMousePos[1] > $aGuiPos[1]) And ($aMousePos[1] < ($aGuiPos[1] + $aGuiPos[3])) Then
			$RET = True
		EndIf
	EndIf
	Return $RET
EndFunc   ;==>_CheckMouseOver


Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
	If ($iMsg = $WM_NCHITTEST) Then
		Return $HTCAPTION
	EndIf
EndFunc   ;==>WM_NCHITTEST

