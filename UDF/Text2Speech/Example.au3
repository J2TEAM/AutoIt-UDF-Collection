#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <Array.au3>
#include <GUIEdit.au3>
#include "GUICtrlPic.au3"

$Object = ObjCreate("SAPI.SpVoice")

Const $SSFMCreateForWrite = 3
Global Enum Step *2 $SPF_ASYNC, _
		$SPF_PURGEBEFORESPEAK, _
		$SPF_IS_FILENAME, _
		$SPF_IS_XML, _
		$SPF_IS_NOT_XML, _
		$SPF_PERSIST_XML, _
		$SPF_NLP_SPEAK_PUNC, _
		$SPF_NLP_MASK, _
		$SPF_VOICE_MASK, _
		$SPF_UNUSED_FLAGS

$Voice = _GetVoices(ObjCreate("SAPI.SpVoice"))
$Voices = ""
For $i = 1 To UBound($Voice) - 1
	$Voices &= $Voice[$i] & "|"
Next

$strFName = @ScriptDir & '\TTS.wav'
$FileRead = ''

$SpFS = GUICreate('Text2Speech - Yagami Raito', 620, 480, 351, 228)
;GUISetBkColor(0XFFFFFF,$SpFS )
$Model = _GUICtrlPic_Create("", 390, 0, 242, 480, BitOR($SS_CENTERIMAGE, $SS_SUNKEN, $SS_NOTIFY), Default)
_GUICtrlPic_SetImage($Model, @ScriptDir & "\Data\1.png", 1)

$Group1 = GUICtrlCreateGroup('File2Wav', 8, 16, 361, 113)
$InfoLabel = GUICtrlCreateLabel('Convert File', 24, 40, 60, 17)
$FileLoc = GUICtrlCreateInput('File Location...', 24, 64, 225, 22)
GUICtrlSetFont(-1, 8, 400, 2, 'Times New Roman')
GUICtrlSetColor(-1, 0x808080)
$FLBrowse = GUICtrlCreateButton('&Browse...', 264, 61, 75, 25, 0)
$FileStream = GUICtrlCreateButton('Convert &File', 145, 96, 80, 25, 0)
GUICtrlCreateGroup('', -99, -99, 1, 1)

$Group2 = GUICtrlCreateGroup('Txt2Wav', 8, 144, 361, 281)
$Txt2Wav = GUICtrlCreateEdit('', 16, 160, 345, 180, BitOR($ES_AUTOVSCROLL, $ES_WANTRETURN, $WS_VSCROLL))
$hMainTxtBox = GUICtrlGetHandle($Txt2Wav)
GUICtrlSetData(-1, 'Text to convert...')
GUICtrlCreateLabel('Rate:', 30, 350, 60, 50)
$Rate = GUICtrlCreateSlider(90, 350, 200, 20)
GUICtrlSetLimit(-1, 10, -10)
$Play = GUICtrlCreateButton('Preview', 20, 392, 75, 25, 0)
$Pause = GUICtrlCreateButton('Pause', 110, 392, 75, 25, 0)
$Resume = GUICtrlCreateButton('Resume', 195, 392, 75, 25, 0)
$Stop = GUICtrlCreateButton('Stop', 280, 392, 75, 25, 0)
$TextStream = GUICtrlCreateButton('Convert mp3', 250, 438, 90, 25, 0)
GUICtrlCreateGroup('', -99, -99, 1, 1)


GUICtrlCreateLabel("Voice: ", 10, 440)
$voiceC = GUICtrlCreateCombo($Voice[0], 60, 438, 150)
GUICtrlSetData(-1, StringTrimRight($Voices, 1))

GUISetState(@SW_SHOW)

ObjEvent($Object, "Object_")

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $FLBrowse
			_Search()
		Case $FileStream
			_File2Wav($FileRead)
		Case $Play
			_Speak(GUICtrlRead($Txt2Wav))
		Case $Rate
			$Object.Rate = GUICtrlRead($Rate)
		Case $Pause
			$Object.Pause()
		Case $Resume
			$Object.Resume()
		Case $Stop
			$Object.Speak(Chr(0), $SPF_PURGEBEFORESPEAK)
		Case $TextStream
			_Txt2Wav(GUICtrlRead($Txt2Wav))
	EndSwitch
WEnd

