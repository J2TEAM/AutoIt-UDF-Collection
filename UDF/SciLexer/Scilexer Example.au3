#include "_SciLexer.au3"
#include <SkinH.au3>
#include <BlockInputEx.au3>
#include <Inet.au3>

Opt("GUIOnEventMode", 1)


_SkinH_Init(@ScriptDir, 0)
_SkinH_AttachEx('QQ2009.she')

$hGUI = GUICreate("Yagami Raito", 650, 635)
$hProgress = GUICtrlCreateProgress(50, 575, 300, 45)
GUICtrlCreateButton("Save to Clipboard",410,575,200,45)
GUICtrlSetOnEvent(-1, "Save2Clip")
GUISetIcon("icon.ico")

$Sci = Sci_CreateEditor($hGUI, 10, 10, 630, 550 )
InitEditor($Sci,"au3.keywords.properties")

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUISetState(@SW_SHOW, $hGUI )

_BlockInputEx(3,'0x25|0x26|0x27|0x28','',$hGUI)

Sci_AddLines($Sci, _INetGetSource("http://pastebin.com/download.php?i=JNaN6A05"), 0)




While 1
	GUICtrlSetData($hProgress,Round(Sci_GetCurrentLine($Sci)/Sci_GetLineCount($Sci)*100))
WEnd

Func Save2Clip()
	ClipPut(Sci_GetText($Sci))
	MsgBox(64,'','Source code has been saved to clipboard successfully!')
EndFunc

Func _Exit()
	Exit
EndFunc

