#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>

_WinAPI_ShowCursor(False)

HotKeySet("{ESC}", "ExitBlueScr")
Global $DesktopWidth = @DesktopWidth, $DesktopHeight = @DesktopHeight
Global $DesktopDepth = @DesktopDepth, $DesktopRefresh = @DesktopRefresh

;~ Beep(1900,800)

$GUI = GUICreate("", @DesktopWidth + 10, @DesktopHeight + 20)
WinSetOnTop($GUI, '', 1)
GUISetBkColor(0x0000A0)
$Label = GUICtrlCreateLabel("A problem has been detected and Windows has been shut down to prevent damage" & @CRLF & _
		"to your computer." & @CRLF & _
		@CRLF & _
		"The problem seems to be caused by the following file: SPCMDCON.SYS" & @CRLF & _
		@CRLF & _
		"PAGE_FAULT_IN_NONPAGED_AREA" & @CRLF & _
		@CRLF & _
		"If this is the first time you've seen this stop error screen," & @CRLF & _
		"restart your computer. If this screen appears again, follow" & @CRLF & _
		"these steps:" & @CRLF & _
		@CRLF & _
		"Check to make sure any new hardware or software is properly installed." & @CRLF & _
		"If this is a new installation, ask your hardware or software manufacturer" & @CRLF & _
		"for any Windows updates you might need." & @CRLF & _
		@CRLF & _
		"If problems continue, disable or remove any newly installed hardware" & @CRLF & _
		"or software. Disable BIOS memory options such as caching or shadowing." & @CRLF & _
		"If you need to use Safe Mode to remove or disable components, restart" & @CRLF & _
		"your computer, press F8 to select Advanced Startup Options, and then" & @CRLF & _
		"select Safe Mode." & @CRLF & _
		@CRLF & _
		"Technical information:" & @CRLF & _
		@CRLF & _
		"*** STOP: 0x00000050 (0xFD3094C2,0x00000001,0xFBFE7617,0x00000000)" & @CRLF & _
		@CRLF & _
		@CRLF & _
		"***  SPCMDCON.SYS - Address FBFE7617 base at FBFE5000, DateStamp 3d6dd67c", 10, 25, @DesktopWidth - 10, @DesktopHeight - 10)
GUICtrlSetFont(-1, 17, 100, -1, "Lucida Console")
GUICtrlSetColor(-1, 0xD8D8D8)
GUICtrlSetOnEvent(-1, "None")
GUISetState()

While 1
	Sleep(100)
WEnd

Func None()

EndFunc   ;==>None

Func ExitBlueScr()
	_WinAPI_ShowCursor(True)
	Exit
EndFunc   ;==>ExitBlueScr