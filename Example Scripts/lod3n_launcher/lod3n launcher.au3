; Special thanks to GaryFrost for updating this to work with AutoIt v3.2.12.0!

#NoTrayIcon
#include <GDIPlus.au3>; this is where the magic happens, people
#include <GuiComboBox.au3>
#include <File.au3>
#include <Array.au3>
#include <WindowsConstants.au3>
#include <GuiConstantsEx.au3>
#include <ButtonConstants.au3>
Opt("MustDeclareVars", 0)

Global Const $AC_SRC_ALPHA = 1
;~ Global Const $ULW_ALPHA         = 2
Global $old_string = "", $runthis = ""
Global $launchDir = @DesktopDir

; Load PNG file as GDI bitmap
_GDIPlus_Startup()
$pngSrc = @ScriptDir & "\LaunchySkin.png"
$hImage = _GDIPlus_ImageLoadFromFile($pngSrc)

; Extract image width and height from PNG
$width = _GDIPlus_ImageGetWidth($hImage)
$height = _GDIPlus_ImageGetHeight($hImage)

; Create layered window
$GUI = GUICreate("lod3n launcher", $width, $height, -1, -1, $WS_POPUP, $WS_EX_LAYERED)
SetBitmap($GUI, $hImage, 0)
; Register notification messages
GUIRegisterMsg($WM_NCHITTEST, "WM_NCHITTEST")
GUISetState()
WinSetOnTop($GUI, "", 1)
;fade in png background
For $i = 0 To 255 Step 10
    SetBitmap($GUI, $hImage, $i)
Next


; create child MDI gui window to hold controls
; this part could use some work - there is some flicker sometimes...
$controlGui = GUICreate("ControlGUI", $width, $height, 0, 0, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $GUI)

; child window transparency is required to accomplish the full effect, so $WS_EX_LAYERED above, and
; I think the way this works is the transparent window color is based on the image you set here:
GUICtrlCreatePic(@ScriptDir & "\grey.gif", 0, 0, $width, $height)
GUICtrlSetState(-1, $GUI_DISABLE)

; just a text label
GUICtrlCreateLabel("Type the name of a file on your desktop and press Enter", 50, 12, 140, 50)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetColor(-1, 0xFFFFFF)

; combo box listing all items on desktop
$Combo = GUICtrlCreateCombo("", 210, 12, 250, -1)
GUICtrlSetFont($Combo, 12)


; set default button for Enter key activation - renders outside GUI window
$goButton = GUICtrlCreateButton("Go", $width, $height, 10, 10, $BS_DEFPUSHBUTTON)

GUISetState()

; get list of files on desktop, show in combobox
$aFileList = _FileListToArray($launchDir)
_ArraySort($aFileList, 0, 1)
$FileList = _ArrayToString($aFileList, "|", 1)
GUICtrlSetData($Combo, $FileList)

AdlibRegister("GoAutoComplete", 1000); combo autocomplete every message loop = often incorrect
While 1
    $msg = GUIGetMsg()
    Select
        Case $msg = $GUI_EVENT_CLOSE
            ExitLoop
        Case $msg = $goButton
            $runthis = GUICtrlRead($Combo)
            ExitLoop
    EndSelect
WEnd
AdlibUnRegister()

If $runthis <> "" Then
    If FileExists($launchDir & "\" & $runthis) Then
        Beep(1000, 50)
        Beep(2000, 50)
        ShellExecute($runthis, "", $launchDir)
    EndIf
EndIf

GUIDelete($controlGui)
;fade out png background
For $i = 255 To 0 Step -10
    SetBitmap($GUI, $hImage, $i)
Next

; Release resources
_WinAPI_DeleteObject($hImage)
_GDIPlus_Shutdown()



Func GoAutoComplete()
    _GUICtrlComboBox_AutoComplete($Combo)
EndFunc   ;==>GoAutoComplete

; ====================================================================================================

; Handle the WM_NCHITTEST for the layered window so it can be dragged by clicking anywhere on the image.
; ====================================================================================================

Func WM_NCHITTEST($hWnd, $iMsg, $iwParam, $ilParam)
    If ($hWnd = $GUI) And ($iMsg = $WM_NCHITTEST) Then Return $HTCAPTION
EndFunc   ;==>WM_NCHITTEST

; ====================================================================================================

; SetBitMap
; ====================================================================================================

Func SetBitmap($hGUI, $hImage, $iOpacity)
    Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend

    $hScrDC = _WinAPI_GetDC(0)
    $hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
    $hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
    $hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
    $tSize = DllStructCreate($tagSIZE)
    $pSize = DllStructGetPtr($tSize)
    DllStructSetData($tSize, "X", _GDIPlus_ImageGetWidth($hImage))
    DllStructSetData($tSize, "Y", _GDIPlus_ImageGetHeight($hImage))
    $tSource = DllStructCreate($tagPOINT)
    $pSource = DllStructGetPtr($tSource)
    $tBlend = DllStructCreate($tagBLENDFUNCTION)
    $pBlend = DllStructGetPtr($tBlend)
    DllStructSetData($tBlend, "Alpha", $iOpacity)
    DllStructSetData($tBlend, "Format", $AC_SRC_ALPHA)
    _WinAPI_UpdateLayeredWindow($hGUI, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
    _WinAPI_ReleaseDC(0, $hScrDC)
    _WinAPI_SelectObject($hMemDC, $hOld)
    _WinAPI_DeleteObject($hBitmap)
    _WinAPI_DeleteDC($hMemDC)
EndFunc   ;==>SetBitmap


; I don't like AutoIt's built in ShellExec. I'd rather do the DLL call myself.
Func _ShellExecute($sCmd, $sArg = "", $sFolder = "", $rState = @SW_SHOWNORMAL)
    $aRet = DllCall("shell32.dll", "long", "ShellExecute", _
            "hwnd", 0, _
            "string", "", _
            "string", $sCmd, _
            "string", $sArg, _
            "string", $sFolder, _
            "int", $rState)
    If @error Then Return 0

    $RetVal = $aRet[0]
    If $RetVal > 32 Then
        Return 1
    Else
        Return 0
    EndIf
EndFunc   ;==>_ShellExecute