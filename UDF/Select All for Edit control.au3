#include <GUIConstantsEx.au3>
#include <GUIEdit.au3>
#include <WinAPI.au3>

$hGUI = GUICreate("Test", 500, 500)

$hInput1 = GUICtrlCreateEdit("here is some text 1", 10, 10, 480, 240)
$hInput2 = GUICtrlCreateEdit("here is some text 2", 10, 250, 480, 240)

; Create dummy for accelerator key to activate
$hSelAll = GUICtrlCreateDummy()

GUISetState()

; Set accelerators for Ctrl+a
Dim $AccelKeys[1][2]=[["^a", $hSelAll]]
GUISetAccelerators($AccelKeys)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $hSelAll
            _SelAll()
    EndSwitch
WEnd

Func _SelAll()
    $hWnd = _WinAPI_GetFocus()
    $class = _WinAPI_GetClassName($hWnd)
    If $class = 'Edit' Then _GUICtrlEdit_SetSel($hWnd, 0, -1)
EndFunc   ;==>_SelAll