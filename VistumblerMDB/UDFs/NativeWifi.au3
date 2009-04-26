#cs
26/04/2009 - Version 3.0a
-----------------------------------------------------------------
----------------------NATIVE WIFI FUNCTIONS----------------------
--------------------------For WinXP SP3--------------------------
----------------------------by MattyD----------------------------
-----------------------------------------------------------------

REQUIREMENTS
	OS:
		XP SP3 or SP2 with hotfix:
			http://support.microsoft.com/kb/918997
			limited fuctionality on Vista... 
	
	Services:
		Windows Zero Configuration (wzcsvc)
		Network Connections (netman)

(UN)INCORPERATED DLL FUNCTIONS
-----------------------------------------------------------------
	Completed Functions:		|	Incomplete Functions:
--------------------------------|--------------------------------
	WlanOpenHandle				|	WlanAllocateMemory
	WlanCloseHandle				|	WlanSetProfileEapXmlUserData
	WlanEnumInterfaces			|
	WlanScan					|
	WlanGetAvailableNetworkList	|
	WlanConnect					|
	WlanDisconnect				|
	WlanGetProfileList			|
	WlanSetProfileList			|
	WlanGetProfile				|
	WlanSetProfile				|
	WlanDeleteProfile			|
	WlanSetProfilePosition		|
	WlanQueryInterface			|
	WlanSetInterface			|
	WlanFreeMemory				|
	WlanRegisterNotification	|
	WLAN_NOTIFICATION_CALLBACK	|
	WlanReasonCodeToString		|
------------------------------------------------------------------

ERROR VALUES
    @error = 0 
        Success!
    
    @error = 1
        Dll Call Error
        
        The function returns a reason for the error
        
        @Extended is set to the Dll error code 
            To interpret the @extended value go to:
            http://msdn.microsoft.com/en-us/library/ms681381.aspx
    
    @error = 2
        Number of interfaces/available networks/profiles/profile names = 0
        
	@error = 3
		Invalid Profile
		
	@error = 4
		Unable To Use Dll
		
	@error = 5
		Function timed out

FUNCTION TABLE
NB:	pGUID and $hClientHandle are only optional if _Wlan_StartSession()
	or _Wlan_SetGlobalConstants() have been called...
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|::::::::::::::NAME:::::::::::::|:::::::::::::::::::;:::::::::::::::::SYNTAX::::::::::::::::::::::::::::::::::::|::::::::::::::::::::::::::::DESCRIPTION::::::::::::::::::::::::::::|::LINE::|
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|	Start Session				|	_Wlan_StartSession()														|	Calls OpenHandle, EnumInterfaces and SetGlobalConstants			|  128	 |
|	End Session					|	_Wlan_EndSession([$hClientHandle])											|	Calls CloseHandle and closes WlanAPI.dll						|  128	 |
|	Open Handle					|	_Wlan_OpenHandle()															|	Returns a client handle for following functions					|  140   |
|	Close Handle				|	_Wlan_CloseHandle([$hClientHandle])											|	Closes a client handle											|  140   |
|	Enumerate Interfaces		|	_Wlan_EnumInterfaces([$hClientHandle])										|	Enumerates and gathers interface information (incl. $pGUID)		|  147   |
|	Set Global Constants		|	_Wlan_SetGlobalConstants($pGUID[, $hClientHandle])							|	Sets default $pGUID and $hClientHandle values					|  147   |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|	Scan						|	_Wlan_Scan([$pGUID[, $hClientHandle]])										|	Scans for wireless networks										|  165   |
|	Get Available Network List	|	_Wlan_GetAvailableNetworkList([$dwFlag[, $pGUID[, $hClientHandle]]])		|	Returns information on networks in range						|  161   |
|	Connect						|	_Wlan_Connect($SSID[, $pGUID[, $hClientHandle]])							|	Connects to a network if a corresponding profile exists			|  172   |
|	Disconnect					|	_Wlan_Disconnect([$pGUID[, $hClientHandle]])								|	Disconnects from a network										|  180   |
|	Connect Wait				|	_Wlan_ConnectWait($SSID[, $Timeout[, $pGUID[, $hClientHandle]]])			|	As Connect but waits for connection to complete					|  187   |
|	Disconnect Wait				|	_Wlan_DisconnectWait([$Timeout[, $pGUID[, $hClientHandle]]])				|	As Disconnect but waits for connection to cease					|  202   |
|	Get Profile List			|	_Wlan_GetProfileList([$pGUID[, $hClientHandle]])							|	Returns a list of profiles in order of priority					|  213   |
|	Set Profile List			|	_Wlan_SetProfileList($aProfileNames[, $pGUID[, $hClientHandle]])			|	Sets existing profiles in order of priority						|  220   |
|	Get Profile					|	_Wlan_GetProfile($SSID[, $pGUID[, $hClientHandle]])							|	Returns information about an existing profile					|  228   |
|	Set Profile					|	_Wlan_SetProfile($Profile[, $pGUID[, $hClientHandle]])						|	Creates a new profile											|  226   |
|	Delete Profile				|	_Wlan_DeleteProfile($SSID[, $pGUID[, $hClientHandle]])						|	Purges an existing profile										|  242   |
|	Set Profile Position		|	_Wlan_SetProfilePosition($SSID, $dwPosition[, $pGUID[, $hClientHandle]])	|	Changes the priority of a nominated profile						|  250   |
|	Query Interface				|	_Wlan_QueryInterface($dwFlag[, $pGUID[, $hClientHandle]])					|	Returns various interface settings or connection information	|  259   |
|	Set Interface				|	_Wlan_SetInterface($dwFlag, $strData[, $pGUID[, $hClientHandle]])			|	Sets various interface parameters								|  283   |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
|	String To pGUID				|	_Wlan_StringTopGuid($strGUID)												|	Returns a $pGUID value from a GUID string						|  306   |
|	pGUID To String				|	_Wlan_pGuidToString([$pGUID])												|	Returns a GUID string from a $pGUID value						|  317   |
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION REFERENCE
General Remarks:
	$hClientHandle is obtained through calling StartSession or OpenHandle
	Once a handle is open there is no need to call these functions again unless CloseHandle or EndSession is called

	$pGUID is obtained through calling StartSession or EnumInterfaces
	
	$hClientHandle and $pGUID values are only optional in fuctions if StartSession or SetGlobalConstants have been called
	
	A function returning "The system cannot find the file specified." (@error = 1 and @extended = 2) is caused by an invalid $pGUID value
	
	Auto Config (AKA the "Use Windows to configure my wireless network settings" checkbox) must be enabled for many functions to work. 
	This can be done through SetInterface
	
	Ad hoc profiles names are generated from the SSID of the network followed by "-adhoc" 
	This should be generally be added on the $SSID parameter for profile related functions (including Connect)
	This should not be added on for SetProfile

	Ad hoc profiles appear after the infrastructure profiles in the profile list
	If changed with SetProfilePosition or SetProfileList, WZCSVC will reorder them to fit this criterion

	EnumInterfaces and QueryInterface will show "Connected" at the start of the connection process
	ConnectWait will wait until the end of the process before resuming the script

