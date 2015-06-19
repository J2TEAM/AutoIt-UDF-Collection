#NoTrayIcon
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <UpDownConstants.au3>
#include <Color.au3>
#include <Sound.au3>
#include <Misc.au3>
;

Global $SCRName 				= "Matrix ScreenSaver"
Global $SCRVersion 				= "1.1"

Global $Matrix_Sound_Name 		= "Matrix_Snd.mp3"
Global $Matrix_Sound_Path 		= @TempDir & "\" & $Matrix_Sound_Name
Global $Matrix_Preview_Image 	= @TempDir & "\Matrix_PV.bmp"

_Singleton($CmdLineRaw)

Global $Matrix_Speed 			= RegRead("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix Speed")
If $Matrix_Speed = "" Then $Matrix_Speed = 50

Global $Matrix_Density 			= RegRead("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix Density")
If $Matrix_Density = "" Or $Matrix_Density <= 0 Then $Matrix_Density = 500

Global $Matrix_FontSize 		= RegRead("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix Font Size")
If $Matrix_FontSize = "" Or $Matrix_FontSize <= 0 Then $Matrix_FontSize = 10

Global $Matrix_Begin_Color 		= RegRead("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix Begin Color")
If $Matrix_Begin_Color = "" Then $Matrix_Begin_Color = 0x00FF00

Global $Matrix_End_Color 		= RegRead("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix End Color")
If $Matrix_End_Color = "" Then $Matrix_End_Color = 0x000000

Global $Play_Sound 				= RegRead("HKEY_CURRENT_USER\Software\Matrix_SCR", "Play Sound")
If $Play_Sound = "" Then $Play_Sound = 1

Global $Matrix_SCR_Path 		= RegRead("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix SCR Path")
If $Matrix_SCR_Path = "" Then $Matrix_SCR_Path = StringTrimRight(@ScriptFullPath, 3) & "scr"

Global $Matrix_SCR_Icon_Path 	= RegRead("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix SCR Icon Path")
If $Matrix_SCR_Icon_Path = "" Then $Matrix_SCR_Icon_Path = @ScriptDir & "\Icon.ico"

Global $MousePos = MouseGetPos()
Global $Main_Timer, $ScrWindow

Global $Width = @DesktopWidth
Global $Height = @DesktopHeight

Global $MatrixArr[$Matrix_Density][4]
Global $ColorsArr = GetColorsArray($Matrix_Begin_Color, $Matrix_End_Color)
Global $CharsArr = GetCharsArray()

Global $Matrix_FontName = "Matrix Code Font"
FileInstall(".\Matrix Code Font.ttf", @TempDir & "\Matrix Code Font.ttf")

_WinAPI_AddFontResource(@TempDir & "\Matrix Code Font.ttf")

If $CmdLineRaw = "/S" Then
	ScreenSaver_Proc()
ElseIf $CmdLine[0] = 0 Or StringLeft($CmdLineRaw, 3) = "/c:" Then
	SCR_Options_Proc(StringLeft($CmdLineRaw, 3) = "/c:")
ElseIf $CmdLine[0] >= 2 And $CmdLine[1] = "/p" Then
	FileInstall("Matrix_PV.bmp", $Matrix_Preview_Image, 1)
	Set_SCR_Preview($Matrix_Preview_Image)
	FileDelete($Matrix_Preview_Image)
EndIf

Func OnAutoItExit()
	_WinAPI_RemoveFontResource(@TempDir & "\Matrix Code Font.ttf")
	FileDelete(@TempDir & "\Matrix Code Font.ttf")
EndFunc

