

; #FUNCTION# ====================================================================================================================
; Name...........: _StartTTS
; Description ...: Creates a object to be used with Text-to-Speak Functions.
; Syntax.........: _StartTTS()
; Parameters ....:
; Return values .: Success - Returns a object
; Author ........: bchris01

; Example .......: Yes
; ===============================================================================================================================
Func _StartTTS()
	Return ObjCreate("SAPI.SpVoice")
EndFunc   ;==>_StartTTS

; #FUNCTION# ====================================================================================================================
; Name...........: _SetRate
; Description ...: Sets the rendering rate of the voice. (How fast the voice talks.)
; Syntax.........: _SetRate(ByRef $Object, $iRate)
; Parameters ....: $Object        - Object returned from _StartTTS().
;                  $iRate         - Value specifying the speaking rate of the voice. Supported values range from -10 to 10
; Return values .:	None
; Author ........: bchris01
; Example .......: Yes
; ===============================================================================================================================
Func _SetRate(ByRef $Object, $iRate); Rates can be from -10 to 10
	$Object.Rate = $iRate
EndFunc   ;==>_SetRate

; #FUNCTION# ====================================================================================================================
; Name...........: _SetVolume
; Description ...: Sets the volume of the voice.
; Syntax.........: _SetVolume(ByRef $Object, $iVolume)
; Parameters ....: $Object        - Object returned from _StartTTS().
;                  $iVolume       - Value specifying the volume of the voice. Supported values range from 0-100. Default = 100
; Return values .:	None
; Author ........: bchris01
; Example .......: Yes
; ===============================================================================================================================
Func _SetVolume(ByRef $Object, $iVolume);Volume
	$Object.Volume = $iVolume
EndFunc   ;==>_SetVolume

; #FUNCTION# ====================================================================================================================
; Name...........: _SetVoice
; Description ...: Sets the identity of the voice used for text synthesis.
; Syntax.........: _SetVoice(ByRef $Object, $sVoiceName)
; Parameters ....: $Object        - Object returned from _StartTTS().
;                  $sVoiceName    - String matching one of the voices installed.
; Return values .:	Success - Sets object to voice.
;					Failure - Sets @error to 1
; Author ........: bchris01
; Example .......: Yes
; ===============================================================================================================================
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

; #FUNCTION# ====================================================================================================================
; Name...........: _GetVoices
; Description ...: Retrives the currently installed voice identitys.
; Syntax.........: _GetVoices(ByRef $Object[, $Return = True])
; Parameters ....: $Object        - Object returned from _StartTTS().
;                  $bReturn    	  - String of text you want spoken.
;				   |If $bReturn = True then a 0-based array is returned.
;				   |If $bReturn = False then a string seperated by delimiter "|" is returned.
; Return values .:	Success - Returns an array or string containing installed voice identitys.
; Author ........: bchris01
; Example .......: Yes
; ===============================================================================================================================
Func _GetVoices(ByRef $Object, $bReturn = True)
	Local $sVoices, $VoiceGroup = $Object.GetVoices
	For $Voices In $VoiceGroup
		$sVoices &= $Voices.GetDescription() & '|'
	Next
	If $bReturn Then Return StringSplit(StringTrimRight($sVoices, 1), '|', 2)
	Return StringTrimRight($sVoices, 1)
EndFunc   ;==>_GetVoices

; #FUNCTION# ====================================================================================================================
; Name...........: _Speak
; Description ...: Speaks the contents of the text string.
; Syntax.........: _Speak(ByRef $Object, $sText)
; Parameters ....: $Object        - Object returned from _StartTTS().
;                  $sText    	  - String of text you want spoken.
; Return values .:	Success - Speaks the text.
; Author ........: bchris01
; Example .......: Yes
; ===============================================================================================================================
Func _Speakz(ByRef $Object, $sText)
	$Object.Speak($sText)
EndFunc   ;==>_Speak