---------------------------------------------------------------------------------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
---------------------------------------------------------------------------------------------------------------------------------------------------------
::::::::::::::::::::::::::::::::StartSession::::::::::::::::::::::::::::::::|:::::::::::::::::::::::::::::::::EndSession:::::::::::::::::::::::::::::::::
Function:																	|Function:
	Calls OpenHandle, EnumInterfaces and SetGlobalConstants (pGUID			|	Calls CloseHandle and closes wlanapi.dll
	parameter is set to the first interface)								|
																			|Syntax:
Syntax:																		|	_Wlan_EndSession([$hClientHandle])
	_Wlan_StartSession()													|
																			|
Return Value:																|Return Value:
	Returns the output of EnumInterfaces and sets @extended to the output	|	Returns the output of EnumInterfaces and sets @extended to the output of
	of OpenHandle															|	of OpenHandle
----------------------------------------------------------------------------|----------------------------------------------------------------------------
::::::::::::::::::::::::::::::::::OpenHandle::::::::::::::::::::::::::::::::|:::::::::::::::::::::::::::::::::CloseHandle::::::::::::::::::::::::::::::::
Function:																	|Function:
    Returns a client handle for following functions							|    Closes a client session handle
																			|
Syntax:																		|Syntax:
    _Wlan_OpenHandle()														|	_Wlan_CloseHandle([$hClientHandle])
----------------------------------------------------------------------------|----------------------------------------------------------------------------
:::::::::::::::::::::::::::::::EnumInterfaces:::::::::::::::::::::::::::::::|:::::::::::::::::::::::::::::SetGlobalConstants:::::::::::::::::::::::::::::
Function:																	|Function:
    Enumerates all enabled wireless cards									|	Sets default values for $hClientHandle and $pGUID
																			|	
Syntax:																		|Syntax:
    _Wlan_EnumInterfaces([$hClientHandle])									|	_Wlan_SetGlobalConstants($pGUID[, $hClientHandle])
																			|
Return Values:																|Remarks:
    Returns a table															|	-1 or Default can be substituted for $hClientHandle and $pGUID for 
    $InterfaceArray[Interface Index][0] - Pointer to the interface's GUID	|	following fuctions
    $InterfaceArray[Interface Index][1] - The name of the interface			|	
    $InterfaceArray[Interface Index][2] - Connection status					|	a blank string ("") can be used for either parameter to preserve the
																			|	existing default value
    Possible connection status values are:									|----------------------------------------------------------------------------
    "Connected"																|:::::::::::::::::::::::::::GetAvailableNetworkList::::::::::::::::::::::::::
    "Disconnected"															|Function:
    "Authenticating"														|    Retrieves the list of available networks on a given interface
----------------------------------------------------------------------------|
::::::::::::::::::::::::::::::::::::Scan::::::::::::::::::::::::::::::::::::|Syntax:
Function:																	|	_Wlan_GetAvailableNetworkList([$dwFlag[, $pGUID[, $hClientHandle]]])
    Scans for available networks on a given interface						|
																			|	$dwFlag - Controls the type of networks returned in the list
Syntax:																		|
    _Wlan_Scan([$pGUID[, $hClientHandle]])									|	$dwFlag values are:
----------------------------------------------------------------------------|		0 - infrastructure only
:::::::::::::::::::::::::::::::::::Connect::::::::::::::::::::::::::::::::::|		1 - include ad hoc networks
Function:																	|		2 - include hidden networks
    Connects to a given network with if a corresponding profile exists		|
																			|Return Values:
Syntax:																		|	Returns a table
    _Wlan_Connect($SSID[, $pGUID[, $hClientHandle]])						|	$AvailableNetworkArray[Network Index][0] - SSID
    $SSID - The name of the profile											|	$AvailableNetworkArray[Network Index][1] - Network type
----------------------------------------------------------------------------|	$AvailableNetworkArray[Network Index][2] - Connectablity
:::::::::::::::::::::::::::::::::Disconnect:::::::::::::::::::::::::::::::::|	$AvailableNetworkArray[Network Index][3] - Signal strength
Function:																	|	$AvailableNetworkArray[Network Index][4] - Authentication method
    Disconnects an interface from a network									|	$AvailableNetworkArray[Network Index][5] - Encryption method
																			|	$AvailableNetworkArray[Network Index][6] - Profile status
