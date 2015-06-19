#include-once
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
Global $__gServer = ""

; #INDEX# =======================================================================================================================
; Title .........: NetInfo v.1.1.0
; AutoIt Version : v3.3.8.1
; Description ...: An UDF to retrive usefull info about your internet connection
; Author(s) .....: Nessie
; ===============================================================================================================================

; #INCLUDES# =========================================================================================================
; None

; #GLOBAL VARIABLES# =================================================================================================
; $__gServer


; #CURRENT# =====================================================================================================================
;_NetInfo_GetDownloadSpeed
;_NetInfo_GetUploadSpeed
;_NetInfo_GetLatency
;_NetInfo_GetHostname
;_NetInfo_GetIPLocation
;_NetInfo_GetISP
;_NetInfo_GetWhois
;_NetInfo_NameToIP
;_NetInfo_IPToName
;_NetInfo_GetLocalDNS
; ===============================================================================================================================


; #INTERNAL_USE_ONLY# ===========================================================================================================
;__NetInfo_GetCountryCode
;__NetInfo_GetServerList
;__NetInfo_RandomText
;__NetInfo_HTTP_Post
;__NetInfo_HTTP_Get
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _NetInfo_GetDownloadSpeed
; Description ...: Return the internet download speed
; Syntax.........: _NetInfo_GetDownloadSpeed([[$i_Size =7] [, $s_CountryCode = 0]])
; Parameters ....: $i_Size       - An interger [0-9] ID where you can select the file download size
;								0 - Download an image with 350x350 resolution and 240KB file size
;								1 - Download an image with 500x500 resolution and 494KB file size
;								2 - Download an image with 750x750 resolution and 1.1MB file size
;								3 - Download an image with 1000x1000 resolution and 1.9MB file size
;								4 - Download an image with 1500x1500 resolution and 4.3MB file size
;								5 - Download an image with 2000x2000 resolution and 7.5MB file size
;								6 - Download an image with 2500x2500 resolution and 12MB file size
;								7 - Download an image with 3000x3000 resolution and 17MB file size
;								8 - Download an image with 3500x3500 resolution and 23MB file size
;								9 - Download an image with 4000x4000 resolution and 30MB file size
;					$s_CountryCode - The ISO 3166-1 country code of the desidered test server
; Return values .: On Success -
;								$array[0] = Peak Speed Value (kB/s)
;								$array[1] = Average Download Speed (kB/s)
;				   On Failure -
;								@error = 1 Wrong Size Test ID
;								@error = 2 Wrong Country Code
;								@error = 3 Unable to get server list
;								@error = 4 Other Error
; Author ........: Nessie
; ===============================================================================================================================

Func _NetInfo_GetDownloadSpeed($i_Size = 7, $s_CountryCode = "")
	If $i_Size < 0 Or $i_Size > 9 Then SetError(1, 0, "")
	If $s_CountryCode <> "" And StringLen($s_CountryCode) <> 2 Then Return SetError(2, 0, "")

	Local $aReturn[2], $_InfoData, $iBytes_read_1, $iBytes_read_2, $iPeak

	If $s_CountryCode = "" Then
		$s_CountryCode = __NetInfo_GetCountryCode()

		If @error Then
			$s_CountryCode = "US"
		EndIf
	EndIf

	If $__gServer = "" Then
		$__gServer = __NetInfo_GetServerList($s_CountryCode)
		If @error Then Return SetError(3, 0, "")
	EndIf

	Local $aResolution[10] = ['350x350', '500x500', '750x750', '1000x1000', '1500x1500', '2000x2000', '2500x2500', '3000x3000', '3500x3500', '4000x4000']

	Local $sTemp = @TempDir & "\SpeedTest_Download.dat"

	Local $hFile = InetGet($__gServer & "random" & $aResolution[$i_Size] & ".jpg", $sTemp, 1, 1)

	Local $iBegin = TimerInit()
	Do
		$_InfoData = InetGetInfo($hFile)
		If @error Then SetError(4, 0, "")

		$iBytes_read_1 = $_InfoData[0]

		Sleep(1000)

		$_InfoData = InetGetInfo($hFile)
		If @error Then SetError(4, 0, "")

		$iBytes_read_2 = $_InfoData[0]
		Local $iDown_Speed = Int(($iBytes_read_2 - $iBytes_read_1) / 1024)

		If $iDown_Speed > $iPeak Then
			$iPeak = $iDown_Speed
		EndIf
	Until $_InfoData[2] = True

	Local $iEnd = TimerDiff($iBegin)

	FileDelete($sTemp)

	$aReturn[0] = $iPeak
	$aReturn[1] = Int($_InfoData[1] / $iEnd) ;Average Speed

	Return $aReturn
EndFunc   ;==>_NetInfo_GetDownloadSpeed

