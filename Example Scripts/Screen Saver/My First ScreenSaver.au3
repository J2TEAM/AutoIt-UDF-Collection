#NoTrayIcon
#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <Misc.au3>

_Singleton($CmdLineRaw)

Global $MainText = RegRead("HKEY_CURRENT_USER\Software\MySCR", "MainText")
If $MainText = "" Then $MainText = "My First Screen Saver..."

Global $TextSpeed = RegRead("HKEY_CURRENT_USER\Software\MySCR", "TextSpeed")
If $TextSpeed = "" Then $TextSpeed = 100

Global $FontName = RegRead("HKEY_CURRENT_USER\Software\MySCR", "FontName")
If $FontName = "" Then $FontName = "Georgia"

Global $FontSize = RegRead("HKEY_CURRENT_USER\Software\MySCR", "FontSize")
If $FontSize = "" Then $FontSize = 24

Global $FontWeight = RegRead("HKEY_CURRENT_USER\Software\MySCR", "FontWeight")
If $FontWeight = "" Then $FontWeight = 600

Global $FontAttrib = RegRead("HKEY_CURRENT_USER\Software\MySCR", "FontAttribute")
If $FontAttrib = "" Then $FontAttrib = 0

Global $FontColor = RegRead("HKEY_CURRENT_USER\Software\MySCR", "FontColor")
If $FontColor = "" Then $FontColor = 0xFFFFFF

Global $MousePos = MouseGetPos()

Global $Main_Timer, $ScrWindow
Global $Preview_Image = @ScriptDir & "\SCR_Image.bmp"

If $CmdLineRaw = "/S" Then
	ScreenSaver_Proc()
ElseIf $CmdLine[0] = 0 Or StringLeft($CmdLineRaw, 3) = "/c:" Then
	SCR_Options_Proc(StringLeft($CmdLineRaw, 3) = "/c:")
ElseIf $CmdLine[0] >= 2 And $CmdLine[1] = "/p" Then
	;Here goes the part with image preview for the desktop properties dialog
	If FileExists($Preview_Image) Then
		Set_SCR_Preview($Preview_Image)
		FileDelete($Preview_Image)
	EndIf
EndIf

