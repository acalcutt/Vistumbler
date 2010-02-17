#CS
07/02/2010 - Version 3.2a
-----------------------------------------------------------------
----------------------NATIVE WIFI FUNCTIONS----------------------
--------------------------For WinXP SP3--------------------------
----------------------------by MattyD----------------------------
-----------------------------------------------------------------
#CE
#include-once

Global	$a_iCall, $ErrorMessage, $WLANAPIDLL = DllOpen("wlanapi.dll"), $GLOBAL_hClientHandle, $GLOBAL_pGUID, $PTR_INFOLIST = 0, _
		$CallbackDisconnectCount = 0, $CallbackConnectCount = 0, $CallbackSSID, $ExtraGUIDs[1]

Global Const _ ;Enumerations
$DOT11_AUTH_ALGORITHM						= 0, _
	$DOT11_AUTH_ALGO_80211_OPEN					= 1, _
	$DOT11_AUTH_ALGO_80211_SHARED_KEY			= 2, _
	$DOT11_AUTH_ALGO_WPA						= 3, _
	$DOT11_AUTH_ALGO_WPA_PSK					= 4, _
	$DOT11_AUTH_ALGO_WPA_NONE					= 5, _
	$DOT11_AUTH_ALGO_RSNA						= 6, _
	$DOT11_AUTH_ALGO_RSNA_PSK					= 7, _
$DOT11_BSS_TYPE								= 1, _
	$dot11_BSS_type_infrastructure				= 1, _
	$dot11_BSS_type_independent					= 2, _
	$dot11_BSS_type_any							= 3, _
$DOT11_CIPHER_ALGORITHM						= 2, _
	$DOT11_CIPHER_ALGO_NONE						= 0x00, _
	$DOT11_CIPHER_ALGO_WEP40					= 0x01, _
	$DOT11_CIPHER_ALGO_TKIP						= 0x02, _
	$DOT11_CIPHER_ALGO_CCMP						= 0x04, _
	$DOT11_CIPHER_ALGO_WEP104					= 0x05, _
	$DOT11_CIPHER_ALGO_WEP						= 0x101, _
$WLAN_CONNECTION_MODE						= 3, _
	$wlan_connection_mode_profile				= 0, _
$WLAN_INTERFACE_STATE						= 4, _
	$wlan_interface_state_connected				= 1, _
	$wlan_interface_state_disconnected			= 4, _
	$wlan_interface_state_authenticating		= 7, _
$WLAN_INTF_OPCODE							= 5, _
	$wlan_intf_opcode_autoconf_enabled			= 1, _
	$wlan_intf_opcode_bss_type					= 5, _
	$wlan_intf_opcode_interface_state			= 6, _
	$wlan_intf_opcode_current_connection		= 7, _
$WLAN_OPCODE_VALUE_TYPE						= 6, _
	$wlan_opcode_value_type_query_only			= 0, _
	$wlan_opcode_value_type_set_by_group_policy	= 1, _
	$wlan_opcode_value_type_set_by_user			= 2, _
	$wlan_opcode_value_type_invalid				= 3

Global Const _ ;Struct Strings
$GUID_STRUCT						= "ulong GUIDFIRST; ushort GUIDSECOND; ushort GUIDTHIRD; ubyte GUIDFOURTH[8]", _
$DOT11_MAC_ADDRESS					= "byte DOT11MACADDRESS[6]", _
$DOT11_SSID							= "ulong uSSIDLength; char ucSSID[32]", _
$WLAN_ASSOCIATION_ATTRIBUTES		= $DOT11_SSID & "; dword DOT11BSSTYPE; " & $DOT11_MAC_ADDRESS & "; dword DOT11PHYTYPE; ulong uDot11PhyIndex; ulong WLANSIGNALQUALITY; ulong ulRxRate; ulong ulTxRate", _
$WLAN_AVAILABLE_NETWORK				= "wchar strProfileName[256]; " & $DOT11_SSID & "; dword DOT11BSSTYPE; ulong uNumberOfBssids; int bNetworkConnectable; dword WLANREASONCODE; ulong uNumberOfPhyTypes; dword DOT11PHYTYPE[8]; int bMorePhyTypes; ulong WLANSIGNALQUALITY; int bSecurityEnabled; dword DOT11AUTHALGORITHM; dword DOT11CIPHERALGORITHM; dword dwFlags; dword dwReserved", _
$WLAN_AVAILABLE_NETWORK_LIST 		= "dword dwNumberOfItems; dword dwIndex", _
$WLAN_SECURITY_ATTRIBUTES			= "int bSecurityEnabled; int bOneXEnabled; dword DOT11AUTHALGORITHM; dword DOT11CIPHERALGORITHM", _
$WLAN_CONNECTION_ATTRIBUTES			= "dword WLANINTERFACESTATE; dword WLANCONNECTIONMODE; wchar strProfileName[256]; " & $WLAN_ASSOCIATION_ATTRIBUTES & "; " & $WLAN_SECURITY_ATTRIBUTES, _
$WLAN_CONNECTION_NOTIFICATION_DATA	= "dword WLANCONNECTIONMODE; wchar strProfileName[256]; " & $DOT11_SSID & "; dword DOT11BSSTYPE; int bSecurityEnabled; dword WLANREASONCODE; wchar strProfileXml[4096]", _
$WLAN_CONNECTION_PARAMETERS			= "dword WLANCONNECTIONMODE; ptr strProfile; ptr PDOT11SSID; ptr PDOT11BSSIDLIST; dword DOT11BSSTYPE; dword dwFlags", _
$WLAN_INTERFACE_INFO				= $GUID_STRUCT & "; wchar strInterfaceDescription[256]; dword WLANINTERFACESTATE", _
$WLAN_INTERFACE_INFO_LIST			= "dword dwNumberOfItems; dword dwIndex", _
$WLAN_NOTIFICATION_DATA				= "dword NotificationSource; dword NotificationCode; " & $GUID_STRUCT & "; dword dwDataSize; ptr pData", _
$WLAN_PROFILE_INFO					= "wchar strProfileName[256]; dword dwFlags", _
$WLAN_PROFILE_INFO_LIST				= "dword dwNumberOfItems; dword dwIndex"

