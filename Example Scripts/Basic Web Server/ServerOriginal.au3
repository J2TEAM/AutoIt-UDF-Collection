#cs
Resources:
    Internet Assigned Number Authority - all Content-Types: http://www.iana.org/assignments/media-types/
    World Wide Web Consortium - An overview of the HTTP protocol: http://www.w3.org/Protocols/

Credits:
    Manadar for starting on the webserver.
    Alek for adding POST and some fixes
    Creator for providing the "application/octet-stream" MIME type.
#ce

; // OPTIONS HERE //
Dim $sRootDir = @ScriptDir & "\www\" ; The absolute path to the root directory of the server.
Dim $sIP = '127.0.0.1' ; ip address as defined by AutoIt
Dim $iPort = 80 ; the listening port
Dim $iMaxUsers = 15 ; Maximum number of users who can simultaneously get/post
; // END OF OPTIONS //

Dim $aSocket[$iMaxUsers] ; Creates an array to store all the possible users
Dim $sBuffer[$iMaxUsers] ; All these users have buffers when sending/receiving, so we need a place to store those

For $x = 0 to UBound($aSocket)-1 ; Fills the entire socket array with -1 integers, so that the server knows they are empty.
    $aSocket[$x] = -1
Next

TCPStartup() ; AutoIt needs to initialize the TCP functions

$iMainSocket = TCPListen($sIP,$iPort) ;create main listening socket
If @error Then ; if you fail creating a socket, exit the application
    MsgBox(0x20, "AutoIt Webserver", "Unable to create a socket on port " & $iPort & ".") ; notifies the user that the HTTP server will not run
    Exit ; if your server is part of a GUI that has nothing to do with the server, you'll need to remove the Exit keyword and notify the user that the HTTP server will not work.
EndIf

ConsoleWrite( "Server created on http://" & $sIP & "/" & @CRLF) ;; If you're in SciTE,