Func SCR_Options_Proc($DisableParent=0)
	Local $ParentHwnd = 0
	
	If $DisableParent = 1 Then
		$ParentHwnd = WinGetHandle("")
		WinSetState($ParentHwnd, "", @SW_DISABLE)
	EndIf
	
	Local $GUI = GuiCreate("My Screensaver Options", 650, 250, -1, -1, -1, $WS_EX_TOPMOST+$WS_EX_TOOLWINDOW, $ParentHwnd)
	
	GuiCtrlCreateLabel("Speed of text:", 10, 15)
	Local $SpeedSlider = GuiCtrlCreateSlider(90, 14, 150, 20)
	GUICtrlSetLimit(-1, 200, 0)
	GUICtrlSetData(-1, $TextSpeed)
	
	Local $FontButton = GUICtrlCreateButton("Choose Text Font", 10, 80, 110, 20)
	
	GUICtrlCreateGroup("Text Preview", 10, 105, 630, 100)
	Local $DemoTextLabel = GUICtrlCreateEdit($MainText, 20, 130, 610, 70, $ES_CENTER+$ES_AUTOHSCROLL, _
		0x990+$WS_EX_STATICEDGE+$WS_EX_CLIENTEDGE)
	GUICtrlSetFont($DemoTextLabel, $FontSize, $FontWeight, $FontAttrib, $FontName)
	GUICtrlSetColor($DemoTextLabel, $FontColor)
	GUICtrlSetBkColor($DemoTextLabel, 0)
	
	Local $OK = GuiCtrlCreateButton("Preview", 10, 220, 70, 20)
	Local $Close = GuiCtrlCreateButton("Close", 170, 220, 70, 20)
	Local $About = GuiCtrlCreateButton("About", 90, 220, 70, 20)
	
	GuiSetState()
	
	While 1
		Switch GUIGetMsg()
			Case $FontButton
				$FontChoose = _ChooseFont($FontName, $FontSize, 0, 400, 0, 0, 0, $GUI)
				If Not @error Then
					$FontAttrib = $FontChoose[1]
					$FontName = $FontChoose[2]
					$FontSize = $FontChoose[3]
					$FontWeight = $FontChoose[4]
					$FontColor = $FontChoose[7]
					
					GUICtrlSetFont($DemoTextLabel, $FontSize, $FontWeight, $FontAttrib, $FontName)
					GUICtrlSetColor($DemoTextLabel, $FontColor)
				EndIf
			Case $GUI_EVENT_CLOSE, $Close
				If $DisableParent = 1 Then WinSetState($ParentHwnd, "", @SW_ENABLE)
				ExitLoop
			Case $OK
				$MainText = GUICtrlRead($DemoTextLabel)
				$TextSpeed = GUICtrlRead($SpeedSlider)
				
				GUISetState(@SW_HIDE, $GUI)
				ScreenSaver_Proc()
				GUISetState(@SW_SHOW, $GUI)
			Case $About
				_MsgBox(64, "About", "My Screensaver" & @CRLF & @CRLF & "Copyright © " & @YEAR & " - " & @UserName, $GUI)
		EndSwitch
	WEnd
	
	$MainText = GUICtrlRead($DemoTextLabel)
	$TextSpeed = GUICtrlRead($SpeedSlider)
	
	RegWrite("HKEY_CURRENT_USER\Software\MySCR", "FontName", "REG_SZ", $FontName)
	RegWrite("HKEY_CURRENT_USER\Software\MySCR", "FontSize", "REG_SZ", $FontSize)
	RegWrite("HKEY_CURRENT_USER\Software\MySCR", "FontWeight", "REG_SZ", $FontWeight)
	RegWrite("HKEY_CURRENT_USER\Software\MySCR", "FontAttribute", "REG_SZ", $FontAttrib)
	
	RegWrite("HKEY_CURRENT_USER\Software\MySCR", "FontColor", "REG_SZ", $FontColor)
	RegWrite("HKEY_CURRENT_USER\Software\MySCR", "MainText", "REG_SZ", $MainText)
	RegWrite("HKEY_CURRENT_USER\Software\MySCR", "TextSpeed", "REG_SZ", $TextSpeed)
	Exit
EndFunc

