; Constants used by _FillGradientTriangleRect
Global Const $GRADIENT_FILL_RECT_H = 0
Global Const $GRADIENT_FILL_RECT_V = 1
Global Const $GRADIENT_FILL_TRIANGLE = 2
; End

#NoTrayIcon
#include <GDIPlus.au3>
#include <Math.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <GuiEdit.au3>
#include <Date.au3>


Global Const $width = 600
Global Const $height =600
Global Const $dots = 10

Global $direction = 2
Global $remx[$dots], $remy[$dots]


Opt("GUIOnEventMode", 1)
$hwnd = GUICreate("Radar", $width, $height,-1,-1,$WS_CAPTION)

GUISetOnEvent(-3, "close")
GUISetState()
GUIRegisterMsg($WM_PAINT, "_Paint")
GUIRegisterMsg($WM_MOVE, "_Move")

; Create the dot.
Global $UFO[$dots][5]

$UFO[0][0]=100
$UFO[0][1]=100
$UFO[0][2] = Random(-0.1, 0.1)
$UFO[0][3] = Random(-0.1, 0.1)



For $a = 0 To UBound($UFO) - 1
	$UFO[$a][0] = Random(0, $width, 1)
	If Random(0, 1, 1) = 0 Then
		$UFO[$a][1] = 0
	Else
		$UFO[$a][1] = $height
	EndIf

	Do
		$UFO[$a][2] = Random(-0.5, 0.5)
		$UFO[$a][3] = Random(-0.5, 0.5)
	Until $UFO[$a][2] + $UFO[$a][3] <> 0
Next


_GDIPlus_Startup()

$graphics = _GDIPlus_GraphicsCreateFromHWND($hwnd)
$bitmap = _GDIPlus_BitmapCreateFromGraphics($width, $height, $graphics)
$background = _GDIPlus_BitmapCreateFromGraphics($width, $height, $graphics)
$backgroundgraphics = _GDIPlus_ImageGetGraphicsContext($background)
_AntiAlias($backgroundgraphics, 4)
$backbuffer = _GDIPlus_ImageGetGraphicsContext($bitmap)
_AntiAlias($backbuffer, 4)
$brush = _GDIPlus_BrushCreateSolid(0xFF005200)
$pen = _GDIPlus_PenCreate(0xFF008800, 3)
$pen2 = _GDIPlus_PenCreate(0xFF00BB00, 3)


Global $whiteshades[32]


For $i = 0 To UBound($whiteshades) - 1
	$whiteshades[$i] = _GDIPlus_BrushCreateSolid("0x" & Hex(((32 - $i) * 8 - 1), 2) & "AAFFAA")
Next



_GDIPlus_GraphicsClear($backgroundgraphics, 0xFF000000)

_GDIPlus_GraphicsFillEllipse($backgroundgraphics, 0, 0, $width, $height, $brush)
_GDIPlus_GraphicsDrawLine($backgroundgraphics, $width / 2, 0, $width / 2, $height, $pen)
_GDIPlus_GraphicsDrawLine($backgroundgraphics, 0, $height / 2, $width, $height / 2, $pen)
_GDIPlus_GraphicsDrawEllipse($backgroundgraphics, 50, 50, $width - (50 * 2), $height - (50 * 2), $pen)
_GDIPlus_GraphicsDrawEllipse($backgroundgraphics, 175, 175, $width - (175 * 2), $height - (175 * 2), $pen)


$inc = 0

$tx = 200
$ty = 100




Do
	_Draw()
	Sleep(20)
Until False



