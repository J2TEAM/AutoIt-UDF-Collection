; ===============================================================================
;~ This script gets the control under the mouse pointer (active or inactive)
;~ The information then can be used with in conjunction with control functions.
;~ Requires AutoIt v3.3.6.0 or later to run and to view apps maximized.
;~ Big thanks to SmOke_N and Valik their help in creating it.
; ===============================================================================
#include <WinAPI.au3>
#include <Array.au3>
#include <WindowsConstants.au3>

AutoItSetOption("MustDeclareVars", 1)
AutoItSetOption("MouseCoordMode", 1)
AdlibRegister("_Mouse_Control_GetInfoAdlib", 10)
HotKeySet("^!x", "MyExit") ; Press Ctrl+Alt+x to stop the script
;~ #AutoIt3Wrapper_run_debug_mode=Y

Global $pos1 = MouseGetPos()
Global $pos2 = MouseGetPos() ; must be initialized
Global $appHandle = 0, $tPoint = 0, $hWnd = 0, $tRect = 0


While 1
    Sleep(0xFFFFFFF)
WEnd

; ===============================================================================
;~ Retrieves the information of a Control located under the mouse and displayes it in a tool tip next to the mouse.
;~ Function uesd
;~  _Mouse_Control_GetInfo()
;~  GetDlgCtrlID
; ===============================================================================
Func _Mouse_Control_GetInfoAdlib()
    $pos1 = MouseGetPos()
    If $pos1[0] <> $pos2[0] Or $pos1[1] <> $pos2[1] Then ; has the mouse moved?
        Local $a_info = _Mouse_Control_GetInfo()
        Local $aDLL = DllCall('User32.dll', 'int', 'GetDlgCtrlID', 'hwnd', $a_info[0]) ; get the ID of the control
        If @error Then Return
		Local $sTitle = WinGetTitle("[ACTIVE]")
		$tPoint = _WinAPI_GetMousePos()
		$hWnd = _WinAPI_WindowFromPoint($tPoint)
		$tRect = _WinAPI_GetWindowRect($hWnd)
		Local $iColor = PixelGetColor($pos1[0], $pos1[1])
        ToolTip("Title = " & $sTitle & @CRLF & _
				"Handle = " & $a_info[0] & @CRLF & _
                "Class = " & $a_info[1] & @CRLF & _
                "ID = " & $aDLL[0] & @CRLF & _
                "MouseClick = " & $a_info[2] &","&$a_info[3] & @CRLF & _
				"ControlClick = " & DllStructGetData($tPoint, 1) - DllStructGetData($tRect, 1) & ", " & _
				DllStructGetData($tPoint, 2) - DllStructGetData($tRect, 2)& @CRLF& _
                "Advanced Mode = " &'[CLASS:'&$a_info[1]&'; INSTANCE:'&StringRight($a_info[4],stringlen($a_info[4])-stringlen($a_info[1]))&']'  & @CRLF & _ ; optional
				"Color ="&"0x"&Hex($iColor, 6) & @CRLF & _
                "Parent Hwd = " & _WinAPI_GetAncestor($appHandle, $GA_ROOT))
        $pos2 = MouseGetPos()
    EndIf
EndFunc   ;==>_Mouse_Control_GetInfoAdlib

; ===============================================================================
;~ Retrieves the information of a Control located under the mouse.
;~ Uses Windows functions WindowFromPoint and GetClassName to retrieve the information.
;~ Functions used
;~  _GetHoveredHwnd()
;~  _ControlGetClassnameNN()
;~ Returns
;~   [0] = Control Handle of the control
;~   [1] = The Class Name of the control
;~   [2] = Mouse X Pos (converted to Screen Coord)
;~   [3] = Mouse Y Pos (converted to Screen Coord)
;~   [4] = ClassNN
; ===============================================================================
Func _Mouse_Control_GetInfo()
    Local $client_mpos = $pos1 ; gets client coords because of "MouseCoordMode" = 2
    Local $a_mpos