Func ScreenSaver_Proc()
	Opt("GuiOnEventMode", 1)
	HotKeySet("{ESC}", "CloseScreenSaver")
	$ScrWindow = GUICreate("", @DesktopWidth, @DesktopHeight, 0, 0, $WS_POPUP, BitOr($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
	
	$MainLabel = GUICtrlCreateLabel($MainText, 0, (@DesktopHeight/2)-20, @DesktopWidth, @DesktopHeight, $ES_CENTER)
	GUICtrlSetFont(-1, $FontSize, $FontWeight, $FontAttrib, $FontName)
	GUICtrlSetColor(-1, $FontColor)
	
	GUISetBkColor(0)
	GUISetCursor(16, 1)
	GUISetState()
	
	$Main_Timer = TimerInit()
	GUISetOnEvent($GUI_EVENT_MOUSEMOVE, "CloseScreenSaver")
	GUISetOnEvent($GUI_EVENT_PRIMARYDOWN, "CloseScreenSaver")
	
	$LabelPos = ControlGetPos($ScrWindow, "", $MainLabel)
	$LabelX = $LabelPos[0]
	$LabelY = $LabelPos[1]
	
	While WinExists($ScrWindow)
		GUICtrlSetPos($MainLabel, $LabelX, $LabelY)
		$LabelX += 2
		If $LabelX >= (@DesktopWidth-50) Then $LabelX = -($LabelPos[2])+(@DesktopWidth/2)
		Sleep(120 - $TextSpeed)
		If Not WinExists($ScrWindow) Then ExitLoop
	WEnd
	Opt("GuiOnEventMode", 0)
	HotKeySet("{ESC}")
EndFunc

Func Set_SCR_Preview($sImage)
	Local $SSP_Text = StringRegExpReplace(@ScriptName, "\.[^\.]*$", "")
	
	While Not WinActive("[CLASS:#32770]", $SSP_Text)
		Run("rundll32.exe shell32.dll,Control_RunDLL desk.cpl,,1")
		If @error Then Return SetError(1)
		Sleep(1)
	WEnd
	
	If $CmdLine[0] < 2 Then Return SetError(2)
	
	;Get handle of the ScreenSaver preview dialog, and the positions of the preview control (Static1)
	Local $SSP_hWnd = WinGetHandle("[CLASS:#32770]", $SSP_Text)
	Local $DC_Pos = ControlGetPos($SSP_hWnd, "", "Static1")
	
	;I am not sure if this is the right way to refresh the image (when we activate another window)...
	While ControlCommand($SSP_hWnd, "", "ComboBox1", "GetCurrentSelection", "") = $SSP_Text
		;_ImageList_Create..
		Local $aResult = DllCall("ComCtl32.dll", "hwnd", "ImageList_Create", _
			"int", $DC_Pos[2], _
			"int", $DC_Pos[3], "int", 24, "int", 4, "int", 4)
		Local $hImage_Main = $aResult[0]
		
		;_ImageList_AddBitmap + _ImageList_GetIconSize...
		Local $tPoint, $pPointX, $pPointY, $aSizeX, $aSizeY
		Local $iIndex, $hDC
		
		$tPoint  = DllStructCreate("int X;int Y")
		$pPointX = DllStructGetPtr($tPoint, "X")
		$pPointY = DllStructGetPtr($tPoint, "Y")
		DllCall("ComCtl32.dll", "int", "ImageList_GetIconSize", "hwnd", $hImage_Main, "ptr", $pPointX, "ptr", $pPointY)
		
		$aSizeX = DllStructGetData($tPoint, "X")
		$aSizeY = DllStructGetData($tPoint, "Y")
		
		$aResult = DllCall("User32.dll", "hwnd", "LoadImage", "hwnd", 0, _
			"str", $sImage, "int", 0, "int", $aSizeX, "int", $aSizeY, "int", 0x0010)
		$aResult = DllCall("ComCtl32.dll", "hwnd", "ImageList_Add", "hwnd", $hImage_Main, "hwnd", $aResult[0], "hwnd", 0)
		DllCall("GDI32.dll", "int", "DeleteObject", "int", $aResult[0])
		$iIndex = $aResult[0]
		
		Sleep(100)
		
		$hDC = DllCall("User32.dll", "hwnd", "GetDC", "hwnd", $CmdLine[2])
		DllCall("ComCtl32.dll", "hwnd", "ImageList_Draw", _
			"hwnd", $hImage_Main, "int", $iIndex, "hwnd", $hDC[0], "int", -5, "int", -5, "uint", "")
		DllCall("User32.dll", "int", "ReleaseDC", "hwnd", $SSP_hWnd, "hwnd", $hDC[0])
		
		;_ImageList_Destroy...
		DllCall("ComCtl32.dll", "hwnd", "ImageList_Destroy", "hwnd", $hImage_Main)
		
		Sleep(200)
		If Not WinExists($SSP_hWnd) Then ExitLoop
	WEnd
EndFunc

Func _MsgBox($MsgBoxType, $MsgBoxTitle, $MsgBoxText, $mainGUI=0)
    $ret = DllCall ("user32.dll", "int", "MessageBox", _
            "hwnd", $mainGUI, _
            "str", $MsgBoxText , _
            "str", $MsgBoxTitle, _
            "int", $MsgBoxType)
    Return $ret [0]
EndFunc

Func CloseScreenSaver()
	If TimerDiff($Main_Timer) >= 500 Then GUIDelete($ScrWindow)
EndFunc