; #FUNCTION# ====================================================================================================================
; Name...........: _NetInfo_GetUploadSpeed
; Description ...:
; Syntax.........: _NetInfo_GetUploadSpeed([$s_CountryCode=""])
; Parameters ....: $s_CountryCode - The ISO 3166-1 country code of the desidered test server
; Return values .: On Success - Return the Average upload speed (kB/s)
;				   On Failure -
;								@error = 1 Unable to get server list
;								@error = 2 Unable to contact the server
; Author ........: Nessie
; ===============================================================================================================================

Func _NetInfo_GetUploadSpeed($s_CountryCode = "")
	If $s_CountryCode <> "" And StringLen($s_CountryCode) <> 2 Then Return SetError(2, 0, "")

	If $s_CountryCode = "" Then
		$s_CountryCode = __NetInfo_GetCountryCode()

		If @error Then
			$s_CountryCode = "US"
		EndIf
	EndIf

	Local $iBegin = TimerInit()
	Local $iRandom = Random(100000000000, 9999999999999, 1)

	If $__gServer = "" Then
		$__gServer = __NetInfo_GetServerList($s_CountryCode)
		If @error Then Return SetError(1, 0, "")
	EndIf

	__NetInfo_HTTP_Post($__gServer & "upload.php?0." & $iRandom, __NetInfo_RandomText())
	If @error Then SetError(2, 0, "")

	Local $iEnd = TimerDiff($iBegin)
	Local $iRet = Int(($iEnd * 1000) / 499999)

	Return $iRet
EndFunc   ;==>_NetInfo_GetUploadSpeed


; #FUNCTION# ====================================================================================================================
; Name...........: _NetInfo_GetLatency
; Description ...: Return the internet latency in milliseconds
; Syntax.........: ([$s_CountryCode=""])
; Parameters ....: $s_CountryCode - The ISO 3166-1 country code of the desidered test server
; Return values .: On Success - Returns the internet latency in milliseconds
;								$array[0] = Wrost Latency Value
;								$array[1] = Average Latency (between 5 test)
;				   On Failure - Returns -1 and sets @error to non-zero.
; Author ........: Nessie
; ===============================================================================================================================

Func _NetInfo_GetLatency($s_CountryCode = "")
	If $s_CountryCode <> "" And StringLen($s_CountryCode) <> 2 Then Return SetError(2, 0, "")
	Local $aReturn[2], $iBegin, $iEnd, $iWrost = 0, $iAverage

	If $s_CountryCode = "" Then
		$s_CountryCode = __NetInfo_GetCountryCode()

		If @error Then
			$s_CountryCode = "US"
		EndIf
	EndIf

	If $__gServer = "" Then
		$__gServer = __NetInfo_GetServerList($s_CountryCode)
		If @error Then Return SetError(1, 0, "")
	EndIf

	Local $iRandom = Random(100000000000, 9999999999999, 1)

	For $i = 1 To 5
		$iBegin = TimerInit()
		__NetInfo_HTTP_Get($__gServer & "latency.txt?x=" & $iRandom, "")
		If @error Then SetError(1, 0, -1)
		$iEnd = TimerDiff($iBegin)
		$iAverage += $iEnd
		If $iEnd > $iWrost Then
			$iWrost = Round($iEnd, 2)
		EndIf
	Next

	$aReturn[0] = $iWrost
	$aReturn[1] = Round($iAverage / 5, 2)

	Return $aReturn
EndFunc   ;==>_NetInfo_GetLatency

; #FUNCTION# ====================================================================================================================
; Name...........: _NetInfo_GetHostname
; Description ...: Retrive the Hostname of current IP
; Syntax.........: _NetInfo_GetHostname()
; Return values .: On Success - Returns the Host Name
;				   On Failure - Returns 0 and sets @error to non-zero.
; Author ........: Nessie
; ===============================================================================================================================
Func _NetInfo_GetHostname()
	Local $bRead, $sRead
	$bRead = InetRead("http://www.ip-tracker.org/track-ip-api.php")
	$sRead = BinaryToString($bRead)

	Local $aReturn = StringRegExp($sRead, 'Your Hostname: <b>(.*?)</b>', 3)
	If @error Then Return SetError(1, 0, 0)

	Return $aReturn[0]
EndFunc   ;==>_NetInfo_GetHostname

