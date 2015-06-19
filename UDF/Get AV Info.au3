#NoTrayIcon
#include <Array.au3>

Global Const $___WMI_WBEMFLAGFORWARDONLY = 0x20 ; Causes a forward-only enumerator to be returned. Forward-only enumerators are generally much faster and use less memory than conventional enumerators, but they do not allow calls to 'SWbemObject.Clone_()'.
Global Const $___WMI_WBEMFLAGRETURNIMMEDIATELY = 0x10 ; Causes the call to return immediately.

Local $aAVInfo = _GetAVInfo() ; Local host.
If Not @error Then
    _ArrayDisplay($aAVInfo, "$aAVInfo")
Else ; Error.
    MsgBox(0, "", "ERROR!")
EndIf

Func _GetAVInfo($sComputerName = ".")
    Local $aReturn[4]
    Local $oWMIService = ObjGet("winmgmts:\\" & $sComputerName & "\root\SecurityCenter2")
    If Not @error Then
        Local $colItems = $oWMIService.ExecQuery("Select * From AntiVirusProduct", "WQL", $___WMI_WBEMFLAGFORWARDONLY + $___WMI_WBEMFLAGRETURNIMMEDIATELY)
        If IsObj($colItems) Then
            For $colItem In $colItems
                $aReturn[0] = $colItem.displayName
                $aReturn[1] = $colItem.productState
                $aReturn[2] = $colItem.pathToSignedProductExe
                $aReturn[3] = $colItem.pathToSignedReportingExe
            Next
            Switch StringMid(Hex($aReturn[1]), 5, 2)
                Case "00", "01"
                    $aReturn[1] = "Disabled"
                Case "10", "11"
                    $aReturn[1] = "Enabled"
            EndSwitch
        Else ; Error.
            SetError(2, 0)
        EndIf
    Else ; Error.
        SetError(1, 0)
    EndIf
    Return $aReturn
EndFunc ;==>_GetAVInfo