Func Object_Word($StreamNum, _
		$StreamPos, _
		$Pos, _
		$Length)
	Local $mmt = _GUICtrlEdit_GetSel($hMainTxtBox)
	HighLightSpokenWords($Pos, $Length)
EndFunc   ;==>Object_Word

Func Object_EndStream($StreamNum, $StreamPos)
	HighLightSpokenWords(0, 0)
	_GUICtrlPic_SetImage($Model, @ScriptDir & "\Data\1.png", 1)
EndFunc   ;==>Object_EndStream

Func HighLightSpokenWords($Pos, $Length)
	_GUICtrlPic_SetImage($Model, @ScriptDir & "\Data\" & Random(1, 5, 1) & ".png", 1)
	GUICtrlSetState($Txt2Wav, $GUI_FOCUS)
	_GUICtrlEdit_BeginUpdate($hMainTxtBox)
	_GUICtrlEdit_SetSel($Txt2Wav, $Pos, $Length + $Pos)
	_GUICtrlEdit_EndUpdate($hMainTxtBox)
	If @error Then
		_GUICtrlEdit_BeginUpdate($hMainTxtBox)
		_GUICtrlEdit_SetSel($Txt2Wav, 0, 0)
		_GUICtrlEdit_EndUpdate($hMainTxtBox)
	EndIf
EndFunc   ;==>HighLightSpokenWords


Func _Speak($sText)
	$Object.Volume = 100
	_SetVoice($Object, GUICtrlRead($voiceC))
	;$Object.Rate=-2
	$Object.Speak($sText, 1)
EndFunc   ;==>_Speak

Func _Search()
	$File = FileOpenDialog('SAPI.SpFileStream Open File...', @MyDocumentsDir, _
			'Text Files (*.txt)|All Files (*.*)', 3)
	$FileRead = FileRead($File)

	GUICtrlSetData($FileLoc, $File)
	GUICtrlSetColor($FileLoc, 0x000000)
	GUICtrlSetFont($FileLoc, 9, 400, -1, -1)
EndFunc   ;==>_Search

Func _File2Wav($Text)
	GUICtrlSetData($FileStream, 'Converting...')

	FileOpen($FileLoc, 0)
	$objVOICE = ObjCreate('SAPI.SpVoice')
	$objFSTRM = ObjCreate('SAPI.SpFileStream')
	_SetVoice($objVOICE, GUICtrlRead($voiceC))

	$objFSTRM.Open($strFName, $SSFMCreateForWrite, False)
	$objVOICE.AudioOutputStream = $objFSTRM
	$objVOICE.Speak($Text)
	$objFSTRM.Close

	GUICtrlSetData($FileStream, 'Converting...')

	SoundPlay($strFName, 0)
EndFunc   ;==>_File2Wav

Func _Txt2Wav($Text)
	GUICtrlSetData($TextStream, 'Converting...')

	$objVOICE = ObjCreate('SAPI.SpVoice')
	$objFSTRM = ObjCreate('SAPI.SpFileStream')
	_SetVoice($objVOICE, GUICtrlRead($voiceC))

	$objFSTRM.Open($strFName, $SSFMCreateForWrite, False)
	$objVOICE.AudioOutputStream = $objFSTRM
	$objVOICE.Speak($Text)
	$objFSTRM.Close

	GUICtrlSetData($TextStream, 'Convert mp3')
	ShellExecuteWait('lame.exe', ' -b320 "TTS.wav" "TTS.mp3"')
	FileDelete("TTS.wav")
	;SoundPlay($strFName, 0)
EndFunc   ;==>_Txt2Wav

Func _GetVoices($Object, $bReturn = True)
	Local $sVoices, $VoiceGroup = $Object.GetVoices
	For $Voices In $VoiceGroup
		$sVoices &= $Voices.GetDescription() & '|'
	Next
	If $bReturn Then Return StringSplit(StringTrimRight($sVoices, 1), '|', 2)
	Return StringTrimRight($sVoices, 1)
EndFunc   ;==>_GetVoices

Func _SetVoice(ByRef $Object, $sVoiceName)
	Local $VoiceNames, $VoiceGroup = $Object.GetVoices
	For $VoiceNames In $VoiceGroup
		If $VoiceNames.GetDescription() = $sVoiceName Then
			$Object.Voice = $VoiceNames
			Return
		EndIf
	Next
	Return SetError(1)
EndFunc   ;==>_SetVoice