Func SCR_Options_Proc($DisableParent=0)
	Local $Local_Height = 280
	If @Compiled Then $Local_Height = 180
	
	Local $ParentHwnd = 0
	If $DisableParent = 1 Then
		$ParentHwnd = WinGetHandle("")
		WinSetState($ParentHwnd, "", @SW_DISABLE)
	EndIf
	
	Local $GUI = GuiCreate($SCRName & " v" & $SCRVersion & " - Options", _
		400, $Local_Height, -1, -1, -1, $WS_EX_TOPMOST+$WS_EX_TOOLWINDOW, $ParentHwnd)
	
	GUISetFont(8, 400)
	
	GUICtrlCreateLabel("Matrix Speed:", 10, 15)
	Local $Speed_Slider = GuiCtrlCreateSlider(90, 14, 300, 20)
	GUICtrlSetLimit(-1, 100, 0)
	GUICtrlSetData(-1, $Matrix_Speed)
	
	GUICtrlCreateLabel("Matrix Density:", 10, 55)
	Local $Density_Input = GUICtrlCreateInput($Matrix_Density, 100, 50, 60, 22, $ES_AUTOHSCROLL+$ES_NUMBER, $WS_EX_DLGMODALFRAME)
	GUICtrlCreateUpdown(-1, $UDS_ARROWKEYS)
	GUICtrlSetLimit(-1, 2000, 1)
	
	GUICtrlCreateLabel("Matrix Font Size:", 10, 80)
	
	Local $Matrix_FontSize_Input = GUICtrlCreateInput($Matrix_FontSize, 100, 75, 60, 22, _
		$ES_AUTOHSCROLL+$ES_READONLY, $WS_EX_DLGMODALFRAME)
	GUICtrlCreateUpdown(-1, $UDS_ARROWKEYS)
	GUICtrlSetLimit(-1, 76, 1)
	
	Local $Play_Sound_CB = GUICtrlCreateCheckbox("Play Sound", 175, 50)
	If $Play_Sound = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
	
	GUISetFont(10, 800)
	
	Local $Matrix_Begin_Color_Label = GUICtrlCreateLabel("M.Begin Color", 175, 85)
	GUICtrlSetColor(-1, $Matrix_Begin_Color)
	GUICtrlSetCursor(-1, 0)
	
	Local $Matrix_End_Color_Label = GUICtrlCreateLabel("M.End Color", 290, 85)
	GUICtrlSetColor(-1, $Matrix_End_Color)
	GUICtrlSetCursor(-1, 0)
	
	GUISetFont(8, 400)
	
	Local $CompileSCR_Button = -1
	Local $SCRPath_Input = -1
	Local $SelectSCRDir_Button = -1
	Local $SCRIconPath_Input = -1
	Local $SelectSCRIconDir_Button = -1
	
	If Not @Compiled Then
		GUICtrlCreateGroup("Compile Options", 5, 110, 390, 120)
		
		$CompileSCR_Button = GUICtrlCreateButton("Compile to SCR", 10, 130, 100, 20)
		
		GUICtrlCreateLabel("SCR Path:", 10, 160)
		$SCRPath_Input = GUICtrlCreateInput($Matrix_SCR_Path, 100, 155, 250, 22, -1, $WS_EX_DLGMODALFRAME)
		$SelectSCRDir_Button = GUICtrlCreateButton("...", 355, 155, 25, 22)
		GUICtrlSetTip(-1, "Select SCR file to save compiled ScreenSaver")
		
		GUICtrlCreateLabel("SCR Icon Path:", 10, 195)
		$SCRIconPath_Input = GUICtrlCreateInput($Matrix_SCR_Icon_Path, 100, 190, 250, 22, -1, $WS_EX_DLGMODALFRAME)
		$SelectSCRIconDir_Button = GUICtrlCreateButton("...", 355, 190, 25, 22)
		GUICtrlSetTip(-1, "Select ICON file for the compiled ScreenSaver")
	EndIf
	
	Local $Preview_Button = GUICtrlCreateButton("Preview", 10, $Local_Height-40, 70, 20)
	Local $About_Button = GUICtrlCreateButton("About", 90, $Local_Height-40, 70, 20)
	
	Local $Cancel_Button = GUICtrlCreateButton("Cancel", 230, $Local_Height-40, 70, 20)
	Local $Apply_Button = GUICtrlCreateButton("Apply", 310, $Local_Height-40, 70, 20)
	
	GUISetState()
	
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $CompileSCR_Button
				Local $SCR_Path = GUICtrlRead($SCRPath_Input)
				Local $SCR_Icon_Path = GUICtrlRead($SCRIconPath_Input)
				
				Local $AutoItPath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt", "InstallDir")
				Local $AutoItExe = $AutoItPath & "\Aut2Exe\Aut2exe.exe"
				
				If Not FileExists($SCR_Icon_Path) Then $SCR_Icon_Path = $AutoItPath & "\Icons\filetype-blank.ico"
				
				If StringRight($SCR_Path, 3) <> "scr" Then
					MsgBox(48, "Error!", "The SCR file not supported, type or select a correct SCR file (*.scr) to save.", 0, $GUI)
					ContinueLoop
				EndIf
				
				RunWait($AutoItExe & ' /in "' & FileGetShortName(@ScriptFullPath) & '" /out "' & _
					$SCR_Path & '" /icon "' & $SCR_Icon_Path & '"')
				
				If @error Or Not FileExists($SCR_Path) Then
					MsgBox(48, "Error!", "There was an error to compile the SCR file.", 0, $GUI)
					ContinueLoop
				EndIf
				
				MsgBox(64, "Done!", "Compiling is finished!" & @LF & $SCRName & " is saved as:" & @LF & @LF & $SCR_Path, 0, $GUI)
			Case $SelectSCRDir_Button
				Local $OldSCRPath = StringRegExpReplace($Matrix_SCR_Path, "\\[^\\]*$", "")
				Local $OldSCRName = StringRegExpReplace($Matrix_SCR_Path, "^.*\\", "")
				
				Local $SCR_Path = FileSaveDialog("Save as", $OldSCRPath, "ScreenSaver Program (*.scr)", 18, $OldSCRName, $GUI)
				If @error Then ContinueLoop
				
				If StringRight($SCR_Path, 4) <> ".scr" Then $SCR_Path &= ".scr"
				
				$Matrix_SCR_Path = $SCR_Path
				GUICtrlSetData($SCRPath_Input, $Matrix_SCR_Path)
			Case $SelectSCRIconDir_Button
				Local $OldSCRIconPath = StringRegExpReplace($Matrix_SCR_Icon_Path, "\\[^\\]*$", "")
				Local $OldSCRIconName = StringRegExpReplace($Matrix_SCR_Icon_Path, "^.*\\", "")
				
				Local $SCR_Icon_Path = FileOpenDialog("Save as", $OldSCRIconPath, "Windows Icon (*.ico)", 11, $OldSCRIconName, $GUI)
				If @error Then ContinueLoop
				
				If StringRight($SCR_Icon_Path, 4) <> ".ico" Then $SCR_Icon_Path &= ".ico"
				
				$Matrix_SCR_Icon_Path = $SCR_Icon_Path
				GUICtrlSetData($SCRIconPath_Input, $Matrix_SCR_Icon_Path)
			Case $Matrix_Begin_Color_Label, $Matrix_End_Color_Label
				Local $sSetColor = $Matrix_Begin_Color
				If $nMsg = $Matrix_End_Color_Label Then $sSetColor = $Matrix_End_Color
				Local $sChooseColor = _ChooseColor(2, $sSetColor, 2, $GUI)
				
				If Not @error Then
					If $nMsg = $Matrix_Begin_Color_Label Then $Matrix_Begin_Color = $sChooseColor
					If $nMsg = $Matrix_End_Color_Label Then $Matrix_End_Color = $sChooseColor
					GUICtrlSetColor($nMsg, $sChooseColor)
					$ColorsArr = GetColorsArray($Matrix_Begin_Color, $Matrix_End_Color)
				EndIf
			Case $Preview_Button
				$Matrix_Speed = GUICtrlRead($Speed_Slider)
				$Matrix_Density = GUICtrlRead($Density_Input)
				$Matrix_FontSize = GUICtrlRead($Matrix_FontSize_Input)
				$Play_Sound = GUICtrlRead($Play_Sound_CB)
				
				If $Matrix_Density = "" Or $Matrix_Density <= 0 Then
					$Matrix_Density = 500
					GUICtrlSetData($Density_Input, $Matrix_Density)
				EndIf
				
				ScreenSaver_Proc()
				GUISwitch($GUI)
			Case $Cancel_Button, $GUI_EVENT_CLOSE
				If StringInStr($CmdLineRaw, "/c:") Then WinSetState($ParentHwnd, "", @SW_ENABLE)
				Exit
			Case $About_Button
				MsgBox(64, "About Program", $SCRName & " v" & $SCRVersion & @LF & @LF & _
					"Copyright © 2007 - 2009, Jex, jokke, (Ms)CreatoR", 0, $GUI)
			Case $Apply_Button
				ExitLoop
		EndSwitch
	WEnd
	
	If $DisableParent = 1 Then WinSetState($ParentHwnd, "", @SW_ENABLE)
	
	$Matrix_Speed = GUICtrlRead($Speed_Slider)
	$Matrix_Density = GUICtrlRead($Density_Input)
	$Matrix_FontSize = GUICtrlRead($Matrix_FontSize_Input)
	$Play_Sound = GUICtrlRead($Play_Sound_CB)
	$Matrix_SCR_Path = GUICtrlRead($SCRPath_Input)
	$Matrix_SCR_Icon_Path = GUICtrlRead($SCRIconPath_Input)
	
	RegWrite("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix Speed", "REG_SZ", $Matrix_Speed)
	RegWrite("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix Density", "REG_SZ", $Matrix_Density)
	RegWrite("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix Font Size", "REG_SZ", $Matrix_FontSize)
	RegWrite("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix Begin Color", "REG_SZ", $Matrix_Begin_Color)
	RegWrite("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix End Color", "REG_SZ", $Matrix_End_Color)
	RegWrite("HKEY_CURRENT_USER\Software\Matrix_SCR", "Play Sound", "REG_SZ", $Play_Sound)
	
	If Not @Compiled Then
		RegWrite("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix SCR Path", "REG_SZ", $Matrix_SCR_Path)
		RegWrite("HKEY_CURRENT_USER\Software\Matrix_SCR", "Matrix SCR Icon Path", "REG_SZ", $Matrix_SCR_Icon_Path)
	EndIf
	
	Exit