Syntax:																		|	$AvailableNetworkArray[Network Index][7] - Not connectable reason
	_Wlan_Disconnect([$pGUID[, $hClientHandle]])							|
---------------------------------------------------------------------------	|	Possible network type values are:
:::::::::::::::::::::::::::::::::ConnectWait::::::::::::::::::::::::::::::::|	"Infrastructure"
Function:																	|	"Ad Hoc"
    Connects to a given network and waits for the connection process to end	|
																			|	Possible connectability values are:
Syntax:																		|	"Connectable"
    _Wlan_ConnectWait($SSID[, $Timeout[, $pGUID[, $hClientHandle]]])		|	"Not Connectable"
    $SSID - The name of the profile											|	
	$Timeout - The time allowed for ConnectWait to finish in seconds		|	Possible signal strength values are:
																			|	0 to 100 (scale is linear)
Return Values:																|	0 = -100dbm or less
	Returns SSID of connected network										|	100 = -50dbm or more
																			|
Remarks:																	|	Possible authentication method values are:
	The default $Timeout value is 15										|	"Open"
----------------------------------------------------------------------------|	"Shared Key"
:::::::::::::::::::::::::::::::DisconnectWait:::::::::::::::::::::::::::::::|	"WPA"
Function:																	|	"WPA-PSK"
    Disconnects from a network and waits for the process to end				|	"WPA2"
																			|	"WPA2-PSK"
Syntax:																		|
	_Wlan_DisconnectWait([$Timeout[, $pGUID[, $hClientHandle]]])			|	Possible encryption method values are:
	$Timeout - The time allowed for DisconnectWait to finish in seconds		|	"None"
																			|	"WEP"
Remarks:																	|	"WEP-64"	
	The default $Timeout value is 5											|	"WEP-128"
----------------------------------------------------------------------------|	"TKIP"
:::::::::::::::::::::::::::::::GetProfileList:::::::::::::::::::::::::::::::|	"AES"
Function:																	|
    Retrieves an array of profile names										|	Possible connection status values are:
																			|	"No Profile" - No profile exists for the network
Syntax:																		|	"Profile" - Profile exists for the network
    _Wlan_GetProfileList([$pGUID[, $hClientHandle]])						|	"Connected" - Connected to the network (profile exists)
----------------------------------------------------------------------------|
:::::::::::::::::::::::::::::::SetProfileList:::::::::::::::::::::::::::::::|Remarks:
Function:																	|	if the connectability value for a network is "Connectable", the Not
    Sets the order of profiles in the preferred network list				|	connectable reason value will be 0
																			|
Syntax:																		|	The default $dwflag value is 0
    _Wlan_SetProfileList($aProfileNames[, $pGUID[, $hClientHandle]])		|----------------------------------------------------------------------------
	$aProfileNames - An array of profile names in the desired order			|:::::::::::::::::::::::::::::::::SetProfile:::::::::::::::::::::::::::::::::
----------------------------------------------------------------------------|Function:
:::::::::::::::::::::::::::::::::GetProfile:::::::::::::::::::::::::::::::::|	Sets the content of a specific profile
Function:																	|
    Retrieves information about a given profile 							|Syntax:
																			|	_Wlan_SetProfile($Profile[, $pGUID[, $hClientHandle]])
Syntax:																		|	$Profile - An array containing profile information (see GetProfile())
    _Wlan_GetProfile($SSID[, $pGUID[, $hClientHandle]])						|
    $SSID - The name of the profile											|Remarks:
																			|	$Profile must be a 9 element table
Return Values:																|	Key type must be "Network Key" for WEP profiles
    Returns an array														|	Key material must be left blank when not required
    $Profile[0] - SSID														|	Key material for WEP must be 5 or 13 ASCII characters or 10 or 26 Hex
    $Profile[1] - Network type												|	Key material for WPA-PSK and WPA2-PSK must be 8 or 63 ASCII characters 
    $Profile[2] - Connection method											|	or 64 Hex
    $Profile[3] - Authentication method										|----------------------------------------------------------------------------
    $Profile[4] - Encryption method											|:::::::::::::::::::::::::::::::DeleteProfile::::::::::::::::::::::::::::::::
	$Profile[5] - 802.1x status												|Function:
    $Profile[6] - Key type													|	Deletes a specific profile
    $Profile[7] - Key material												|
    $Profile[8] - Key index													|Syntax:
																			|	_Wlan_DeleteProfile($SSID[, $pGUID[, $hClientHandle]])
    Possible network type values are:										|	$SSID - The name of the profile
    "Infrastructure"														|----------------------------------------------------------------------------
    "Ad Hoc"																|:::::::::::::::::::::::::::::SetProfilePosition:::::::::::::::::::::::::::::
																			|Function:
    Possible connection method values are:									|	Sets the position of a profile in the preferred network list
    "Automatic"																|
    "Manual"																|Syntax:
																			|	_Wlan_SetProfilePosition($SSID, $dwPosition[, $pGUID[, $hClientHandle]])
    Possible authentication method values are:								|	$SSID - The name of the profile
    "Open"																	|	$dwPosition - Position in the list (0 based)
    "Shared Key"															|----------------------------------------------------------------------------
    "WPA"																	|:::::::::::::::::::::::::::::::QueryInterface:::::::::::::::::::::::::::::::
    "WPA-PSK"																|Function:
    "WPA2"																	|	Queries various parameters of a given interface
    "WPA2-PSK"																|
																			|Syntax:
    Possible encryption method values are:									|	_Wlan_QueryInterface($dwFlag[, $pGUID[, $hClientHandle]])
    "Unecrypted"															|	$dwFlag - Specifies the parameter to query
    "WEP"																	|
    "TKIP"																	|	$dwFlag values are:
    "AES"																	|	0 - auto config state
																			|		determines if Windows has control of network connections
	Possible 802.1x status values are:										|	1 - bss config
	"802.1x Enabled"														|		determines the type of network an interface can connect to
	"802.1x Disabled"														|	2 - connection status
																			|		determines the connection status of an interface
    Possible key type values are:											|	3 - connection information
    "No Key Material"														|		returns information about a current connection
	"Network Key" - Key material value is in hex							|
    "Pass Phrase" - Key material value is a string							|Return Values:
																			|	If $dwFlag = 0 the function returns a string
    Possible key index values are:											|	"Auto Config Enabled"
    "No Key Index"															|	"Auto Config Disabled"
	1 to 4 - specifies which key index is used to encrypt traffic			|