Func _Draw()
	; Clear the backbuffer and draw the background on it.
	_GDIPlus_GraphicsClear($backbuffer, 0xFF000000)
	_GDIPlus_GraphicsDrawImageRect($backbuffer, $background, 0, 0, $width, $height)

	; Get the x and y position to draw the line on
	$temparray = _GetXY($inc)
	$x = $temparray[0]
	$y = $temparray[1]


	; Check if the line is intercepted


	For $a = 0 To UBound($UFO) - 1
		$result = PointDistanceFromLine($width / 2, $height / 2, $x, $y, $UFO[$a][0], $UFO[$a][1])
		If CircleIntersection($result, 10) And $UFO[$a][4] = 0 Then
			$UFO[$a][4] = 1
			$remx[$a] = $UFO[$a][0]
			$remy[$a] = $UFO[$a][1]
			If ($remx[$a] - $width / 2) ^ 2 + ($remy[$a] - $height / 2) ^ 2 <= (($width - (175 * 2)) / 2) ^ 2 Then
				If $remx[$a] < $width / 2 Then
					If $remy[$a] < $height / 2 Then
						;_GUICtrlEdit_AppendText($edit, @CRLF & @HOUR&":"&@MIN&":"&@SEC&": "&"Object intercepted in sector A1")
					Else
						;_GUICtrlEdit_AppendText($edit, @CRLF &@HOUR&":"&@MIN&":"&@SEC&": "& "Object intercepted in sector A3")
					EndIf
				Else
					If $remy[$a] < $height / 2 Then
						;_GUICtrlEdit_AppendText($edit, @CRLF &@HOUR&":"&@MIN&":"&@SEC&": "& "Object intercepted in sector A2")
					Else
						;_GUICtrlEdit_AppendText($edit, @CRLF &@HOUR&":"&@MIN&":"&@SEC&": "& "Object intercepted in sector A4")
					EndIf
				EndIf

			ElseIf ($remx[$a] - $width / 2) ^ 2 + ($remy[$a] - $height / 2) ^ 2 <= (($width - (50 * 2)) / 2) ^ 2 Then
				If $remx[$a] < $width / 2 Then
					If $remy[$a] < $height / 2 Then
						;_GUICtrlEdit_AppendText($edit, @CRLF &@HOUR&":"&@MIN&":"&@SEC&": "& "Object intercepted in sector B1")
					Else
						;_GUICtrlEdit_AppendText($edit, @CRLF &@HOUR&":"&@MIN&":"&@SEC&": "& "Object intercepted in sector B3")
					EndIf
				Else
					If $remy[$a] < $height / 2 Then
						;_GUICtrlEdit_AppendText($edit, @CRLF &@HOUR&":"&@MIN&":"&@SEC&": "& "Object intercepted in sector B2")
					Else
						;_GUICtrlEdit_AppendText($edit, @CRLF &@HOUR&":"&@MIN&":"&@SEC&": "& "Object intercepted in sector B4")
					EndIf
				EndIf
			Else
				If $remx[$a] < $width / 2 Then
					If $remy[$a] < $height / 2 Then
						;_GUICtrlEdit_AppendText($edit, @CRLF &@HOUR&":"&@MIN&":"&@SEC&": "& "Object intercepted in sector C1")
					Else
						;_GUICtrlEdit_AppendText($edit, @CRLF &@HOUR&":"&@MIN&":"&@SEC&": "& "Object intercepted in sector C3")
					EndIf
				Else
					If $remy[$a] < $height / 2 Then
						;_GUICtrlEdit_AppendText($edit, @CRLF &@HOUR&":"&@MIN&":"&@SEC&": "& "Object intercepted in sector C2")
					Else
						;_GUICtrlEdit_AppendText($edit, @CRLF &@HOUR&":"&@MIN&":"&@SEC&": "& "Object intercepted in sector C4")
					EndIf
				EndIf
			EndIf


		EndIf

		ConsoleWrite("Result: " & $result & @CRLF)
	Next


	_GDIPlus_GraphicsDrawLine($backbuffer, $width / 2, $height / 2, $x, $y, $pen2)



	Local $temp[3][3]
	$temp[0][0] = $width / 2
	$temp[0][1] = $height / 2
	$temp[0][2] = "0x00005200"

	$temp[1][0] = $x
	$temp[1][1] = $y
	$temp[1][2] = "0xFF00BB00"


	$xy = _GetXY($inc - 0.0005 * $direction * 7)
	$temp[2][0] = $xy[0]
	$temp[2][1] = $xy[1]
	$temp[2][2] = "0x00005200"


	$dc = _GDIPlus_GraphicsGetDC($backbuffer)
	_FillGradientTriangleRect($dc, $temp, $GRADIENT_FILL_TRIANGLE)
	_GDIPlus_GraphicsReleaseDC($backbuffer, $dc)


	; If the dot has been found
	For $a = 0 To UBound($UFO) - 1
		If $UFO[$a][4] > 0 Then
			_GDIPlus_GraphicsFillEllipse($backbuffer, $remx[$a], $remy[$a], 5, 5, $whiteshades[$UFO[$a][4] - 1])
			$UFO[$a][4] += 1
			If $UFO[$a][4] > 32 Then
				$UFO[$a][4] = 0
			EndIf
		EndIf
		; Move the dot (regardless of state)
		$UFO[$a][0] += $UFO[$a][2]
		$UFO[$a][1] += $UFO[$a][3]

		; If the dot is of screen recreate it
		If $UFO[$a][0] > $width Or $UFO[$a][0] < 0 Or $UFO[$a][1] > $height Or $UFO[$a][1] < 0 Then
			$UFO[$a][0] = Random(0, $width, 1)
			If Random(0, 1, 1) = 0 Then
				$UFO[$a][1] = 0
			Else
				$UFO[$a][1] = $height
			EndIf


			Do
				$UFO[$a][2] = Random(-0.5, 0.5)
				$UFO[$a][3] = Random(-0.5, 0.5)
			Until $UFO[$a][2] + $UFO[$a][3] <> 0
		EndIf
	Next


	_GDIPlus_GraphicsDrawImageRect($graphics, $bitmap, 0, 0, $width, $height)
	$inc += 0.0005 * $direction