EndFunc

Func ScreenSaver_Proc()
	Local $Old_Opt_GOEM = Opt("GuiOnEventMode", 1)
	HotKeySet("{ESC}", "CloseScreenSaver")
	
	Local $SoundID = -1
	
	If $Play_Sound = 1 Then
		FileInstall("Matrix_Snd.mp3", $Matrix_Sound_Path)
		$SoundID = _SoundOpen($Matrix_Sound_Path)
		_SoundPlay($SoundID, 0)
	EndIf
	
	$ScrWindow = GUICreate($SCRName & " - ScreenSaver", $Width, $Height, 0, 0, $WS_POPUP, BitOr($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
	GUISetOnEvent($GUI_EVENT_MOUSEMOVE, "CloseScreenSaver")
	GUISetOnEvent($GUI_EVENT_PRIMARYDOWN, "CloseScreenSaver")
	GUISwitch($ScrWindow)
	
	GUISetBkColor(0)
	GUISetCursor(16, 1)
	
	$Main_Timer = TimerInit()
	GUISetState(@SW_SHOW, $ScrWindow)
	
	Dim $MatrixArr[$Matrix_Density][4]
	MatrixInitialize($MatrixArr)
	
	While WinActive($ScrWindow)
		For $x = 0 To UBound($MatrixArr) -1
			If Not WinActive($ScrWindow) Then ExitLoop 2
			$MatrixArr[$x][2] += Random(8, 25, 1)
			
			If $MatrixArr[$x][2] > $Height Then 
				GUICtrlSetColor($MatrixArr[$x][3], $ColorsArr[Random(1, 50, 1)]);assign new color
				GUICtrlSetData($MatrixArr[$x][3], Chr(Random(33, 255, 1)))  ;assign new chr
				$MatrixArr[$x][2] = 0 ;char back at top
				$MatrixArr[$x][1] = Random(0, $Width/25, 1) * 25 ;new row
			EndIf
			
			GUICtrlSetPos($MatrixArr[$x][3], $MatrixArr[$x][1], $MatrixArr[$x][2])
			Sleep(101 - $Matrix_Speed)
		Next
		
		Sleep(1)
		If _SoundStatus($SoundID) <> "playing" Then _SoundPlay($SoundID, 0)
	WEnd
	
	If BitAND(WinGetState($ScrWindow), 2) Then GUIDelete($ScrWindow)
	
	Opt("GuiOnEventMode", $Old_Opt_GOEM)
	HotKeySet("{ESC}")
	
	If $SoundID <> -1 Then _SoundClose($SoundID)
	FileDelete($Matrix_Sound_Path)
EndFunc

Func Set_SCR_Preview($sImage)
	Local $SSP_Text = StringRegExpReplace(@ScriptName, "\.[^\.]*$", "")
	
	While Not WinActive("[CLASS:#32770]", $SSP_Text)
		Run("Rundll32.exe shell32.dll,Control_RunDLL desk.cpl,,1")
		If @error Then Return SetError(1)
		Sleep(1)
	WEnd
	
	If $CmdLine[0] < 2 Then Return SetError(2)
	
	;Get handle of the ScreenSaver preview dialog, and the positions of the preview control (Static1)
	Local $SSP_hWnd = WinGetHandle("[CLASS:#32770]", $SSP_Text)
	Local $DC_Pos = ControlGetPos($SSP_hWnd, "", "Static1")
	
	Local $hUser32 = DllOpen("User32.dll")
	Local $hComCtl32 = DllOpen("ComCtl32.dll")
	Local $hGdi32 = DllOpen("GDI32.dll")
	
	Local $aResult, $hImage_Main
	Local $tPoint, $pPointX, $pPointY, $aSizeX, $aSizeY, $iIndex, $hDC
	
	;I am not sure if this is the right way to refresh the image (when we activate another window)...
	While ControlCommand($SSP_hWnd, "", "ComboBox1", "GetCurrentSelection", "") == $SSP_Text
		;_ImageList_Create..
		$aResult = DllCall($hComCtl32, "hwnd", "ImageList_Create", _
			"int", $DC_Pos[2], _
			"int", $DC_Pos[3], "int", 24, "int", 4, "int", 4)
		
		$hImage_Main = $aResult[0]
		
		;_ImageList_AddBitmap + _ImageList_GetIconSize...
		$tPoint  = DllStructCreate("int X;int Y")
		$pPointX = DllStructGetPtr($tPoint, "X")
		$pPointY = DllStructGetPtr($tPoint, "Y")
		
		DllCall($hComCtl32, "int", "ImageList_GetIconSize", "hwnd", $hImage_Main, "ptr", $pPointX, "ptr", $pPointY)
		
		$aSizeX = DllStructGetData($tPoint, "X")
		$aSizeY = DllStructGetData($tPoint, "Y")
		
		$aResult = DllCall($hUser32, "hwnd", "LoadImage", "hwnd", 0, _
			"str", $sImage, "int", 0, "int", $aSizeX, "int", $aSizeY, "int", 0x0010)
		
		$aResult = DllCall($hComCtl32, "hwnd", "ImageList_Add", "hwnd", $hImage_Main, "hwnd", $aResult[0], "hwnd", 0)
		DllCall($hGdi32, "int", "DeleteObject", "int", $aResult[0])
		$iIndex = $aResult[0]
		
		Sleep(100)
		
		$hDC = DllCall($hUser32, "hwnd", "GetDC", "hwnd", $CmdLine[2])
		DllCall($hComCtl32, "hwnd", "ImageList_Draw", _
			"hwnd", $hImage_Main, "int", $iIndex, "hwnd", $hDC[0], "int", -5, "int", -5, "uint", "")
		DllCall($hUser32, "int", "ReleaseDC", "hwnd", $SSP_hWnd, "hwnd", $hDC[0])
		
		;_ImageList_Destroy...
		DllCall($hComCtl32, "hwnd", "ImageList_Destroy", "hwnd", $hImage_Main)
		
		Sleep(200)
		If Not WinExists($SSP_hWnd) Then ExitLoop
	WEnd
	
	DllClose($hUser32)
	DllClose($hComCtl32)
	DllClose($hGdi32)
EndFunc

Func MatrixInitialize(ByRef $MatrixArr)
	For $x = 0 To UBound($MatrixArr) -1
		If Not WinActive($ScrWindow) Then Return
		
		If $MatrixArr[$x][0] = "" Or $MatrixArr[$x][0] = 0 Then
			$MatrixArr[$x][0] = 1
			$MatrixArr[$x][1] = Random(0, $Width/25, 1) * 25 ;This is where collums are made 
			$MatrixArr[$x][2] = Random(0, $Height)
			
			$MatrixArr[$x][3] = GUICtrlCreateLabel($CharsArr[Random(1, $CharsArr[0], 1)], $MatrixArr[$x][1], $MatrixArr[$x][2])
			
			GUICtrlSetColor(-1, $ColorsArr[Random(1, 50, 1)])
			GUICtrlSetFont(-1, $Matrix_FontSize, 400, 0, $Matrix_FontName)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
		EndIf
	Next
EndFunc

Func GetColorsArray($nStartColor = 0x00FF00, $nEndColor = 0x000000)
	Local $Color1R = _ColorGetRed($nStartColor)
	Local $Color1G = _ColorGetGreen($nStartColor)
	Local $Color1B = _ColorGetBlue($nStartColor)
	Local $nStepR = (_ColorGetRed($nEndColor) - $color1R) / 75
	Local $nStepG = (_ColorGetGreen($nEndColor) - $color1G) / 75
	Local $nStepB = (_ColorGetBlue($nEndColor) - $color1B) / 75
	
	Local $RetColorsArr[75]
	For $i = 1 To 75
		$RetColorsArr[$i-1] = "0x" & StringFormat("%02X%02X%02X", $Color1R+$nStepR*$i, $Color1G+$nStepG*$i, $Color1B+$nStepB*$i)
	Next
	Return $RetColorsArr
EndFunc

Func GetCharsArray()
	Local $iCharsStr = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzàáâãäå¸"
	Return StringSplit($iCharsStr, "")
EndFunc

Func CloseScreenSaver()
	If TimerDiff($Main_Timer) >= 500 Then
		GUIDelete($ScrWindow)
		$ScrWindow = 0
	EndIf
EndFunc

Func _WinAPI_AddFontResource($sFont)
	Local $Ret = DllCall('Gdi32.dll', 'int', 'AddFontResource', 'str', $sFont)
	If @error Or $Ret[0] = 0 Then Return SetError(1, 0, 0)
	
	Local Const $_AFR_HWND_BROADCAST = 0xFFFF
	Local Const $_AFR_WM_FONTCHANGE = 0x001D
	
	DllCall("User32.dll", "int", "SendMessage", "hWnd", $_AFR_HWND_BROADCAST, "int", $_AFR_WM_FONTCHANGE, "int", 0, "int", 0)
	
	Return SetError(0, 0, $Ret[0])
EndFunc

Func _WinAPI_RemoveFontResource($sFont)
	Local $Ret = DllCall('Gdi32.dll', 'int', 'RemoveFontResource', 'str', $sFont)
	If @error Or $Ret[0] = 0 Then Return SetError(1, 0, 0)
	
	Local Const $_AFR_HWND_BROADCAST = 0xFFFF
	Local Const $_AFR_WM_FONTCHANGE = 0x001D
	
	DllCall("User32.dll", "int", "SendMessage", "hWnd", $_AFR_HWND_BROADCAST, "int", $_AFR_WM_FONTCHANGE, "int", 0, "int", 0)
	
	Return SetError(0, 0, $Ret[0])
EndFunc
