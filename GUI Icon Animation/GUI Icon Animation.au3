#Region AutoIt3Wrapper directives section
#AutoIt3Wrapper_Icon=E:\wamp\www\favicon.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=Y
#AutoIt3Wrapper_Res_Comment=Developed by Juno_okyo
#AutoIt3Wrapper_Res_Description=Developed by Juno_okyo
#AutoIt3Wrapper_Res_Fileversion=1.0.0.15
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y
#AutoIt3Wrapper_Res_ProductVersion=1.0.0.0;=>Edit
#AutoIt3Wrapper_Res_LegalCopyright=(C) 2015 Juno_okyo. All rights reserved.

#AutoIt3Wrapper_Res_Icon_Add=icons\1.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\2.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\3.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\4.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\5.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\6.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\7.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\8.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\9.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\10.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\11.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\12.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\13.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\14.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\15.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\16.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\17.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\18.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\19.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\20.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\21.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\22.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\23.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\24.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\25.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\26.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\27.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\28.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\29.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\30.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\31.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\32.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\33.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\34.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\35.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\36.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\37.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\38.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\39.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\40.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\41.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\42.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\43.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\44.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\45.ico
#EndRegion AutoIt3Wrapper directives section

#NoTrayIcon

#Region Includes
#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#EndRegion Includes

_Singleton(@ScriptName)

#Region Options
Opt('MustDeclareVars', 1)
Opt('WinTitleMatchMode', 2)
Opt('GUICloseOnESC', 0)
Opt('GUIOnEventMode', 1)
Opt('TrayOnEventMode', 1)
#EndRegion Options

; Script Start - Add your code below here
#Region ### START Koda GUI section ### Form=
Global $MainForm = GUICreate("Juno_okyo", 220, 150, -1, -1, -1, BitOR($WS_EX_TOPMOST, $WS_EX_WINDOWEDGE))
GUISetFont(12, 400, 0, "Arial")
GUISetOnEvent($GUI_EVENT_CLOSE, "MainFormClose")
Global $Label = GUICtrlCreateLabel("GUI Icon Animation", 15, 20, 196, 28)
GUICtrlSetFont(-1, 16, 800, 0, "Arial")
GUICtrlSetColor(-1, 0x000080)
GUICtrlCreateLabel("Created by Juno_okyo", 20, 60, 178, 26)
Global $icon = GUICtrlCreateIcon('', '', 182, 60, 16, 16)
Global $btn = GUICtrlCreateButton('Show me again', 45, 100, 130, 28)
GUICtrlSetCursor(-1, 0)
GUICtrlSetOnEvent(-1, 'BtnClick')
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

;=> Call function when GUI is already display
BtnClick()

While 1
	Sleep(100)
WEnd

Func BtnClick()
	If @Compiled Then
		_GuiIconAnimation(45)
	Else
		_GuiIconAnimation2(@ScriptDir & '\icons\', 45)
	EndIf
EndFunc   ;==>BtnClick

Func _GuiIconAnimation($max, $timeout = 60)
	Local $min = 201
	$max = $min + $max - 1

	For $i = $min To $max
		GUISetIcon(@ScriptFullPath, $i)
		GUICtrlSetImage($icon, @ScriptFullPath, $i)
		Sleep($timeout)
	Next
EndFunc   ;==>_GuiIconAnimation2

Func _GuiIconAnimation2($icon_dir, $max, $prefix = '', $gui_handled = Default, $timeout = 60)
	If Not FileExists($icon_dir) Or Not $max > 1 Then Return False

	For $i = 1 To $max
		Local $path = $icon_dir & $prefix & $i & '.ico'
		If FileExists($path) Then
			GUISetIcon($path, -1, $gui_handled)
			GUICtrlSetImage($icon, $path) ;=> This line only for demo, you can remove it
			Sleep($timeout)
		EndIf
	Next
EndFunc   ;==>_GuiIconAnimation

Func MainFormClose()
	Exit
EndFunc   ;==>MainFormClose
