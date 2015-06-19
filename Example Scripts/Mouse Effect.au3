#NoTrayIcon
#include <Misc.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>

Func _SetCursorState($bValue)
	DllCall('User32.dll', 'int', 'ShowCursor', 'int', $bValue)
EndFunc   ;==>_SetCursorState

Func Dot($mxo, $myo, $color, $size)
	$hPen = _WinAPI_CreatePen($PS_DASH, $size, $color)
	$obj_orig = _WinAPI_SelectObject($hDC, $hPen)
	_WinAPI_DrawLine($hDC, $mxo - 1, $myo - 1, $mxo, $myo)
	_WinAPI_SelectObject($hDC, $obj_orig)
	_WinAPI_DeleteObject($hPen)
EndFunc   ;==>Dot

HotKeySet("{ESC}", "_Exit")
Global Const $pi = 3.14159265358979
Global Const $hFullScreen = WinGetHandle("Program Manager")
Global Const $aFullScreen = WinGetPos($hFullScreen)
Global Const $hGUI = GUICreate("", $aFullScreen[2], $aFullScreen[3], $aFullScreen[0], $aFullScreen[1], $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_TRANSPARENT))
GUISetBkColor(0xABCDEF)
_WinAPI_SetLayeredWindowAttributes($hGUI, 0xABCDEF, 0xA0)
WinSetOnTop($hGUI, "", 1)
GUISetState()

Global Const $hDC = _WinAPI_GetWindowDC($hGUI)
Global Const $user32_dll = DllOpen("user32.dll")