EndFunc   ;==>_Draw



Func _GetXY($value)
	Local $array[2]
	$cos = Cos(_Degree($value))
	$sin = Sin(_Degree($value))
	$fx = $cos * ($width / 2) + ($width / 2)
	$fy = $sin * ($height / 2) + ($height / 2)
	$array[0] = $fx
	$array[1] = $fy
	Return $array
EndFunc   ;==>_GetXY




Func close()
	For $i = 0 To UBound($whiteshades) - 1
		_GDIPlus_BrushDispose($whiteshades[$i])
	Next
	_GDIPlus_PenDispose($pen)
	_GDIPlus_PenDispose($pen2)
	_GDIPlus_BrushDispose($brush)
	_WinAPI_DeleteObject($bitmap)
	_WinAPI_DeleteObject($background)
	_GDIPlus_GraphicsDispose($backgroundgraphics)
	_GDIPlus_GraphicsDispose($graphics)
	_GDIPlus_GraphicsDispose($backbuffer)
	_GDIPlus_Shutdown()
	Exit
EndFunc   ;==>close

Func _Paint()
	_GDIPlus_GraphicsDrawImageRect($graphics, $bitmap, 0, 0, $width, $height)
	Return "GUI_RUNDEFMSG"
EndFunc   ;==>_Paint

Func _Move()
	_Draw()
	$tpos = WinGetPos($hwnd)
	;WinMove($childhwnd, "", $tpos[0] + ($width - 500) / 2, $tpos[1] + $height + 30)
	Return "GUI_RUNDEFMSG"
EndFunc   ;==>_Move



; Thanks weaponx for these three functions :)
;distance: Center point distance from line
;radius: circle radius
Func CircleIntersection($distance, $Radius)
	If $distance < $Radius Then
		;MsgBox(0,"","Circle intersects line")
		Return True
	Else
		;MsgBox(0,"","Circle doesn't intersect line")
		Return False
	EndIf
