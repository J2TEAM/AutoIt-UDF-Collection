#NoTrayIcon
#include "zip.au3"

Local $path = @ScriptDir & '\test.zip'

If FileExists($path) Then
	_Zip_UnzipAll($path, @ScriptDir)
EndIf
