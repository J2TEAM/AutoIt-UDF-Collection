; #INDEX# =======================================================================================================================
; Title .........: GUICtrlPic
; AutoIt Version : 3.3.6.1
; Description ...: Ergänzende Funktionen für Pic-Controls
; Author(s) .....: Großvater
; Dll ...........: GDI32.dll, GDIPlus.dll
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _GUICtrlPic_Create
; _GUICtrlPic_SetImage
; _GUICtrlPic_LoadImage
; _GUICtrlPic_ScaleBitmap
; _GUICtrlPic_GradientFill
; _GUICtrlPic_Invert
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlPic_Create
; Description ...: Pic-Control für alle von GDIPlus unterstützten Formate ggf. mit Transparenz erstellen.
; Syntax.........: _GUICtrlPic_Create($sPicPath, $iLeft, $iTop[, $iWidth = 0[, $iHeight = 0[, $uStyles = -1[, $uExStyles = -1[, $bKeepAspectRatio = False]]]]])
; Parameters ....: Die Parameter entsprechen bis auf den letzten der AU3-Funktion GUICtrlCreatePic()
;                  $bKeepAspectRatio - Seitenverhältnis bei der Größenanpassung beachten:
;                  |True    - ja
;                  |False   - nein
;                  |Default - nein
; Return values .: Im Erfolgsfall: ControlID aus GUICtrlCreatePic()
;                  Im Fehlerfall: False, @error und @extended enthalten ergänzende fehlerbeschreibende Werte.
; Author ........: Großvater (www.autoit.de)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlPic_Create($sPicPath, $iLeft, $iTop, $iWidth = 0, $iHeight = 0, $uStyles = -1, $uExStyles = -1, $bKeepAspectRatio = False)
    Local Const $IMAGE_BITMAP = 0x0000
    Local Const $STM_SETIMAGE = 0x0172
    Local $aResult, $hBitmap, $hImage, $Height, $Width, $CtrlID
    Local $aBitmap = _GUICtrlPic_LoadImage($sPicPath)
    If @error Then Return SetError(@error, @extended, False)
    $hBitmap = $aBitmap[0]
    $Width = $aBitmap[1]
    $Height = $aBitmap[2]
    If $iWidth = 0 And $iHeight = 0 Then
        $iWidth = $Width
        $iHeight = $Height
    Else
        $hBitmap = _GUICtrlPic_ScaleBitmap($hBitmap, $iWidth, $iHeight, $Width, $Height, $bKeepAspectRatio)
        If @error Then Return SetError(@error, @extended, False)
    EndIf
    $CtrlID = GUICtrlCreatePic("", $iLeft, $iTop, $iWidth, $iHeight, $uStyles, $uExStyles)
    GUICtrlSendMsg($CtrlID, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
    DllCall("Gdi32.dll", "BOOL", "DeleteObject", "Handle", $hBitmap)
    Return $CtrlID
EndFunc   ;==>_GUICtrlPic_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlPic_SetImage
; Description ...: Neues Bild in Pic-Control erstellen.
; Syntax.........: _GUICtrlPic_SetImage($idPic, $sPicPath[, $bKeepAspectRatio = False])
; Parameters ....: $idPic            - ID des PIC-Controls
;                  $sPicPath         - vollständiger Pfad der Bilddatei
;                  $bKeepAspectRatio - Seitenverhältnis bei der Größenanpassung beachten:
;                  |True    - ja
;                  |False   - nein
;                  |Default - nein
; Return values .: Im Erfolgsfall: True
;                  Im Fehlerfall: False, @error und @extended enthalten ggf. ergänzende fehlerbeschreibende Werte
; Author ........: Großvater (www.autoit.de)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlPic_SetImage($idPic, $sPicPath,$NWidth,$NHeight, $bKeepAspectRatio = False)
    Local Const $IMAGE_BITMAP = 0x0000
    Local Const $STM_SETIMAGE = 0x0172
    Local Const $STM_GETIMAGE = 0x0173
    Local $aSize[2], $hBM, $hBitmap, $Height, $Width
    Local $aBitmap = _GUICtrlPic_LoadImage($sPicPath)
    If @error Or $aBitmap[0] = 0 Then Return SetError(@error, @extended, False)
    $hBitmap = $aBitmap[0]
    $Width = $aBitmap[1]
    $Height = $aBitmap[2]
    ;$aSize = WinGetClientSize(GUICtrlGetHandle($idPic))
	$aSize[0]=$NWidth
	$aSize[1]=$NHeight
    $hBitmap = _GUICtrlPic_ScaleBitmap($hBitmap, $aSize[0], $aSize[1], $Width, $Height, $bKeepAspectRatio)
    $hBM = GUICtrlSendMsg($idPic, $STM_GETIMAGE, $IMAGE_BITMAP, 0)
    If $hBM Then DllCall("Gdi32.dll", "BOOL", "DeleteObject", "Handle", $hBM)
    GUICtrlSendMsg($idPic, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
    DllCall("Gdi32.dll", "BOOL", "DeleteObject", "Handle", $hBitmap)
    GUICtrlSetState($idPic, $GUI_SHOW)
    Return True
EndFunc   ;==>_GUICtrlPic_SetImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlPic_LoadImage
; Description ...: Bilddatei laden und HBITMAP erzeugen
; Syntax.........: _GUICtrlPic_LoadImage($sPicPath)
; Parameters ....: $sPicPath         - vollständiger Pfad der Bilddatei
; Return values .: Im Erfolgsfall: Array mit drei Einträgen, Array[0] enthält ein HBITMAP-Handle,
;                                  Array[1] die Breite und Array[2] die Höhe der Bitmap
;                  Im Fehlerfall: False, @error und @extended enthalten ggf. ergänzende fehlerbeschreibende Werte
; Author ........: Großvater (www.autoit.de)
; Modified.......:
; Remarks .......: Die Funktion kann auch einzeln genutzt werden, um eine Bitmap zu laden und dann per
;                  GUICtrlSendMsg($idPIC, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap) einem Pic-Control zuzuweisen.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlPic_LoadImage($sPicPath)
    Local $aResult, $hBitmap, $hImage, $Height, $Width
    Local $aBitmap[3] = [0, 0, 0]
    Local $hGDIPDll = DllOpen("GDIPlus.dll")
    If $hGDIPDll = -1 Then Return SetError(1, 2, $aBitmap)
    Local $tInput = DllStructCreate("UINT Version;ptr Callback;BOOL NoThread;BOOL NoCodecs")
    Local $pInput = DllStructGetPtr($tInput)
    Local $tToken = DllStructCreate("ULONG_PTR Data")
    Local $pToken = DllStructGetPtr($tToken)
    DllStructSetData($tInput, "Version", 1)
    $aResult = DllCall($hGDIPDll, "INT", "GdiplusStartup", "Ptr", $pToken, "Ptr", $pInput, "Ptr", 0)
    If @error Then Return SetError(@error, @extended, $aBitmap)
    $aResult = DllCall($hGDIPDll, "INT", "GdipLoadImageFromFile", "WStr", $sPicPath, "Ptr*", 0)
    If @error Or $aResult[2] = 0 Then
        Local $Error = @error, $Extended = @extended
        DllCall($hGDIPDll, "None", "GdiplusShutdown", "Ptr", DllStructGetData($tToken, "Data"))
        DllClose($hGDIPDll)
        Return SetError($Error, $Extended, $aBitmap)
    EndIf
    $hImage = $aResult[2]
    $aResult = DllCall($hGDIPDll, "INT", "GdipGetImageWidth", "Handle", $hImage, "UINT*", 0)
    $Width = $aResult[2]
    $aResult = DllCall($hGDIPDll, "INT", "GdipGetImageHeight", "Handle", $hImage, "UINT*", 0)
    $Height = $aResult[2]
    $aResult = DllCall($hGDIPDll, "INT", "GdipCreateHBITMAPFromBitmap", "Handle", $hImage, "Ptr*", 0, "DWORD", 0xFF000000)
    $hBitmap = $aResult[2]
    DllCall($hGDIPDll, "INT", "GdipDisposeImage", "Handle", $hImage)
    DllCall($hGDIPDll, "None", "GdiplusShutdown", "Ptr", DllStructGetData($tToken, "Data"))
    DllClose($hGDIPDll)
    $aBitmap[0] = $hBitmap
    $aBitmap[1] = $Width
    $aBitmap[2] = $Height
    Return $aBitmap
EndFunc   ;==>_GUICtrlPic_LoadImage

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlPic_ScaleBitmap
; Description ...: Geladene Bitmap skalieren.
; Syntax.........: _GUICtrlPic_ScaleBitmap($hBitmap, $iNewW, $iNewH[, $iBitmapW[, $iBitmapH[, $bKeepAspectRatio = False]]])
; Parameters ....: $hBitmap          - HBITMAP-Handle
;                  $iNewW            - gewünschte Breite in Pixeln
;                  $iNewH            - gewünschte Höhe in Pixeln
;                  $iBitmapW         - aktuelle Breite der Bitmap (wird nur für das Skalieren im Seitenverhältnis benötigt
;                  $iBitmapH         - aktuelle Höhe der Bitmap (wird nur für das Skalieren im Seitenverhältnis benötigt
;                  $bKeepAspectRatio - Seitenverhältnis bei der Größenanpassung beachten:
;                  |True    - ja
;                  |False   - nein
;                  |Default - nein
; Return values .: Im Erfolgsfall: HBITMAP-Handle für die skalierte Bitmap
;                  Im Fehlerfall: False, @error und @extended enthalten ggf. ergänzende fehlerbeschreibende Werte
; Author ........: Großvater (www.autoit.de)
; Modified.......:
; Remarks .......: Die Funktion kann auch einzeln genutzt werden, um eine Bitmap zu skalieren und dann per
;                  GUICtrlSendMsg($idPIC, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap) einem Pic-Control zuzuweisen.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlPic_ScaleBitmap($hBitmap, $iNewW, $iNewH, $iBitmapW, $iBitmapH, $bKeepAspectRatio = False)
    Local Const $IMAGE_BITMAP = 0x0000
    If $bKeepAspectRatio Then
        If $iBitmapW >= $iBitmapH Then
            $iBitmapH *= $iNewW / $iBitmapW
            $iBitmapW = $iNewW
            If $iBitmapH > $iNewH Then
                $iBitmapW *= $iNewH / $iBitmapH
                $iBitmapH = $iNewH
            EndIf
        Else
            $iBitmapW *= $iNewH / $iBitmapH
            $iBitmapH = $iNewH
            If $iBitmapW > $iNewW Then
                $iBitmapH *= $iNewW / $iBitmapW
                $iBitmapW = $iNewW
            EndIf
        EndIf
    Else
        $iBitmapW = $iNewW
        $iBitmapH = $iNewH
    EndIf
    Local $aResult = DllCall("User32.dll", "Handle", "CopyImage", _
            "Handle", $hBitmap, "UINT", $IMAGE_BITMAP, "INT", $iBitmapW, "INT", $iBitmapH, "UINT", 0x4 + 0x8)
    If @error Then Return SetError(@error, @extended, False)
    Return $aResult[0]
EndFunc   ;==>_GUICtrlPic_ScaleBitmap

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlPic_GradientFill
; Description ...: Füllt ein Pic-Control mit einem zweifarbigen linearen Farbverlauf.
; Syntax.........: _GUICtrlPic_GradientFill($idCTRL, $C1, $C2[, $D = 1[, $3D = 3[, $GC = 0[, $BW = 0[, $BH = 0]]]]])
; Parameters ....: $idCTRL  - ID des Pic-Controls aus GUIStrlCreatePic()
;                  $C1      - Startfarbe als 6-stelliger RGB-Hexstring ("RRGGBB")
;                  $C2      - Zielfarbe als 6-stelliger RGB-Hexstring ("RRGGBB")
;                  $D       - Verlaufsrichtung:
;                  |0       - horizontal
;                  |1       - vertikal
;                  |2       - diagonal (links oben -> rechts unten)
;                  |3       - diagonal (rechts oben -> links unten)
;                  |Default - 0
;                  $3D      - Verlaufsart:
;                  |1       - flacher Verlauf (Startfarbe -> Zielfarbe)
;                  |2       - "3D"-Verlauf (Startfarbe -> Zielfarbe -> Startfarbe)
;                  |3       - erhaben (wie 2, die Startfarbe bleibt aber im Randbereich)
;                  |Default - 1
;                  $GC      - Gammakorrektur:
;                  |0       - ohne
;                  |1       - mit
;                  |Default - 0
;                  $BW      - Breite des Verlaufs in Pixeln
;                  |Default - 0 (Breite des Controls)
;                  $BH      - Höhe des Verlaufs in Pixeln
;                  |Default - 0 (Höhe des Controls)
; Return values .: Bei erfolgreicher Ausführung: Handle der erzeugten Bitmap (HBITMAP)
;                  Im Fehlerfall: False, @error wird auf 1 gesetzt
; Author ........: Großvater (www.autoit.de)
; Modified.......:
; Remarks .......: Das Control muss mit GUICtrlCreatePic() erzeugt worden sein, sonst geschieht nichts.
;                  Die Parameter $BW und $BH laden zum Experimentieren ein.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlPic_GradientFill($idCTRL, $C1, $C2, $D = 1, $3D = 3, $GC = 0, $BW = 0, $BH = 0)
    Local Static $STM_SETIMAGE = 0x172
    Local Static $IMAGE_BITMAP = 0x0
    Local Static $BITSPIXEL = 0xC
    Local $hWnd
    If IsHWnd($idCTRL) Then
        $hWnd = $idCTRL
    Else
        $hWnd = GUICtrlGetHandle($idCTRL)
    EndIf
    Local $aResult = DllCall("User32.dll", "Int", "GetClassName", "Hwnd", $hWnd, _
            "Str", "", "Int", 256)
    If $aResult[2] <> "Static" Then
        Return False
    EndIf
    Local $GDIPDll = DllOpen("GDIPlus.dll")
    If $GDIPDll = -1 Then
        Return SetError(1, 0, False)
    EndIf
    Local $SI = DllStructCreate("UInt Version;Ptr Callback;Bool NoThread;Bool NoCodecs")
    Local $Token = DllStructCreate("ulong_ptr Data")
    DllStructSetData($SI, "Version", 1)
    $aResult = DllCall($GDIPDll, "Int", "GdiplusStartup", _
            "Ptr", DllStructGetPtr($Token), "Ptr", DllStructGetPtr($SI), "Ptr", 0)
    If @error Then
        DllClose($GDIPDll)
        Return SetError(1, 0, False)
    EndIf
    Local $GDIPToken = DllStructGetData($Token, "Data")
    Local $RECT = DllStructCreate("Long; Long; Long Right;Long Bottom")
    DllCall("User32.dll", "Bool", "GetClientRect", "Hwnd", $hWnd, _
            "Ptr", DllStructGetPtr($RECT))
    Local $W = DllStructGetData($RECT, "Right")
    Local $H = DllStructGetData($RECT, "Bottom")
    Switch $D
        Case 0, 1, 2, 3
        Case Else
            $D = 0
    EndSwitch
    Switch $3D
        Case 1, 2, 3
        Case Else
            $3D = 1
    EndSwitch
    Switch $GC
        Case 0, 1
        Case Else
            $GC = 0
    EndSwitch
    If $BW = 0 Then $BW = $W
    If $BH = 0 Then $BH = $H
    Local $pBITMAP = DllStructCreate("Ptr")
    DllCall($GDIPDll, "Int", "GdipCreateBitmapFromScan0", _
            "Int", $W, "Int", $H, "Int", 0, "Int", 0x26200A, "Ptr", 0, _
            "Ptr", DllStructGetPtr($pBITMAP))
    $pBITMAP = DllStructGetData($pBITMAP, 1)
    Local $pGRAPHICS = DllStructCreate("Ptr")
    DllCall($GDIPDll, "Int", "GdipGetImageGraphicsContext", _
            "Ptr", $pBITMAP, "Ptr", DllStructGetPtr($pGRAPHICS))
    $pGRAPHICS = DllStructGetData($pGRAPHICS, 1)
    DllCall($GDIPDll, "Int", "GdipSetSmoothingMode", "Ptr", $pGRAPHICS, "Int", 0)
    Local $RECTF = DllStructCreate("Float L;Float T;Float R;Float B")
    DllStructSetData($RECTF, "R", $BW)
    DllStructSetData($RECTF, "B", $BH)
    Local $Color1 = "0xFF" & $C1
    Local $Color2 = "0xFF" & $C2
    Local $pBRUSH = DllStructCreate("Ptr")
    DllCall($GDIPDll, "Int", "GdipCreateLineBrushFromRect", _
            "Ptr", DllStructGetPtr($RECTF), "Int", $Color1, "Int", $Color2, _
            "Int", $D, "Int", 0, "Ptr", DllStructGetPtr($pBRUSH))
    $pBRUSH = DllStructGetData($pBRUSH, 1)
    DllCall($GDIPDll, "Int", "GdipSetLineGammaCorrection", "Ptr", $pBRUSH, _
            "Int", $GC)
    Local $RELINT = DllStructCreate("Float[5]")
    Switch $3D
        Case 1
            DllStructSetData($RELINT, 1, 0.00, 1)
            DllStructSetData($RELINT, 1, 0.25, 2)
            DllStructSetData($RELINT, 1, 0.50, 3)
            DllStructSetData($RELINT, 1, 0.75, 4)
            DllStructSetData($RELINT, 1, 1.00, 5)
        Case 2
            DllStructSetData($RELINT, 1, 0.0, 1)
            DllStructSetData($RELINT, 1, 0.5, 2)
            DllStructSetData($RELINT, 1, 1.0, 3)
            DllStructSetData($RELINT, 1, 0.5, 4)
            DllStructSetData($RELINT, 1, 0.0, 5)
        Case Else
            DllStructSetData($RELINT, 1, 0.0, 1)
            DllStructSetData($RELINT, 1, 1.0, 2)
            DllStructSetData($RELINT, 1, 1.0, 3)
            DllStructSetData($RELINT, 1, 1.0, 4)
            DllStructSetData($RELINT, 1, 0.0, 5)
    EndSwitch
    Local $RELPOS = DllStructCreate("Float[5]")
    DllStructSetData($RELPOS, 1, 0.0, 1)
    If $3D <> 3 Then
        DllStructSetData($RELPOS, 1, 0.25, 2)
    Else
        DllStructSetData($RELPOS, 1, 0.15, 2)
    EndIf
    DllStructSetData($RELPOS, 1, 0.5, 3)
    If $3D <> 3 Then
        DllStructSetData($RELPOS, 1, 0.75, 4)
    Else
        DllStructSetData($RELPOS, 1, 0.85, 4)
    EndIf
    DllStructSetData($RELPOS, 1, 1.0, 5)
    DllCall($GDIPDll, "Int", "GdipSetLineBlend", _
            "Ptr", $pBRUSH, "Ptr", DllStructGetPtr($RELINT), _
            "Ptr", DllStructGetPtr($RELPOS), "Int", 5)
    DllCall($GDIPDll, "Int", "GdipFillRectangle", "Ptr", $pGRAPHICS, _
            "Ptr", $pBRUSH, "Float", 0, "Float", 0, "Float", $W, "Float", $H)
    Local $hBitmap = DllStructCreate("Ptr")
    DllCall($GDIPDll, "Int", "GdipCreateHBITMAPFromBitmap", _
            "Ptr", $pBITMAP, "Ptr", DllStructGetPtr($hBitmap), "Int", 0XFFFFFFFF)
    $hBitmap = DllStructGetData($hBitmap, 1)
    DllCall($GDIPDll, "Int", "GdipDeleteBrush", "Ptr", $pBRUSH)
    DllCall($GDIPDll, "Int", "GdipDisposeImage", "Ptr", $pBITMAP)
    DllCall($GDIPDll, "Int", "GdipDeleteGraphics", "Ptr", $pGRAPHICS)
    DllCall($GDIPDll, "None", "GdiplusShutdown", "Ptr", $GDIPToken)
    DllClose($GDIPDll)
    GUICtrlSendMsg($idCTRL, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
    Return $hBitmap
EndFunc   ;==>_GUICtrlPic_GradientFill

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlPic_Invert
; Description ...: Farben eines Pic-Controls invertieren.
; Syntax.........: _GUICtrlPic_LoadImage($sPicPath)
; Parameters ....: $idPic          - ControlID aus GUICtrlCreatePic()
; Return values .: Keine
; Author ........: Großvater (www.autoit.de)
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _GUICtrlPic_Invert($idPic)
    Local Const $IMAGE_BITMAP = 0x0000, $STM_SETIMAGE = 0x0172, $STM_GETIMAGE = 0x0173, $DSTINVERT = 0x00550009
    Local $aResult
    Local $hBitmap = GUICtrlSendMsg($idPic, $STM_GETIMAGE, $IMAGE_BITMAP, 0)
    Local $aSize = WinGetClientSize(GUICtrlGetHandle($idPic))
    Local $iWidth = $aSize[0], $iHeight = $aSize[1]
    Local $hGDI32 = DllOpen("Gdi32.dll")
    $aResult = DllCall($hGDI32, "Handle", "CreateCompatibleDC", "Handle", 0)
    Local $hDC = $aResult[0]
    $aResult = DllCall($hGDI32, "Handle", "SelectObject", "Handle", $hDC, "Handle", $hBitmap)
    $aResult = DllCall($hGDI32, "BOOL", "BitBlt", "Handle", $hDC, "INT", 0, "INT", 0, "INT", $iWidth, "INT", $iHeight, _
            "Handle", $hDC, "INT", 0, "INT", 0, "DWORD", $DSTINVERT)
    $aResult = DllCall($hGDI32, "BOOL", "DeleteDC", "Handle", $hDC)
    DllClose($hGDI32)
    GUICtrlSendMsg($idPic, $STM_SETIMAGE, $IMAGE_BITMAP, $hBitmap)
EndFunc   ;==>_GUICtrlPic_Invert
; ===============================================================================================================================