; #FUNCTION# ====================================================================================================================
; Name...........: _NetInfo_GetIPLocation
; Description ...: Retrive the location of current IP
; Syntax.........: _NetInfo_GetIPLocation()
; Return values .: On Success -
;								$array[0] = Country Code
;								$array[1] = State
;								$array[2] = Longitude
;								$array[3] = Latitude
;				   On Failure -
;								@error = 1 Unable to resolve IP
; Author ........: Nessie
; ===============================================================================================================================
Func _NetInfo_GetIPLocation()
	Local $aReturn[4], $bRead, $sRead, $aRegex
	$bRead = InetRead("http://www.ip-tracker.org/track-ip-api.php")
	$sRead = BinaryToString($bRead)
	$aRegex = StringRegExp($sRead, '<b>(.*?)</b>', 3)
	If UBound($aRegex) - 1 <> 7 Then Return SetError(1, 0, "")
	$aReturn[0] = $aRegex[0]
	$aReturn[1] = $aRegex[1]
	$aReturn[2] = $aRegex[4]
	$aReturn[3] = $aRegex[5]

	Return $aReturn
EndFunc   ;==>_NetInfo_GetIPLocation

; #FUNCTION# ====================================================================================================================
; Name...........: _NetInfo_GetISP
; Description ...: Retrive the user ISP (Internet Provider)
; Syntax.........: _NetInfo_GetISP()
; Return values .: On Success - Return the ISP name
;				   On Failure - Returns 0 and sets @error to non-zero.
; Author ........: Nessie
; ===============================================================================================================================

Func _NetInfo_GetISP()
	Local $aReturn, $bRead, $sRead
	$bRead = InetRead("http://www.ip-tracker.org/track-ip-api.php")
	$sRead = BinaryToString($bRead)

	$aReturn = StringRegExp($sRead, 'Your ISP: <b>(.*?)</b>', 3)
	If @error Then Return SetError(1, 0, 0)

	Return $aReturn[0]
EndFunc   ;==>_NetInfo_GetISP

; #FUNCTION# ====================================================================================================================
; Name...........: _NetInfo_GetWhois
; Description ...: Retrive the domain whois
; Syntax.........: _NetInfo_GetWhois($domain)
; Remarks .......: You have to insert as parameter only the url domain ex: "autoit.com". Complete url like "http://www.autoit.com"
;				   or "www.autoit.com", etc are NOT allowed.
; Return values .: On Success - Return the domain Whois
;				   On Failure - Returns 0 and sets @error to non-zero.
; Author ........: Nessie
; ===============================================================================================================================

Func _NetInfo_GetWhois($s_Domain)
	Local $aReturn, $bRead, $sRead
	$bRead = InetRead("http://whoiz.herokuapp.com/lookup?url=" & $s_Domain)
	$sRead = BinaryToString($bRead)

	$aReturn = StringRegExp($sRead, "(?s)<pre class='content'>(.*?)</div>", 3)
	If @error Then Return SetError(1, 0, 0)

	Return $aReturn[0]
EndFunc   ;==>_NetInfo_GetWhois

; #FUNCTION# ====================================================================================================================
; Name...........: _NetInfo_NameToIP
; Description ...: Converts an Internet name to IP address.
; Syntax.........: _NetInfo_NameToIP($domain)
; Remarks .......: You have to insert as parameter only the url domain ex: "autoit.com". Complete url like "http://www.autoit.com"
;				   or "www.autoit.com", etc are NOT allowed.
; Return values .: On Success - Returns string containing IP address corresponding to the name
;				   On Failure - Returns "" and set @error.
; Author ........: Nessie
; ===============================================================================================================================

Func _NetInfo_NameToIP($s_Domain)
	TCPStartup()
	Local $aResult = TCPNameToIP($s_Domain)
	If @error Then Return SetError(1, 0, "")
	TCPShutdown()

	Return $aResult
EndFunc   ;==>_NetInfo_NameToIP

; #FUNCTION# ====================================================================================================================
; Name...........: _NetInfo_IPToName
; Description ...: Converts an IP to Internet name
; Syntax.........: _NetInfo_IPToName($ip)
; Return values .: On Success - Returns string containing IP address corresponding to the name
;				   On Failure - Returns "" and set @error.
; Author ........: Nessie
; ===============================================================================================================================

Func _NetInfo_IPToName($s_Address)
	Local $objWMIService = ObjGet("winmgmts:\\.\root\cimv2")
	Local $sQuery = 'SELECT * FROM Win32_PingStatus WHERE address="' & $s_Address & '" AND ResolveAddressNames=True'
	Local $oColItems = $objWMIService.ExecQuery($sQuery)

	If IsObj($oColItems) Then
		Local $sResult

		For $objItem In $oColItems
			$sResult = $objItem.ProtocolAddressResolved
			ExitLoop
		Next

		Return $sResult
	EndIf

	Return SetError(1, 0, "")
EndFunc   ;==>_NetInfo_IPToName

; #FUNCTION# ====================================================================================================================
; Name...........: _NetInfo_GetLocalDNS
; Description ...: Retrive the list of Local DNS in use
; Syntax.........: _NetInfo_GetLocalDNS()
; Return values .: On Success - Returns an array with all Local DNS in use
;								$array[0] = DNS1
;								$array[1] = DNS2
;				   On Failure - Returns "" and set @error.
; Author ........: Nessie
; ===============================================================================================================================

