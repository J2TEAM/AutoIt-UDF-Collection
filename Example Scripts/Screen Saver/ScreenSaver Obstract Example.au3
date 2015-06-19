#NoTrayIcon
#include <GuiConstants.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>

_Singleton($CmdLineRaw)

#CS
If Not @Compiled Then
	$AutoItPath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt", "InstallDir")
	$AutoItExe = $AutoItPath & "\Aut2Exe\Aut2exe.exe"
	
	$SCR_Name = StringTrimRight(@ScriptName, 4)
	$SCR_Path = StringTrimRight(@ScriptFullPath, 3) & "scr"
	$SCR_Icon = $AutoItPath & "\Icons\filetype-blank.ico"
	
	RunWait($AutoItExe & ' /in "' & FileGetShortName(@ScriptFullPath) & '" /out "' & $SCR_Path & '" /icon "' & $SCR_Icon & '"')
	
	If @error Or Not FileExists($SCR_Path) Then
		MsgBox(48, "Error!", "There was an error to compile the SCR file.")
		Exit
	EndIf
	
	MsgBox(64, "Done!", "Compiling is finished!" & @LF & $SCR_Name & " is saved as:" & @LF & @LF & $SCR_Path)
	Exit
EndIf
#CE

If $CmdLineRaw = "/S" Then
	ScreenSaver_Proc()
ElseIf $CmdLine[0] = 0 Or StringLeft($CmdLineRaw, 3) = "/c:" Then
	SCR_Options_Proc(StringLeft($CmdLineRaw, 3) = "/c:")
ElseIf $CmdLine[0] >= 2 And $CmdLine[1] = "/p" Then
	;Here goes the part with image preview for the desktop properties dialog
	
	Local $Preview_Image = @ScriptDir & "\SCR_Image.bmp"
	
	If FileExists($Preview_Image) Then
		Set_SCR_Preview($Preview_Image)
		FileDelete($Preview_Image)
	EndIf
EndIf

Func SCR_Options_Proc($DisableParent=0)
	Local $iMsg, $ParentHwnd = 0
	
	;If "/c:" passed as commandline, that's mean that the "Options" button was pressed from the screensaver installation dialog
	;therefore we can disable the parent dialog and open our Options dialog as child
	If $DisableParent = 1 Then
		$ParentHwnd = WinGetHandle("")
		WinSetState($ParentHwnd, "", @SW_DISABLE)
	EndIf
	
	Local $GUI = GuiCreate("ScreenSaver Options", 250, 120, -1, -1, -1, $WS_EX_TOOLWINDOW+$WS_EX_TOPMOST, $ParentHwnd)
	
	GUICtrlCreateLabel("Our Options go here", 30, 20, 200, 30)
	GUICtrlSetFont(-1, 16)
	
	Local $Preview_Button = GUICtrlCreateButton("Preview", 10, 80, 70, 20)
	
	GUISetState()
	
	While 1
		$iMsg = GUIGetMsg()
		Switch $iMsg
			Case $GUI_EVENT_CLOSE
				;Enable back the parent dialog
				If $DisableParent = 1 Then WinSetState($ParentHwnd, "", @SW_ENABLE)
				Exit
			Case $Preview_Button
				ScreenSaver_Proc()
		EndSwitch
	WEnd
EndFunc

Func ScreenSaver_Proc()
	MsgBox(262144+64, "ScreenSaver", "Our ScreenSaver")
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