EndFunc   ;==>CircleIntersection

;xa,ya: Start X,Y
;xb,yb: End X,Y
;xp,yp: Point X,Y
Func PointDistanceFromLine($xa, $ya, $xb, $yb, $xp, $yp)
	;Xa,Ya is point 1 on the line segment.
	;Xb,Yb is point 2 on the line segment.
	;Xp,Yp is the point.

	$xu = $xp - $xa
	$yu = $yp - $ya
	$xv = $xb - $xa
	$yv = $yb - $ya
	If ($xu * $xv + $yu * $yv < 0) Then
		Return Sqrt(($xp - $xa) ^ 2 + ($yp - $ya) ^ 2)
	EndIf

	$xu = $xp - $xb
	$yu = $yp - $yb
	$xv = -$xv
	$yv = -$yv
	If ($xu * $xv + $yu * $yv < 0) Then
		Return Sqrt(($xp - $xb) ^ 2 + ($yp - $yb) ^ 2)
	EndIf

	Return Abs(($xp * ($ya - $yb) + $yp * ($xb - $xa) + ($xa * $yb - $xb * $ya)) / Sqrt(($xb - $xa) ^ 2 + ($yb - $ya) ^ 2))
EndFunc   ;==>PointDistanceFromLine


Func _AntiAlias($hGraphics, $iMode)
	Local $aResult

	$aResult = DllCall($__g_hGDIPDll, "int", "GdipSetSmoothingMode", "hwnd", $hGraphics, "int", $iMode)
	If @error Then Return SetError(@error, @extended, False)
	Return SetError($aResult[0], 0, $aResult[0] = 0)
EndFunc   ;==>_AntiAlias





; #FUNCTION#;===============================================================================
;
; Name...........: _FillGradientTriangleRect()
; Description ...: Draws a gradient triangle or rect on a device context
; Syntax.........: _FillGradientTriangleRect(ByRef $hDc, ByRef $aVertexes, $iFlag)
; Parameters ....:  $hDc		- Handle to a device context
;				   $sVertexes  - A 2 dimension array that specifies the triangle (or rect) The array has this structure:"
;				  |$aVertexes[n][0] = x coord
;				  |$aVertexes[n][1] = y coord
;				  |$aVertexes[n][2] = Color of the vertex in 0xAARRGGBB format
;				   $iFlag - Flag that specifies the drawing, flags:
;				  |$GRADIENT_FILL_RECT_H - Rectangle with horizontal gradient
;				  |$GRADIENT_FILL_RECT_V - Rectangle with vertical gradient
;				  |$GRADIENT_FILL_TRIANGLE - Triangle
; Return values .: Success - 1
;				  Failure - Returns -1 and sets error to 1
; Author ........: Andreas Karlsson (monoceres)
; Modified.......:
; Remarks .......: Pass 3 vertexes for triangles and 2 for rects
; Related .......:
; Link ..........; http://msdn.microsoft.com/en-us/library/ms532348(VS.85).aspx
; Example .......; No
;
;;==========================================================================================
Func _FillGradientTriangleRect(ByRef $hDc, ByRef $aVertexes, $iFlag)
	Local $sTRIVERTEXString, $vTRIVERTEX, $aReturn
	Local $iColor
	Local $GRADIENT_STRUCT
	If $iFlag = $GRADIENT_FILL_TRIANGLE Then
		$GRADIENT_STRUCT = DllStructCreate("ulong V1;ulong V2;ulong V3;")
		DllStructSetData($GRADIENT_STRUCT, "V1", 0)
		DllStructSetData($GRADIENT_STRUCT, "V2", 1)
		DllStructSetData($GRADIENT_STRUCT, "V3", 2)
	Else
		$GRADIENT_STRUCT = DllStructCreate("ulong UpperLeft;ulong LowerRight;")
		DllStructSetData($GRADIENT_STRUCT, "UpperLeft", 0)
		DllStructSetData($GRADIENT_STRUCT, "LowerRight", 1)
	EndIf
	For $i = 0 To UBound($aVertexes) - 1
		$sTRIVERTEXString &= "ulong x" & $i & ";ulong y" & $i & ";short Red" & $i & ";short Green" & $i & ";short Blue" & $i & ";"
	Next
	$vTRIVERTEX = DllStructCreate($sTRIVERTEXString)
	For $i = 0 To UBound($aVertexes) - 1
		$iColor = StringRight($aVertexes[$i][2], 8)
		DllStructSetData($vTRIVERTEX, "x" & $i, $aVertexes[$i][0])
		DllStructSetData($vTRIVERTEX, "y" & $i, $aVertexes[$i][1])
		DllStructSetData($vTRIVERTEX, "Alpha" & $i, "0x" & Hex(Dec(StringLeft($iColor, 2)) * 256, 4))
		DllStructSetData($vTRIVERTEX, "Red" & $i, "0x" & Hex(Dec(StringMid($iColor, 3, 2)) * 256, 4))
		DllStructSetData($vTRIVERTEX, "Green" & $i, "0x" & Hex(Dec(StringMid($iColor, 5, 2)) * 256, 4))
		DllStructSetData($vTRIVERTEX, "Blue" & $i, "0x" & Hex(Dec(StringRight($iColor, 2)) * 256, 4))
	Next
	$aReturn = DllCall("Msimg32.dll", "int", "GradientFill", "ptr", $hDc, "ptr", DllStructGetPtr($vTRIVERTEX), "ulong", UBound($aVertexes), "ptr", DllStructGetPtr($GRADIENT_STRUCT), "ulong", 1, "ulong", $iFlag)
	If Not IsArray($aReturn) Or $aReturn[0] = 0 Then
		Return SetError(1, 0, -1)
	Else
		Return SetError(0, 0, 1)
	EndIf
