;START OF VIRTUAL MACHINE PROTECTION
Opt("MustDeclareVars", 1)

Call("_VCheck")

Func _VCheck()
	Local $strComputer = ".", $sMake, $sModel, $sBIOSVersion, $bIsVM, $sVMPlatform
	Local $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	Local $colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem")
	If IsObj($colItems) Then
		For $objItem In $colItems
			$sMake = $objItem.Manufacturer
			$sModel = $objItem.Model
		Next
	EndIf
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_BIOS", "WQL", 0x10 + 0x20)
	If IsObj($colItems) Then
		For $objItem In $colItems
			$sBIOSVersion = $objItem.SMBIOSBIOSVersion
		Next
	EndIf
	$bIsVM = False
	$sVMPlatform = ""
	If $sModel = "Virtual Machine" Then
		$sVMPlatform = "Hyper-V"
		$bIsVM = True
		Switch $sBIOSVersion
			Case "VRTUAL - 1000831"
				$bIsVM = True
				$sVMPlatform = "Hyper-V 2008 Beta or RC0"
			Case "VRTUAL - 5000805", "BIOS Date: 05/05/08 20:35:56 Ver: 08.00.02"
				$bIsVM = True
				$sVMPlatform = "Hyper-V 2008 RTM"
			Case "VRTUAL - 3000919"
				$bIsVM = True
				$sVMPlatform = "Hyper-V 2008 R2"
			Case "A M I - 2000622"
				$bIsVM = True
				$sVMPlatform = "VS2005R2SP1 or VPC2007"
			Case "A M I - 9000520"
				$bIsVM = True
				$sVMPlatform = "VS2005R2"
			Case "A M I - 9000816", "A M I - 6000901"
				$bIsVM = True
				$sVMPlatform = "Windows Virtual PC"
			Case "A M I - 8000314"
				$bIsVM = True
				$sVMPlatform = "VS2005 or VPC2004"
		EndSwitch
	ElseIf $sModel = "VMware Virtual Platform" Then
		$sVMPlatform = "VMware"
		$bIsVM = True
	ElseIf $sModel = "VirtualBox" Then
		$bIsVM = True
		$sVMPlatform = "VirtualBox"
	Else
		; This computer does not appear to be a virtual machine.
	EndIf
	If $bIsVM Then
		MsgBox(4096, "", "IM WAY TOO SEXY, THEREFOR I DONT WANNA RUN IN YOUR VIRTUAL SHIT")
		Exit
	Else

	EndIf
	Return $bIsVM
EndFunc   ;==>_VCheck
