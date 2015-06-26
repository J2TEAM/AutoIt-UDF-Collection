#NoTrayIcon
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ie.au3>

Opt('MustDeclareVars', 1)
Opt('WinTitleMatchMode', 2)
Opt('GUICloseOnESC', 0)
Opt('GUIOnEventMode', 1)
Opt('TrayOnEventMode', 1)

Global $oIE = _IECreateEmbedded()

#Region ### START Koda GUI section ### Form=
Global $MainForm = GUICreate("Google Search", 701, 540, -1, -1, -1, BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE))
GUISetFont(12, 400, 0, "Arial")
GUISetOnEvent($GUI_EVENT_CLOSE, "MainFormClose")
GUICtrlCreateObj($oIE, 0, 0, 700, 539)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

main()

While 1
	Sleep(100)
WEnd

Func main()
	_IENavigate($oIE, 'https://www.google.com/')
	Global $input = _IEGetObjById($oIE, 'lst-ib')
	_IEFormElementSetValue($input, 'juno_okyo')
	Global $form = _IEGetObjById($oIE, 'tsf')
	_IEFormSubmit($form)
EndFunc

Func MainFormClose()
	Exit
EndFunc
