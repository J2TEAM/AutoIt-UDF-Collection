#include <WinAPI.au3>
Opt("MustDeclareVars", 1)
Global $hCBTHook

For $flag = 0 To 7
	_MsgBox($flag, "Endless Love", "MsgBox Custom Text " & $flag + 1)
Next

Func _MsgBox($flag, $title, $text, $timeout = 0, $hwnd = Default)
	Local $hHookProc = DllCallbackRegister("CBTHookProc", "int", "int;int;int")
	Local $nThreadID = _WinAPI_GetCurrentThreadId()
	$hCBTHook = _WinAPI_SetWindowsHookEx($WH_CBT, DllCallbackGetPtr($hHookProc), 0, $nThreadID)
	Local $nRet = MsgBox($flag, $title, $text, $timeout, $hwnd)
	Local $nError = @error
	_WinAPI_UnhookWindowsHookEx($hCBTHook)
	DllCallbackFree($hHookProc)
	Return SetError($nError, "", $nRet)
EndFunc   ;==>_MsgBox

Func CBTHookProc($nCode, $wParam, $lParam)
	If $nCode < 0 Then
		Return _WinAPI_CallNextHookEx($hCBTHook, $nCode, $wParam, $lParam)
	EndIf
	Switch $nCode
		Case 5;=HCBT_ACTIVATE
			_WinAPI_SetDlgItemText($wParam, 1, "OK") ; OK
			_WinAPI_SetDlgItemText($wParam, 2, "Hủy bỏ") ; Cancel
			_WinAPI_SetDlgItemText($wParam, 3, "Hủy bỏ") ; Abort
			_WinAPI_SetDlgItemText($wParam, 4, "Thử lại") ; Retry
			_WinAPI_SetDlgItemText($wParam, 5, "Bỏ qua") ; Ignore
			_WinAPI_SetDlgItemText($wParam, 6, "Có") ; Yes
			_WinAPI_SetDlgItemText($wParam, 7, "Không") ; No
			_WinAPI_SetDlgItemText($wParam, 8, "Trợ giúp") ; Help
			_WinAPI_SetDlgItemText($wParam, 10, "Thử lại") ; Try Again
			_WinAPI_SetDlgItemText($wParam, 11, "Tiếp tục") ; Continue
	EndSwitch
	Return _WinAPI_CallNextHookEx($hCBTHook, $nCode, $wParam, $lParam)
EndFunc   ;==>CBTHookProc

Func _WinAPI_SetDlgItemText($hDlg, $nIDDlgItem, $lpString)
	Local $aRet = DllCall('user32.dll', "int", "SetDlgItemTextW", _
			"hwnd", $hDlg, _
			"int", $nIDDlgItem, _
			"wstr", $lpString)

	If IsArray($aRet) Then Return $aRet[0]
	Return SetError(-1, 0, "")
EndFunc   ;==>_WinAPI_SetDlgItemText