While 1
    $iNewSocket = TCPAccept($iMainSocket) ;; Tries to accept incoming connections

    If $iNewSocket >= 0 Then ; Verifies that there actually is an incoming connection
        For $x = 0 to UBound($aSocket)-1 ;; Attempts to store the incoming connection
            If $aSocket[$x] = -1 Then
                $aSocket[$x] = $iNewSocket ;store the new socket
                ExitLoop
            EndIf
        Next
    EndIf

    For $x = 0 to UBound($aSocket)-1 ; A big loop to receive data from everyone connected
        If $aSocket[$x] = -1 Then ContinueLoop ;; if the socket is empty, it will continue to the next iteration, doing nothing
        $sNewData = TCPRecv($aSocket[$x],1024) ; Receives a whole lot of data if possible
        If @error Then ;; Client has disconnected
            $aSocket[$x] = -1 ; Socket is freed so that a new user may join
            ContinueLoop ; Go to the next iteration of the loop, not really needed but looks oh so good
        ElseIf $sNewData Then ; data received
            $sBuffer[$x] &= $sNewData ;store it in the buffer
            If StringInStr(StringStripCR($sBuffer[$x]),@LF&@LF) Then ; if the request has ended ..
                $sFirstLine = StringLeft($sBuffer[$x],StringInStr($sBuffer[$x],@LF)) ;; helps to get the type of the request
                $sRequestType = StringLeft($sFirstLine,StringInStr($sFirstLine," ")-1) ;; gets the type of the request
                If $sRequestType = "GET" Then ;; user wants to download a file or whatever ..
                    $sRequest = StringTrimRight(StringTrimLeft($sFirstLine,4),11) ;; let's see what file he actually wants
					If StringInStr(StringReplace($sRequest,"\","/"), "/.") Then ;; Disallow any attempts to go back a folder
						_SendError($aSocket[$x]) ;; sends back an error
					Else
						If $sRequest = "/" Then ;; user has requested the root
							$sRequest = "/index.html" ;; instead of root we'll give him the index page
						EndIf
						$sRequest = StringReplace($sRequest,"/","\") ; convert HTTP slashes to windows slashes, not really required because windows accepts both
						If FileExists($sRootDir & "\" & $sRequest) Then ;; makes sure the file that the user wants exists
							$sFileType = StringRight($sRequest,4) ;; determines the file type, so that we may choose what mine type to use
							Switch $sFileType
								Case "html", ".htm" ;; in case of normal HTML files
									_SendFile($sRootDir & "\" & $sRequest, "text/html", $aSocket[$x])
								Case ".css" ;; in case of style sheets
									_SendFile($sRootDir & "\" & $sRequest, "text/css", $aSocket[$x])
								Case ".jpg", "jpeg" ;; for common images
									_SendFile($sRootDir & "\" & $sRequest, "image/jpeg", $aSocket[$x])
								Case ".png" ;; another common image format
									_SendFile($sRootDir & "\" & $sRequest, "image/png", $aSocket[$x])
								Case Else ; this is for .exe, .zip, or anything else that is not supported is downloaded to the client using a application/octet-stream
									_SendFile($sRootDir & "\" & $sRequest, "application/octet-stream", $aSocket[$x])
							EndSwitch
						Else
							_SendError($aSocket[$x]) ;; File does not exist, so we'll send back an error..
						EndIf
					EndIf
                ElseIf $sRequestType = "POST" Then ;; user has come to us with data, we need to parse that data and based on that do something special

                    $aPOST = _Get_Post($sBuffer[$x]) ;; parses the post data

                    $sName = _POST("Name",$aPOST) ; Like PHPs _POST, but it requires the second parameter to be the return value from _Get_Post
                    $sComment = _POST("Comment",$aPOST) ;; Gets the comment

                    _POST_ConvertString($sName) ;; Needs to convert the POST HTTP string into a normal string
                    _POST_ConvertString($sComment) ;; same ..

                    FileWrite($sRootDir & "\index.html", "<br />" & $sName & " made comment: " & $sComment) ;Ofcourse, in real situations you have to prevent people to use HTML/PHP/Javascript etc. in their comments.
                    ;; The last line adds whatever Name:Comment said in the root file .. this creates some sort of chatty effect

                    _SendFile($sRootDir & "\index.html", "text/html", $aSocket[$x]) ; Sends back the new file we just created
                EndIf

                $sBuffer[$x] = "" ;; clears the buffer because we just used to buffer and did some actions based on them
                TCPCloseSocket($aSocket[$x]) ;; we have defined connection: close, so we close the connection
                $aSocket[$x] = -1 ;; reset the socket so that we may accept new clients

            EndIf
        EndIf
    Next

    Sleep(10)
WEnd

Func _POST_ConvertString(ByRef $sString) ;; converts any characters like %20 into space 8)
    $sString = StringReplace($sString, '+', ' ')
    StringReplace($sString, '%', '')
    For $t = 0 To @extended
        $Find_Char = StringLeft( StringTrimLeft($sString, StringInStr($sString, '%')) ,2)
        $sString = StringReplace($sString, '%' & $Find_Char, Chr(Dec($Find_Char)))
    Next
EndFunc

Func _SendHTML($sHTML,$sSocket) ;; sends HTML data back to the client on X socket
    Local $iLen, $sPacket, $sSplit

    $iLen = StringLen($sHTML)
    $sPacket = Binary("HTTP/1.1 200 OK" & @CRLF & _
    "Server: ManadarX/1.0 (" & @OSVersion & ") AutoIt " & @AutoItVersion & @CRLF & _
    "Connection: close" & @CRLF & _
    "Content-Lenght: " & $iLen & @CRLF & _
    "Content-Type: text/html" & @CRLF & _
    @CRLF & _
    $sHTML)
    $sSplit = StringSplit($sPacket,"")
    $sPacket = ""
    For $i = 1 to $sSplit[0]
        If Asc($sSplit[$i]) <> 0 Then ; Just make sure we don't send any null bytes, because they show up as ???? in your browser.
            $sPacket = $sPacket & $sSplit[$i]
        EndIf
    Next
    TCPSend($sSocket,$sPacket)
EndFunc

Func _SendFile($sAddress, $sType, $sSocket) ;; Sends a file back to the client on X socket, with X mime-type
    Local $hFile, $sImgBuffer, $sPacket, $a

    $hFile = FileOpen($sAddress,16)
    $sImgBuffer = FileRead($hFile)
    FileClose($hFile)

    $sPacket = Binary("HTTP/1.1 200 OK" & @CRLF & _
    "Server: ManadarX/1.3.26 (" & @OSVersion & ") AutoIt " & @AutoItVersion & @CRLF & _
    "Connection: close" & @CRLF & _
    "Content-Type: " & $sType & @CRLF & _
    @CRLF)
    TCPSend($sSocket,$sPacket)

    While BinaryLen($sImgbuffer) ;LarryDaLooza's idea to send in chunks to reduce stress on the application
        $a = TCPSend($sSocket,$sImgbuffer)
        $sImgbuffer = BinaryMid($sImgbuffer,$a+1,BinaryLen($sImgbuffer)-$a)
    WEnd

    $sPacket = Binary(@CRLF & _
    @CRLF)
    TCPSend($sSocket,$sPacket)
    TCPCloseSocket($sSocket)
EndFunc

Func _SendError($sSocket) ;; Sends back a basic 404 error
    _SendHTML("404 Error: " & @CRLF & @CRLF & "The file you requested could not be found.", $sSocket)
EndFunc

Func _Get_Post($s_Buffer) ;; parses incoming POST data
    Local $sTempPost, $sLen, $sPostData, $sTemp

    ;Get the lenght of the data in the POST
    $sTempPost = StringTrimLeft($s_Buffer,StringInStr($s_Buffer,"Content-Length:"))
    $sLen = StringTrimLeft($sTempPost,StringInStr($sTempPost,": "))

    ;Create the base struck
    $sPostData = StringSplit(StringRight($s_Buffer,$sLen),"&")

    Local $sReturn[$sPostData[0]+1][2]

    For $t = 1 To $sPostData[0]
        $sTemp = StringSplit($sPostData[$t],"=")
        If $sTemp[0] >= 2 Then
            $sReturn[$t][0] = $sTemp[1]
            $sReturn[$t][1] = $sTemp[2]
        EndIf
    Next

    Return $sReturn
EndFunc

Func _POST($sName,$sArray) ;; Returns a POST variable based on their name and not their array index. This function basically makes up for the lack of associative arrays in Au3
    For $i = 1 to UBound($sArray)-1
        If $sArray[$i][0] = $sName Then
            Return $sArray[$i][1]
        EndIf
    Next
    Return ""
EndFunc