$i = 0
$j = 0
While 1
	While $j < 4
		$i = $i + 0.02
		$j = $j + 1
		$posX = MouseGetPos(0) + Abs($aFullScreen[0])
		$posY = MouseGetPos(1) + Abs($aFullScreen[1])

		$x = $posX + 25 * Cos($i * $pi - $pi / 2 - $pi)
		$y = $posY + 100 * Cos($i * $pi - $pi)
		Dot($x, $y, 0xFF0000, 10)

		$x = $posX + 25 * Cos($i * $pi - $pi / 2 - $pi / 12 - $pi)
		$y = $posY + 100 * Cos($i * $pi - $pi / 12 - $pi)
		Dot($x, $y, 0xFF0000, 20 / 3)

		$x = $posX + 25 * Cos($i * $pi - $pi / 2 - $pi / 6 - $pi)
		$y = $posY + 100 * Cos($i * $pi - $pi / 6 - $pi)
		Dot($x, $y, 0xFF0000, 10 / 3)

		$x = $posX + 25 * Cos($i * $pi - $pi / 2)
		$y = $posY + 100 * Cos($i * $pi)
		Dot($x, $y, 0xFF0000, 10)

		$x = $posX + 25 * Cos($i * $pi - $pi / 2 - $pi / 12)
		$y = $posY + 100 * Cos($i * $pi - $pi / 12)
		Dot($x, $y, 0xFF0000, 20 / 3)

		$x = $posX + 25 * Cos($i * $pi - $pi / 2 - $pi / 6)
		$y = $posY + 100 * Cos($i * $pi - $pi / 6)
		Dot($x, $y, 0xFF0000, 10 / 3)

		$x = $posX + 100 * Cos($i * $pi - $pi) * Sqrt(3) / 2 + 25 * Cos($i * $pi + $pi / 2 - $pi) / 2
		$y = $posY - 100 * Cos($i * $pi - $pi) / 2 + 25 * Cos($i * $pi + $pi / 2 - $pi) * Sqrt(3) / 2
		Dot($x, $y, 0x00FF00, 10)

		$x = $posX + 100 * Cos($i * $pi - $pi / 12 - $pi) * Sqrt(3) / 2 + 25 * Cos($i * $pi + $pi / 2 - $pi / 12 - $pi) / 2
		$y = $posY - 100 * Cos($i * $pi - $pi / 12 - $pi) / 2 + 25 * Cos($i * $pi + $pi / 2 - $pi / 12 - $pi) * Sqrt(3) / 2
		Dot($x, $y, 0x00FF00, 20 / 3)

		$x = $posX + 100 * Cos($i * $pi - $pi / 6 - $pi) * Sqrt(3) / 2 + 25 * Cos($i * $pi + $pi / 2 - $pi / 6 - $pi) / 2
		$y = $posY - 100 * Cos($i * $pi - $pi / 6 - $pi) / 2 + 25 * Cos($i * $pi + $pi / 2 - $pi / 6 - $pi) * Sqrt(3) / 2
		Dot($x, $y, 0x00FF00, 10 / 3)

		$x = $posX + 100 * Cos($i * $pi) * Sqrt(3) / 2 + 25 * Cos($i * $pi + $pi / 2) / 2
		$y = $posY - 100 * Cos($i * $pi) / 2 + 25 * Cos($i * $pi + $pi / 2) * Sqrt(3) / 2
		Dot($x, $y, 0x00FF00, 10)

		$x = $posX + 100 * Cos($i * $pi - $pi / 12) * Sqrt(3) / 2 + 25 * Cos($i * $pi + $pi / 2 - $pi / 12) / 2
		$y = $posY - 100 * Cos($i * $pi - $pi / 12) / 2 + 25 * Cos($i * $pi + $pi / 2 - $pi / 12) * Sqrt(3) / 2
		Dot($x, $y, 0x00FF00, 20 / 3)

		$x = $posX + 100 * Cos($i * $pi - $pi / 6) * Sqrt(3) / 2 + 25 * Cos($i * $pi + $pi / 2 - $pi / 6) / 2
		$y = $posY - 100 * Cos($i * $pi - $pi / 6) / 2 + 25 * Cos($i * $pi + $pi / 2 - $pi / 6) * Sqrt(3) / 2
		Dot($x, $y, 0x00FF00, 10 / 3)

		$x = $posX - 100 * Cos($i * $pi) * Sqrt(3) / 2 - 25 * Cos(-$i * $pi + $pi / 2) / 2
		$y = $posY - 100 * Cos($i * $pi) / 2 + 25 * Cos(-$i * $pi + $pi / 2) * Sqrt(3) / 2
		Dot($x, $y, 0x0000FF, 10)

		$x = $posX - 100 * Cos($i * $pi - $pi / 12) * Sqrt(3) / 2 - 25 * Cos(-$i * $pi + $pi / 2 + $pi / 12) / 2
		$y = $posY - 100 * Cos($i * $pi - $pi / 12) / 2 + 25 * Cos(-$i * $pi + $pi / 2 + $pi / 12) * Sqrt(3) / 2
		Dot($x, $y, 0x0000FF, 20 / 3)

		$x = $posX - 100 * Cos($i * $pi - $pi / 6) * Sqrt(3) / 2 - 25 * Cos(-$i * $pi + $pi / 2 + $pi / 6) / 2
		$y = $posY - 100 * Cos($i * $pi - $pi / 6) / 2 + 25 * Cos(-$i * $pi + $pi / 2 + $pi / 6) * Sqrt(3) / 2
		Dot($x, $y, 0x0000FF, 10 / 3)

		$x = $posX - 100 * Cos($i * $pi - $pi) * Sqrt(3) / 2 - 25 * Cos(-$i * $pi + $pi / 2 - $pi) / 2
		$y = $posY - 100 * Cos($i * $pi - $pi) / 2 + 25 * Cos(-$i * $pi + $pi / 2 - $pi) * Sqrt(3) / 2
		Dot($x, $y, 0x0000FF, 10)

		$x = $posX - 100 * Cos($i * $pi - $pi / 12 - $pi) * Sqrt(3) / 2 - 25 * Cos(-$i * $pi + $pi / 2 + $pi / 12 - $pi) / 2
		$y = $posY - 100 * Cos($i * $pi - $pi / 12 - $pi) / 2 + 25 * Cos(-$i * $pi + $pi / 2 + $pi / 12 - $pi) * Sqrt(3) / 2
		Dot($x, $y, 0x0000FF, 20 / 3)

		$x = $posX - 100 * Cos($i * $pi - $pi / 6 - $pi) * Sqrt(3) / 2 - 25 * Cos(-$i * $pi + $pi / 2 + $pi / 6 - $pi) / 2
		$y = $posY - 100 * Cos($i * $pi - $pi / 6 - $pi) / 2 + 25 * Cos(-$i * $pi + $pi / 2 + $pi / 6 - $pi) * Sqrt(3) / 2
		Dot($x, $y, 0x0000FF, 10 / 3)

;~ $x = $posX + 100*Cos($i*$pi)
;~ $y = $posY + 100*Cos($i*$pi + $pi/2)
;~ Dot($x,$y,0xFF0000,10)

;~ $x = $posX + 100*Cos($i*$pi + 2*$pi/3)
;~ $y = $posY + 100*Cos($i*$pi + $pi/2 + 2*$pi/3)
;~ Dot($x,$y,0x00FF00,10)

;~ $x = $posX + 100*Cos($i*$pi + 4*$pi/3)
;~ $y = $posY + 100*Cos($i*$pi + $pi/2 + 4*$pi/3)
;~ Dot($x,$y,0x0000FF,10)

		Sleep(20)
	WEnd
	$j = 0
	GUISetBkColor(0xABCDEF)
WEnd

Func _Exit()
	DllClose($user32_dll)
	_WinAPI_ReleaseDC($hGUI, $hDC)
	Exit
EndFunc   ;==>_Exit