----------------------------------------------------------------------------|	If $dwFlag = 1 the function returns a string
::::::::::::::::::::::::::::::::SetInterface::::::::::::::::::::::::::::::::|	"Infrastructure Only"
Function:																	|	"Ad Hoc Only"
    Sets various parameters of a given interface							|	"Any Available Network"
																			|
Syntax:																		|	If $dwFlag = 2 the function returns a string
	_Wlan_SetInterface($dwFlag, $strData[, $pGUID[, $hClientHandle]])		|	"Connected"
    $dwFlag - Specifies the parameter to configure							|	"Disconnected"
																			|	"Authenticating"
	$dwFlag values are:														|
	0 - auto config state													|	If $dwFlag = 3 the function returns a array
		configures whether or not Windows has control of network connections|	$ConnectionAttributes[0] - Connection status
	1 - bss config															|	$ConnectionAttributes[1] - SSID
		configures the type of network an interface can connect to			|	$ConnectionAttributes[2] - Host MAC address
																			|	$ConnectionAttributes[3] - Signal strength
	If $dwFlag = 0 $strData values are:										|	$ConnectionAttributes[4] - Security status
	"Auto Config Enabled"													|	$ConnectionAttributes[5] - 802.1x status
	"Auto Config Disabled"													|	$ConnectionAttributes[6] - Authentication method
																			|	$ConnectionAttributes[7] - Encryption method
	If $dwFlag = 1 $strData values are:										|
	"Infrastructure Only"													|	Possible connection status values are:
	"Ad Hoc Only"															|	"Connected"
	"Any Available Network"													|	"Disconnected"
----------------------------------------------------------------------------|	"Authenticating"
::::::::::::::::::::::::::::::::StringTopGuid:::::::::::::::::::::::::::::::|
Function:																	|	Possible signal strength values are:
    Returns a pointer to a struct from a string representation of a GUID	|	0 to 100 (scale is linear)
																			|	0 = -100dbm or less
Syntax:																		|	100 = -50dbm or more
   _Wlan_StringTopGuid($strGUID)											|
    $strGUID - String representation of a GUID								|	Possible security status values are:
																			|	"Security Enabled"
Return Value:																|	"Security Disabled"
	Returns a pointer to a GUID struct ($pGUID)								|
----------------------------------------------------------------------------|	Possible 802.1x status values are:
::::::::::::::::::::::::::::::::pGuidToString:::::::::::::::::::::::::::::::|	"802.1x Enabled"
Function:																	|	"802.1x Disabled"
    Returns a string representation of a GUID from a GUID struct			|
																			|	Possible authentication method values are:
Syntax:																		|	"Open"
    _Wlan_pGuidToString($pGUID)												|	"Shared Key"
																			|	"WPA"
Return Value:																|	"WPA-PSK"
	Returns a string representation of a GUID								|	"WPA2"
----------------------------------------------------------------------------|	"WPA2-PSK"
																			|
																			|	Possible encryption method values are:
																			|	"None"
																			|	"WEP"
																			|	"WEP-64"
																			|	"WEP-128"
																			|	"TKIP"
																			|	"AES"
---------------------------------------------------------------------------------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
---------------------------------------------------------------------------------------------------------------------------------------------------------
#ce

#include-once

Global	$a_iCall, $ErrorMessage, $WLANAPIDLL = DllOpen("wlanapi.dll"), $GLOBAL_hClientHandle, $GLOBAL_pGUID, $PTR_INFOLIST = 0, _ 
		$CallbackDisconnectCount = 0, $CallbackConnectCount = 0, $CallbackSSID

Global _ ;Enumerations
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

Global _ ;Struct Strings
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

Func _Wlan_OpenHandle()
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanOpenHandle", "dword", 1, "ptr", 0, "dword*", 0, "hwnd*", 0)
    
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] == 0 Then
			Return $a_iCall[4]
		Else
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf
	EndIf
EndFunc