;~  Call to removed due to offset issue $a_mpos = _ClientToScreen($appHandle, $client_mpos[0], $client_mpos[1]) ; $a_mpos now screen coords
    $a_mpos = $client_mpos
    $appHandle = GetHoveredHwnd($client_mpos[0], $client_mpos[1]) ; Uses the mouse to do the equivalent of WinGetHandle()

    If @error Then Return SetError(1, 0, 0)
    Local $a_wfp = DllCall("user32.dll", "hwnd", "WindowFromPoint", "long", $a_mpos[0], "long", $a_mpos[1]) ; gets the control handle
    If @error Then Return SetError(2, 0, 0)

    Local $t_class = DllStructCreate("char[260]")
    DllCall("User32.dll", "int", "GetClassName", "hwnd", $a_wfp[0], "ptr", DllStructGetPtr($t_class), "int", 260)
    Local $a_ret[5] = [$a_wfp[0], DllStructGetData($t_class, 1), $a_mpos[0], $a_mpos[1], "none"]
    Local $sClassNN = _ControlGetClassnameNN($a_ret[0]) ; optional, will run faster without it
    $a_ret[4] = $sClassNN

    Return $a_ret
EndFunc   ;==>_Mouse_Control_GetInfo

; ===============================================================================
; Retrieves the Handle of GUI/Application the mouse is over.
; Similar to WinGetHandle except it used the current mouse position
; Taken from <a href='http://www.autoitscript.com/forum/index.php?showtopic=444962' class='bbc_url' title=''>http://www.autoitscript.com/forum/index.php?showtopic=444962</a>
; Changed to take params to allow only one set of coords to be used.
; Params
;~  $i_xpos - x position of the mouse - usually from MouseGetPos(0)
;~  $i_ypos - x position of the mouse - usually from MouseGetPos(1)
; ===============================================================================
Func GetHoveredHwnd($i_xpos, $i_ypos)
    Local $iRet = DllCall("user32.dll", "int", "WindowFromPoint", "long", $i_xpos, "long", $i_ypos)
    If IsArray($iRet) Then
        $appHandle = $iRet[0]
        Return HWnd($iRet[0])
    Else
        Return SetError(1, 0, 0)
    EndIf
EndFunc   ;==>GetHoveredHwnd

; ===============================================================================
;~ Gets the ClassNN of a control (Classname and Instance Count). This is checked with ControlGetHandle
;~ The instance is really a way to uniquely identify classes with the same name
;~ Big thanks to Valik for writing the function, taken from - <a href='http://www.autoitscript.com/forum/index.php?showtopic=97662' class='bbc_url' title=''>http://www.autoitscript.com/forum/index.php?showtopic=97662</a>
;~ Param
;~  $hControl - the control handle from which you want the ClassNN
;~ Returns
;~  the ClassNN of the given control

; ===============================================================================
Func _ControlGetClassnameNN($hControl)
    If Not IsHWnd($hControl) Then Return SetError(1, 0, "")
    Local Const $hParent = _WinAPI_GetAncestor($appHandle, $GA_ROOT) ; get the Window handle, this is set in GetHoveredHwnd()
    If Not $hParent Then Return SetError(2, 0, "")

    Local Const $sList = WinGetClassList($hParent) ; list of every class in the Window
    Local $aList = StringSplit(StringTrimRight($sList, 1), @LF, 2)
    _ArraySort($aList) ; improves speed
    Local $nInstance, $sLastClass, $sComposite

    For $i = 0 To UBound($aList) - 1
        If $sLastClass <> $aList[$i] Then ; set up the first occurrence of a unique classname
            $sLastClass = $aList[$i]
            $nInstance = 1
        EndIf
        $sComposite = $sLastClass & $nInstance ;build the ClassNN for testing with ControlGetHandle. ClassNN = Class & ClassCount
        ;if ControlGetHandle(ClassNN) matches the given control return else look at the next instance of the classname
        If ControlGetHandle($hParent, "", $sComposite) = $hControl Then
            Return $sComposite
        EndIf
        $nInstance += 1 ; count the number of times the class name appears in the list
    Next
    Return SetError(3, 0, "")

EndFunc   ;==>_ControlGetClassnameNN

Func MyExit() ; stops the script
    ConsoleWrite("Script Stoppted By User" & @CR)
    Exit
EndFunc   ;==>MyExit