Global Const $Elements_Base_Start = 'WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1"+|name|SSIDConfig+|SSID+|name|-|-|' & _ ;XML Elements
'connectionType|connectionMode|MSM+|security+|authEncryption+|authentication|encryption|useOneX|-|sharedKey+|keyType|protected|keyMaterial|-|keyIndex|'
Global Const $Elements_OneX_Start = 'OneX xmlns="http://www.microsoft.com/networking/OneX/v1"+|EAPConfig+|' & _
'EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig"' & @CRLF & 'xmlns:eapCommon="http://www.microsoft.com/provisioning/EapCommon"' & @CRLF & _
'xmlns:baseEap="http://www.microsoft.com/provisioning/BaseEapMethodConfig"+|EapMethod+|eapCommon:Type|eapCommon:AuthorId|-|Config ' & _
'xmlns:baseEap="http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1"' & @CRLF & _
'xmlns:msPeap="http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV1"' & @CRLF & _
'xmlns:eapTls="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV1"' & @CRLF & _
'xmlns:msChapV2="http://www.microsoft.com/provisioning/MsChapV2ConnectionPropertiesV1"+|'
Global Const $Elements_PEAP_Start = 'baseEap:Eap+|baseEap:Type|msPeap:EapType+|msPeap:ServerValidation+|msPeap:DisableUserPromptForServerValidation|' & _
'msPeap:ServerNames|msPeap:TrustedRootCA|-|msPeap:FastReconnect|msPeap:InnerEapOptional|'
Global Const $Elements_TLS = 'baseEap:Eap+|baseEap:Type|eapTls:EapType+|eapTls:CredentialsSource+|eapTls:SmartCard|eapTls:CertificateStore+|' & _
'eapTls:SimpleCertSelection|-|-|eapTls:ServerValidation+|eapTls:DisableUserPromptForServerValidation|eapTls:ServerNames|eapTls:TrustedRootCA|' & _
'-|eapTls:DifferentUsername|-|-|'
Global Const $Elements_MSCHAP = 'baseEap:Eap+|baseEap:Type|msChapV2:EapType+|msChapV2:UseWinLogonCredentials|-|-|'
Global Const $Elements_PEAP_End = 'msPeap:EnableQuarantineChecks|msPeap:RequireCryptoBinding|-|-|'
Global Const $Elements_OneX_End = '-|ConfigBlob|-|-|-|'
Global Const $Elements_Base_End = '-|-|-'

Func _Wlan_OpenHandle()
	Local $iVesion = 1
	If @OSBuild == "WIN_VISTA" Or @OSBuild == "WIN_2008" Or @OSBuild == "WIN_7" Then $iVesion = 2
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanOpenHandle", "dword", $iVesion, "ptr", 0, "dword*", 0, "hwnd*", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
	Return $a_iCall[4]
EndFunc

Func _Wlan_CloseHandle($hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanCloseHandle", "ptr", $hClientHandle, "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _Wlan_EnumInterfaces($hClientHandle = $GLOBAL_hClientHandle)
    Local $pInfoList, $INFO_LIST, $NumberOfItems, $StructString, $index
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle

	If $PTR_INFOLIST <> 0 Then _Wlan_FreeMemory($PTR_INFOLIST)

    $a_iCall = DllCall($WLANAPIDLL, "dword", "WlanEnumInterfaces", "hwnd", $hClientHandle, "ptr", 0, "ptr*", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))

	$pInfoList = $a_iCall[3]
	$PTR_INFOLIST = $a_iCall[3]
	$INFO_LIST = DllStructCreate($WLAN_INTERFACE_INFO_LIST, $pInfoList)
	$NumberOfItems = DllStructGetData($INFO_LIST, "dwNumberOfItems")

	If Not $NumberOfItems Then Return SetError(2, 0, 0)

	$StructString = _Wlan_BuildListStructString($WLAN_INTERFACE_INFO_LIST, $WLAN_INTERFACE_INFO, $NumberOfItems)
	$INFO_LIST = DllStructCreate($StructString, $pInfoList)

	Dim $InterfaceArray[$NumberOfItems][3]

	For $i = 0 To $NumberOfItems - 1
		$InterfaceArray[$i][0] = $pInfoList + $i * 532 + 8
		$InterfaceArray[$i][1] = StringRegExpReplace(DllStructGetData($INFO_LIST, "strInterfaceDescription" & $index), " - Packet Scheduler Miniport", "")
		$InterfaceArray[$i][2] = DllStructGetData($INFO_LIST, "WLANINTERFACESTATE" & $index)
		If $InterfaceArray[$i][2] = $wlan_interface_state_connected Then $InterfaceArray[$i][2] = "Connected"
		If $InterfaceArray[$i][2] = $wlan_interface_state_disconnected Then $InterfaceArray[$i][2] = "Disconnected"
		If $InterfaceArray[$i][2] = $wlan_interface_state_authenticating Then $InterfaceArray[$i][2] = "Authenticating"
		$index += 1
	Next
   Return($InterfaceArray)
EndFunc

