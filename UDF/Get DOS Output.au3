#NoTrayIcon
;~ #include <Constants.au3>

ConsoleWrite(_GetDOSOutput('ping google.com'))

Func _GetDOSOutput($sCommand)
    Local $iPID, $sOutput = ''

    $iPID = Run('"' & @ComSpec & '" /c ' & $sCommand, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
    While 1
        $sOutput &= StdoutRead($iPID, False, False)
        If @error Then
            ExitLoop
        EndIf
        Sleep(10)
    WEnd
    Return $sOutput
EndFunc