EndFunc   ;==>_FillGradientTriangleRect


;===============================================================================
;
; Function Name:   _API_SetLayeredWindowAttributes
; Description::    Sets Layered Window Attributes:) See MSDN for more informaion
; Parameter(s):
;                  $hwnd - Handle of GUI to work on
;                  $i_transcolor - Transparent color
;                  $Transparency - Set Transparancy of GUI
;                  $isColorRef - If True, $i_transcolor is a COLORREF-Strucure, else an RGB-Color
; Requirement(s):  Layered Windows
; Return Value(s): Success: 1
;                  Error: 0
;                   @error: 1 to 3 - Error from DllCall
;                   @error: 4 - Function did not succeed - use
;                               _WinAPI_GetLastErrorMessage or _WinAPI_GetLastError to get more information
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _API_SetLayeredWindowAttributes($hwnd, $i_transcolor, $Transparency = 255, $isColorRef = False)

	Local Const $AC_SRC_ALPHA = 1
	Local Const $ULW_ALPHA = 2
	Local Const $LWA_ALPHA = 0x2
	Local Const $LWA_COLORKEY = 0x1
	If Not $isColorRef Then
		$i_transcolor = Hex(String($i_transcolor), 6)
		$i_transcolor = Execute('0x00' & StringMid($i_transcolor, 5, 2) & StringMid($i_transcolor, 3, 2) & StringMid($i_transcolor, 1, 2))
	EndIf
	Local $Ret = DllCall("user32.dll", "int", "SetLayeredWindowAttributes", "hwnd", $hwnd, "long", $i_transcolor, "byte", $Transparency, "long", $LWA_COLORKEY + $LWA_ALPHA)
	Select
		Case @error
			Return SetError(@error, 0, 0)
		Case $Ret[0] = 0
			Return SetError(4, 0, 0)
		Case Else
			Return 1
	EndSelect
EndFunc   ;==>_API_SetLayeredWindowAttributes