Func _Wlan_Scan($pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanScan", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", 0, "ptr", 0, "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _Wlan_GetAvailableNetworkList($dwFlag = 0, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
    Local $NETWORK_LIST, $index, $pAvailableNetworkList, $NumberOfItems, $StructString, $ArrayDuplicateCount = 0, $ArrayTransferCount = 0
    If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	If $dwFlag == -1 Or $dwFlag == Default Then $dwFlag = 0

    $a_iCall = DllCall($WLANAPIDLL, "dword", "WlanGetAvailableNetworkList", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $dwFlag, "ptr", 0, "ptr*", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))

	$pAvailableNetworkList = $a_iCall[5]

	$NETWORK_LIST = DllStructCreate($WLAN_AVAILABLE_NETWORK_LIST, $pAvailableNetworkList)
	$NumberOfItems = DllStructGetData($NETWORK_LIST, "dwNumberOfItems")

	If Not $NumberOfItems Then Return SetError(2, 0, 0)

	$StructString = _Wlan_BuildListStructString($WLAN_AVAILABLE_NETWORK_LIST, $WLAN_AVAILABLE_NETWORK, $NumberOfItems)
	$NETWORK_LIST = DllStructCreate($StructString, $pAvailableNetworkList)

	Dim $AvailableNetworkArray[$NumberOfItems][8]

	For $i = 0 To $NumberOfItems - 1
		$AvailableNetworkArray[$i][0] = DllStructGetData($NETWORK_LIST, "ucSSID" & $index)
		$AvailableNetworkArray[$i][1] = DllStructGetData($NETWORK_LIST, "DOT11BSSTYPE" & $index)
		$AvailableNetworkArray[$i][2] = DllStructGetData($NETWORK_LIST, "bNetworkConnectable" & $index)
		$AvailableNetworkArray[$i][3] = DllStructGetData($NETWORK_LIST, "WLANSIGNALQUALITY" & $index)
		$AvailableNetworkArray[$i][4] = DllStructGetData($NETWORK_LIST, "DOT11AUTHALGORITHM" & $index)
		$AvailableNetworkArray[$i][5] = DllStructGetData($NETWORK_LIST, "DOT11CIPHERALGORITHM" & $index)
		$AvailableNetworkArray[$i][6] = DllStructGetData($NETWORK_LIST, "dwFlags" & $index)
		$AvailableNetworkArray[$i][7] = DllStructGetData($NETWORK_LIST, "WLANREASONCODE" & $index)
		$index += 1

		If $AvailableNetworkArray[$i][1] == $dot11_BSS_type_infrastructure		Then $AvailableNetworkArray[$i][1] = "Infrastructure"
		If $AvailableNetworkArray[$i][1] == $dot11_BSS_type_independent			Then $AvailableNetworkArray[$i][1] = "Ad Hoc"
		If $AvailableNetworkArray[$i][2] == 1									Then $AvailableNetworkArray[$i][2] = "Connectable"
		If $AvailableNetworkArray[$i][2] == 0									Then $AvailableNetworkArray[$i][2] = "Not Connectable"
		If $AvailableNetworkArray[$i][4] == $DOT11_AUTH_ALGO_80211_OPEN			Then $AvailableNetworkArray[$i][4] = "Open"
		If $AvailableNetworkArray[$i][4] == $DOT11_AUTH_ALGO_80211_SHARED_KEY 	Then $AvailableNetworkArray[$i][4] = "Shared Key"
		If $AvailableNetworkArray[$i][4] == $DOT11_AUTH_ALGO_WPA 				Then $AvailableNetworkArray[$i][4] = "WPA"
		If $AvailableNetworkArray[$i][4] == $DOT11_AUTH_ALGO_WPA_PSK 			Then $AvailableNetworkArray[$i][4] = "WPA-PSK"
		If $AvailableNetworkArray[$i][4] == $DOT11_AUTH_ALGO_RSNA 				Then $AvailableNetworkArray[$i][4] = "WPA2"
		If $AvailableNetworkArray[$i][4] == $DOT11_AUTH_ALGO_RSNA_PSK 			Then $AvailableNetworkArray[$i][4] = "WPA2-PSK"
		If $AvailableNetworkArray[$i][5] == $DOT11_CIPHER_ALGO_NONE				Then $AvailableNetworkArray[$i][5] = "Unencrypted"
		If $AvailableNetworkArray[$i][5] == $DOT11_CIPHER_ALGO_WEP40			Then $AvailableNetworkArray[$i][5] = "WEP-64"
		If $AvailableNetworkArray[$i][5] == $DOT11_CIPHER_ALGO_TKIP				Then $AvailableNetworkArray[$i][5] = "TKIP"
		If $AvailableNetworkArray[$i][5] == $DOT11_CIPHER_ALGO_CCMP				Then $AvailableNetworkArray[$i][5] = "AES"
		If $AvailableNetworkArray[$i][5] == $DOT11_CIPHER_ALGO_WEP104			Then $AvailableNetworkArray[$i][5] = "WEP-128"
		If $AvailableNetworkArray[$i][5] == $DOT11_CIPHER_ALGO_WEP				Then $AvailableNetworkArray[$i][5] = "WEP"
		If $AvailableNetworkArray[$i][6] == 3									Then $AvailableNetworkArray[$i][6] = "Connected"
		If $AvailableNetworkArray[$i][6] == 2									Then $AvailableNetworkArray[$i][6] = "Profile"
		If $AvailableNetworkArray[$i][6] == 0									Then $AvailableNetworkArray[$i][6] = "No Profile"
		If $AvailableNetworkArray[$i][7] <> ""									Then $AvailableNetworkArray[$i][7] = _Wlan_ReasonCodeToString($AvailableNetworkArray[$i][7])
	Next

	_Wlan_FreeMemory($pAvailableNetworkList)

	For $i = 0 To $NumberOfItems - 1
		For $j = $i + 1 To $NumberOfItems - 1
			If $AvailableNetworkArray[$i][0] == "" And $AvailableNetworkArray[$i][1] == "Ad Hoc" Then
				$AvailableNetworkArray[$i][0] = "@"
				$ArrayDuplicateCount += 1
			EndIf
			If $AvailableNetworkArray[$i][0] == $AvailableNetworkArray[$j][0] And $AvailableNetworkArray[$i][1] == $AvailableNetworkArray[$j][1] Then
				If $AvailableNetworkArray[$i][6] == "No Profile" And $AvailableNetworkArray[$i][0] <> "@" Then
					$AvailableNetworkArray[$i][0] = "@"
					$ArrayDuplicateCount += 1
				ElseIf $AvailableNetworkArray[$j][6] == "No Profile" And $AvailableNetworkArray[$i][0] <> "@" Then
					$AvailableNetworkArray[$j][0] = "@"
					$ArrayDuplicateCount += 1
				EndIf
			EndIf
		Next
	Next

	Dim $AvailableNetworkArrayDuplicate[$NumberOfItems - $ArrayDuplicateCount][8]

	For $i = 0 To $NumberOfItems - 1
		If $AvailableNetworkArray[$i][0] <> "@" Then
			For $j = 0 To 7
				$AvailableNetworkArrayDuplicate[$ArrayTransferCount][$j] = $AvailableNetworkArray[$i][$j]
			Next
			$ArrayTransferCount += 1
		EndIf
	Next

	$AvailableNetworkArray = $AvailableNetworkArrayDuplicate
	Return $AvailableNetworkArray
EndFunc