Func _Wlan_CloseHandle($hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanCloseHandle", "ptr", $hClientHandle, "ptr", 0)
	
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf
	EndIf
EndFunc

Func _Wlan_EnumInterfaces($hClientHandle = $GLOBAL_hClientHandle)
    Local $pInfoList, $INFO_LIST, $NumberOfItems, $StructString, $index
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	
	If $PTR_INFOLIST <> 0 Then _Wlan_FreeMemory($PTR_INFOLIST)
	
    $a_iCall = DllCall($WLANAPIDLL, "dword", "WlanEnumInterfaces", "hwnd", $hClientHandle , "ptr", 0, "ptr*", 0)
    
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		Else
			$pInfoList = $a_iCall[3]
			$PTR_INFOLIST = $a_iCall[3]
			$INFO_LIST = DllStructCreate($WLAN_INTERFACE_INFO_LIST, $pInfoList)
			$NumberOfItems = DllStructGetData($INFO_LIST, "dwNumberOfItems")
			
			If $NumberOfItems = 0 Then
				SetError(2)
				Return 0
			Else
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
			EndIf
		EndIf
	EndIf
EndFunc

Func _Wlan_Scan($pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanScan", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", 0, "ptr", 0, "ptr", 0)
		
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf
	EndIf
EndFunc

Func _Wlan_GetAvailableNetworkList($dwFlag = 0, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
    Local $NETWORK_LIST, $index, $pAvailableNetworkList, $NumberOfItems, $StructString, $ArrayDuplicateCount = 0, $ArrayTransferCount = 0
    If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	If $dwFlag == -1 Or $dwFlag == Default Then $dwFlag = 0
	
    $a_iCall = DllCall($WLANAPIDLL, "dword", "WlanGetAvailableNetworkList", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $dwFlag, "ptr", 0, "ptr*", 0)
    
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		Else    
			$pAvailableNetworkList = $a_iCall[5]
			
			$NETWORK_LIST = DllStructCreate($WLAN_AVAILABLE_NETWORK_LIST, $pAvailableNetworkList)
			$NumberOfItems = DllStructGetData($NETWORK_LIST, "dwNumberOfItems")
			
			If $NumberOfItems = 0 Then
				SetError(2)
				Return 0
			Else
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
					
					_Wlan_FreeMemory($pAvailableNetworkList)
					
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
					If $AvailableNetworkArray[$i][0] <> "@" then 
						For $j = 0 To 7
							$AvailableNetworkArrayDuplicate[$ArrayTransferCount][$j] = $AvailableNetworkArray[$i][$j]
						Next
						$ArrayTransferCount += 1
					EndIf
				Next
				
				$AvailableNetworkArray = $AvailableNetworkArrayDuplicate
				Return $AvailableNetworkArray
			EndIf
        EndIf
    EndIf
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
	
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf
	EndIf
EndFunc

Func _Wlan_Disconnect($pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanDisconnect", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", 0)
	
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf
	EndIf
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
	If @error <> 0 Then
		_Wlan_RegisterNotification($hClientHandle, 0)
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			_Wlan_RegisterNotification($hClientHandle, 0)
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf
		
		While 1
			Select
				Case TimerDiff($Timer) > 1000 * $Timeout
					$Timeout = "Timeout"
					ExitLoop
				Case $CallbackConnectCount = 3
					ExitLoop
			EndSelect
			Sleep(500)
		WEnd

	_Wlan_RegisterNotification($hClientHandle, 0)
	
	If $Timeout = "Timeout" Then SetError(5)
	Return $CallbackSSID
	EndIf
EndFunc

Func _Wlan_DisconnectWait($Timeout = 5, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $strProfile, $ConnectionParameters, $Timer
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	If $Timeout == -1 Or $Timeout == Default Then $Timeout = 5

	$CallbackDisconnectCount = 0
	
	_Wlan_RegisterNotification($hClientHandle, 1)
	
	$Timer = TimerInit()

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanDisconnect", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", 0)
	
	If @error <> 0 Then
		_Wlan_RegisterNotification($hClientHandle, 0)
		SetError(4)
		Return 0
	Else
		
		If $a_iCall[0] <> 0 Then
			_Wlan_RegisterNotification($hClientHandle, 0)
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf

		While 1
			Select
				Case TimerDiff($Timer) > 1000 * $Timeout
					$Timeout = "Timeout"
					ExitLoop
				Case $CallbackDisconnectCount = 1
					ExitLoop
			EndSelect
			Sleep(500)
		WEnd
	
	_Wlan_RegisterNotification($hClientHandle, 0)
	
	If $Timeout = "Timeout" Then SetError(5)
	EndIf
EndFunc

Func _Wlan_GetProfileList($pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $pProfileList, $PROFILE_LIST, $NumberOfItems, $StructString, $index
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanGetProfileList", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", 0, "ptr*", 0)
	
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else	
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		Else	
			$pProfileList = $a_iCall[4]
			$PROFILE_LIST = DllStructCreate($WLAN_PROFILE_INFO_LIST, $pProfileList)
			$NumberOfItems = DllStructGetData($PROFILE_LIST, "dwNumberOfItems")
			
			If $NumberOfItems = 0 Then
				SetError(2)
				Return 0
			Else
				$StructString = _Wlan_BuildListStructString($WLAN_PROFILE_INFO_LIST, $WLAN_PROFILE_INFO, $NumberOfItems)
				$PROFILE_LIST = DllStructCreate($StructString, $pProfileList)
				
				Dim $ProfileArray[$NumberOfItems]
				
				For $i = 0 To $NumberOfItems - 1
					$ProfileArray[$i] = DllStructGetData($PROFILE_LIST, "strProfileName" & $index)
					$index += 1
				Next
				
				_Wlan_FreeMemory($pProfileList)
				
				Return $ProfileArray
			EndIf
		EndIf
	EndIf
EndFunc

Func _Wlan_SetProfileList($aProfileNames, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $StructString = "ptr", $NumberOfItems = UBound($aProfileNames)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	
	If $NumberOfItems = 0 Then
		SetError(2)
		Return(0)
	EndIf
	
	For $i = 1 To $NumberOfItems - 1
		$StructString = $StructString & ";ptr"
	Next
	For $i = 0 To $NumberOfItems - 1
		$StructString = $StructString & ";wchar[32]"
	Next
	
	$PROFILE_STRUCT = DllStructCreate($StructString)
	
	For $i = 0 To $NumberOfItems - 1
		DllStructSetData($PROFILE_STRUCT, $i + 1, DllStructGetPtr($PROFILE_STRUCT) + ($NumberOfItems * 4) + ($i * 64))
		DllStructSetData($PROFILE_STRUCT, $NumberOfItems + $i + 1, $aProfileNames[$i])
	Next
		
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfileList", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $NumberOfItems, "ptr", DllStructGetPtr($PROFILE_STRUCT), "ptr", 0)
	
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf
	EndIf
EndFunc

Func _Wlan_GetProfile($SSID, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $ProfileAttributes, $ProfileAttributes2, $SREString = "("
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanGetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $SSID,"ptr", 0, "wstr*", 0, "ptr*", 0, "ptr*", 0)
	
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		Else
			$ProfileAttributes = StringSplit("<name>|<connectionType>|<connectionMode>|<authentication>|<encryption>|<useOneX>|<keyType>|<keyMaterial>|<keyIndex>", "|")
			For $i = 1 To UBound($ProfileAttributes) - 1
				If StringRegExp($a_iCall[5], $ProfileAttributes[$i]) == 1 Then $SREString = $SREString & $ProfileAttributes[$i] & "[^<]{0,256})[^@]{0,256}("
			Next
			$SREString = $SREString & ")"
			
			$ProfileAttributes2 = StringRegExp($a_iCall[5], $SREString, 1)
			Dim $Profile[9]
			For $i = 1 To Ubound($ProfileAttributes) - 1
				For $j = 0 To Ubound($ProfileAttributes2) - 2
					If StringRegExp($ProfileAttributes2[$j], $ProfileAttributes[$i]) == 1 Then _
					$Profile[$i - 1] = StringRegExpReplace($ProfileAttributes2[$j], $ProfileAttributes[$i], "")
				Next
				If String($Profile[$i - 1]) == "ESS"		Then $Profile[$i - 1] = "Infrastructure"
				If String($Profile[$i - 1]) == "IBSS"		Then $Profile[$i - 1] = "Ad Hoc"
				If String($Profile[$i - 1]) == "auto"		Then $Profile[$i - 1] = "Automatic"
				If String($Profile[$i - 1]) == "manual"		Then $Profile[$i - 1] = "Manual"
				If String($Profile[$i - 1]) == "open"		Then $Profile[$i - 1] = "Open"
				If String($Profile[$i - 1]) == "shared"		Then $Profile[$i - 1] = "Shared Key"
				If String($Profile[$i - 1]) == "WPAPSK"		Then $Profile[$i - 1] = "WPA-PSK"
				If String($Profile[$i - 1]) == "WPA2PSK"	Then $Profile[$i - 1] = "WPA2-PSK"
				If String($Profile[$i - 1]) == "none"		Then $Profile[$i - 1] = "Unencrypted"
				If String($Profile[$i - 1]) == "true"		Then $Profile[$i - 1] = "802.1x Enabled"
				If String($Profile[$i - 1]) == "false"		Then $Profile[$i - 1] = "802.1x Disabled"
				If String($Profile[$i - 1]) == "networkKey"	Then $Profile[$i - 1] = "Network Key"
				If String($Profile[$i - 1]) == "passPhrase"	Then $Profile[$i - 1] = "Pass Phrase"
			Next
			If String($Profile[2]) == "" And String($Profile[1]) <> "" Then $Profile[2] = "Automatic"
			If String($Profile[6]) == "" Then $Profile[6] = "No Key Material"
			If String($Profile[7]) == "" Then $Profile[7] = "No Key Material"
			If String($Profile[8]) <> "" Then $Profile[8] += 1
			If String($Profile[8]) == "" Then $Profile[8] = "No Key Index"
			Return $Profile
		EndIf
	EndIf
EndFunc

Func _Wlan_SetProfile($Profile, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $XMLElements, $XMLProfile = '<?xml version="1.0"?>' & @CRLF, $XMLStack[1] = [-1]
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	
	If Ubound($Profile) <> 9 Then
		SetError(3)
		Return 0
	Else
		$XMLElements = StringSplit("WLANProfile+|name|SSIDConfig+|SSID+|name|-|-|connectionType|connectionMode|MSM+|security+|" & _
		"authEncryption+|authentication|encryption|useOneX|-|sharedKey+|keyType|protected|keyMaterial|-|keyIndex|" & _
		"OneX+|EAPConfig+|EapHostConfig+|EapMethod+|Type|VendorId|VendorType|AuthorId|-|ConfigBlob|-|-|-|-|-|-", "|")
		
		For $i = 1 To UBound($XMLElements) - 1
			If StringInStr($XMLElements[$i], "+") <> 0 Then
				$XMLProfile = $XMLProfile & "<" & StringReplace($XMLElements[$i], "+", "") & ">" & @CRLF
				Redim $XMLStack[Ubound($XMLStack) + 1]
				$XMLStack[Ubound($XMLStack) - 1] = StringReplace($XMLElements[$i], "+", "")
				$XMLStack[0] += 1
			ElseIf $XMLElements[$i] == "-" Then
				$XMLProfile = $XMLProfile & "</" & $XMLStack[Ubound($XMLStack) - 1] & ">" & @CRLF
				Redim $XMLStack[Ubound($XMLStack) - 1]
			Else
				$XMLProfile = $XMLProfile & "<" & $XMLElements[$i] & "></" & $XMLElements[$i] & ">" & @CRLF
			EndIf
			If $i < UBound($XMLElements) - 1 And $XMLElements[$i + 1] == "-" Then $XMLStack[0] -= 1
			For $j = 0 To $XMLStack[0]
				$XMLProfile = $XMLProfile & "	"
			Next
		Next
		
		If $Profile[1] == "Infrastructure"	Then $Profile[1] = "ESS"
		If $Profile[1] == "Ad Hoc"			Then $Profile[1] = "IBSS"
		If $Profile[2] == "Automatic"		Then $Profile[2] = "auto"
		If $Profile[2] == "Manual"			Then $Profile[2] = "manual"
		If $Profile[3] == "Open"			Then $Profile[3] = "open"
		If $Profile[3] == "Shared Key"		Then $Profile[3] = "shared"
		If $Profile[3] == "WPA-PSK"			Then $Profile[3] = "WPAPSK"
		If $Profile[3] == "WPA2-PSK"		Then $Profile[3] = "WPA2PSK"
		If $Profile[4] == "Unencrypted"		Then $Profile[4] = "none"
		If $Profile[6] == "Network Key"		Then $Profile[6] = "networkKey"
		If $Profile[6] == "Pass Phrase"		Then $Profile[6] = "passPhrase"
		If $Profile[6] == "No Key Material" Then $Profile[6] = ""
		If $Profile[7] == "No Key Material" Then $Profile[7] = ""
		If $Profile[8] <> "No Key Index"	Then $Profile[8] -= 1
		If $Profile[8] == "No Key Index"	Then $Profile[8] = ""

		If $Profile[5] == "802.1x Enabled" Then
			$Profile[5] = "true"
			$XMLProfile = StringRegExpReplace($XMLProfile, "[[:space:]]{0,8}<sharedKey>[^@]{0,200}</keyIndex>", "")
		ElseIf $Profile[5] == "802.1x Disabled" Then 
			$Profile[5] = "false"
			$XMLProfile = StringRegExpReplace($XMLProfile, "[[:space:]]{0,8}<OneX>[^@]{0,300}</OneX>", "")
		EndIf
		
		If StringIsInt($Profile[8]) == 0 Then $XMLProfile = StringRegExpReplace($XMLProfile, "[[:space:]]{0,8}<keyIndex></keyIndex>", "")
	
		$XMLProfile = StringRegExpReplace($XMLProfile, '<WLANProfile>', '<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">')
		$XMLProfile = StringRegExpReplace($XMLProfile, "<name>", "<name>" & $Profile[0])
		$XMLProfile = StringRegExpReplace($XMLProfile, "<connectionType>", "\0" & $Profile[1])
		$XMLProfile = StringRegExpReplace($XMLProfile, "<connectionMode>", "\0" & $Profile[2])
		$XMLProfile = StringRegExpReplace($XMLProfile, "<authentication>", "\0" & $Profile[3])
		$XMLProfile = StringRegExpReplace($XMLProfile, "<encryption>", "\0" & $Profile[4])
		$XMLProfile = StringRegExpReplace($XMLProfile, "<useOneX>", "\0" & $Profile[5])
		$XMLProfile = StringRegExpReplace($XMLProfile, "<keyType>", "\0" & $Profile[6])
		$XMLProfile = StringRegExpReplace($XMLProfile, "<protected>", "\0false")
		$XMLProfile = StringRegExpReplace($XMLProfile, "<keyMaterial>", "<keyMaterial>" & $Profile[7])
		$XMLProfile = StringRegExpReplace($XMLProfile, "<keyIndex>", "<keyIndex>" & $Profile[8])
		$XMLProfile = StringRegExpReplace($XMLProfile, "<OneX>", '<OneX xmlns="http://www.microsoft.com/networking/OneX/v1">')
		$XMLProfile = StringRegExpReplace($XMLProfile, "<EapHostConfig>", '<EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig">')
		$XMLProfile = StringRegExpReplace($XMLProfile, "<Type>", '<Type xmlns="http://www.microsoft.com/provisioning/EapCommon">13')
		$XMLProfile = StringRegExpReplace($XMLProfile, "<VendorId>", '<VendorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0')
		$XMLProfile = StringRegExpReplace($XMLProfile, "<VendorType>", '<VendorType xmlns="http://www.microsoft.com/provisioning/EapCommon">0')
		$XMLProfile = StringRegExpReplace($XMLProfile, "<AuthorId>", '<AuthorId xmlns="http://www.microsoft.com/provisioning/EapCommon">0')
		$XMLProfile = StringRegExpReplace($XMLProfile, "<ConfigBlob>", "<ConfigBlob>00000000280000000500000000000000000000000000000000000000000000000000000000000000")
		
		$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", 0, "wstr", $XMLProfile, "ptr", 0, "int", 1, "ptr", 0, "dword*", 0)
		
		If @error <> 0 Then
			SetError(4)
			Return 0
		Else		
			If $a_iCall[0] <> 0 Then
				$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
				SetError(1, $a_iCall[0])
				Return $ErrorMessage
			EndIf
		EndIf
	EndIf
EndFunc

Func _Wlan_DeleteProfile($SSID, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)	
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanDeleteProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $SSID, "ptr", 0)
	
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf
	EndIf
EndFunc

Func _Wlan_SetProfilePosition($SSID, $dwPosition, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
    If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfilePosition", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $SSID, "dword", $dwPosition, "ptr", 0)
    
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf
	EndIf
EndFunc

Func _Wlan_QueryInterface($dwFlag, $pGUID = $GLOBAL_pGUID, $hClientHandle = $GLOBAL_hClientHandle)
	Local $pData, $Output, $AutoConfigState, $BssType, $DOT11BSSTYPE, $ConnectionAttributes
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
		
	If $dwFlag == 0 Then 
		$dwFlag = $wlan_intf_opcode_autoconf_enabled
	ElseIf $dwFlag == 1 Then 
		$dwFlag = $wlan_intf_opcode_bss_type
	ElseIf $dwFlag == 2 Then 
		$dwFlag = $wlan_intf_opcode_interface_state
	ElseIf $dwFlag == 3 Then 
		$dwFlag = $wlan_intf_opcode_current_connection
	EndIf
	
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanQueryInterface", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $dwFlag, "ptr", 0, "dword*", 0, "ptr*", 0, "dword*", 0)
	
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		Else		
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
		EndIf
	EndIf
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
	
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf
	EndIf
EndFunc

;----Tools----;

Func _Wlan_StartSession()
	$hClientHandle = _Wlan_OpenHandle()
	If @error <> 0 Then
		SetError(@error, @extended)
		Return $hClientHandle
	EndIf
	
	$InterfaceArray = _Wlan_EnumInterfaces($hClientHandle)
	If @error <> 0 Then
		SetError(@error, @extended)
		_Wlan_CloseHandle($hClientHandle)
		Return $InterfaceArray
	EndIf
	
	_Wlan_SetGlobalConstants($InterfaceArray[0][0], $hClientHandle)

	SetExtended($hClientHandle)
	Return $InterfaceArray
EndFunc

Func _Wlan_EndSession($hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	_Wlan_CloseHandle($hClientHandle)
	SetError(@error, @extended)
	DllClose($WLANAPIDLL)
EndFunc

Func _Wlan_SetGlobalConstants($pGUID, $hClientHandle = "")
	If $hClientHandle <> "" Then Global $GLOBAL_hClientHandle = $hClientHandle
	If $pGUID <> "" Then Global $GLOBAL_pGUID = $pGUID
EndFunc

Func _Wlan_StringTopGuid($strGUID)
	Local $aGUID
	Global $GUIDstruct = DllStructCreate($GUID_STRUCT)
	
	$strGUID = StringRegExpReplace($strGUID, "[}{]", "")
	$aGUID = StringSplit($strGUID, "-")
	
	DllStructSetData($GUIDstruct, "GUIDFIRST", "0x" & $aGUID[1])
	DllStructSetData($GUIDstruct, "GUIDSECOND", "0x" & $aGUID[2])
	DllStructSetData($GUIDstruct, "GUIDTHIRD", "0x" & $aGUID[3])
	DllStructSetData($GUIDstruct, "GUIDFOURTH", "0x" & $aGUID[4] & $aGUID[5])

	Return DllStructGetPtr($GUIDstruct)
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
		$strGUID = $strGUID & $aGUID[$i] & "-"
	Next
	
	$strGUID = $strGUID & $aGUID[4] & "}"
	
	Return $strGUID
EndFunc

;----Function Dependencies---;

Func _Wlan_ReasonCodeToString($ReasonCode)
	Local $BUFFER
	
	$BUFFER = DllStructCreate("wchar BUFFER[512]")
	DllCall($WLANAPIDLL, "dword", "WlanReasonCodeToString", "dword", $ReasonCode, "dword", 512, "ptr", DllStructGetPtr($BUFFER), "ptr", 0)
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		Return(DllStructGetData($BUFFER, "BUFFER"))
	EndIf
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
				
				$StructElements2[$j] = $StructElements2[$j] & $ElementCount[$i] & $Buffer[$j]
			EndIf
		Next
	Next
	
	For $i = 1 To Ubound($StructElements2) -1
		$StructString = $StructString & $StructElements2[$i]
		If $i <> Ubound($StructElements2) -1 Then $StructString = $StructString & ";"
	Next
	
	Return $StructString
	
EndFunc

Func _Wlan_GetErrorMessage($iError)
	Local $tText = DllStructCreate("char Text[4096]")
	DllCall("Kernel32.dll", "int", "FormatMessageA", "int", 0x1000, "hwnd", 0, "int", $iError, "int", 0, "ptr", DllStructGetPtr($tText), "int", 4096, "ptr", 0)
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		Return DllStructGetData($tText, "Text")
	EndIf
EndFunc

Func _Wlan_FreeMemory($ptr)
	DllCall($WLANAPIDLL, "dword", "WlanFreeMemory", "ptr", $ptr)
	If @error <> 0 Then
		SetError(4)
		Return 0
	EndIf
EndFunc

Func _Wlan_RegisterNotification($hClientHandle, $Flag)
	Local $WLAN_NOTIFICATION_CALLBACK
	If $Flag = 1 Then
		$WLAN_NOTIFICATION_CALLBACK = DllCallbackRegister("_WLAN_NOTIFICATION_CALLBACK", "none", "ptr;ptr")
		$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanRegisterNotification", "hwnd", $hClientHandle, "dword", 0X08 , "int", 0, "ptr", DllCallbackGetPtr($WLAN_NOTIFICATION_CALLBACK), "ptr", 0, "ptr", 0, "ptr*", 0)
	Else
		$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanRegisterNotification", "hwnd", $hClientHandle, "dword", 0 , "int", 0, "ptr", 0, "ptr", 0, "ptr", 0, "ptr*", 0)
	EndIf
	
	If @error <> 0 Then
		SetError(4)
		Return 0
	Else
		If $a_iCall[0] <> 0 Then
			$ErrorMessage = _Wlan_GetErrorMessage($a_iCall[0])
			SetError(1, $a_iCall[0])
			Return $ErrorMessage
		EndIf
	EndIf
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