Func _NetInfo_GetLocalDNS()
	Local $objWMIService = ObjGet("winmgmts:\\.\root\cimv2")
	Local $sQuery = "SELECT * FROM Win32_NetworkAdapterConfiguration Where IPEnabled = TRUE"
	Local $oColItems = $objWMIService.ExecQuery($sQuery)
	Local $sIP = @IPAddress1, $aReturn

	If IsObj($oColItems) Then
		For $oObjectItem In $oColItems
			If $oObjectItem.IPAddress(0) == $sIP Then
				$aReturn = $oObjectItem.DNSServerSearchOrder()
			EndIf
		Next
		If IsArray($aReturn) Then
			Return $aReturn
		EndIf
	EndIf
	Return SetError(1, 0, "")
EndFunc   ;==>_NetInfo_GetLocalDNS




; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __NetInfo_GetCountryCode
; Description ...: Return the system Country Code in ISO 3166-1
; Author ........: Nessie
; ===============================================================================================================================

Func __NetInfo_GetCountryCode()
	Local $Ret = DllCall('kernel32.dll', 'ulong', 'GetUserDefaultLCID')

	If @error Then
		Return SetError(1, 0, 0)
	EndIf

	Local $iLCID = $Ret[0]

	Local $aRet = DllCall('kernel32.dll', 'int', 'GetLocaleInfoW', 'ulong', $iLCID, 'dword', 0x005A, 'wstr', '', 'int', 2048)

	If (@error) Or (Not $aRet[0]) Then
		Return SetError(1, 0, '')
	EndIf

	Return $aRet[3]
EndFunc   ;==>__NetInfo_GetCountryCode

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __NetInfo_GetServerList
; Description ...: Return the list of all avaiable server
; Author ........: Nessie
; ===============================================================================================================================

Func __NetInfo_GetServerList($s_CountryCode)
	Local $sRet

	Local $bRead = InetRead("http://speedtest.net/speedtest-servers.php", 1)
	If @error Then Return SetError(1, 0, "")
	Local $sRead = BinaryToString($bRead)
	If @error Then Return SetError(1, 0, "")

	Local $sPattern = 'url="(.*?)upload.php".*cc="' & $s_CountryCode & '"'

	Local $aRegex = StringRegExp($sRead, $sPattern, 3)

	If @error Then
		$sRet = "http://sto-bvrt-01.sys.comcast.net/speedtest/"
	Else
		Local $iID = Int(Random(0, UBound($aRegex) - 1))
		$sRet = $aRegex[$iID]
	EndIf

	Return $sRet
EndFunc   ;==>__NetInfo_GetServerList

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __NetInfo_RandomText
; Description ...: Used internally within this file, not for general use
; Syntax.........: __NetInfo_RandomText()
; Author ........: Nessie
; ===============================================================================================================================

Func __NetInfo_RandomText()
	Local $sData = '', $sRandom = ''
	For $i = 1 To 499999
		$sRandom = Random(97, 122, 1)
		$sData &= Chr($sRandom)
	Next
	Return $sData
EndFunc   ;==>__NetInfo_RandomText

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __NetInfo_HTTP_Post
; Description ...: Used internally within this file, not for general use
; Syntax.........: __NetInfo_HTTP_Post($s_Url, $s_Data)
; Author ........: Nessie
; ===============================================================================================================================

Func __NetInfo_HTTP_Post($s_Url, $s_Data)
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	If @error Then Return SetError(1, 0, "")

	$oHTTP.Open("POST", $s_Url, False)
	$oHTTP.SetRequestHeader("User-Agent", "Mozilla/4.0 (compatible;)")
	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	$oHTTP.Send($s_Data)
	Local $oReceived = $oHTTP.ResponseText

	If $oReceived = "" Then Return SetError(1, 0, "")

	Return $oReceived
EndFunc   ;==>__NetInfo_HTTP_Post

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __NetInfo_HTTP_Get
; Description ...: Used internally within this file, not for general use
; Syntax.........: __NetInfo_HTTP_Get($s_Url, $s_Data)
; Author ........: Nessie
; ===============================================================================================================================

Func __NetInfo_HTTP_Get($s_Url, $s_Data)
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	If @error Then Return SetError(1, 0, "")

	$oHTTP.Open("GET", $s_Url, False)
	$oHTTP.SetRequestHeader("User-Agent", "Mozilla/4.0 (compatible;)")
	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	$oHTTP.Send($s_Data)
	Local $oReceived = $oHTTP.ResponseText

	If $oReceived = "" Then Return SetError(1, 0, "")

	Return $oReceived
EndFunc   ;==>__NetInfo_HTTP_Get