Func _Wlan_Connect($SSID, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $strProfile, $ConnectionParameters
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	$strProfile = DllStructCreate("wchar strProfile[256]")
	DllStructSetData($strProfile, "strProfile", $SSID)

	$ConnectionParameters = DllStructCreate($WLAN_CONNECTION_PARAMETERS)
	DllStructSetData($ConnectionParameters, "strProfile", DllStructGetPtr($strProfile))
	DllStructSetData($ConnectionParameters, "DOT11BSSTYPE", 1)

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanConnect", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", DllStructGetPtr($ConnectionParameters), "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _Wlan_Disconnect($pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanDisconnect", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _Wlan_ConnectWait($SSID, $Timeout = 15, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $strProfile, $ConnectionParameters, $Timer
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	If $Timeout == -1 Or $Timeout == Default Then $Timeout = 15

	$CallbackConnectCount = 0

	$strProfile = DllStructCreate("wchar strProfile[256]")
	DllStructSetData($strProfile, "strProfile", $SSID)

	$ConnectionParameters = DllStructCreate($WLAN_CONNECTION_PARAMETERS)
	DllStructSetData($ConnectionParameters, "strProfile", DllStructGetPtr($strProfile))
	DllStructSetData($ConnectionParameters, "DOT11BSSTYPE", 1)

	_Wlan_RegisterNotification($hClientHandle, 1)

	$Timer = TimerInit()

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanConnect", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", DllStructGetPtr($ConnectionParameters), "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then
		_Wlan_RegisterNotification($hClientHandle, 0)
		Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
	EndIf

	While 1
		Select
			Case TimerDiff($Timer) > 1000 * $Timeout
				$Timeout = "Timeout"
				ExitLoop
			Case $CallbackConnectCount == 3
				ExitLoop
		EndSelect
		Sleep(500)
	WEnd

	_Wlan_RegisterNotification($hClientHandle, 0)

	If $Timeout = "Timeout" Then SetError(5, 0, 0)
	Return $CallbackSSID
EndFunc

Func _Wlan_DisconnectWait($Timeout = 5, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $Timer
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	If $Timeout == -1 Or $Timeout == Default Then $Timeout = 5

	$CallbackDisconnectCount = 0

	_Wlan_RegisterNotification($hClientHandle, 1)

	$Timer = TimerInit()

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanDisconnect", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then
		_Wlan_RegisterNotification($hClientHandle, 0)
		Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
	EndIf

	While 1
		Select
			Case TimerDiff($Timer) > 1000 * $Timeout
				$Timeout = "Timeout"
				ExitLoop
			Case $CallbackDisconnectCount
				ExitLoop
		EndSelect
		Sleep(500)
	WEnd

	_Wlan_RegisterNotification($hClientHandle, 0)

	If $Timeout = "Timeout" Then SetError(5, 0, 0)
EndFunc

Func _Wlan_WaitForDisconnect($Timeout = -1, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $Timer
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $Timeout == Default Then $Timeout = -1

	If _Wlan_QueryInterface(2, $pGUID, $hClientHandle) <> "Connected" Then Return 0

	$CallbackDisconnectCount = 0

	_Wlan_RegisterNotification($hClientHandle, 1)

	$Timer = TimerInit()

	While 1
		Select
			Case TimerDiff($Timer) > 1000 * $Timeout And $Timeout <> -1
				$Timeout = "Timeout"
				ExitLoop
			Case $CallbackDisconnectCount
				ExitLoop
		EndSelect
		Sleep(500)
	WEnd

	_Wlan_RegisterNotification($hClientHandle, 0)

	If $Timeout = "Timeout" Then SetError(5, 0, 0)
EndFunc

Func _Wlan_GetProfileList($pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $pProfileList, $PROFILE_LIST, $NumberOfItems, $StructString, $index
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanGetProfileList", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", 0, "ptr*", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))

	$pProfileList = $a_iCall[4]
	$PROFILE_LIST = DllStructCreate($WLAN_PROFILE_INFO_LIST, $pProfileList)
	$NumberOfItems = DllStructGetData($PROFILE_LIST, "dwNumberOfItems")
	If Not $NumberOfItems Then Return SetError(2, 0, 0)

	$StructString = _Wlan_BuildListStructString($WLAN_PROFILE_INFO_LIST, $WLAN_PROFILE_INFO, $NumberOfItems)
	$PROFILE_LIST = DllStructCreate($StructString, $pProfileList)

	Dim $ProfileArray[$NumberOfItems]

	For $i = 0 To $NumberOfItems - 1
		$ProfileArray[$i] = DllStructGetData($PROFILE_LIST, "strProfileName" & $index)
		$index += 1
	Next

	_Wlan_FreeMemory($pProfileList)

	Return $ProfileArray
EndFunc

Func _Wlan_SetProfileList($aProfileNames, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $StructString = "ptr", $NumberOfItems = UBound($aProfileNames)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	If Not $NumberOfItems Then Return SetError(2, 0, 0)

	For $i = 1 To $NumberOfItems - 1
		$StructString &= ";ptr"
	Next
	For $i = 0 To $NumberOfItems - 1
		$StructString &= ";wchar[32]"
	Next

	$PROFILE_STRUCT = DllStructCreate($StructString)

	For $i = 0 To $NumberOfItems - 1
		DllStructSetData($PROFILE_STRUCT, $i + 1, DllStructGetPtr($PROFILE_STRUCT) + ($NumberOfItems * 4) + ($i * 64))
		DllStructSetData($PROFILE_STRUCT, $NumberOfItems + $i + 1, $aProfileNames[$i])
	Next

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfileList", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $NumberOfItems, "ptr", DllStructGetPtr($PROFILE_STRUCT), "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _Wlan_GetProfile($SSID, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $XMLProfile, $Profile[11], $ProfileAttributes, $TMP
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	$XMLProfile = _Wlan_GetProfileXML($SSID, $pGUID, $hClientHandle)
	If @error Then Return SetError(@error, @extended, $XMLProfile)

	$ProfileAttributes = StringSplit('<name>|<connectionType>|<connectionMode>|<authentication>|<encryption>|<useOneX>|<keyType>|<keyMaterial>|<keyIndex>|<Type xmlns="http://www.microsoft.com/provisioning/EapCommon">|<ConfigBlob>', "|")

	For $i = 1 To UBound($ProfileAttributes) - 1
		$TMP = StringRegExp($XMLProfile, $ProfileAttributes[$i] & "([^<]{0,})<", 1)
		If IsArray($TMP) Then
			$Profile[$i - 1] = $TMP[0]
			If $TMP[0] == "ESS" Then $Profile[$i - 1] = "Infrastructure"
			If $TMP[0] == "IBSS" Then $Profile[$i - 1] = "Ad Hoc"
			If $TMP[0] == "auto" Then $Profile[$i - 1] = "Automatic"
			If $TMP[0] == "manual" Then $Profile[$i - 1] = "Manual"
			If $TMP[0] == "open" Then $Profile[$i - 1] = "Open"
			If $TMP[0] == "shared" Then $Profile[$i - 1] = "Shared Key"
			If $TMP[0] == "WPAPSK" Then $Profile[$i - 1] = "WPA-PSK"
			If $TMP[0] == "WPA2PSK" Then $Profile[$i - 1] = "WPA2-PSK"
			If $TMP[0] == "none" Then $Profile[$i - 1] = "Unencrypted"
			If $TMP[0] == "true" Then $Profile[$i - 1] = "802.1x Enabled"
			If $TMP[0] == "false" Then $Profile[$i - 1] = "802.1x Disabled"
			If $TMP[0] == "networkKey" Then $Profile[$i - 1] = "Network Key"
			If $TMP[0] == "passPhrase" Then $Profile[$i - 1] = "Pass Phrase"
			If $TMP[0] == "13" Then $Profile[$i - 1] = "TLS"
			If $TMP[0] == "25" Then $Profile[$i - 1] = "PEAP"
		EndIf
	Next

	If Not $Profile[2] And $Profile[1] Then $Profile[2] = "Automatic"
	If Not $Profile[7] Then $Profile[6] = "No Key Material"
	If Not $Profile[7] Then $Profile[7] = "No Key Material"
	If $Profile[8] Then $Profile[8] += 1
	If Not $Profile[8] Then $Profile[8] = "No Key Index"
	If Not $Profile[10] Then $Profile[9] = "No Blob"
	If Not $Profile[10] Then $Profile[10] = "No Blob"
	Return $Profile
EndFunc

Func _Wlan_GetProfileXML($SSID, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanGetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $SSID,"ptr", 0, "wstr*", 0, "ptr*", 0, "ptr*", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
	Return $a_iCall[5]
EndFunc

Func _Wlan_SetProfileXML($Profile, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", 0, "wstr", $Profile, "ptr", 0, "int", 1, "ptr", 0, "dword*", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[8] Then Return SetError(1, $a_iCall[0], _Wlan_ReasonCodeToString($a_iCall[8]) & @CRLF)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _Wlan_SetProfile($Profile, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	Local $Return
	$Return = _Wlan_GenerateXMLProfile($Profile)
	If @error Then Return SetError(@error, @extended, $Return)
	$Return = _Wlan_SetProfileXML($Return, $pGUID, $hClientHandle)
	Return SetError(@error, @extended, $Return)
EndFunc

Func _Wlan_GenerateXMLProfile($Profile)
	Local $XMLElements_Start = $Elements_Base_Start, $XMLElements_End = $Elements_Base_End, _
	$XMLProfile = '<?xml version="1.0"?>' & @CRLF, $XMLStack[1] = [-1], $XMLElements, $TMP

	If UBound($Profile, 0) < 1 Or UBound($Profile, 0) > 2 Then Return SetError(3, 0, 0)
	If UBound($Profile, 0) == 1 Then
		$TMP = $Profile
		ReDim $Profile[1][11]
		For $i = 0 To UBound($TMP) - 1
			$Profile[0][$i] = $TMP[$i]
		Next
	EndIf
	If UBound($Profile, 2) < 11 Then ReDim $Profile[UBound($Profile)][11]

	If $Profile[0][5] And $Profile[0][5] <> "802.1x Disabled" And $Profile[0][1] <> "Ad Hoc" Then
		$XMLElements_Start &= $Elements_OneX_Start
		$XMLElements_End = $Elements_OneX_End & $XMLElements_End
		$Profile[0][5] = "true"
		If $Profile[0][9] = "No Blob" Or Not $Profile[0][9] Then
			If UBound($Profile) == 1 Then Return SetError(3, 0, 0)
			$Profile[0][10] = ""
			$Profile[0][9] = ""
			For $i = 1 To UBound($Profile) - 1
				Switch $Profile[$i][0]
					Case "PEAP"
						$XMLElements_Start &= $Elements_PEAP_Start
						$XMLElements_End = $Elements_PEAP_End & $XMLElements_End
						If $Profile[$i][1] = "Fast Reconnect" Then $Profile[$i][1] = "true"
						If $Profile[$i][1] = "No Fast Reconnect" Then $Profile[$i][1] = "false"
						If $Profile[$i][2] = "Quarantine Checks" Then $Profile[$i][2] = "true"
						If $Profile[$i][2] = "No Quarantine Checks" Then $Profile[$i][2] = "false"
						If $Profile[$i][3] = "Require Cryptobinding" Then $Profile[$i][3] = "true"
						If $Profile[$i][3] = "Don't Require Cryptobinding" Then $Profile[$i][3] = "false"
					Case "TLS"
						$XMLElements_Start &= $Elements_TLS
						If $Profile[$i][2] = "Simple Selection" Then $Profile[$i][2] = "true"
						If $Profile[$i][2] = "No Simple Selection" Or Not $Profile[$i][2] Then $Profile[$i][2] = "false"
						If $Profile[$i][1] = "Smart Card" Then $Profile[$i][2] = ""
						If $Profile[$i][3] = "Different User Name" Then $Profile[$i][3] = "true"
						If $Profile[$i][3] = "Same User Name" Then $Profile[$i][3] = "false"
					Case "MSCHAP"
						$XMLElements_Start &= $Elements_MSCHAP
						If $Profile[$i][1] = "Use Win Logon" Then $Profile[$i][1] = "true"
						If $Profile[$i][1] = "Don't Use Win Logon" Then $Profile[$i][1] = "false"
					Case "Validate Certificate"
						If $Profile[$i][1] = "Prompt User" Then $Profile[$i][1] = "false"
						If $Profile[$i][1] = "Don't Prompt User" Then $Profile[$i][1] = "true"
				EndSwitch
			Next
		Else
			If $Profile[0][9] = "Default Blob" Then
				$Profile[0][10] = "00000000280000000500000000000000000000000000000000000000000000000000000000000000"
				$Profile[0][9] = "13"
			EndIf
			If $Profile[0][9] = "TLS" Then $Profile[0][9] = "13"
			If $Profile[0][9] = "PEAP" Then $Profile[0][9] = "25"
		EndIf
	Else
		$Profile[0][5] = "false"
	EndIf

	If $Profile[0][1] = "Infrastructure" Or Not $Profile[0][1] Then $Profile[0][1] = "ESS"
	If $Profile[0][1] = "Ad Hoc" Then $Profile[0][1] = "IBSS"
	If $Profile[0][2] = "Automatic" Or Not $Profile[0][2] Then $Profile[0][2] = "auto"
	$Profile[0][2] = StringLower($Profile[0][2])
	$Profile[0][3] = StringReplace(StringUpper($Profile[0][3]), "-", "")
	If $Profile[0][3] = "Open" Or Not $Profile[0][3] Then $Profile[0][3] = "open"
	If $Profile[0][3] = "Shared Key" Then $Profile[0][3] = "shared"
	$Profile[0][4] = StringUpper($Profile[0][4])
	If $Profile[0][4] = "Unencrypted" Or $Profile[0][4] = "None" Or Not $Profile[0][4] Then $Profile[0][4] = "none"
	If $Profile[0][6] = "Network Key" Or $Profile[0][4] = "WEP" Then $Profile[0][6] = "networkKey"
	If $Profile[0][6] = "Pass Phrase" Then $Profile[0][6] = "passPhrase"
	If $Profile[0][6] = "No Key Material" Then $Profile[0][6] = ""
	If $Profile[0][7] = "No Key Material" Then $Profile[0][7] = ""
	If $Profile[0][8] And $Profile[0][8] <> "No Key Index" Then $Profile[0][8] -= 1
	If $Profile[0][8] = "No Key Index" Then $Profile[0][8] = ""

	$XMLElements = StringSplit($XMLElements_Start & $XMLElements_End, "|")
	For $i = 1 To UBound($XMLElements) - 1
		If StringInStr($XMLElements[$i], @CRLF) Then
			For $j = 0 To $XMLStack[0]
				$XMLElements[$i] = StringReplace($XMLElements[$i], @CRLF, @CRLF & @TAB)
			Next
		EndIf
		If StringInStr($XMLElements[$i], "+") Then
			$XMLProfile &= "<" & StringReplace($XMLElements[$i], "+", "") & ">" & @CRLF
			Redim $XMLStack[Ubound($XMLStack) + 1]
			$XMLStack[Ubound($XMLStack) - 1] = StringReplace($XMLElements[$i], "+", "")
			$XMLStack[0] += 1
		ElseIf $XMLElements[$i] == "-" Then
			$XMLProfile &= "</" & StringRegExpReplace($XMLStack[Ubound($XMLStack) - 1], " [^>]{0,}", "") & ">" & @CRLF
			Redim $XMLStack[Ubound($XMLStack) - 1]
		Else
			$XMLProfile &= "<" & $XMLElements[$i] & "></" & StringRegExpReplace($XMLElements[$i], " [^>]{0,}", "") & ">" & @CRLF
		EndIf
		If $i < UBound($XMLElements) - 1 And $XMLElements[$i + 1] == "-" Then $XMLStack[0] -= 1
		For $j = 0 To $XMLStack[0]
			$XMLProfile &= "	"
		Next
	Next

	If Not $Profile[0][7] Then $XMLProfile = StringRegExpReplace($XMLProfile, "\n[^<]{0,}<sharedKey>[^@]{0,}</keyIndex>\r", "", 1)
	$XMLProfile = StringReplace($XMLProfile, "<name>", "<name>" & $Profile[0][0])
	$XMLProfile = StringRegExpReplace($XMLProfile, "<connectionType>", "\0" & $Profile[0][1])
	$XMLProfile = StringRegExpReplace($XMLProfile, "<connectionMode>", "\0" & $Profile[0][2])
	$XMLProfile = StringRegExpReplace($XMLProfile, "<authentication>", "\0" & $Profile[0][3])
	$XMLProfile = StringRegExpReplace($XMLProfile, "<encryption>", "\0" & $Profile[0][4])
	$XMLProfile = StringRegExpReplace($XMLProfile, "<useOneX>", "\0" & $Profile[0][5])
	$XMLProfile = StringRegExpReplace($XMLProfile, "<keyType>", "\0" & $Profile[0][6])
	$XMLProfile = StringRegExpReplace($XMLProfile, "<protected>", "\0false")
	$XMLProfile = StringReplace($XMLProfile, "<keyMaterial>", "<keyMaterial>" & $Profile[0][7])
	$XMLProfile = StringReplace($XMLProfile, "<keyIndex>", "<keyIndex>" & $Profile[0][8])
	If $Profile[0][10] Then
		$XMLProfile = StringRegExpReplace($XMLProfile, "<ConfigBlob>", "<ConfigBlob>" & $Profile[0][10])
		$XMLProfile = StringRegExpReplace($XMLProfile, "\n[^<]{0,}<Config [^>]{0,}>([^\r]{0,}\r){2}", "")
	EndIf
	$XMLProfile = StringReplace($XMLProfile, "<eapCommon:AuthorId>", "<eapCommon:AuthorId>0")
	$XMLProfile = StringReplace($XMLProfile, "<eapCommon:Type><", "<eapCommon:Type>" & $Profile[0][9] & "<", 1)

	If $Profile[0][5] == "false" Or $Profile[0][9] Then Return StringRegExpReplace($XMLProfile, "\n[^>]{0,}><[^\r]{0,}\r", "")

	Local $Stage = 1
	While 1
		Switch $Profile[$Stage][0]
			Case "Don't Validate Certificate"
				$XMLProfile = StringRegExpReplace($XMLProfile, "\n([^:]){0,}:ServerValidation>\r[^@]{0,}\1:ServerValidation>\r", "", 1)
			Case "Validate Certificate"
				$XMLProfile = StringReplace($XMLProfile, "DisableUserPromptForServerValidation><", "DisableUserPromptForServerValidation>" & $Profile[$Stage][1] & "<", 1)
				$XMLProfile = StringReplace($XMLProfile, "ServerNames><", "ServerNames>" & $Profile[$Stage][2] & "<", 1)
				For $i = 3 To UBound($Profile,2) - 1
					If $Profile[$Stage][$i] Then $XMLProfile = StringRegExpReplace($XMLProfile, "\n[^:]{0,}:TrustedRootCA><[^\r]{0,}\r", "\0\0", 1)
					$XMLProfile = StringReplace($XMLProfile, "TrustedRootCA><", "TrustedRootCA>" & $Profile[$Stage][$i] & "<", 1)
				Next
				$XMLProfile = StringRegExpReplace($XMLProfile, "\n[^:]{0,}:TrustedRootCA><[^\r]{0,}\r", "", 1)
				If Not $Profile[$Stage][1] Then $XMLProfile = StringRegExpReplace($XMLProfile, "\n[^:]{0,}:DisableUserPromptForServerValidation><[^\r]{0,}\r", "", 1)
				If Not $Profile[$Stage][2] Then $XMLProfile = StringRegExpReplace($XMLProfile, "\n[^:]{0,}:ServerNames><[^\r]{0,}\r", "", 1)
				$XMLProfile = StringRegExpReplace($XMLProfile, "(:ServerValidation)>\r[[:space:]]{0,}[^:]{0,}:ServerValidation>", ":ServerValidation />")
			Case "PEAP"
				$XMLProfile = StringReplace($XMLProfile, "<eapCommon:Type><", "<eapCommon:Type>" & "25" & "<", 1)
				$XMLProfile = StringReplace($XMLProfile, "<baseEap:Type><", "<baseEap:Type>" & "25" & "<", 1)
				$XMLProfile = StringReplace($XMLProfile, "<msPeap:FastReconnect><", "<msPeap:FastReconnect>" & $Profile[$Stage][1] & "<", 1)
				$XMLProfile = StringReplace($XMLProfile, "<msPeap:InnerEapOptional><", "<msPeap:InnerEapOptional>0<", 1)
				$XMLProfile = StringReplace($XMLProfile, "<msPeap:EnableQuarantineChecks><", "<msPeap:EnableQuarantineChecks>" & $Profile[$Stage][2] & "<", 1)
				$XMLProfile = StringReplace($XMLProfile, "<msPeap:RequireCryptoBinding><", "<msPeap:RequireCryptoBinding>" & $Profile[$Stage][3] & "<", 1)
			Case "TLS"
				$XMLProfile = StringReplace($XMLProfile, "<eapCommon:Type><", "<eapCommon:Type>" & "13" & "<", 1)
				$XMLProfile = StringReplace($XMLProfile, "<baseEap:Type><", "<baseEap:Type>" & "13" & "<", 1)
				If $Profile[$Stage][2] Then
					$XMLProfile = StringReplace($XMLProfile, "<eapTls:SimpleCertSelection><", "<eapTls:SimpleCertSelection>" & $Profile[$Stage][3] & "<", 1)
					$XMLProfile = StringRegExpReplace($XMLProfile, "\n[^<]{0,}<eapTls:SmartCard><[^\r]{0,}\r", "", 1)
				Else
					$XMLProfile = StringReplace($XMLProfile, "<eapTls:SmartCard></eapTls:SmartCard>", "<eapTls:SmartCard />", 1)
					$XMLProfile = StringRegExpReplace($XMLProfile, "\n[^<]{0,}<eapTls:CertificateStore>[^@]{0,}</eapTls:CertificateStore>\r", "", 1)
				EndIf

				$XMLProfile = StringReplace($XMLProfile, "<eapTls:DifferentUsername><", "<eapTls:DifferentUsername>" & $Profile[$Stage][3] & "<", 1)
			Case "MSCHAP"
				$XMLProfile = StringReplace($XMLProfile, "<baseEap:Type><", "<baseEap:Type>" & "26" & "<", 1)
				$XMLProfile = StringReplace($XMLProfile, "<msChapV2:UseWinLogonCredentials><", "<msChapV2:UseWinLogonCredentials>" & $Profile[$Stage][1] & "<", 1)
		EndSwitch
		$Stage += 1
		If $Stage = UBound($Profile) Then ExitLoop
	WEnd
	$XMLProfile = StringRegExpReplace($XMLProfile, "\n[^>]{0,}><[^\r]{0,}\r", "")
	Return StringRegExpReplace($XMLProfile, "\n[^:]{0,}:ServerValidation>\r[[:space:]]{0,}[^:]{0,}:ServerValidation>\r", "")
EndFunc

Func _Wlan_DeleteProfile($SSID, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanDeleteProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $SSID, "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _Wlan_SetProfilePosition($SSID, $dwPosition, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
    If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfilePosition", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $SSID, "dword", $dwPosition, "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _Wlan_QueryInterface($dwFlag, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $pData, $Output, $AutoConfigState, $BssType, $DOT11BSSTYPE, $ConnectionAttributes
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	Switch $dwFlag
		Case 0
			$dwFlag = $wlan_intf_opcode_autoconf_enabled
		Case 1
			$dwFlag = $wlan_intf_opcode_bss_type
		Case 2
			$dwFlag = $wlan_intf_opcode_interface_state
		Case 3
			$dwFlag = $wlan_intf_opcode_current_connection
	EndSwitch

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanQueryInterface", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $dwFlag, "ptr", 0, "dword*", 0, "ptr*", 0, "dword*", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))

	$pData = $a_iCall[6]

	If $dwFlag == $wlan_intf_opcode_autoconf_enabled Then
		$AutoConfigState = DllStructCreate("int bool", $pData)
		$Output = DllStructGetData($AutoConfigState, "bool")
		If $Output == 1 Then $Output = "Auto Config Enabled"
		If $Output == 0 Then $Output = "Auto Config Disabled"
	ElseIf $dwFlag == $wlan_intf_opcode_bss_type Then
		$BssType = DllStructCreate("dword DOT11BSSTYPE", $pData)
		$DOT11BSSTYPE = DllStructGetData($BssType, "DOT11BSSTYPE")
		If $DOT11BSSTYPE == $dot11_BSS_type_infrastructure	Then $Output = "Infrastructure Only"
		If $DOT11BSSTYPE == $dot11_BSS_type_independent		Then $Output = "Ad Hoc Only"
		If $DOT11BSSTYPE == $dot11_BSS_type_any				Then $Output = "Any Available Network"
	ElseIf $dwFlag == $wlan_intf_opcode_interface_state Then
		$InterfaceState = DllStructCreate("dword WLANINTERFACESTATE", $pData)
		$WLANINTERFACESTATE = DllStructGetData($InterfaceState, "WLANINTERFACESTATE")
		If $WLANINTERFACESTATE == $wlan_interface_state_connected		Then $Output = "Connected"
		If $WLANINTERFACESTATE == $wlan_interface_state_disconnected	Then $Output = "Disconnected"
		If $WLANINTERFACESTATE == $wlan_interface_state_authenticating	Then $Output = "Authenticating"
	ElseIf $dwFlag == $wlan_intf_opcode_Current_Connection Then
		$ConnectionAttributes = DllStructCreate($WLAN_CONNECTION_ATTRIBUTES, $pData)
		Dim $Output[8]
		$Output[0] = DllStructGetData($ConnectionAttributes, "WLANINTERFACESTATE")
			If $Output[0] == $wlan_interface_state_connected		Then $Output[0] = "Connected"
			If $Output[0] == $wlan_interface_state_disconnected		Then $Output[0] = "Disconnected"
			If $Output[0] == $wlan_interface_state_authenticating	Then $Output[0] = "Authenticating"
		$Output[1] = DllStructGetData($ConnectionAttributes, "strProfileName")
		$Output[2] = DllStructGetData($ConnectionAttributes, "DOT11MACADDRESS")
			$Output[2] = StringReplace($Output[2], "0x", "")
			$Output[2] = StringRegExpReplace($Output[2], "[[:xdigit:]]{2}", "\0-", 5)
		$Output[3] = DllStructGetData($ConnectionAttributes, "WLANSIGNALQUALITY")
		$Output[4] = DllStructGetData($ConnectionAttributes, "bSecurityEnabled")
			If $Output[4] == 1	Then $Output[4] = "Security Enabled"
			If $Output[4] == 0	Then $Output[4] = "Security Disabled"
		$Output[5] = DllStructGetData($ConnectionAttributes, "bOneXEnabled")
			If $Output[5] == 1	Then $Output[5] = "802.1x Enabled"
			If $Output[5] == 0	Then $Output[5] = "802.1x Disabled"
		$Output[6] = DllStructGetData($ConnectionAttributes, "DOT11AUTHALGORITHM")
			If $Output[6] == $DOT11_AUTH_ALGO_80211_OPEN		Then $Output[6] = "Open"
			If $Output[6] == $DOT11_AUTH_ALGO_80211_SHARED_KEY	Then $Output[6] = "Shared Key"
			If $Output[6] == $DOT11_AUTH_ALGO_WPA				Then $Output[6] = "WPA"
			If $Output[6] == $DOT11_AUTH_ALGO_WPA_PSK			Then $Output[6] = "WPA-PSK"
			If $Output[6] == $DOT11_AUTH_ALGO_RSNA				Then $Output[6] = "WPA2"
			If $Output[6] == $DOT11_AUTH_ALGO_RSNA_PSK			Then $Output[6] = "WPA2-PSK"
		$Output[7] = DllStructGetData($ConnectionAttributes, "DOT11CIPHERALGORITHM")
			If $Output[7] == $DOT11_CIPHER_ALGO_NONE	Then $Output[7] = "Unencrypted"
			If $Output[7] == $DOT11_CIPHER_ALGO_WEP40	Then $Output[7] = "WEP-64"
			If $Output[7] == $DOT11_CIPHER_ALGO_TKIP	Then $Output[7] = "TKIP"
			If $Output[7] == $DOT11_CIPHER_ALGO_CCMP	Then $Output[7] = "AES"
			If $Output[7] == $DOT11_CIPHER_ALGO_WEP104	Then $Output[7] = "WEP-128"
			If $Output[7] == $DOT11_CIPHER_ALGO_WEP		Then $Output[7] = "WEP"
		EndIf

		_Wlan_FreeMemory($pData)

	Return $Output
EndFunc

Func _Wlan_SetInterface($dwFlag, $strData, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $Input, $Struct
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	If $dwFlag == 0 Then
		$dwFlag = $wlan_intf_opcode_autoconf_enabled
	ElseIf $dwFlag == 1 Then
		$dwFlag = $wlan_intf_opcode_bss_type
	EndIf

	$AutoConfigState = DllStructCreate("int bool")
	If $dwFlag == $wlan_intf_opcode_autoconf_enabled Then
		$Struct = DllStructCreate("int bool")
		If $strData == "Auto Config Enabled"	Then $Input = 1
		If $strData == "Auto Config Disabled"	Then $Input = 0
		DllStructSetData($Struct, "bool", $Input)
	ElseIf $dwFlag == $wlan_intf_opcode_bss_type Then
		$Struct = DllStructCreate("dword DOT11BSSTYPE")
		If $strData == "Infrastructure Only"	Then $Input = $dot11_BSS_type_infrastructure
		If $strData == "Ad Hoc Only"			Then $Input = $dot11_BSS_type_independent
		If $strData == "Any Available Network"	Then $Input = $dot11_BSS_type_any
		DllStructSetData($Struct, "DOT11BSSTYPE", $Input)
	EndIf

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetInterface", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $dwFlag, "dword", 4, "ptr", DllStructGetPtr($Struct), "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

;----Tools----;

Func _Wlan_StartSession()
	Local $Error, $Extended, $hClientHandle, $InterfaceArray
	$hClientHandle = _Wlan_OpenHandle()
	If @error Then Return SetError(@error, @extended, $hClientHandle)

	$InterfaceArray = _Wlan_EnumInterfaces($hClientHandle)
	If @error Then
		$Error = @error
		$Extended = @extended
		_Wlan_CloseHandle($hClientHandle)
		Return SetError($Error, $Extended, $InterfaceArray)
	EndIf

	_Wlan_SetGlobalConstants($InterfaceArray[0][0], $hClientHandle)

	SetExtended($hClientHandle)
	Return $InterfaceArray
EndFunc

Func _Wlan_EndSession($hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	_Wlan_CloseHandle($hClientHandle)
	SetError(@error, @extended, 0)
	DllClose($WLANAPIDLL)
EndFunc

Func _Wlan_SetGlobalConstants($pGUID, $hClientHandle = "")
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	If $hClientHandle Then Global $GLOBAL_hClientHandle = $hClientHandle
	If $pGUID Then Global $GLOBAL_pGUID = $pGUID
EndFunc

Func _Wlan_StringTopGuid($strGUID)
	Local $aGUID
	$strGUID = StringRegExpReplace($strGUID, "[}{]", "")
	$aGUID = StringSplit($strGUID, "-")
	If UBound($aGUID) < 6 Then Return SetError(3, 0, 0)

	$ExtraGUIDs[UBound($ExtraGUIDs) - 1] = DllStructCreate($GUID_STRUCT)
	ReDim $ExtraGUIDs[UBound($ExtraGUIDs) + 1]
	DllStructSetData($ExtraGUIDs[UBound($ExtraGUIDs) - 2], "GUIDFIRST", "0x" & $aGUID[1])
	DllStructSetData($ExtraGUIDs[UBound($ExtraGUIDs) - 2], "GUIDSECOND", "0x" & $aGUID[2])
	DllStructSetData($ExtraGUIDs[UBound($ExtraGUIDs) - 2], "GUIDTHIRD", "0x" & $aGUID[3])
	DllStructSetData($ExtraGUIDs[UBound($ExtraGUIDs) - 2], "GUIDFOURTH", "0x" & $aGUID[4] & $aGUID[5])
	Return DllStructGetPtr($ExtraGUIDs[UBound($ExtraGUIDs) - 2])
EndFunc

Func _Wlan_pGuidToString($pGUID = $GLOBAL_pGUID)
	Local $GUIDstruct2, $strGUID = "{"
	Dim $aGUID[5]
	$GUIDstruct2 = DllStructCreate($GUID_STRUCT, $pGUID)

	$aGUID[0] = Hex(DllStructGetData($GUIDstruct2, "GUIDFIRST"))
	$aGUID[1] = Hex(DllStructGetData($GUIDstruct2, "GUIDSECOND"), 4)
	$aGUID[2] = Hex(DllStructGetData($GUIDstruct2, "GUIDTHIRD"), 4)
	$aGUID[3] = Hex(StringTrimRight(DllStructGetData($GUIDstruct2, "GUIDFOURTH"), 12), 4)
	$aGUID[4] = StringTrimLeft(DllStructGetData($GUIDstruct2, "GUIDFOURTH"), 6)

	For $i = 0 To UBound($aGUID) - 2
		$strGUID &= $aGUID[$i] & "-"
	Next

	$strGUID &= $aGUID[4] & "}"

	Return $strGUID
EndFunc

;----Function Dependencies---;

Func _Wlan_ReasonCodeToString($ReasonCode)
	Local $BUFFER

	$BUFFER = DllStructCreate("wchar BUFFER[512]")
	DllCall($WLANAPIDLL, "dword", "WlanReasonCodeToString", "dword", $ReasonCode, "dword", 512, "ptr", DllStructGetPtr($BUFFER), "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	Return(DllStructGetData($BUFFER, "BUFFER"))
EndFunc

Func _Wlan_BuildListStructString($Header, $Data, $NumberOfItems)
	Local $StructString, $StructElements, $StructElements2, $Buffer

	$StructString = $Header

	For $i = 0 To $NumberOfItems - 1
		$StructString = $StructString & "; " & $Data
	Next

	$StructElements = StringSplit($StructString, ";")
	$StructElements2 = $StructElements
	$StructString = ""
	Dim $ElementCount[UBound($StructElements)], $Buffer[UBound($StructElements)]

	For $i = 1 To Ubound($StructElements) -1
		For $j = $i To Ubound($StructElements2) -1
			If $i <> $j And $StructElements[$i] == $StructElements2[$j] Then
				If StringInStr($StructElements[$i], "[") <> 0 Then
					$Buffer[$j] = StringRegExpReplace($StructElements[$i], "[^[]{0,1024}", "" )
					$StructElements2[$j] = StringRegExpReplace($StructElements2[$j], "[[][[:digit:]]{0,9}[]]", "" )
				Else
					$Buffer[$j] = ""
				EndIf

				$ElementCount[$i] += 1

				$StructElements2[$j] &= $ElementCount[$i] & $Buffer[$j]
			EndIf
		Next
	Next

	For $i = 1 To Ubound($StructElements2) -1
		$StructString &= $StructElements2[$i]
		If $i <> Ubound($StructElements2) -1 Then $StructString &= ";"
	Next

	Return $StructString
EndFunc

Func _Wlan_GetErrorMessage($Error)
	Local $BUFFER = DllStructCreate("char BUFFER[4096]")
	DllCall("Kernel32.dll", "int", "FormatMessageA", "int", 0x1000, "hwnd", 0, "int", $Error, "int", 0, "ptr", DllStructGetPtr($BUFFER), "int", 4096, "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	Return DllStructGetData($BUFFER, "BUFFER")
EndFunc

Func _Wlan_FreeMemory($ptr)
	DllCall($WLANAPIDLL, "dword", "WlanFreeMemory", "ptr", $ptr)
	If @error Then Return SetError(4, 0, 0)
EndFunc

Func _Wlan_RegisterNotification($hClientHandle, $Flag)
	Local $WLAN_NOTIFICATION_CALLBACK
	If $Flag = 1 Then
		$WLAN_NOTIFICATION_CALLBACK = DllCallbackRegister("_WLAN_NOTIFICATION_CALLBACK", "none", "ptr;ptr")
		$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanRegisterNotification", "hwnd", $hClientHandle, "dword", 0X08, "int", 0, "ptr", DllCallbackGetPtr($WLAN_NOTIFICATION_CALLBACK), "ptr", 0, "ptr", 0, "ptr*", 0)
	Else
		$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanRegisterNotification", "hwnd", $hClientHandle, "dword", 0, "int", 0, "ptr", 0, "ptr", 0, "ptr", 0, "ptr*", 0)
	EndIf
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _WLAN_NOTIFICATION_CALLBACK($PTR1, $PTR2)
	Local $NOTIFICATION, $pData, $Data
	$CallbackSSID = ""
	$NOTIFICATION = DllStructCreate($WLAN_NOTIFICATION_DATA, $PTR1)
	$pData = DllStructGetData($NOTIFICATION, "pData")
	$Data = DllStructCreate($WLAN_CONNECTION_NOTIFICATION_DATA, $pData)
	If DllStructGetData($NOTIFICATION, "NotificationCode") == 10 Then $CallbackConnectCount += 1
	If DllStructGetData($NOTIFICATION, "NotificationCode") == 21 Then $CallbackDisconnectCount += 1

	If $CallbackConnectCount = 3 Then $CallbackSSID = DllStructGetData($Data, "ucSSID")
EndFunc
