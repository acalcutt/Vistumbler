#AutoIt3Wrapper_Run_Au3check=y
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

;--------------Enumerations-------------

;DOT11_AUTH_ALGORITHM
Global Enum $DOT11_AUTH_ALGO_80211_OPEN = 1, $DOT11_AUTH_ALGO_80211_SHARED_KEY, $DOT11_AUTH_ALGO_WPA, $DOT11_AUTH_ALGO_WPA_PSK, _
		$DOT11_AUTH_ALGO_WPA_NONE, $DOT11_AUTH_ALGO_RSNA, $DOT11_AUTH_ALGO_RSNA_PSK, $DOT11_AUTH_ALGO_IHV_START = 2147483648, $DOT11_AUTH_ALGO_IHV_END = 4294967295

;DOT11_BSS_TYPE
Global Enum $DOT11_BSS_TYPE_INFRASTRUCTURE = 1, $DOT11_BSS_TYPE_INDEPENDENT, $DOT11_BSS_TYPE_ANY

;DOT11_CIPHER_ALGORITHM
Global Enum $DOT11_CIPHER_ALGO_NONE, $DOT11_CIPHER_ALGO_WEP40, $DOT11_CIPHER_ALGO_TKIP, $DOT11_CIPHER_ALGO_CCMP = 0x04, $DOT11_CIPHER_ALGO_WEP104, _
		$DOT11_CIPHER_ALGO_WPA_USE_GROUP = 0x100, $DOT11_CIPHER_ALGO_RSN_USE_GROUP = 0x100, $DOT11_CIPHER_ALGO_WEP, $DOT11_CIPHER_ALGO_IHV_START = 2147483648, _
		$DOT11_CIPHER_ALGO_IHV_END = 4294967295

;DOT11_PHY_TYPE
Global Enum $DOT11_PHY_TYPE_UNKNOWN, $DOT11_PHY_TYPE_ANY = 0, $DOT11_PHY_TYPE_FHSS, $DOT11_PHY_TYPE_DSSS, $DOT11_PHY_TYPE_IRBASEBAND, $DOT11_PHY_TYPE_OFDM, _
		$DOT11_PHY_TYPE_HRDSSS, $DOT11_PHY_TYPE_ERP, $DOT11_PHY_TYPE_HT, $DOT11_PHY_TYPE_IHV_START = 2147483648, $DOT11_PHY_TYPE_IHV_END = 4294967295

;DOT11_RADIO_STATE
Global Enum $DOT11_RADIO_STATE_UNKNOWN, $DOT11_RADIO_STATE_ON, $DOT11_RADIO_STATE_OFF

;ONEX_AUTH_IDENTITY
Global Enum $OneXAuthIdentityNone, $OneXAuthIdentityMachine, $OneXAuthIdentityUser, $OneXAuthIdentityExplicitUser, $OneXAuthIdentityGuest, _
		$OneXAuthIdentityInvalid

;ONEX_AUTH_RESTART_REASON
Global Enum $OneXRestartReasonPeerInitiated, $OneXRestartReasonMsmInitiated, $OneXRestartReasonOneXHeldStateTimeout, $OneXRestartReasonOneXAuthTimeout, _
		$OneXRestartReasonOneXConfigurationChanged, $OneXRestartReasonOneXUserChanged, $OneXRestartReasonQuarantineStateChanged, $OneXRestartReasonAltCredsTrial, _
		$OneXRestartReasonInvalid

;ONEX_AUTH_STATUS
Global Enum $OneXAuthNotStarted, $OneXAuthInProgress, $OneXAuthNoAuthenticatorFound, $OneXAuthSuccess, $OneXAuthFailure, $OneXAuthInvalid

;ONEX_EAP_METHOD_BACKEND_SUPPORT
Global Enum $OneXEapMethodBackendSupportUnknown, $OneXEapMethodBackendSupported, $OneXEapMethodBackendUnsupported

;ONEX_NOTIFICATION_TYPE
Global Enum $OneXPublicNotificationBase, $OneXNotificationTypeResultUpdate, $OneXNotificationTypeAuthRestarted, $OneXNotificationTypeEventInvalid, _
		$OneXNumNotifications = 3

;ONEX_REASON_CODE
Global Enum $ONEX_REASON_CODE_SUCCESS, $ONEX_REASON_START = 0x5000, $ONEX_UNABLE_TO_IDENTIFY_USER, $ONEX_IDENTITY_NOT_FOUND, $ONEX_UI_DISABLED, _
		$ONEX_UI_FAILURE, $ONEX_EAP_FAILURE_RECEIVED, $ONEX_AUTHENTICATOR_NO_LONGER_PRESENT, $ONEX_NO_RESPONSE_TO_IDENTITY, $ONEX_PROFILE_VERSION_NOT_SUPPORTED, _
		$ONEX_PROFILE_INVALID_LENGTH, $ONEX_PROFILE_DISALLOWED_EAP_TYPE, $ONEX_PROFILE_INVALID_EAP_TYPE_OR_FLAG, $ONEX_PROFILE_INVALID_ONEX_FLAGS, _
		$ONEX_PROFILE_INVALID_TIMER_VALUE, $ONEX_PROFILE_INVALID_SUPPLICANT_MODE, $ONEX_PROFILE_INVALID_AUTH_MODE, $ONEX_PROFILE_INVALID_EAP_CONNECTION_PROPERTIES, _
		$ONEX_UI_CANCELLED, $ONEX_PROFILE_INVALID_EXPLICIT_CREDENTIALS, $ONEX_PROFILE_EXPIRED_EXPLICIT_CREDENTIALS, $ONEX_UI_NOT_PERMITTED

;WL_DISPLAY_PAGES
Global Enum $WLConnectionPage, $WLSecurityPage, $WLAdvPage

;WLAN_ADHOC_NETWORK_STATE
Global Enum $WLAN_ADHOC_NETWORK_STATE_FORMED, $WLAN_ADHOC_NETWORK_STATE_CONNECTED

;WLAN_AUTOCONF_OPCODE
Global Enum $WLAN_AUTOCONF_OPCODE_START, $WLAN_AUTOCONF_OPCODE_SHOW_DENIED_NETWORKS, $WLAN_AUTOCONF_OPCODE_POWER_SETTING, _
		$WLAN_AUTOCONF_OPCODE_ONLY_USE_GP_PROFILES_FOR_ALLOWED_NETWORKS, $WLAN_AUTOCONF_OPCODE_ALLOW_EXPLICIT_CREDS, $WLAN_AUTOCONF_OPCODE_BLOCK_PERIOD, _
		$WLAN_AUTOCONF_OPCODE_ALLOW_VIRTUAL_STATION_EXTENSIBILITY, $WLAN_AUTOCONF_OPCODE_END

;WLAN_CONNECTION_MODE
Global Enum $WLAN_CONNECTION_MODE_PROFILE, $WLAN_CONNECTION_MODE_TEMPORARY_PROFILE, $WLAN_CONNECTION_MODE_DISCOVERY_SECURE, _
		$WLAN_CONNECTION_MODE_DISCOVERY_UNSECURE, $WLAN_CONNECTION_MODE_AUTO, $WLAN_CONNECTION_MODE_INVALID

;WLAN_FILTER_LIST_TYPE
Global Enum $WLAN_FILTER_LIST_TYPE_GP_PERMIT, $WLAN_FILTER_LIST_TYPE_GP_DENY, $WLAN_FILTER_LIST_TYPE_USER_PERMIT, $WLAN_FILTER_LIST_TYPE_USER_DENY

;WLAN_HOSTED_NETWORK_NOTIFICATION_CODE
Global Enum $WLAN_HOSTED_NETWORK_STATE_CHANGE = 0X00001000, $WLAN_HOSTED_NETWORK_PEER_STATE_CHANGE, $WLAN_HOSTED_NETWORK_RADIO_STATE_CHANGE

;WLAN_HOSTED_NETWORK_OPCODE
Global Enum $WLAN_HOSTED_NETWORK_OPCODE_CONNECTION_SETTINGS, $WLAN_HOSTED_NETWORK_OPCODE_SECURITY_SETTINGS, $WLAN_HOSTED_NETWORK_OPCODE_STATION_PROFILE, _
		$WLAN_HOSTED_NETWORK_OPCODE_ENABLE

;WLAN_HOSTED_NETWORK_PEER_AUTH_STATE
Global Enum $WLAN_HOSTED_NETWORK_PEER_STATE_INVALID, $WLAN_HOSTED_NETWORK_PEER_STATE_AUTHENTICATED

;WLAN_HOSTED_NETWORK_REASON
Global Enum $WLAN_HOSTED_NETWORK_REASON_SUCCESS, $WLAN_HOSTED_NETWORK_REASON_UNSPECIFIED, $WLAN_HOSTED_NETWORK_REASON_BAD_PARAMETERS, _
		$WLAN_HOSTED_NETWORK_REASON_SERVICE_SHUTTING_DOWN, $WLAN_HOSTED_NETWORK_REASON_INSUFFICIENT_RESOURCES, $WLAN_HOSTED_NETWORK_REASON_ELEVATION_REQUIRED, _
		$WLAN_HOSTED_NETWORK_REASON_READ_ONLY, $WLAN_HOSTED_NETWORK_REASON_PERSISTENCE_FAILED, $WLAN_HOSTED_NETWORK_REASON_CRYPT_ERROR, _
		$WLAN_HOSTED_NETWORK_REASON_IMPERSONATION, $WLAN_HOSTED_NETWORK_REASON_STOP_BEFORE_START, $WLAN_HOSTED_NETWORK_REASON_INTERFACE_AVAILABLE, _
		$WLAN_HOSTED_NETWORK_REASON_INTERFACE_UNAVAILABLE, $WLAN_HOSTED_NETWORK_REASON_MINIPORT_STOPPED, $WLAN_HOSTED_NETWORK_REASON_MINIPORT_STARTED, _
		$WLAN_HOSTED_NETWORK_REASON_INCOMPATIBLE_CONNECTION_STARTED, $WLAN_HOSTED_NETWORK_REASON_INCOMPATIBLE_CONNECTION_STOPPED, _
		$WLAN_HOSTED_NETWORK_REASON_USER_ACTION, $WLAN_HOSTED_NETWORK_REASON_CLIENT_ABORT, $WLAN_HOSTED_NETWORK_REASON_AP_START_FAILED, _
		$WLAN_HOSTED_NETWORK_REASON_PEER_ARRIVED, $WLAN_HOSTED_NETWORK_REASON_PEER_DEPARTED, $WLAN_HOSTED_NETWORK_REASON_PEER_TIMEOUT, _
		$WLAN_HOSTED_NETWORK_REASON_GP_DENIED, $WLAN_HOSTED_NETWORK_REASON_SERVICE_UNAVAILABLE, $WLAN_HOSTED_NETWORK_REASON_DEVICE_CHANGE, _
		$WLAN_HOSTED_NETWORK_REASON_PROPERTIES_CHANGE, $WLAN_HOSTED_NETWORK_REASON_VIRTUAL_STATION_BLOCKING_USE, _
		$WLAN_HOSTED_NETWORK_REASON_SERVICE_AVAILABLE_ON_VIRTUAL_STATION

;WLAN_HOSTED_NETWORK_STATE
Global Enum $WLAN_HOSTED_NETWORK_UNAVAILABLE, $WLAN_HOSTED_NETWORK_IDLE, $WLAN_HOSTED_NETWORK_ACTIVE

;WLAN_IHV_CONTROL_TYPE
Global Enum $WLAN_IHV_CONTROL_TYPE_SERVICE, $WLAN_IHV_CONTROL_TYPE_DRIVER

;WLAN_INTERFACE_STATE
Global Enum $WLAN_INTERFACE_STATE_NOT_READY, $WLAN_INTERFACE_STATE_CONNECTED, $WLAN_INTERFACE_STATE_AD_HOC_NETWORK_FORMED, _
		$WLAN_INTERFACE_STATE_DISCONNECTING, $WLAN_INTERFACE_STATE_DISCONNECTED, $WLAN_INTERFACE_STATE_ASSOCIATING, $WLAN_INTERFACE_STATE_DISCOVERING, _
		$WLAN_INTERFACE_STATE_AUTHENTICATING

;WLAN_INTERFACE_TYPE
Global Enum $WLAN_INTERFACE_TYPE_EMULATED_802_11, $WLAN_INTERFACE_TYPE_NATIVE_802_11, $WLAN_INTERFACE_TYPE_INVALID

;WLAN_INTF_OPCODE
Global Enum $WLAN_INTF_OPCODE_AUTOCONF_START, $WLAN_INTF_OPCODE_AUTOCONF_ENABLED, $WLAN_INTF_OPCODE_BACKGROUND_SCAN_ENABLED, _
		$WLAN_INTF_OPCODE_MEDIA_STREAMING_MODE, $WLAN_INTF_OPCODE_RADIO_STATE, $WLAN_INTF_OPCODE_BSS_TYPE, $WLAN_INTF_OPCODE_INTERFACE_STATE, _
		$WLAN_INTF_OPCODE_CURRENT_CONNECTION, $WLAN_INTF_OPCODE_CHANNEL_NUMBER, $WLAN_INTF_OPCODE_SUPPORTED_INFRASTRUCTURE_AUTH_CIPER_PAIRS, _
		$WLAN_INTF_OPCODE_SUPPORTED_ADHOC_AUTH_CIPER_PAIRS, $WLAN_INTF_OPCODE_SUPPORTED_COUNTRY_OR_REGION_STRING_LIST, $WLAN_INTF_OPCODE_CURRENT_OPERATION_MODE, _
		$WLAN_INTF_OPCODE_SUPPORTED_SAFE_MODE, $WLAN_INTF_OPCODE_CERTIFIED_SAFE_MODE, $WLAN_INTF_OPCODE_HOSTED_NETWORK_CAPABLE, _
		$WLAN_INTF_OPCODE_AUTOCONF_END = 0x0FFFFFFF, $WLAN_INTF_OPCODE_MSM_START = 0x10000100, $WLAN_INTF_OPCODE_STATISTICS, $WLAN_INTF_OPCODE_RSSI, _
		$WLAN_INTF_OPCODE_MSM_END = 0x1FFFFFFF, $WLAN_INTF_OPCODE_SECURITY_START = 0x20010000, $WLAN_INTF_OPCODE_SECURITY_END = 0x2FFFFFFF, _
		$WLAN_INTF_OPCODE_IHV_START = 0x30000000, $WLAN_INTF_OPCODE_IHV_END = 0x3FFFFFFF

;WLAN_NOTIFICATION_ACM
Global Enum $WLAN_NOTIFICATION_ACM_START, $WLAN_NOTIFICATION_ACM_AUTOCONF_ENABLED, $WLAN_NOTIFICATION_ACM_AUTOCONF_DISABLED, _
		$WLAN_NOTIFICATION_ACM_BACKGROUND_SCAN_ENABLED, $WLAN_NOTIFICATION_ACM_BACKGROUND_SCAN_DISABLED, $WLAN_NOTIFICATION_ACM_BSS_TYPE_CHANGE, _
		$WLAN_NOTIFICATION_ACM_POWER_SETTING_CHANGE, $WLAN_NOTIFICATION_ACM_SCAN_COMPLETE, $WLAN_NOTIFICATION_ACM_SCAN_FAIL, _
		$WLAN_NOTIFICATION_ACM_CONNECTION_START, $WLAN_NOTIFICATION_ACM_CONNECTION_COMPLETE, $WLAN_NOTIFICATION_ACM_CONNECTION_ATTEMPT_FAIL, _
		$WLAN_NOTIFICATION_ACM_FILTER_LIST_CHANGE, $WLAN_NOTIFICATION_ACM_INTERFACE_ARRIVAL, $WLAN_NOTIFICATION_ACM_INTERFACE_REMOVAL, _
		$WLAN_NOTIFICATION_ACM_PROFILE_CHANGE, $WLAN_NOTIFICATION_ACM_PROFILE_NAME_CHANGE, $WLAN_NOTIFICATION_ACM_PROFILES_EXHAUSTED, _
		$WLAN_NOTIFICATION_ACM_NETWORK_NOT_AVAILABLE, $WLAN_NOTIFICATION_ACM_NETWORK_AVAILABLE, $WLAN_NOTIFICATION_ACM_DISCONNECTING, _
		$WLAN_NOTIFICATION_ACM_DISCONNECTED, $WLAN_NOTIFICATION_ACM_ADHOC_NETWORK_STATE_CHANGE, $WLAN_NOTIFICATION_ACM_END

;WLAN_NOTIFICATION_MSM
Global Enum $WLAN_NOTIFICATION_MSM_START, $WLAN_NOTIFICATION_MSM_ASSOCIATING, $WLAN_NOTIFICATION_MSM_ASSOCIATED, $WLAN_NOTIFICATION_MSM_AUTHENTICATING, _
		$WLAN_NOTIFICATION_MSM_CONNECTED, $WLAN_NOTIFICATION_MSM_ROAMING_START, $WLAN_NOTIFICATION_MSM_ROAMING_END, $WLAN_NOTIFICATION_MSM_RADIO_STATE_CHANGE, _
		$WLAN_NOTIFICATION_MSM_SIGNAL_QUALITY_CHANGE, $WLAN_NOTIFICATION_MSM_DISASSOCIATING, $WLAN_NOTIFICATION_MSM_DISCONNECTED, $WLAN_NOTIFICATION_MSM_PEER_JOIN, _
		$WLAN_NOTIFICATION_MSM_PEER_LEAVE, $WLAN_NOTIFICATION_MSM_ADAPTER_REMOVAL, $WLAN_NOTIFICATION_MSM_ADAPTER_OPERATION_MODE_CHANGE, $WLAN_NOTIFICATION_MSM_END

;WLAN_OPCODE_VALUE_TYPE
Global Enum $WLAN_OPCODE_VALUE_TYPE_QUERY_ONLY, $WLAN_OPCODE_VALUE_TYPE_SET_BY_GROUP_POLICY, $WLAN_OPCODE_VALUE_TYPE_SET_BY_USER, _
		$WLAN_OPCODE_VALUE_TYPE_INVALID

;WLAN_POWER_SETTING
Global Enum $WLAN_POWER_SETTING_NO_SAVING, $WLAN_POWER_SETTING_LOW_SAVING, $WLAN_POWER_SETTING_MEDIUM_SAVING, $WLAN_POWER_SETTING_MAXIMUM_SAVING, _
		$WLAN_POWER_SETTING_INVALID

;WLAN_SECURABLE_OBJECT
Global Enum $WLAN_SECURE_PERMIT_LIST, $WLAN_SECURE_DENY_LIST, $WLAN_SECURE_AC_ENABLED, $WLAN_SECURE_BC_SCAN_ENABLED, $WLAN_SECURE_BSS_TYPE, _
		$WLAN_SECURE_SHOW_DENIED, $WLAN_SECURE_INTERFACE_PROPERTIES, $WLAN_SECURE_IHV_CONTROL, $WLAN_SECURE_ALL_USER_PROFILES_ORDER, _
		$WLAN_SECURE_ADD_NEW_ALL_USER_PROFILES, $WLAN_SECURE_ADD_NEW_PER_USER_PROFILES, $WLAN_SECURE_MEDIA_STREAMING_MODE_ENABLED, _
		$WLAN_SECURE_CURRENT_OPERATION_MODE, $WLAN_SECURE_GET_PLAINTEXT_KEY, $WLAN_SECURE_HOSTED_NETWORK_ELEVATED_ACCESS

;--------------Flags-------------
;profile flags
Global Const $WLAN_PROFILE_GROUP_POLICY = 1, $WLAN_PROFILE_USER = 2, $WLAN_PROFILE_GET_PLAINTEXT_KEY = 4 , $WLAN_PROFILE_CONNECTION_MODE_SET_BY_CLIENT = 0x00010000, _
		$WLAN_PROFILE_CONNECTION_MODE_AUTO = 0x00020000

;EAPHost data storage flags
Global Const $WLAN_SET_EAPHOST_DATA_ALL_USERS = 1

;available network flags
Global Const $WLAN_AVAILABLE_NETWORK_CONNECTED = 1, $WLAN_AVAILABLE_NETWORK_HAS_PROFILE = 2, $WLAN_AVAILABLE_NETWORK_CONSOLE_USER_PROFILE = 4

;flags that control the list returned by WlanGetAvailableNetworkList
Global Const $WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES = 1, $WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_MANUAL_HIDDEN_PROFILES = 2

;Wlan connection flags used in WLAN_CONNECTION_PARAMETERS
Global Const $WLAN_CONNECTION_HIDDEN_NETWORK = 1, $WLAN_CONNECTION_ADHOC_JOIN_ONLY = 2, $WLAN_CONNECTION_IGNORE_PRIVACY_BIT = 4, $WLAN_CONNECTION_EAPOL_PASSTHROUGH = 8

;flags for connection notifications
Global Const $WLAN_CONNECTION_NOTIFICATION_ADHOC_NETWORK_FORMED = 1, $WLAN_CONNECTION_NOTIFICATION_CONSOLE_USER_PROFILE = 4

;--------------Other-------------
;types of notification
Global Const $WLAN_NOTIFICATION_SOURCE_NONE = 0, $WLAN_NOTIFICATION_SOURCE_ALL = 0XFFFF, $WLAN_NOTIFICATION_SOURCE_ACM = 0x08, $WLAN_NOTIFICATION_SOURCE_MSM = 0X10, _
		$WLAN_NOTIFICATION_SOURCE_SECURITY = 0X20, $WLAN_NOTIFICATION_SOURCE_IHV = 0X40, $WLAN_NOTIFICATION_SOURCE_HNWK = 0X80, $WLAN_NOTIFICATION_SOURCE_ONEX = 0X04

;access masks
Global Const $WLAN_READ_ACCESS = 0x00020001, $WLAN_EXECUTE_ACCESS = 0x00020021, $WLAN_WRITE_ACCESS = 0x00070023

;dot11 Operation modes
Global Const $DOT11_OPERATION_MODE_UNKNOWN = 0, $DOT11_OPERATION_MODE_STATION = 1, $DOT11_OPERATION_MODE_AP = 2, $DOT11_OPERATION_MODE_EXTENSIBLE_STATION = 4, _
		$DOT11_OPERATION_MODE_EXTENSIBLE_AP = 8, $DOT11_OPERATION_MODE_NETWORK_MONITOR = 2147483648

;for the UI related functions
Global Const $WLAN_UI_API_VERSION = 1, $WLAN_UI_API_INITIAL_VERSION = 1

Func _Wlan_EnumToString($sCategory, $iEnumeration)
	Switch $sCategory
		Case "DOT11_AUTH_ALGORITHM"
			Switch $iEnumeration
				Case $DOT11_AUTH_ALGO_80211_OPEN
					Return "Open"
				Case $DOT11_AUTH_ALGO_80211_SHARED_KEY
					Return "Shared Key"
				Case $DOT11_AUTH_ALGO_WPA
					Return "WPA"
				Case $DOT11_AUTH_ALGO_WPA_PSK
					Return "WPA-PSK"
				Case $DOT11_AUTH_ALGO_WPA_NONE
					Return "WPA-None"
				Case $DOT11_AUTH_ALGO_RSNA
					Return "WPA2"
				Case $DOT11_AUTH_ALGO_RSNA_PSK
					Return "WPA2-PSK"
				Case $DOT11_AUTH_ALGO_IHV_START To $DOT11_AUTH_ALGO_IHV_END
					Return "IHV Auth (0x" & Hex($iEnumeration) & ")"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "DOT11_BSS_TYPE"
			Switch $iEnumeration
				Case $DOT11_BSS_TYPE_INFRASTRUCTURE
					Return "Infrastructure"
				Case $DOT11_BSS_TYPE_INDEPENDENT
					Return "Ad Hoc"
				Case $DOT11_BSS_TYPE_ANY
					Return "Any BSS Type"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "DOT11_CIPHER_ALGORITHM"
			Switch $iEnumeration
				Case $DOT11_CIPHER_ALGO_NONE
					Return "Unencrypted"
				Case $DOT11_CIPHER_ALGO_WEP40
					Return "WEP-40"
				Case $DOT11_CIPHER_ALGO_TKIP
					Return "TKIP"
				Case $DOT11_CIPHER_ALGO_CCMP
					Return "AES"
				Case $DOT11_CIPHER_ALGO_WEP104
					Return "WEP-104"
				Case $DOT11_CIPHER_ALGO_WPA_USE_GROUP
					Return "WPA Use Group"
				Case $DOT11_CIPHER_ALGO_RSN_USE_GROUP
					Return "WPA2 Use Group"
				Case $DOT11_CIPHER_ALGO_WEP
					Return "WEP"
				Case $DOT11_CIPHER_ALGO_IHV_START To $DOT11_CIPHER_ALGO_IHV_END
					Return "IHV Cipher (0x" & Hex($iEnumeration) & ")"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "DOT11_PHY_TYPE"
			Switch $iEnumeration
				Case $DOT11_PHY_TYPE_UNKNOWN
					Return "Unknown/Any Phy Type"
				Case $DOT11_PHY_TYPE_FHSS
					Return "Bluetooth"
				Case $DOT11_PHY_TYPE_DSSS
					Return "b*"
				Case $DOT11_PHY_TYPE_IRBASEBAND
					Return "legacy"
				Case $DOT11_PHY_TYPE_OFDM
					Return "a"
				Case $DOT11_PHY_TYPE_HRDSSS
					Return "b"
				Case $DOT11_PHY_TYPE_ERP
					Return "g"
				Case $DOT11_PHY_TYPE_HT
					Return "n"
				Case $DOT11_PHY_TYPE_IHV_START To $DOT11_PHY_TYPE_IHV_END
					Return "IHV Phy Type (0x" & Hex($iEnumeration) & ")"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "DOT11_RADIO_STATE"
			Switch $iEnumeration
				Case $DOT11_RADIO_STATE_UNKNOWN
					Return "Unknown"
				Case $DOT11_RADIO_STATE_ON
					Return "On"
				Case $DOT11_RADIO_STATE_OFF
					Return "Off"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "ONEX_AUTH_IDENTITY"
			Switch $iEnumeration
				Case $OneXAuthIdentityNone
					Return "No Identity"
				Case $OneXAuthIdentityMachine
					Return "Local Machine Account"
				Case $OneXAuthIdentityUser
					Return "Logged-on User"
				Case $OneXAuthIdentityExplicitUser
					Return "Profile User - Explicit"
				Case $OneXAuthIdentityGuest
					Return "Profile User - Guest"
				Case $OneXAuthIdentityInvalid
					Return "Identity Not Valid"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "ONEX_AUTH_RESTART_REASON"
			Switch $iEnumeration
				Case $OneXRestartReasonPeerInitiated
					Return "The EAPHost component (the peer) requested the 802.1x module to restart 802.1X authentication."
				Case $OneXRestartReasonMsmInitiated
					Return "The Media Specific Module (MSM) initiated the 802.1X authentication restart."
				Case $OneXRestartReasonOneXHeldStateTimeout
					Return "The 802.1X authentication restart was the result of a heldWhile timeout of the 802.1X supplicant state machine."
				Case $OneXRestartReasonOneXAuthTimeout
					Return "The 802.1X authentication restart was the result of an authWhile timeout of the 802.1X supplicant port access entity."
				Case $OneXRestartReasonOneXConfigurationChanged
					Return "The 802.1X authentication restart was the result of a configuration change to the current profile."
				Case $OneXRestartReasonOneXUserChanged
					Return "The 802.1X authentication restart was the result of a change of user."
				Case $OneXRestartReasonQuarantineStateChanged
					Return "The 802.1X authentication restart was the result of receiving a notification from the EAP quarantine enforcement client (QEC) due to a network health change."
				Case $OneXRestartReasonAltCredsTrial
					Return "The 802.1X authentication restart was caused by a new authentication attempt with alternate user credentials."
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "ONEX_AUTH_STATUS"
			Switch $iEnumeration
				Case $OneXAuthNotStarted
					Return "Not Started"
				Case $OneXAuthInProgress
					Return "In Progress"
				Case $OneXAuthNoAuthenticatorFound
					Return "No Authenticator Found"
				Case $OneXAuthSuccess
					Return "Successful"
				Case $OneXAuthFailure
					Return "Failed"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "ONEX_EAP_METHOD_BACKEND_SUPPORT"
			Switch $iEnumeration
				Case $OneXEapMethodBackendSupportUnknown
					Return "Backend Support Unknown"
				Case $OneXEapMethodBackendSupported
					Return "Backend Supported"
				Case $OneXEapMethodBackendUnsupported
					Return "Backend Unsupported"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "ONEX_REASON_CODE"
			Switch $iEnumeration
				Case $ONEX_REASON_CODE_SUCCESS
					Return "The 802.1X authentication was a success."
				Case $ONEX_UNABLE_TO_IDENTIFY_USER
					Return "The 802.1X module was unable to identify a set of credentials to be used."
				Case $ONEX_IDENTITY_NOT_FOUND
					Return "The EAP module was unable to acquire an identity for the user."
				Case $ONEX_UI_DISABLED
					Return "To proceed with 802.1X authentication, the system needs to request user input, but the user interface is disabled."
				Case $ONEX_UI_FAILURE
					Return "The 802.1X authentication module was unable to return the requested user input."
				Case $ONEX_EAP_FAILURE_RECEIVED
					Return "The EAP module returned an error code."
				Case $ONEX_AUTHENTICATOR_NO_LONGER_PRESENT
					Return "The peer with which the 802.1X module was negotiating is no longer present or is not responding."
				Case $ONEX_NO_RESPONSE_TO_IDENTITY
					Return "No response was received to an EAP identity response packet."
				Case $ONEX_PROFILE_VERSION_NOT_SUPPORTED
					Return "The 802.1X module does not support this version of the profile."
				Case $ONEX_PROFILE_INVALID_LENGTH
					Return "The length member specified in the 802.1X profile is invalid."
				Case $ONEX_PROFILE_DISALLOWED_EAP_TYPE
					Return "The EAP type specified in the 802.1X profile is not allowed for this media."
				Case $ONEX_PROFILE_INVALID_EAP_TYPE_OR_FLAG
					Return "The EAP type or EAP flags specified in the 802.1X profile are not valid."
				Case $ONEX_PROFILE_INVALID_ONEX_FLAGS
					Return "The 802.1X flags specified in the 802.1X profile are not valid."
				Case $ONEX_PROFILE_INVALID_TIMER_VALUE
					Return "One or more timer values specified in the 802.1X profile is out of its valid range."
				Case $ONEX_PROFILE_INVALID_SUPPLICANT_MODE
					Return "The supplicant mode specified in the 802.1X profile is not valid."
				Case $ONEX_PROFILE_INVALID_AUTH_MODE
					Return "The authentication mode specified in the 802.1X profile is not valid."
				Case $ONEX_PROFILE_INVALID_EAP_CONNECTION_PROPERTIES
					Return "The EAP connection properties specified in the 802.1X profile are not valid. "
				Case $ONEX_UI_CANCELLED
					Return "User input was canceled."
				Case $ONEX_PROFILE_INVALID_EXPLICIT_CREDENTIALS
					Return "The saved user credentials are not valid."
				Case $ONEX_PROFILE_EXPIRED_EXPLICIT_CREDENTIALS
					Return "The saved user credentials have expired."
				Case $ONEX_UI_NOT_PERMITTED
					Return "User interface is not permitted."
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "WLAN_ADHOC_NETWORK_STATE"
			Switch $iEnumeration
				Case $WLAN_ADHOC_NETWORK_STATE_FORMED
					Return "The ad hoc network has been formed, but no client or host is connected to the network."
				Case $WLAN_ADHOC_NETWORK_STATE_CONNECTED
					Return "A client or host is connected to the ad hoc network."
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "WLAN_CONNECTION_MODE"
			Switch $iEnumeration
				Case $WLAN_CONNECTION_MODE_PROFILE
					Return "Profile"
				Case $WLAN_CONNECTION_MODE_TEMPORARY_PROFILE
					Return "Temporary Profile"
				Case $WLAN_CONNECTION_MODE_DISCOVERY_SECURE
					Return "Secure Discovery"
				Case $WLAN_CONNECTION_MODE_DISCOVERY_UNSECURE
					Return "Unsecure Discovery"
				Case $WLAN_CONNECTION_MODE_AUTO
					Return "Persistent Profile"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "WLAN_HOSTED_NETWORK_PEER_AUTH_STATE"
			Switch $iEnumeration
				Case $WLAN_HOSTED_NETWORK_PEER_STATE_INVALID
					Return "Invalid Peer State"
				Case $WLAN_HOSTED_NETWORK_PEER_STATE_AUTHENTICATED
					Return "Peer State Authenticated"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "WLAN_HOSTED_NETWORK_REASON"
			Switch $iEnumeration
				Case $WLAN_HOSTED_NETWORK_REASON_SUCCESS
					Return "The operation was successful."
				Case $WLAN_HOSTED_NETWORK_REASON_UNSPECIFIED
					Return "Unknown Error."
				Case $WLAN_HOSTED_NETWORK_REASON_BAD_PARAMETERS
					Return "Bad parameters."
				Case $WLAN_HOSTED_NETWORK_REASON_SERVICE_SHUTTING_DOWN
					Return "Service is shutting down."
				Case $WLAN_HOSTED_NETWORK_REASON_INSUFFICIENT_RESOURCES
					Return "Service is out of resources."
				Case $WLAN_HOSTED_NETWORK_REASON_ELEVATION_REQUIRED
					Return "This operation requires elevation."
				Case $WLAN_HOSTED_NETWORK_REASON_READ_ONLY
					Return "An attempt was made to write read-only data."
				Case $WLAN_HOSTED_NETWORK_REASON_PERSISTENCE_FAILED
					Return "Data persistence failed."
				Case $WLAN_HOSTED_NETWORK_REASON_CRYPT_ERROR
					Return "A cryptographic error occurred."
				Case $WLAN_HOSTED_NETWORK_REASON_IMPERSONATION
					Return "User impersonation failed."
				Case $WLAN_HOSTED_NETWORK_REASON_STOP_BEFORE_START
					Return "An incorrect function call sequence was made."
				Case $WLAN_HOSTED_NETWORK_REASON_INTERFACE_AVAILABLE
					Return "A wireless interface has become available."
				Case $WLAN_HOSTED_NETWORK_REASON_INTERFACE_UNAVAILABLE
					Return "A wireless interface has become unavailable."
				Case $WLAN_HOSTED_NETWORK_REASON_MINIPORT_STOPPED
					Return "The wireless miniport driver stopped the Hosted Network."
				Case $WLAN_HOSTED_NETWORK_REASON_MINIPORT_STARTED
					Return "The wireless miniport driver status changed."
				Case $WLAN_HOSTED_NETWORK_REASON_INCOMPATIBLE_CONNECTION_STARTED
					Return "An incompatible connection started."
				Case $WLAN_HOSTED_NETWORK_REASON_INCOMPATIBLE_CONNECTION_STOPPED
					Return "An incompatible connection stopped."
				Case $WLAN_HOSTED_NETWORK_REASON_USER_ACTION
					Return "A state change occurred that was caused by explicit user action."
				Case $WLAN_HOSTED_NETWORK_REASON_CLIENT_ABORT
					Return "A state change occurred that was caused by client abort."
				Case $WLAN_HOSTED_NETWORK_REASON_AP_START_FAILED
					Return "The driver for the wireless Hosted Network failed to start."
				Case $WLAN_HOSTED_NETWORK_REASON_PEER_ARRIVED
					Return "A peer connected to the wireless Hosted Network."
				Case $WLAN_HOSTED_NETWORK_REASON_PEER_DEPARTED
					Return "A peer disconnected from the wireless Hosted Network."
				Case $WLAN_HOSTED_NETWORK_REASON_PEER_TIMEOUT
					Return "A peer timed out."
				Case $WLAN_HOSTED_NETWORK_REASON_GP_DENIED
					Return "The operation was denied by group policy."
				Case $WLAN_HOSTED_NETWORK_REASON_SERVICE_UNAVAILABLE
					Return "The Wireless LAN service is not running."
				Case $WLAN_HOSTED_NETWORK_REASON_DEVICE_CHANGE
					Return "The wireless adapter used by the wireless Hosted Network changed."
				Case $WLAN_HOSTED_NETWORK_REASON_PROPERTIES_CHANGE
					Return "The properties of the wireless Hosted Network changed."
				Case $WLAN_HOSTED_NETWORK_REASON_VIRTUAL_STATION_BLOCKING_USE
					Return "A virtual station is active and blocking operation."
				Case $WLAN_HOSTED_NETWORK_REASON_SERVICE_AVAILABLE_ON_VIRTUAL_STATION
					Return "An identical service is available on a virtual station."
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "WLAN_HOSTED_NETWORK_STATE"
			Switch $iEnumeration
				Case $WLAN_HOSTED_NETWORK_UNAVAILABLE
					Return "Unavailable"
				Case $WLAN_HOSTED_NETWORK_IDLE
					Return "Idle"
				Case $WLAN_HOSTED_NETWORK_ACTIVE
					Return "Active"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "WLAN_INTERFACE_STATE"
			Switch $iEnumeration
				Case $WLAN_INTERFACE_STATE_NOT_READY
					Return "Not Ready"
				Case $WLAN_INTERFACE_STATE_CONNECTED
					Return "Connected"
				Case $WLAN_INTERFACE_STATE_AD_HOC_NETWORK_FORMED
					Return "Network Formed"
				Case $WLAN_INTERFACE_STATE_DISCONNECTING
					Return "Disconnecting"
				Case $WLAN_INTERFACE_STATE_DISCONNECTED
					Return "Disconnected"
				Case $WLAN_INTERFACE_STATE_ASSOCIATING
					Return "Associating"
				Case $WLAN_INTERFACE_STATE_DISCOVERING
					Return "Discovering"
				Case $WLAN_INTERFACE_STATE_AUTHENTICATING
					Return "Authenticating"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "WLAN_INTERFACE_TYPE"
			Switch $iEnumeration
				Case $WLAN_INTERFACE_TYPE_EMULATED_802_11
					Return "Emulated Interface"
				Case $WLAN_INTERFACE_TYPE_NATIVE_802_11
					Return "Native Interface"
				Case $WLAN_INTERFACE_TYPE_INVALID
					Return "Invalid Interface"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "WLAN_OPCODE_VALUE_TYPE"
			Switch $iEnumeration
				Case $WLAN_OPCODE_VALUE_TYPE_QUERY_ONLY
					Return "Undetermined"
				Case $WLAN_OPCODE_VALUE_TYPE_SET_BY_GROUP_POLICY
					Return "Group Policy"
				Case $WLAN_OPCODE_VALUE_TYPE_SET_BY_USER
					Return "User"
				Case $WLAN_OPCODE_VALUE_TYPE_INVALID
					Return "Invalid"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case "WLAN_POWER_SETTING"
			Switch $iEnumeration
				Case $WLAN_POWER_SETTING_NO_SAVING
					Return "None"
				Case $WLAN_POWER_SETTING_LOW_SAVING
					Return "Low"
				Case $WLAN_POWER_SETTING_MEDIUM_SAVING
					Return "Medium"
				Case $WLAN_POWER_SETTING_MAXIMUM_SAVING
					Return "Maximum"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case Else
			Return SetError(3, 0, "")
	EndSwitch
EndFunc

Func _Wlan_NotificationToString($iSource, $iNotification)
	Switch $iSource
		Case $WLAN_NOTIFICATION_SOURCE_IHV
			Return "IHV code[" & Hex($iNotification) & "]"
		Case $WLAN_NOTIFICATION_SOURCE_SECURITY
			Return "Security code[" & $iNotification & "]"
		Case $WLAN_NOTIFICATION_SOURCE_ONEX
			Switch $iNotification
				Case $OneXNotificationTypeResultUpdate
					Return  "802.1X authentication has had a status change."
				Case $OneXNotificationTypeAuthRestarted
					Return "802.1X authentication has restarted."
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case $WLAN_NOTIFICATION_SOURCE_HNWK
			Switch $iNotification
				Case $WLAN_HOSTED_NETWORK_STATE_CHANGE
					Return "The Hosted Network state has changed."
				Case $WLAN_HOSTED_NETWORK_PEER_STATE_CHANGE
					Return "The Hosted Network peer state has changed."
				Case $WLAN_HOSTED_NETWORK_RADIO_STATE_CHANGE
					Return "The Hosted Network radio state has changed."
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case $WLAN_NOTIFICATION_SOURCE_ACM
			Switch $iNotification
				Case $WLAN_NOTIFICATION_ACM_AUTOCONF_ENABLED
					Return "Autoconfig enabled"
				Case $WLAN_NOTIFICATION_ACM_AUTOCONF_DISABLED
					Return "Autoconfig disabled"
				Case $WLAN_NOTIFICATION_ACM_BACKGROUND_SCAN_ENABLED
					Return "Background scans enabled"
				Case $WLAN_NOTIFICATION_ACM_BACKGROUND_SCAN_DISABLED
					Return "Background scans disabled"
				Case $WLAN_NOTIFICATION_ACM_BSS_TYPE_CHANGE
					Return "BSS type change"
				Case $WLAN_NOTIFICATION_ACM_POWER_SETTING_CHANGE
					Return "Power setting change"
				Case $WLAN_NOTIFICATION_ACM_SCAN_COMPLETE
					Return "Scan completed"
				Case $WLAN_NOTIFICATION_ACM_SCAN_FAIL
					Return "Scan failed"
				Case $WLAN_NOTIFICATION_ACM_CONNECTION_START
					Return "Connection started"
				Case $WLAN_NOTIFICATION_ACM_CONNECTION_COMPLETE
					Return "Connection complete"
				Case $WLAN_NOTIFICATION_ACM_CONNECTION_ATTEMPT_FAIL
					Return "Connection failed"
				Case $WLAN_NOTIFICATION_ACM_FILTER_LIST_CHANGE
					Return "Filter list change"
				Case $WLAN_NOTIFICATION_ACM_INTERFACE_ARRIVAL
					Return "Interface added or enabled"
				Case $WLAN_NOTIFICATION_ACM_INTERFACE_REMOVAL
					Return "Interface removed or disabled"
				Case $WLAN_NOTIFICATION_ACM_PROFILE_CHANGE
					Return "Profile or profile list change"
				Case $WLAN_NOTIFICATION_ACM_PROFILE_NAME_CHANGE
					Return "Profile name change"
				Case $WLAN_NOTIFICATION_ACM_PROFILES_EXHAUSTED
					Return "All profiles exhausted"
				Case $WLAN_NOTIFICATION_ACM_NETWORK_NOT_AVAILABLE
					Return "No available networks"
				Case $WLAN_NOTIFICATION_ACM_NETWORK_AVAILABLE
					Return "Network available"
				Case $WLAN_NOTIFICATION_ACM_DISCONNECTING
					Return "Disconnecting"
				Case $WLAN_NOTIFICATION_ACM_DISCONNECTED
					Return "Disconnected (acm)"
				Case $WLAN_NOTIFICATION_ACM_ADHOC_NETWORK_STATE_CHANGE
					Return "Ad hoc network state change"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case $WLAN_NOTIFICATION_SOURCE_MSM
			Switch $iNotification
				Case $WLAN_NOTIFICATION_MSM_ASSOCIATING
					Return "Associating"
				Case $WLAN_NOTIFICATION_MSM_ASSOCIATED
					Return "Associated"
				Case $WLAN_NOTIFICATION_MSM_AUTHENTICATING
					Return "Authenticating"
				Case $WLAN_NOTIFICATION_MSM_CONNECTED
					Return "Connected (msm)"
				Case $WLAN_NOTIFICATION_MSM_ROAMING_START
					Return "Roaming started"
				Case $WLAN_NOTIFICATION_MSM_ROAMING_END
					Return "Roaming completed"
				Case $WLAN_NOTIFICATION_MSM_RADIO_STATE_CHANGE
					Return "Radio state change"
				Case $WLAN_NOTIFICATION_MSM_SIGNAL_QUALITY_CHANGE
					Return "Signal quality change"
				Case $WLAN_NOTIFICATION_MSM_DISASSOCIATING
					Return "Disassociating"
				Case $WLAN_NOTIFICATION_MSM_DISCONNECTED
					Return "Disconnected (msm)"
				Case $WLAN_NOTIFICATION_MSM_PEER_JOIN
					Return "Peer joined"
				Case $WLAN_NOTIFICATION_MSM_PEER_LEAVE
					Return "Peer left"
				Case $WLAN_NOTIFICATION_MSM_ADAPTER_REMOVAL
					Return "Adapter removed"
				Case $WLAN_NOTIFICATION_MSM_ADAPTER_OPERATION_MODE_CHANGE
					Return "Operation mode changed"
				Case Else
					Return SetError(3, 0, "")
			EndSwitch
		Case Else
			Return SetError(3, 0, "")
	EndSwitch
EndFunc

Func _Wlan_Dot11OpModeToString($iOpMode)
	Switch $iOpMode
		Case $DOT11_OPERATION_MODE_UNKNOWN
			Return "Unknown"
		Case $DOT11_OPERATION_MODE_STATION
			Return "Station"
		Case $DOT11_OPERATION_MODE_AP
			Return "AP"
		Case $DOT11_OPERATION_MODE_EXTENSIBLE_STATION
			Return "Extensible Station"
		Case $DOT11_OPERATION_MODE_EXTENSIBLE_AP
			Return "Extensible AP"
		Case $DOT11_OPERATION_MODE_NETWORK_MONITOR
			Return "Network Monitor"
		Case Else
			Return SetError(3, 0, "")
	EndSwitch
EndFunc

Func _Wlan_pGUIDToString($pGUID)
	Local $tGUID, $sGUID = "{", $aGUID[5]
	$tGUID = DllStructCreate("ulong data1; ushort data2; ushort data3; ubyte data4[8]", $pGUID)

	$aGUID[0] = Hex(DllStructGetData($tGUID, "data1"))
	$aGUID[1] = Hex(DllStructGetData($tGUID, "data2"), 4)
	$aGUID[2] = Hex(DllStructGetData($tGUID, "data3"), 4)
	$aGUID[3] = Hex(StringTrimRight(DllStructGetData($tGUID, "data4"), 12), 4)
	$aGUID[4] = StringTrimLeft(DllStructGetData($tGUID, "data4"), 6)

	For $i = 0 To UBound($aGUID) - 2
		$sGUID &= $aGUID[$i] & "-"
	Next

	$sGUID &= $aGUID[4] & "}"
	Return $sGUID
EndFunc

Func _Wlan_bMACToString($bMAC)
	Local $sMAC, $aMAC
	$aMAC = StringSplit($bMAC, "", 2)
	If UBound($aMAC) <> 14 Then Return SetError(4, 0, False)
	For $i = 2 To UBound($aMAC) - 2 Step 2
		$sMAC &= $aMAC[$i] & $aMAC[$i + 1] & " "
	Next
	Return StringTrimRight($sMAC, 1)
EndFunc

Global $hWLANAPI = DllOpen("WlanAPI.dll")
OnAutoItExitRegister("_Wlan_CloseDll")

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanCloseHandle
; Description ...: Closes a connection to the server.
; Syntax.........: _WinAPI_WlanCloseHandle($hClientHandle, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: After a connection has been closed, any attempted use of the closed handle can cause unexpected errors.
;                  Upon closing, all outstanding notifications are discarded.
;                  Do not call WlanCloseHandle from a callback function or a deadlock may occur.
; Related .......: _WinAPI_WlanOpenHandle
; Link ..........: @@MsdnLink@@ WlanCloseHandle
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanCloseHandle($hClientHandle, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanCloseHandle", "ptr", $hClientHandle, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanConnect
; Description ...: Connects to a network.
; Syntax.........: _WinAPI_WlanConnect($hClientHandle, $pGUID, $pConnParams, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $pConnParams - A pointer to a WLAN_CONNECTION_PARAMETERS structure.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: WlanConnect returns immediately.  A client must call WlanRegisterNotification to be notified when a connection attempt is completed.
;                  The caller must have execute access on an all-user profile when attempting to connect to its associated network.
; Related .......: _WinAPI_WlanDisconnect
; Link ..........: @@MsdnLink@@ WlanConnect
;                  @@MsdnLink@@ WLAN_CONNECTION_PARAMETERS
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanConnect($hClientHandle, $pGUID, $pConnParams, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanConnect", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", $pConnParams, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanDeleteProfile
; Description ...: Deletes a profile from the profile list.
; Syntax.........: _WinAPI_WlanDeleteProfile($hClientHandle, $pGUID, $sProfileName, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $sProfileName - The name of the profile to delete.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_WlanSetProfile
; Link ..........: @@MsdnLink@@ WlanDeleteProfile
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanDeleteProfile($hClientHandle, $pGUID, $sProfileName, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanDeleteProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $sProfileName, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanDisconnect
; Description ...: Disconnects from a network.
; Syntax.........: _WinAPI_WlanDisconnect($hClientHandle, $pGUID, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If the network to be disconnected is associated with an all-user profile, the WlanDisconnect caller must have execute access on the profile.
;                  On Windows XP, WlanDisconnect modifies the associated profile to have a manual connection type (on-demand profile).
;                  There is no need to call WlanDisconnect before calling WlanConnect. Any existing network connection is dropped automatically when WlanConnect is called.
; Related .......: _WinAPI_WlanConnect
; Link ..........: @@MsdnLink@@ WlanDisconnect
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanDisconnect($hClientHandle, $pGUID, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanDisconnect", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanEnumInterfaces
; Description ...: Enumerates all of the wireless LAN interfaces currently enabled on the local computer.
; Syntax.........: _WinAPI_WlanEnumInterfaces($hClientHandle, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
; Return values .: Success - A pointer to a WLAN_INTERFACE_INFO_LIST structure.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function allocates memory to recieve data. This should be released by calling _WinAPI_WlanFreeMemory.
; Related .......: _WinAPI_WlanFreeMemory
; Link ..........: @@MsdnLink@@ WlanEnumInterfaces
;                  @@MsdnLink@@ WLAN_INTERFACE_INFO_LIST
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanEnumInterfaces($hClientHandle, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanEnumInterfaces", "hwnd", $hClientHandle, "ptr", $pReserved, "ptr*", 0)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return $aResult[3]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanFreeMemory
; Description ...: Frees memory. Any memory returned from Native Wifi functions must be freed.
; Syntax.........: _WinAPI_WlanFreeMemory($pMemory)
; Parameters ....: $pMemory - Pointer to the memory to be freed.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
; Author ........: MattyD
; Modified.......:
; Remarks .......: If $pMemory points to memory that has already been freed, an access violation or heap corruption may occur.
;                  There is a hotfix for Windows XP SP2 that can help improve the performance of WlanFreeMemory. (http://support.microsoft.com/kb/940541)
; Related .......: _WinAPI_WlanAllocateMemory
; Link ..........: @@MsdnLink@@ WlanFreeMemory
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanFreeMemory($pMemory)
	DllCall($hWLANAPI, "dword", "WlanFreeMemory", "ptr", $pMemory)
	If @error Then Return SetError(1, @error, False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanGetAvailableNetworkList
; Description ...: Retrieves the list of available networks on a wireless LAN interface.
; Syntax.........: _WinAPI_WlanEnumInterfaces($hClientHandle, $pGUID, $iFlags, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $iFlags - Controls the type of networks returned in the list. This parameter can be a combination of these values:
;                  |0x01 - Include all ad hoc profiles in the list, including profiles that are not visible.
;                  |0x02 - Include all 'hidden network' profiles in list.
; Return values .: Success - A pointer to a WLAN_AVAILABLE_NETWORK_LIST structure.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function allocates memory to recieve data. This should be released by calling _WinAPI_WlanFreeMemory.
; Related .......: _WinAPI_WlanFreeMemory, _WinAPI_WlanScan, _WinAPI_WlanGetNetworkBssList
; Link ..........: @@MsdnLink@@ WlanEnumInterfaces
;                  @@MsdnLink@@ WLAN_AVAILABLE_NETWORK_LIST
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanGetAvailableNetworkList($hClientHandle, $pGUID, $iFlags, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanGetAvailableNetworkList", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $iFlags, "ptr", $pReserved, "ptr*", 0)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return $aResult[5]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanGetInterfaceCapability
; Description ...: Retrieves the capabilities of an interface.
; Syntax.........: _WinAPI_WlanGetInterfaceCapability($hClientHandle, $pGUID, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
; Return values .: Success - A pointer to a WLAN_INTERFACE_CAPABILITY structure.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function allocates memory to recieve data. This should be released by calling _WinAPI_WlanFreeMemory.
; Related .......:
; Link ..........: @@MsdnLink@@ WlanGetInterfaceCapability
;                  @@MsdnLink@@ WLAN_INTERFACE_CAPABILITY
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanGetInterfaceCapability($hClientHandle, $pGUID, $pReserved = 0)
	Local $aResult, $pCapability
	$aResult = DllCall($hWLANAPI, "dword", "WlanGetInterfaceCapability", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", $pReserved, "ptr*", $pCapability)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return $aResult[4]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanGetNetworkBssList
; Description ...: Retrieves a list of the BSS entries of the wireless network or networks on a given wireless LAN interface.
; Syntax.........: _WinAPI_WlanGetNetworkBssList($hClientHandle, $pGUID, $pDOT11_SSID, $iDOT11_BSS_TYPE, $fSecurityEnabled, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $pDOT11_SSID - A pointer to a DOT11_SSID structure that specifies the SSID of the network from which the BSS list is requested.
;                  $iDOT11_BSS_TYPE - A DOT11_BSS_TYPE enumereration that defines the BSS type of the network. (Ignored if $pDOT11_SSID is unspecified)
;                  $fSecurityEnabled - Indicates whether security is enabled on the network. (Ignored if $pDOT11_SSID is unspecified)
; Return values .: Success - A pointer to a WLAN_BSS_LIST structure.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is not supported in Windows XP.
;                  This function allocates memory to recieve data. This should be released by calling _WinAPI_WlanFreeMemory.
;                  If $pDOT11_SSID is not specified the returned list contains all of available BSS entries on a wireless LAN interface.
;                  If $pDOT11_SSID is specified and $iDOT11_BSS_TYPE is set to $DOT11_BSS_TYPE_ANY, then the WlanGetNetworkBssList function returns ERROR_SUCCESS but no BSS entries will be returned.
;                  The function does not validate that any information returned in the informaion element data blob pointed to by the ulIeOffset member is a valid. (The blob bay be truncated)
; Related .......: _WinAPI_WlanGetAvailableNetworkList
; Link ..........: @@MsdnLink@@ WlanGetNetworkBssList
;                  @@MsdnLink@@ DOT11_SSID
;                  @@MsdnLink@@ DOT11_BSS_TYPE
;                  @@MsdnLink@@ WLAN_BSS_LIST
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanGetNetworkBssList($hClientHandle, $pGUID, $pDOT11_SSID, $iDOT11_BSS_TYPE, $fSecurityEnabled, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanGetNetworkBssList", "ptr", $hClientHandle, "ptr", $pGUID, "ptr", $pDOT11_SSID, "int", $iDOT11_BSS_TYPE, "bool", $fSecurityEnabled, "ptr", $pReserved, "ptr*", 0)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return $aResult[7]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanGetProfile
; Description ...: Retrieves all information about a specified wireless profile.
; Syntax.........: _WinAPI_WlanGetProfile($hClientHandle, $pGUID, $sProfileName, $pFlags = 0, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $sProfileName - The name of the profile. (case sensitive)
;                  $pFlags - A pointer to a dword value that provides additional information about the request. (Vista, 2008 and up)
;                  |$WLAN_PROFILE_GET_PLAINTEXT_KEY - (input) The caller wants to retrieve the unencrypted key from a profile. (7, 2008 R2 and up)
;                  |$WLAN_PROFILE_GROUP_POLICY - (output) The profile was created by group policy.
;                  |$WLAN_PROFILE_USER - (output) The profile is a per-user profile.
; Return values .: Success - A pointer to an XML representation of the profile.
;                  @extended - The access mask of the all-user profile.
;                  |$WLAN_READ_ACCESS - The user can view the contents of the profile.
;                  |$WLAN_EXECUTE_ACCESS - The user has read access, and the user can also connect to and disconnect from a network using the profile.
;                  |$WLAN_WRITE_ACCESS - The user has execute access and the user can also modify the content of the profile or delete the profile.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function allocates memory to recieve data. This should be released by calling _WinAPI_WlanFreeMemory.
;                  $pFlags must be 0 on XP platforms
;                  In Vista and Server 2008 the key is always returned encrypted. In XP it is never encrypted.
;                  The key is always encrypted in Windows 7 and Server 2008 R2 if the calling process lacks required permissions to return a plain text key.
;                  CryptUnprotectData can be used to unencrypt the key if the process is running in the context of the LocalSystem account.
; Related .......: _WinAPI_WlanSetProfile
; Link ..........: @@MsdnLink@@ WlanGetProfile
;                  @@MsdnLink@@ WLAN_policy Schema
;                  @@MsdnLink@@ CryptUnprotectData
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanGetProfile($hClientHandle, $pGUID, $sProfileName, $pFlags = 0, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanGetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $sProfileName, "ptr", $pReserved, "wstr*", 0, "ptr", $pFlags, "dword*", 0)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return SetExtended($aResult[7], $aResult[5])
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanGetProfileList
; Description ...: Retrieves the list of profiles in preference order.
; Syntax.........: _WinAPI_WlanGetProfileList($hClientHandle, $pGUID, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
; Return values .: Success - A pointer to a WLAN_PROFILE_INFO_LIST structure.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function allocates memory to recieve data. This should be released by calling _WinAPI_WlanFreeMemory.
; Related .......: _WinAPI_WlanSetProfileList _WinAPI_WlanSetProfilePosition
; Link ..........: @@MsdnLink@@ WlanGetProfileList
;                  @@MsdnLink@@ WLAN_PROFILE_INFO_LIST
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanGetProfileList($hClientHandle, $pGUID, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanGetProfileList", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", $pReserved, "ptr*", 0)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return $aResult[4]
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanHostedNetworkForceStart
; Description ...: Starts the wireless Hosted Network without associating the request with the application's calling handle.
; Syntax.........: _WinAPI_WlanHostedNetworkForceStart($hClientHandle, ByRef $iReasonCode, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $iReasonCode - On output, A WLAN_HOSTED_NETWORK_REASON code that indicates why the funtion failed.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is only supported from Windows 7 and Server 2008 R2.
;                  Successful calls should be matched by calls to WlanHostedNetworkForceStop function.
;                  Any Hosted Network state change caused by this function would not be automatically undone if the application calls WlanCloseHandle or if the process ends.
;                  See _WinAPI_WlanHostedNetworkStartUsing for more information about the Hosted Network.
;                  This function can only be called if the user has the appropriate associated privilege. Permissions are stored in a discretionary access control list (DACL) associated with a WLAN_SECURABLE_OBJECT.
;                  To call the WlanHostedNetworkForceStart, the client access token of the caller must have elevated privileges exposed by WLAN_SECURE_HOSTED_NETWORK_ELEVATED_ACCESS in WLAN_SECURABLE_OBJECT.
; Related .......: _WinAPI_WlanHostedNetworkForceStop _WinAPI_WlanHostedNetworkStartUsing
; Link ..........: @@MsdnLink@@ WlanHostedNetworkStartUsing
;                  @@MsdnLink@@ WLAN_HOSTED_NETWORK_REASON
;                  @@MsdnLink@@ WLAN_SECURABLE_OBJECT
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanHostedNetworkForceStart($hClientHandle, ByRef $iReasonCode, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanHostedNetworkForceStart", "hwnd", $hClientHandle, "dword*", 0, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	$iReasonCode = $aResult[2]
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanHostedNetworkForceStop
; Description ...: Stops wireless Hosted Network without associating the request with the application's calling handle.
; Syntax.........: _WinAPI_WinAPI_WlanHostedNetworkForceStop($hClientHandle, ByRef $iReasonCode, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $iReasonCode - On output, A WLAN_HOSTED_NETWORK_REASON code that indicates why the funtion failed.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is only supported from Windows 7 and Server 2008 R2.
;                  Any Hosted Network state change caused by this function would not be automatically undone if the application calls WlanCloseHandle or if the process ends.
;                  Any user can call the WlanHostedNetworkForceStop function to force the stop of the Hosted Network.
; Related .......: _WinAPI_WlanHostedNetworkStartUsing _WinAPI_WlanHostedNetworkForceStart _WinAPI_WlanHostedNetworkStopUsing
; Link ..........: @@MsdnLink@@ WlanHostedNetworkForceStop
;                  @@MsdnLink@@ WLAN_HOSTED_NETWORK_REASON
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanHostedNetworkForceStop($hClientHandle, ByRef $iReasonCode, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanHostedNetworkForceStop", "hwnd", $hClientHandle, "dword*", 0, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	$iReasonCode = $aResult[2]
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanHostedNetworkStartUsing
; Description ...: Configures and persists to storage the network connection settings on the wireless Hosted Network if these settings are not already configured.
; Syntax.........: _WinAPI_WlanHostedNetworkStartUsing($hClientHandle, ByRef $iReasonCode, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $iReasonCode - On output, A WLAN_HOSTED_NETWORK_REASON code that indicates why the funtion failed.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is only supported from Windows 7 and Server 2008 R2.
;                  WlanHostedNetworkInitSettings should be called before using other Hosted Network features on the local computer.
;                  If not already configured, this function performs the following actions:
;                  |Computes a random and readable SSID from the host name and computes a random primary key
;                  |Sets the maximum number of peers allowed to 100
;                  Any Hosted Network state change caused by this function would not be automatically undone if the application calls WlanCloseHandle or if the process ends.
; Related .......: _WinAPI_WlanHostedNetworkSetProperty
; Link ..........: @@MsdnLink@@ WlanHostedNetworkInitSettings
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanHostedNetworkInitSettings($hClientHandle, ByRef $iReasonCode, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanHostedNetworkInitSettings", "hwnd", $hClientHandle, "dword*", 0, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	$iReasonCode = $aResult[2]
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanHostedNetworkQueryProperty
; Description ...: Queries the current static properties of the wireless Hosted Network.
; Syntax.........: _WinAPI_WlanHostedNetworkQueryProperty($hClientHandle, $iOpCode, ByRef $iDataSize, ByRef $pData, ByRef $iValueType, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $iOpCode - A WLAN_HOSTED_NETWORK_OPCODE value to identify the property to be queried (the return data type in brackets):
;                  |WLAN_HOSTED_NETWORK_OPCODE_CONNECTION_SETTINGS (WLAN_HOSTED_NETWORK_CONNECTION_SETTINGS)
;                  |WLAN_HOSTED_NETWORK_OPCODE_SECURITY_SETTINGS (WLAN_HOSTED_NETWORK_SECURITY_SETTINGS)
;                  |WLAN_HOSTED_NETWORK_OPCODE_STATION_PROFILE (WSTR)
;                  |WLAN_HOSTED_NETWORK_OPCODE_ENABLE (BOOL)
;                  $iDataSize - On output, the size of the buffer returned in bytes.
;                  $pData - On output, a pointer to the buffer.
;                  $iValueType - A WLAN_OPCODE_VALUE_TYPE value that indicates the returned value type:
;                  |WLAN_OPCODE_VALUE_TYPE_QUERY_ONLY
;                  |WLAN_OPCODE_VALUE_TYPE_SET_BY_GROUP_POLICY
;                  |WLAN_OPCODE_VALUE_TYPE_SET_BY_USER
;                  |WLAN_OPCODE_VALUE_TYPE_INVALID
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is only supported from Windows 7 and Server 2008 R2.
; Related .......: _WinAPI_WlanHostedNetworkSetProperty
; Link ..........: @@MsdnLink@@ WlanHostedNetworkQueryProperty
;                  @@MsdnLink@@ WLAN_HOSTED_NETWORK_OPCODE
;                  @@MsdnLink@@ WLAN_HOSTED_NETWORK_CONNECTION_SETTINGS
;                  @@MsdnLink@@ WLAN_HOSTED_NETWORK_SECURITY_SETTINGS
;                  @@MsdnLink@@ WLAN_OPCODE_VALUE_TYPE
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanHostedNetworkQueryProperty($hClientHandle, $iOpCode, ByRef $iDataSize, ByRef $pData, ByRef $iValueType, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanHostedNetworkQueryProperty", "hwnd", $hClientHandle, "dword", $iOpCode, "dword*", 0, "ptr*", 0, "dword*", 0, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	$iDataSize = $aResult[3]
	$pData = $aResult[4]
	$iValueType = $aResult[5]
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanHostedNetworkSetProperty
; Description ...: Sets static properties of the wireless Hosted Network.
; Syntax.........: _WinAPI_WlanHostedNetworkSetProperty($hClientHandle, $iOpCode, $iDataSize, $pData, ByRef $iReasonCode, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $iOpCode - A WLAN_HOSTED_NETWORK_OPCODE value to identify the property to set (the expected data type in brackets):
;                  |WLAN_HOSTED_NETWORK_OPCODE_CONNECTION_SETTINGS (WLAN_HOSTED_NETWORK_CONNECTION_SETTINGS)
;                  |WLAN_HOSTED_NETWORK_OPCODE_ENABLE (BOOL)
;                  $iDataSize - The size of the data buffer.
;                  $pData - A pointer to the buffer containting the expected data type (see above).
;                  $iReasonCode - On output, a WLAN_HOSTED_NETWORK_REASON value that indicates why the funtion failed.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is only supported from Windows 7 and Server 2008 R2.
; Related .......: _WinAPI_WlanHostedNetworkQueryProperty
; Link ..........: @@MsdnLink@@ WlanHostedNetworkSetProperty
;                  @@MsdnLink@@ WLAN_HOSTED_NETWORK_OPCODE
;                  @@MsdnLink@@ WLAN_HOSTED_NETWORK_CONNECTION_SETTINGS
;                  @@MsdnLink@@ WLAN_HOSTED_NETWORK_REASON
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanHostedNetworkSetProperty($hClientHandle, $iOpCode, $iDataSize, $pData, ByRef $iReasonCode, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanHostedNetworkSetProperty", "hwnd", $hClientHandle, "dword", $iOpCode, "dword", $iDataSize, "ptr", $pData, "dword*", 0, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	$iReasonCode = $aResult[5]
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanHostedNetworkStartUsing
; Description ...: Starts the wireless Hosted Network.
; Syntax.........: _WinAPI_WlanHostedNetworkStartUsing($hClientHandle, ByRef $iReasonCode, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $iReasonCode - On output, A WLAN_HOSTED_NETWORK_REASON code that indicates why the funtion failed.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is only supported from Windows 7 and Server 2008 R2.
;                  When called for the first time, the operating system installs a virtual device if a capable wireless adapter is present.
;                  The virtual device is used exclusively for performing SoftAP connections and is not present in the list returned by WlanEnumInterfaces.
;                  The lifetime of the virtual device is tied to the physical wireless adapter. If the physical wireless adapter is disabled, this virtual device will be removed as well.
;                  Successful calls must be matched by calls to WlanHostedNetworkStopUsing.
;                  Any Hosted Network state change caused by this function would be automatically undone if the application calls WlanCloseHandle or if the process ends.
; Related .......: _WinAPI_WlanHostedNetworkStopUsing _WinAPI_WlanHostedNetworkForceStart _WinAPI_WlanHostedNetworkForceStop
; Link ..........: @@MsdnLink@@ WlanHostedNetworkStartUsing
;                  @@MsdnLink@@ WLAN_HOSTED_NETWORK_REASON
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanHostedNetworkStartUsing($hClientHandle, ByRef $iReasonCode, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanHostedNetworkStartUsing", "hwnd", $hClientHandle, "dword*", 0, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	$iReasonCode = $aResult[2]
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanHostedNetworkStopUsing
; Description ...: Stops the wireless Hosted Network.
; Syntax.........: _WinAPI_WlanHostedNetworkStopUsing($hClientHandle, ByRef $iReasonCode, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $iReasonCode - On output, A WLAN_HOSTED_NETWORK_REASON code that indicates why the funtion failed.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is only supported from Windows 7 and Server 2008 R2.
;                  A application calls the WlanHostedNetworkStopUsing function to match earlier successful calls to the WlanHostedNetworkStartUsing function.
;                  The wireless Hosted Network will remain active until all applications have called WlanHostedNetworkStopUsing or WlanHostedNetworkForceStop is called to force a stop.
; Related .......: _WinAPI_WlanHostedNetworkStartUsing _WinAPI_WlanHostedNetworkForceStart _WinAPI_WlanHostedNetworkForceStop
; Link ..........: @@MsdnLink@@ WlanHostedNetworkStopUsing
;                  @@MsdnLink@@ WLAN_HOSTED_NETWORK_REASON
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanHostedNetworkStopUsing($hClientHandle, ByRef $iReasonCode, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanHostedNetworkStopUsing", "hwnd", $hClientHandle, "dword*", 0, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	$iReasonCode = $aResult[2]
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanOpenHandle
; Description ...: Opens a connection to the server.
; Syntax.........: _WinAPI_WlanOpenHandle($iClientVersion, $pReserved = 0)
; Parameters ....: $iClientVersion - The highest version of the WLAN API that the client supports.
;                  |1 - XP SP2 with Wireless LAN API (KB918997), XP SP3
;                  |2 - Vista, Server 2008 and above
; Return values .: Success - A handle for the client to use in this session.
;                  @extended - Specifies the version of the WLAN API that will be used in this session.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......:
; Related .......: _WinAPI_WlanCloseHandle
; Link ..........: @@MsdnLink@@ WlanOpenHandle
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanOpenHandle($iClientVersion, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanOpenHandle", "dword", $iClientVersion, "ptr", $pReserved, "dword*", 0, "hwnd*", 0)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return SetExtended($aResult[3], $aResult[4])
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanQueryAutoConfigParameter
; Description ...: Queries for the parameters of the auto configuration service.
; Syntax.........: _WinAPI_WlanQueryAutoConfigParameter($hClientHandle, $iOpCode, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $iOpCode - A WLAN_AUTOCONF_OPCODE value that specifies the configuration parameter to be queried (the return data type in brackets):
;                  |$WLAN_AUTOCONF_OPCODE_SHOW_DENIED_NETWORKS (BOOL)
;                  |$WLAN_AUTOCONF_OPCODE_POWER_SETTING (WLAN_POWER_SETTING)
;                  |$WLAN_AUTOCONF_OPCODE_ONLY_USE_GP_PROFILES_FOR_ALLOWED_NETWORKS (BOOL)
;                  |$WLAN_AUTOCONF_OPCODE_ALLOW_EXPLICIT_CREDS (BOOL)
;                  |$WLAN_AUTOCONF_OPCODE_BLOCK_PERIOD (DWORD)
;                  |$WLAN_AUTOCONF_OPCODE_ALLOW_VIRTUAL_STATION_EXTENSIBILITY (BOOL)
; Return values .: Success - A pointer to a corresponding data type - see above.
;                  @extended - A WLAN_OPCODE_VALUE_TYPE value. (specifies the origin of auto config settings.)
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is not supported in version 1.0 of the API (Windows XP).
; Related .......: _WinAPI_WlanSetAutoConfigParameter
; Link ..........: @@MsdnLink@@ WlanQueryAutoConfigParameter
;                  @@MsdnLink@@ WLAN_AUTOCONF_OPCODE
;                  @@MsdnLink@@ WLAN_POWER_SETTING
;                  @@MsdnLink@@ WLAN_OPCODE_VALUE_TYPE
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanQueryAutoConfigParameter($hClientHandle, $iOpCode, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanQueryAutoConfigParameter", "hwnd", $hClientHandle, "int", $iOpCode, "ptr", $pReserved, "ptr*", 0, "ptr*", 0, "ptr*", 0)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return SetExtended($aResult[6], $aResult[5])
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanQueryInterface
; Description ...: Queries various parameters of a specified interface.
; Syntax.........: _WinAPI_WlanQueryInterface($hClientHandle, $pGUID, $iOpCode, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $iOpCode - A WLAN_INTF_OPCODE value that specifies the parameter to be queried (the return data type in brackets):
;                  |$WLAN_INTF_OPCODE_AUTOCONF_ENABLED                           (BOOL) (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_BACKGROUND_SCAN_ENABLED                    (BOOL) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_RADIO_STATE                                (WLAN_RADIO_STATE) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_BSS_TYPE                                   (DOT11_BSS_TYPE) (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_INTERFACE_STATE                            (WLAN_INTERFACE_STATE) (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_CURRENT_CONNECTION                         (WLAN_CONNECTION_ATTRIBUTES) (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_CHANNEL_NUMBER                             (ULONG) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_SUPPORTED_INFRASTRUCTURE_AUTH_CIPHER_PAIRS (WLAN_AUTH_CIPHER_PAIR_LIST) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_SUPPORTED_ADHOC_AUTH_CIPHER_PAIRS          (WLAN_AUTH_CIPHER_PAIR_LIST) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_SUPPORTED_COUNTRY_OR_REGION_STRING_LIST    (WLAN_COUNTRY_OR_REGION_STRING_LIST) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_MEDIA_STREAMING_MODE                       (BOOL) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_STATISTICS                                 (WLAN_STATISTICS) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_RSSI                                       (LONG) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_CURRENT_OPERATION_MODE                     (ULONG) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_SUPPORTED_SAFE_MODE                        (BOOL) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_CERTIFIED_SAFE_MODE                        (BOOL) (Vista, 2008 and up)
; Return values .: Success - A pointer to a corresponding data type - see above.
;                  @extended A pointer to a WLAN_OPCODE_VALUE_TYPE value that specifies the type of opcode returned. This parameter may be NULL.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function allocates memory to recieve data. This should be released by calling _WinAPI_WlanFreeMemory.
; Related .......: _WinAPI_WlanSetInterface
; Link ..........: @@MsdnLink@@ WlanQueryInterface
;                  @@MsdnLink@@ WLAN_RADIO_STATE
;                  @@MsdnLink@@ DOT11_BSS_TYPE
;                  @@MsdnLink@@ WLAN_INTERFACE_STATE
;                  @@MsdnLink@@ WLAN_CONNECTION_ATTRIBUTES
;                  @@MsdnLink@@ WLAN_AUTH_CIPHER_PAIR_LIST
;                  @@MsdnLink@@ WLAN_COUNTRY_OR_REGION_STRING_LIST
;                  @@MsdnLink@@ WLAN_STATISTICS
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanQueryInterface($hClientHandle, $pGUID, $iOpCode, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanQueryInterface", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $iOpCode, "ptr", $pReserved, "dword*", 0, "ptr*", 0, "dword*", 0)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return SetExtended($aResult[7], $aResult[6])
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanReasonCodeToString
; Description ...: Retrieves a string that describes a specified reason code.
; Syntax.........: _WinAPI_WlanReasonCodeToString($iReasonCode, $iBufferSize, $pStringBuffer, $pReserved = 0)
; Parameters ....: $iReasonCode - A WLAN_REASON_CODE value of which the string description is requested.
;                  $iBufferSize - The size of the buffer used to store the string, in WCHAR.
;                  $pStringBuffer - Pointer to a buffer that will receive the string.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If the reason code string is longer than the buffer, it will be truncated.
;                  If $iBufferSize is larger than the amount of memory allocated to $pStringBuffer, an access violation will occur.
; Related .......:
; Link ..........: @@MsdnLink@@ WlanReasonCodeToString
;                  @@MsdnLink@@ WLAN_REASON_CODE
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanReasonCodeToString($iReasonCode, $iBufferSize, $pStringBuffer, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanReasonCodeToString", "dword", $iReasonCode, "dword", $iBufferSize, "ptr", $pStringBuffer, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanRegisterNotification
; Description ...: Registers and unregisters notifications on all wireless interfaces.
; Syntax.........: _WinAPI_WlanRegisterNotification($hClientHandle, $iNotifSource, $fIgnoreDuplicate, $pNotificationCallback = 0, $pCallbackContext = 0, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $iNotifSource - The notification sources to be registered:
;                  |$WLAN_NOTIFICATION_SOURCE_NONE     - Unregisters for all notifications. (XP and up)
;                  |$WLAN_NOTIFICATION_SOURCE_ALL      - Registers for all notifications within the capabilities of the OS. (XP and up)
;                  |$WLAN_NOTIFICATION_SOURCE_ACM      - Registers for notifications generated by the auto configuration module. (XP and up)
;                  |$WLAN_NOTIFICATION_SOURCE_HNWK     - Registers for notifications generated by the wireless Hosted Network. (7 and 2008 R2)
;                  |$WLAN_NOTIFICATION_SOURCE_ONEX     - Registers for notifications generated by 802.1X. (Vista, 2008 and up)
;                  |$WLAN_NOTIFICATION_SOURCE_MSM      - Registers for notifications generated by MSM. (Vista, 2008 and up)
;                  |$WLAN_NOTIFICATION_SOURCE_SECURITY - Registers for notifications generated by the security module. (Vista, 2008 and up - currently unused)
;                  |$WLAN_NOTIFICATION_SOURCE_IHV      - Registers for notifications generated by independent hardware vendors. (Vista, 2008 and up)
;                  $fIgnoreDuplicate - Specifies whether duplicate notifications will be ignored.
;                  $pNotificationCallback - A WLAN_NOTIFICATION_CALLBACK type that defines the type of notification callback function.
;                  $pCallbackContext - A pointer to the client context that will be passed to the callback function with the notification.
; Return values .: Success - True
;                  @extended - If present, a pointer to the previously registered notification sources.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: Once registered, the callback function will be called whenever a notification is available until the client unregisters or closes the handle.
;                  Do not call WlanRegisterNotification or WlanCloseHandle from a callback function or a deadlock may occur.
;                  Notifications are handled by the Netman service in XP.
; Related .......: _WinAPI_WlanCloseHandle, _WinAPI_WlanRegisterVirtualStationNotification
; Link ..........: @@MsdnLink@@ WlanRegisterNotification
;                  @@MsdnLink@@ WLAN_NOTIFICATION_CALLBACK
;                  @@MsdnLink@@ ONEX_NOTIFICATION_TYPE
;                  @@MsdnLink@@ WLAN_NOTIFICATION_ACM
;                  @@MsdnLink@@ WLAN_NOTIFICATION_DATA
;                  @@MsdnLink@@ WLAN_HOSTED_NETWORK_NOTIFICATION_CODE
;                  @@MsdnLink@@ WLAN_NOTIFICATION_MSM
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanRegisterNotification($hClientHandle, $iNotifSource, $fIgnoreDuplicate, $pNotificationCallback = 0, $pCallbackContext = 0, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanRegisterNotification", "hwnd", $hClientHandle, "dword", $iNotifSource, "int", $fIgnoreDuplicate, "ptr", $pNotificationCallback, "ptr", $pCallbackContext, "ptr", $pReserved, "ptr*", 0)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return SetExtended($aResult[7], True)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanRenameProfile
; Description ...: Renames an existing profile.
; Syntax.........: _WinAPI_WlanRenameProfile($hClientHandle, $pGUID, $sOldProfileName, $sNewProfileName, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $sOldProfileName - The name of the profile to change.
;                  $sNewProfileName - The new name of the profile.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is not supported in Windows XP.
; Related .......: _WinAPI_WlanSetProfile _WinAPI_WlanGetProfile _WinAPI_WlanDeleteProfile
; Link ..........: @@MsdnLink@@ WlanRenameProfile
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanRenameProfile($hClientHandle, $pGUID, $sOldProfileName, $sNewProfileName, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanRenameProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $sOldProfileName, "wstr", $sNewProfileName, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanSaveTemporaryProfile
; Description ...: Saves a temporary profile to the profile store.
; Syntax.........: _WinAPI_WlanSaveTemporaryProfile($hClientHandle, $pGUID, $sProfileName, $iFlags, $pAllUserProfSec = 0, $fOverwrite = 0, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $sProfileName - The name to call the profile.
;                  $iFlags - The flags to set on the profile.
;                  |0 - The profile is an all-user profile.
;                  |$WLAN_PROFILE_USER (0x02) - The profile is a per-user profile.
;                  |$WLAN_PROFILE_CONNECTION_MODE_SET_BY_CLIENT (0x10000) The profile was created by the client.
;                  |$WLAN_PROFILE_CONNECTION_MODE_AUTO (0x20000) The profile was created by the automatic configuration module.
;                  $pAllUserProfSec - A pointer to a string that sets the security descriptor string on the all-user profile - see remarks. (Vista, 2008 and up)
;                  $fOverwrite - Specifies whether the new profile should overwrite an existing profile if it exists with the same name.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is not supported in Windows XP.
;                  A temporary profile is one that is passed to WlanConnect as such (in XML format).
;                  See _WinAPI_SetProfile for a description of how to create a security descriptor object and parse it as a string.
; Related .......: _WinAPI_WlanConnect _WinAPISetProfile
; Link ..........: @@MsdnLink@@ WlanSaveTemporaryProfile
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanSaveTemporaryProfile($hClientHandle, $pGUID, $sProfileName, $iFlags, $pAllUserProfSec = 0, $fOverwrite = 0, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanSaveTemporaryProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $sProfileName, "ptr", $pAllUserProfSec, "dword", $iFlags, "bool", $fOverwrite, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanScan
; Description ...: Requests a scan for available networks on the indicated interface.
; Syntax.........: _WinAPI_WlanScan($hClientHandle, $pGUID, $pDOT11_SSID = 0, $pWLAN_RAW_DATA = 0, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $pDOT11_SSID - A pointer to a DOT11_SSID structure that specifies the SSID of the network to be scanned (Vista, 2008 and up)
;                  $pWLAN_RAW_DATA - A pointer to an information element to include in probe requests. (Vista, 2008 and up)
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: To be notified when the network scan is complete, a client must call WlanRegisterNotification. (Vista, 2008 and up)
;                  Wireless network drivers that meet Windows logo requirements are required to complete a WlanScan function request in 4 seconds.
; Related .......: _WinAPI_WlanGetAvailableNetworkList, _WinAPI_WlanGetNetworkBssList, _WinAPI_WlanRegisterNotification, _WinAPI_WlanSetPsdIEDataList
; Link ..........: @@MsdnLink@@ WlanScan
;                  @@MsdnLink@@ DOT11_SSID
;                  @@MsdnLink@@ WLAN_RAW_DATA
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanScan($hClientHandle, $pGUID, $pDOT11_SSID = 0, $pWLAN_RAW_DATA = 0, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanScan", "hwnd", $hClientHandle, "ptr", $pGUID, "ptr", $pDOT11_SSID, "ptr", $pWLAN_RAW_DATA, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanSetAutoConfigParameter
; Description ...: Sets the parameters of the auto configuration service.
; Syntax.........: _WinAPI_WlanSetAutoConfigParameter($hClientHandle, $iOpCode, $iDataSize, $pData, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $iOpCode - A WLAN_AUTOCONF_OPCODE value that specifies the configuration parameter to be set (the expected data type of the struct pointed to by $pData in brackets):
;                  |$WLAN_AUTOCONF_OPCODE_SHOW_DENIED_NETWORKS (BOOL)
;                  |$WLAN_AUTOCONF_OPCODE_ALLOW_EXPLICIT_CREDS (BOOL)
;                  |$WLAN_AUTOCONF_OPCODE_BLOCK_PERIOD (DWORD)
;                  |$WLAN_AUTOCONF_OPCODE_ALLOW_VIRTUAL_STATION_EXTENSIBILITY (BOOL)
;                  $iDataSize - The size, in bytes, of the struct pointed to by $pData
;                  $pData - a poiter to a BOOL or DWORD, depending on the $iOpCode value - see above.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is not supported in version 1.0 of the API (Windows XP).
; Related .......: _WinAPI_WlanQueryAutoConfigParameter
; Link ..........: @@MsdnLink@@ WlanSetAutoConfigParameter
;                  @@MsdnLink@@ WLAN_AUTOCONF_OPCODE
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanSetAutoConfigParameter($hClientHandle, $iOpCode, $iDataSize, $pData, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanSetAutoConfigParameter", "hwnd", $hClientHandle, "int", $iOpCode, "dword", $iDataSize, "ptr", $pData, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanSetInterface
; Description ...: Sets user-configurable parameters for a specified interface.
; Syntax.........: _WinAPI_WlanSetInterface($hClientHandle, $pGUID, $iOpCode, $iDataSize, $pData, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $iOpCode - A WLAN_INTF_OPCODE value that specifies the parameter to be set (the expected data type in brackets):
;                  |$WLAN_INTF_OPCODE_AUTOCONF_ENABLED                           (BOOL) (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_BACKGROUND_SCAN_ENABLED                    (BOOL) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_RADIO_STATE                                (_WLAN_PHY_RADIO_STATE) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_BSS_TYPE                                   (DOT11_BSS_TYPE) (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_MEDIA_STREAMING_MODE                       (BOOL) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_CURRENT_OPERATION_MODE                     (ULONG) (Vista, 2008 and up)
;                  $iDataSize - The size of the struct containing the configuration data.
;                  $pData - A pointer to a struct containing the configuration data.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: The hardware radio state cannot be changed by calling the WlanSetInterface function.
;                  Changing the software radio state will cause related changes of the wireless Hosted Network or virtual wireless adapter radio states.
; Related .......: _WinAPI_WlanConnect
; Link ..........: @@MsdnLink@@ WlanSetInterface
;                  @@MsdnLink@@ WLAN_RADIO_STATE
;                  @@MsdnLink@@ DOT11_BSS_TYPE
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanSetInterface($hClientHandle, $pGUID, $iOpCode, $iDataSize, $pData, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanSetInterface", "hwnd", $hClientHandle, "ptr", $pGUID, "int", $iOpCode, "int", $iDataSize, "ptr", $pData, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanSetProfile
; Description ...: Sets the content of a specific profile.
; Syntax.........: _WinAPI_WlanSetProfile($hClientHandle, $pGUID, $iFlags, $sProfile,  ByRef $iReasonCode, $pAllUserProfSec = 0, $fOverwrite = 0, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $iFlags - The flags to set on the profile. (Vista, 2008 and up)
;                  |0 - The profile is an all-user profile.
;                  |$WLAN_PROFILE_GROUP_POLICY (0x01) - The profile is a group policy profile.
;                  |$WLAN_PROFILE_USER (0x02) - The profile is a per-user profile.
;                  $sProfile - The XML representation of the profile. (http://msdn.microsoft.com/en-us/library/bb525370(v=VS.85).aspx)
;                  $iReasonCode - On output, a WLAN_REASON_CODE value that indicates why the profile is not valid.
;                  $pAllUserProfSec - A pointer to a string that sets the security descriptor string on the all-user profile - see remarks. (Vista, 2008 and up)
;                  $fOverwrite - Specifies whether this profile should overwrite an existing profile if they share the same name.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: A new profile is added at the top of the list after the group policy profiles.
;                  A profile's position in the list is not changed if an existing profile is overwritten.
;                  In Windows XP, ad hoc profiles appear after the infrastructure profiles in the profile list.
;                  In Windows XP, new ad hoc profiles are placed at the top of the ad hoc list, after the group policy and infrastructure profiles.
;                  The following describes the procedure for creating a security descriptor object and parsing it as a string.
;                  1.Call InitializeSecurityDescriptor to create a security descriptor in memory.
;                  2.Call SetSecurityDescriptorOwner.
;                  3.Call InitializeAcl to create a discretionary access control list (DACL) in memory.
;                  4.Call AddAccessAllowedAce or AddAccessDeniedAce to add access control entries (ACEs) to the DACL.
;                  Set the AccessMask parameter to one of the following as appropriate:
;                  |WLAN_READ_ACCESS
;                  |WLAN_EXECUTE_ACCESS
;                  |WLAN_WRITE_ACCESS
;                  5.Call SetSecurityDescriptorDacl to add the DACL to the security descriptor.
;                  6.Call ConvertSecurityDescriptorToStringSecurityDescriptor to convert the descriptor to string.
;                  Use the string returned by ConvertSecurityDescriptorToStringSecurityDescriptor in a dll struct for the $pAllUserProfSec parameter
; Related .......: _WinAPI_WlanGetProfile
; Link ..........: @@MsdnLink@@ WlanSetProfile
;                  @@MsdnLink@@ WLAN_REASON_CODE
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanSetProfile($hClientHandle, $pGUID, $iFlags, $sProfile, ByRef $iReasonCode, $pAllUserProfSec = 0, $fOverwrite = 0, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $iFlags, "wstr", $sProfile, "ptr", $pAllUserProfSec, "bool", $fOverwrite, "ptr", $pReserved, "dword*", 0)
	If @error Then Return SetError(1, @error, False)
	$iReasonCode = $aResult[8]
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanSetProfileEapXmlUserData
; Description ...: Sets the EAP user credentials as specified by an XML string.
; Syntax.........: _WinAPI_WlanSetProfileEapXmlUserData($hClientHandle, $pGUID, $sProfileName, $iFlags, $sEAPUserData, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $sProfile - The name of the profile associated with the EAP user data.
;                  $iFlags - The flags to set on the profile. (7, 2008 R2 and up)
;                  |$WLAN_SET_EAPHOST_DATA_ALL_USERS (0x01) - Set EAP host data for all users of this profile.
;                  $sEAPUserData - User credentials in a XML format. (http://msdn.microsoft.com/en-us/library/bb204765(v=vs.85).aspx)
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: On Vista and Server 2008, these credentials can only be used by the caller.
; Related .......: _WinAPI_WlanSetProfile
; Link ..........: @@MsdnLink@@ SetProfileEapXmlUserData
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanSetProfileEapXmlUserData($hClientHandle, $pGUID, $sProfileName, $iFlags, $sEAPUserData, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanSetProfileEapXmlUserData", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $sProfileName, "dword", $iFlags, "wstr", $sEAPUserData, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanSetProfileList
; Description ...: Sets a list of profiles in order of preference.
; Syntax.........: _WinAPI_WlanSetProfileList($hClientHandle, $pGUID, $iItems, $pProfileNames, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $iItems - The number of profiles in the list to set.
;                  $pProfileNames - A pointer to a cocatenation of pointers to strings.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: The position of group policy profiles cannot be changed.
;                  In Windows XP, ad hoc profiles always appear below Infrastructure profiles.
; Related .......: _WinAPI_WlanGetProfileList _WinAPI_WlanSetProfilePosition _WinAPI_WlanDeleteProfile
; Link ..........: @@MsdnLink@@ WlanSetProfileList
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanSetProfileList($hClientHandle, $pGUID, $iItems, $pProfileNames, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanSetProfileList", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $iItems, "ptr", $pProfileNames, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanSetProfilePosition
; Description ...: Sets the position of a single, specified profile in the preference list.
; Syntax.........: _WinAPI_WlanSetProfilePosition($hClientHandle, $pGUID, $sProfileName, $iPosition, $pReserved = 0)
; Parameters ....: $hClientHandle - The client's session handle, obtained by a previous call to the WlanOpenHandle function.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface to be queried (Obtained through WlanEnumInterfaces)
;                  $sProfileName - The profile to move.
;                  $iPosition - Indicates the position in the preference list that the profile should be shifted to. (0 is the first position)
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: The position of group policy profiles cannot be changed.
;                  In Windows XP, ad hoc profiles always appear below Infrastructure profiles.
; Related .......: _WinAPI_WlanGetProfileList _WinAPI_WlanSetProfileList _WinAPI_DeleteProfile
; Link ..........: @@MsdnLink@@ WlanSetProfilePosition
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanSetProfilePosition($hClientHandle, $pGUID, $sProfileName, $iPosition, $pReserved = 0)
	Local $aResult = DllCall($hWLANAPI, "dword", "WlanSetProfilePosition", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $sProfileName, "dword", $iPosition, "ptr", $pReserved)
	If @error Then Return SetError(1, @error, False)
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _WinAPI_WlanUIEditProfile
; Description ...: Displays the wireless profile user interface (UI).
; Syntax.........: _WinAPI_WlanUIEditProfile($iClientVersion, $sProfileName, $pGUID, $iStartPage, ByRef $iReasonCode, $pReserved = 0)
; Parameters ....: $iClientVersion - Specifies the highest version of the WLAN API that the client supports. Values must be $WLAN_UI_API_VERSION (1).
;                  $sProfileName - Contains the name of the profile to be viewed or edited.
;                  $pGUID - A pointer to the GUID of the wireless LAN interface where the profile is stored (Obtained through WlanEnumInterfaces)
;                  $hWindow - The handle of the application window requesting the UI display.
;                  $iStartPage - A WL_DISPLAY_PAGES value that specifies the active tab when the UI dialog box appears.
;                  |$WLConnectionPage (0) - Displays the Connection tab.
;                  |$WLSecurityPage (1) - Displays the Security tab.
;                  |$WLAdvPage (2) - Displays the advanced dialouge under the Security tab.
;                  $iReasonCode - On output, a WLAN_REASON_CODE value that indicates why the function failed.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is not supported in version 1.0 of the API (Windows XP).
;                  Any changes to the profile made in the UI will be saved in the profile store.
; Related .......: _WinAPI_WlanSetProfile
; Link ..........: @@MsdnLink@@ WlanUIEditProfile
;                  @@MsdnLink@@ WL_DISPLAY_PAGES
;                  @@MsdnLink@@ WLAN_REASON_CODE
; Example .......:
; ===============================================================================================================================
Func _WinAPI_WlanUIEditProfile($iClientVersion, $sProfileName, $pGUID, $hWindow, $iStartPage, ByRef $iReasonCode, $pReserved = 0)
	Local $aResult = DllCall("Wlanui.dll", "dword", "WlanUIEditProfile", "dword", $iClientVersion, "wstr", $sProfileName, "ptr", $pGUID, "hwnd", $hWindow, "dword", $iStartPage, "ptr", $pReserved, "dword*", 0)
	If @error Then Return SetError(1, @error, False)
	$iReasonCode = $aResult[7]
	If $aResult[0] Then Return SetError(2, $aResult[0], False)
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_CloseDll
; Description ...: Closes the handle to WlanAPI.dll.
; Syntax.........: _Wlan_CloseDll()
; Parameters ....:
; Return values .: none.
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is hard coded into the UDF as an exit function.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_CloseDll()
	DllClose($hWLANAPI)
EndFunc

#include <WinAPI.au3>
#include <NamedPipes.au3>
#include "AutoItObject.au3"
#include "oLinkedList.au3"

Global $fDebugWifi, $hClientHandle, $tGUID, $pGUID, $iNegotiatedVersion, $tNotifOverlap, $pNotifOverlap, $hNotifPipe, $iNotifPID, $hNotifThread, $iNotifKeepTime = 4000, $asNotificationCache[1][2], $avOnNotif[1][4], $fOnNotif

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_APIVersion
; Description ...: Converts version numbers into a number of formats.
; Syntax.........: _Wlan_APIVersion($vVersion = $iNegotiatedVersion)
; Parameters ....: $vVersion - An API version number in one of the following formats:
;                  |String/Float - MajorVersion.MinorVersion
;                  |Int32 - the major version in the low-order word, minor in high-order.
; Return values .: Success - A vesion array.
;                  |$avVersion[0] - Version (string) major.minor
;                  |$avVersion[1] - Version (dword) major in low-order word, minor in high-order word
;                  |$avVersion[2] - Major version (int)
;                  |$avVersion[3] - Minor version (int)
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |4 - Invalid parameter.
; Author ........: MattyD
; Modified.......:
; Remarks .......: The default $vVersion value is the current version of the API in use.
;                  Currently the only two versions of the API used are 1.0 (usually denotes a WinXP platform) and 2.0 (everything else)
; Related .......: _Wlan_StartSession
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_APIVersion($vVersion = $iNegotiatedVersion)
	Local $avVersion[4]
	If StringRegExp($vVersion, "[^0-9\.]") Or Not $vVersion Then Return SetError(4, 0, False)
	If StringInStr($vVersion, ".") Then
		$avVersion[2] = Number(StringRegExpReplace($vVersion, "\.[0-9]{0,}", ""))
		$avVersion[3] = Number(StringRegExpReplace($vVersion, "[0-9]{1,}\.", ""))
		$avVersion[0] = $avVersion[2] & "." & $avVersion[3]
		$avVersion[1] = BitOR(BitShift($avVersion[3], -16), $avVersion[2])
	Else
		$avVersion[1] = $vVersion
		$avVersion[2] = BitAND($avVersion[1], 0x0000FFFF)
		$avVersion[3] = BitShift($avVersion[1], 16)
		$avVersion[0] = $avVersion[2] & "." & $avVersion[3]
	EndIf
	Return $avVersion
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _Wlan_CacheNotification
; Description ...: Caches messages sent by the notification module.
; Syntax.........: _Wlan_CacheNotification()
; Parameters ....:
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |3 - There is no notification to cache.
;                  |6 - The notification module is not running.
; Author ........: MattyD
; Modified.......:
; Remarks .......: _Wlan_GetNotification should be called to read messages from the cache.
; Related .......: _Wlan_GetNotification
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_CacheNotification()
	Local $iTrim = -1, $sStream, $asStream, $asEntry, $iEntryPoint, $tBuffer, $pBuffer, $iRead, $fSuccess
	Local Const $ERROR_BROKEN_PIPE = 109

	For $i = 1 To UBound($asNotificationCache) - 1
		If TimerDiff($asNotificationCache[$i][0]) < $iNotifKeepTime Then
			If $iTrim < 0 Then $iTrim = $i - 1
			$asNotificationCache[$i - $iTrim][0] = $asNotificationCache[$i][0]
			$asNotificationCache[$i - $iTrim][1] = $asNotificationCache[$i][1]
		EndIf
	Next
	If $iTrim < 0 Then $iTrim = UBound($asNotificationCache) - 1
	ReDim $asNotificationCache[$i - $iTrim][2]
	If Not ProcessExists($iNotifPID) Then Return SetError(6, 0, False)

	$tBuffer = DllStructCreate("char Text[4096]")
	$pBuffer = DllStructGetPtr($tBuffer)
	While 1
		$fSuccess = _WinAPI_ReadFile($hNotifPipe, $pBuffer, 4096, $iRead, $pNotifOverlap)
		If _WinAPI_GetLastError() = $ERROR_BROKEN_PIPE Then
			_Wlan_StopNotificationModule()
			OnAutoItExitUnRegister("_Wlan_StopNotificationModule")
			Return SetError(6, 0, False)
		EndIf
		If $fSuccess And $iRead Then
			$sStream &= StringLeft(DllStructGetData($tBuffer, 1), $iRead)
		EndIf
		If StringRight($sStream, 5) == "[EON]" Or Not $sStream Then ExitLoop
		Sleep(5)
	Wend
	If Not $sStream Then Return SetError(3, 0, "")
	$asStream = StringSplit($sStream, "[EON]", 3)

	$iEntryPoint = UBound($asNotificationCache)
	ReDim $asNotificationCache[$iEntryPoint + UBound($asStream) - 1][2]
	For $i = 0 To UBound($asStream) - 2
		$asEntry = StringSplit($asStream[$i], "|", 2)
		$asNotificationCache[$iEntryPoint + $i][0] = $asEntry[0]
		$asNotificationCache[$iEntryPoint + $i][1] = $asEntry[1]
	Next

	If $fOnNotif Then
		For $i = 0 To UBound($asNotificationCache) - 1
			_Wlan_OnNotifHandler()
			Sleep(10)
		Next
	EndIf

	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_Connect
; Description ...: Connects an interface to a network.
; Syntax.........:  _Wlan_Connect($vProfile, $fWait = False, $iTimeout = 15, $sSSID = "", $iFlags = 0)
; Parameters ....: $vProfile - Either a profile name (connect using an existing profile), XML profile or profile object. (connect using a temporary profile)
;                  $fWait - Specifies if the function should wait for the connection to be disconnected before returning.
;                  $iTimeout - The maximum length of time in seconds the function should wait before returning.
;                  $SSID - Specifies which SSID within a profile to connect to.
;                  $iFlags - Specifies more connection parameters. (flags only applicable on networks/profiles as outlined in brackets)
;                  |$WLAN_CONNECTION_HIDDEN_NETWORK (0x01) - Connect to the destination network even if it is not broadcasting a SSID. (infrastructure)
;                  |$WLAN_CONNECTION_ADHOC_JOIN_ONLY (0x02) - Do not form an ad-hoc network. Only join an ad-hoc network if the network already exists. (ad hoc)
;                  |$WLAN_CONNECTION_IGNORE_PRIVACY_BIT (0x04) - Ignore whether packets are encrypted and the method of encryption used. (infrastructure with temporary profile)
;                  |$WLAN_CONNECTION_EAPOL_PASSTHROUGH (0x08) - Exempt EAPOL traffic from encryption and decryption. Use only when an application must send EAPOL traffic using open authentication and WEP encryption. (Infrastructure, 802.1x disabled, temporary profile)
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |5 - The function timed out.
;                  |6 - Notification module is not running.
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  $vProfile must be a profile name on Windows XP.
;                  If $fWait is True then the notification module must be running and accepting ACM notifications.
;                  If connection attempt is successfully started but fails before timing
;                  If the network to be disconnected is associated with an all-user profile, the WlanDisconnect caller must have execute access on the profile.
;                  On Windows XP, WlanDisconnect modifies the associated profile to have a manual connection type (on-demand profile).
;                  There is no need to call WlanDisconnect before calling WlanConnect. Any existing network connection is dropped automatically when WlanConnect is called.
; Related .......: _Wlan_Disconnect _Wlan_SaveTemporaryProfile
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_Connect($vProfile, $fWait = False, $iTimeout = 15, $sSSID = "", $iFlags = 0);, $iConnMode = -1, $iBSSType = -1)
	Local $avVersion = _Wlan_APIVersion(), $iConnectCount, $iTimer, $avNotification, $asSREXResult, $tProfile, $tConnParams
	Local $tSSID, $pSSID = 0, $sReasonCode, $iConnMode = $WLAN_CONNECTION_MODE_TEMPORARY_PROFILE, $iBSSType = $DOT11_BSS_TYPE_INFRASTRUCTURE

	If $fWait < 0 Or $fWait = Default Then $fWait = False
	If $iTimeout < 0 Or $iTimeout = Default Then $iTimeout = 15
	;If $iConnMode < 0 Or $iConnMode = Default Then $iConnMode = $WLAN_CONNECTION_MODE_TEMPORARY_PROFILE
	;If $iBSSType < 0 Or $iBSSType = Default Then $iBSSType = $DOT11_BSS_TYPE_INFRASTRUCTURE

	If IsObj($vProfile) Then
		If $vProfile.Type = "Ad Hoc" Then $iBSSType = $DOT11_BSS_TYPE_INDEPENDENT
		$vProfile = _Wlan_GenerateXMLProfile($vProfile)
		If @error Then Return SetError(@error, @extended, False)
	ElseIf StringInStr($vProfile, 'xml version="1.0"') Then
		$asSREXResult = StringRegExp($vProfile, "<connectionType" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then
			If $asSREXResult[0] = "IBSS" Then $iBSSType = $DOT11_BSS_TYPE_INDEPENDENT
		EndIf
	ElseIf $vProfile Then
		$vProfile = _Wlan_GetProfile($vProfile, $sReasonCode)
		If @error Then Return SetError(@error, @extended, False)
		$iConnMode = $WLAN_CONNECTION_MODE_PROFILE
		If Not @error Then
			If $vProfile.Type = "Ad Hoc" Then $iBSSType = $DOT11_BSS_TYPE_INDEPENDENT
			$vProfile = $vProfile.Name
		EndIf
	EndIf

	If $sSSID Then
		$tSSID = DllStructCreate("dword Length; wchar char[32]")
		DllStructSetData($tSSID, "SSID", $sSSID)
		DllStructSetData($tSSID, "SSID", StringLen($sSSID))
		$pSSID = DllStructGetPtr($tSSID)
	EndIf

	$tProfile = DllStructCreate("wchar Profile[4096]")
	DllStructSetData($tProfile, "Profile", $vProfile)

	$tConnParams = DllStructCreate("dword ConnMode; ptr Profile; ptr SSID; ptr BSSIDList; dword BSSType; dword Flags")
	DllStructSetData($tConnParams, "ConnMode", $iConnMode)
	DllStructSetData($tConnParams, "Profile", DllStructGetPtr($tProfile))
	DllStructSetData($tConnParams, "SSID", $pSSID)
	DllStructSetData($tConnParams, "BSSType", $iBSSType)
	DllStructSetData($tConnParams, "Flags", $iFlags)

	_WinAPI_WlanConnect($hClientHandle, $pGUID, DllStructGetPtr($tConnParams))
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanConnect"))
	If Not $fWait Then Return True

	$iTimer = TimerInit()
	While TimerDiff($iTimer) < $iTimeout * 1000
		$avNotification = _Wlan_GetNotification()
		If @error And @error <> 3 Then Return SetError(6, 0, False)
		If @error = 3 Then ContinueLoop
		If $avNotification[0] = $WLAN_NOTIFICATION_SOURCE_ACM And $avNotification[2] = _Wlan_pGUIDToString($pGUID) Then
		Switch $avNotification[1]
			Case $WLAN_NOTIFICATION_ACM_CONNECTION_COMPLETE
				If $avVersion[2] > 1 Then Return True
				$iConnectCount += 1
				If $iConnectCount = 3 Then Return True
			Case $WLAN_NOTIFICATION_ACM_DISCONNECTED, $WLAN_NOTIFICATION_ACM_CONNECTION_ATTEMPT_FAIL
				Return False
			EndSwitch
		EndIf
	WEnd
	Return SetError(5, 0, False)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_ConvertProfile
; Description ...: Converts an XML profile to a profile object and vica versa.
; Syntax.........: _Wlan_ConvertProfile($vProfile)
; Parameters ....: $vProfile - An XML profile or profile object
; Return values .: Success - An XML profile or profile object depending on the input format.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |6 - A dependency is missing.
;                  @extended - _AutoItObject_Create error code.
; Author ........: MattyD
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_ConvertProfile($vProfile)
	If IsObj($vProfile) Then
		$vProfile = _Wlan_GenerateXMLProfile($vProfile)
		Return SetError(@error, @extended, $vProfile)
	Else
		$vProfile = _Wlan_GenerateProfileObject($vProfile)
		Return SetError(@error, @extended, $vProfile)
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_ConvertUserData
; Description ...: Converts XML user data for profiles using 802.1x authentication to a user data object and vica versa.
; Syntax.........: _Wlan_ConvertUserData($vUserData)
; Parameters ....: $vUserData - XML EAP user data or user data object
; Return values .: Success - XML EAP user data or user data object depending on the input format.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |6 - A dependency is missing.
;                  @extended - _AutoItObject_Create error code.
; Author ........: MattyD
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_ConvertUserData($vProfile)
	If IsObj($vProfile) Then
		$vProfile = _Wlan_GenerateXMLUserData($vProfile)
		Return SetError(@error, @extended, $vProfile)
	Else
		$vProfile = _Wlan_GenerateUserDataObject($vProfile)
		Return SetError(@error, @extended, $vProfile)
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_CreateProfileObject
; Description ...: Creates a profile object.
; Syntax.........:  _Wlan_CreateProfileObject()
; Parameters ....:
; Return values .: Success - A profile object
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |6 - A dependency is missing. (@extended - _AutoItObject_Create error code.)
; Author ........: MattyD
; Modified.......:
; Remarks .......: The structure of a profile object is outlined in the documentation of _Wlan_SetProfile
; Related .......: _Wlan_SetProfile _Wlan_GetProfile _Wlan_GenerateProfileObject _Wlan_GenerateXMLProfile _Wlan_Connect
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_CreateProfileObject()
	Local $oProfileClass, $oProfile, $oKeyClass, $oOptionsClass, $oSSOClass, $oOneXClass, $oPMKClass, $oFIPSClass, $oServerValidationClass, _
		$oServerValidation, $oMSCHAPClass, $oTLSClass, $oTLS, $oPEAPClass, $oEAPClass

	$oKeyClass = _AutoitObject_Class()
	With $oKeyClass
		.AddProperty("Material", $ELSCOPE_PUBLIC, "")
		.AddProperty("Protected", $ELSCOPE_PUBLIC, "")
		.AddProperty("Type", $ELSCOPE_PUBLIC, "")
		.AddProperty("Index", $ELSCOPE_PUBLIC, "")
	EndWith

	$oOptionsClass = _AutoitObject_Class()
	With $oOptionsClass
		.AddProperty("NonBroadcast", $ELSCOPE_PUBLIC, "")
		.AddProperty("ConnMode", $ELSCOPE_PUBLIC, "")
		.AddProperty("Autoswitch", $ELSCOPE_PUBLIC, "")
		.AddProperty("PhyTypes", $ELSCOPE_PUBLIC, LinkedList())
	EndWith

	$oSSOClass = _AutoitObject_Class()
	With $oSSOClass
		.AddProperty("MaxDelay", $ELSCOPE_PUBLIC, "")
		.AddProperty("Type", $ELSCOPE_PUBLIC, "")
		.AddProperty("UserBasedVLAN", $ELSCOPE_PUBLIC, "")
		.AddProperty("AllowMoreDialogs", $ELSCOPE_PUBLIC, "")
	EndWith

	$oOneXClass = _AutoitObject_Class()
	With $oOneXClass
		.AddProperty("Enabled", $ELSCOPE_PUBLIC, "")
		.AddProperty("AuthMode", $ELSCOPE_PUBLIC, "")
		.AddProperty("AuthPeriod", $ELSCOPE_PUBLIC, "")
		.AddProperty("CacheUserData", $ELSCOPE_PUBLIC, "")
		.AddProperty("HeldPeriod", $ELSCOPE_PUBLIC, "")
		.AddProperty("MaxAuthFailures", $ELSCOPE_PUBLIC, "")
		.AddProperty("MaxStart", $ELSCOPE_PUBLIC, "")
		.AddProperty("StartPeriod", $ELSCOPE_PUBLIC, "")
		.AddProperty("SuppMode", $ELSCOPE_PUBLIC, "")
		.AddProperty("SSO", $ELSCOPE_PUBLIC, $oSSOClass.Object)
	EndWith

	$oPMKClass = _AutoitObject_Class()
	With $oPMKClass
		.AddProperty("CacheEnabled", $ELSCOPE_PUBLIC, "")
		.AddProperty("CacheTTL", $ELSCOPE_PUBLIC, "")
		.AddProperty("CacheSize", $ELSCOPE_PUBLIC, "")
		.AddProperty("PreAuthEnabled", $ELSCOPE_PUBLIC, "")
		.AddProperty("PreAuthThrottle", $ELSCOPE_PUBLIC, "")
	EndWith

	$oFIPSClass = _AutoitObject_Class()
	$oFIPSClass.AddProperty("Enabled", $ELSCOPE_PUBLIC, "")

	$oServerValidationClass = _AutoitObject_Class()
	With $oServerValidationClass
		.AddProperty("NoUserPrompt", $ELSCOPE_PUBLIC, "")
		.AddProperty("ServerNames", $ELSCOPE_PUBLIC, "")
		.AddProperty("ThumbPrints", $ELSCOPE_PUBLIC, "")
		.AddProperty("Enabled", $ELSCOPE_PUBLIC, "")
		.AddProperty("AcceptServerNames", $ELSCOPE_PUBLIC, "")
	EndWith
	$oServerValidation = $oServerValidationClass.Object

	$oMSCHAPClass = _AutoitObject_Class()
	$oMSCHAPClass.AddProperty("UseWinLogonCreds", $ELSCOPE_PUBLIC, "")

	$oTLSClass = _AutoitObject_Class()
	With $oTLSClass
		.AddProperty("Source", $ELSCOPE_PUBLIC, "")
		.AddProperty("SimpleCertSel", $ELSCOPE_PUBLIC, "")
		.AddProperty("DiffUsername", $ELSCOPE_PUBLIC, "")
		.AddProperty("ServerValidation", $ELSCOPE_PUBLIC, "")
	EndWith
	$oTLS = $oTLSClass.Object

	$oPEAPClass = _AutoitObject_Class()
	With $oPEAPClass
		.AddProperty("FastReconnect", $ELSCOPE_PUBLIC, "")
		.AddProperty("QuarantineChecks", $ELSCOPE_PUBLIC, "")
		.AddProperty("RequireCryptobinding", $ELSCOPE_PUBLIC, "")
		.AddProperty("EnableIdentityPrivacy", $ELSCOPE_PUBLIC, "")
		.AddProperty("AnonUsername", $ELSCOPE_PUBLIC, "")
		.AddProperty("ServerValidation", $ELSCOPE_PUBLIC, _AutoitObject_Create($oServerValidation))
		.AddProperty("MSCHAP", $ELSCOPE_PUBLIC, $oMSCHAPClass.Object)
		.AddProperty("TLS", $ELSCOPE_PUBLIC, _AutoitObject_Create($oTLS))
	EndWith

	$oEAPClass = _AutoitObject_Class()
	With $oEAPClass
		.AddProperty("Blob", $ELSCOPE_PUBLIC, "")
		.AddProperty("BaseType", $ELSCOPE_PUBLIC, "")
		.AddProperty("Type", $ELSCOPE_PUBLIC, "")
		.AddProperty("PEAP", $ELSCOPE_PUBLIC, _AutoitObject_Create($oPEAPClass.Object))
		.AddProperty("TLS", $ELSCOPE_PUBLIC, _AutoitObject_Create($oTLS))
	EndWith

	$oProfileClass = _AutoitObject_Class()
	With $oProfileClass
		.AddProperty("XML", $ELSCOPE_PUBLIC, "")
		.AddProperty("Name", $ELSCOPE_PUBLIC, "")
		.AddProperty("SSID", $ELSCOPE_PUBLIC, LinkedList())
		.AddProperty("Type", $ELSCOPE_PUBLIC, "")
		.AddProperty("Auth", $ELSCOPE_PUBLIC, "")
		.AddProperty("Encr", $ELSCOPE_PUBLIC, "")
		.AddProperty("Key", $ELSCOPE_PUBLIC, $oKeyClass.Object)
		.AddProperty("Options", $ELSCOPE_PUBLIC, $oOptionsClass.Object)
		.AddProperty("OneX", $ELSCOPE_PUBLIC, $oOneXClass.Object)
		.AddProperty("PMK", $ELSCOPE_PUBLIC, $oPMKClass.Object)
		.AddProperty("FIPS", $ELSCOPE_PUBLIC, $oFIPSClass.Object)
		.AddProperty("EAP", $ELSCOPE_PUBLIC, $oEAPClass.Object)
	EndWith
	$oProfile = $oProfileClass.Object

	$oProfile.EAP.TLS.ServerValidation = _AutoitObject_Create($oServerValidation)
	$oProfile.EAP.PEAP.TLS.ServerValidation = _AutoitObject_Create($oServerValidation)
	$oProfile.EAP.PEAP.ServerValidation.Thumbprints = LinkedList()
	$oProfile.EAP.PEAP.TLS.ServerValidation.Thumbprints = LinkedList()
	$oProfile.EAP.TLS.ServerValidation.Thumbprints = LinkedList()

	Return $oProfile
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_CreateUserDataObject
; Description ...: Creates a user data object for profiles incorperating 802.1x authentication.
; Syntax.........:  _Wlan_CreateUserDataObject()
; Parameters ....:
; Return values .: Success - A user data object
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |6 - A dependency is missing. (@extended - _AutoItObject_Create error code.)
; Author ........: MattyD
; Modified.......:
; Remarks .......: The structure of a user data object is outlined in the documentation of _Wlan_SetProfileUserData
; Related .......: _Wlan_SetProfileUserData _Wlan_GenerateUserDataObject _Wlan_GenerateXMLUserData
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_CreateUserDataObject()
	Local $oUserDataClass, $oUserData, $oPEAPUserDataClass, $oTLSUserDataClass, $oTLSUserData, $oMSCHAPUserDataClass

	$oTLSUserDataClass = _AutoitObject_Class()
	With $oTLSUserDataClass
		.AddProperty("Domain", $ELSCOPE_PUBLIC, "")
		.AddProperty("Username", $ELSCOPE_PUBLIC, "")
		.AddProperty("Cert", $ELSCOPE_PUBLIC, "")
	EndWith
	$oTLSUserData = $oTLSUserDataClass.Object

	$oMSCHAPUserDataClass = _AutoitObject_Class()
	With $oMSCHAPUserDataClass
		.AddProperty("Domain", $ELSCOPE_PUBLIC, "")
		.AddProperty("Username", $ELSCOPE_PUBLIC, "")
		.AddProperty("Password", $ELSCOPE_PUBLIC, "")
	EndWith

	$oPEAPUserDataClass = _AutoitObject_Class()
	With $oPEAPUserDataClass
		.AddProperty("Username", $ELSCOPE_PUBLIC, "")
		.AddProperty("MSCHAP", $ELSCOPE_PUBLIC, $oMSCHAPUserDataClass.Object)
		.AddProperty("TLS", $ELSCOPE_PUBLIC, "")
	EndWith

	$oUserDataClass = _AutoitObject_Class()
	With $oUserDataClass
		.AddProperty("BaseType", $ELSCOPE_PUBLIC, "")
		.AddProperty("Type", $ELSCOPE_PUBLIC, "")
		.AddProperty("Blob", $ELSCOPE_PUBLIC, "")
		.AddProperty("PEAP", $ELSCOPE_PUBLIC, $oPEAPUserDataClass.Object)
		.AddProperty("TLS", $ELSCOPE_PUBLIC, _AutoitObject_Create($oTLSUserData))
	EndWith
	$oUserData = $oUserDataClass.Object

	$oUserData.PEAP.TLS = _AutoitObject_Create($oTLSUserData)

	Return $oUserData
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_DecryptKey
; Description ...: Decrypts a protected network key returned by _Wlan_GetProfile.
; Syntax.........: _Wlan_DecryptKey($bKey)
; Parameters ....: $bKey - A binary representation of an encrypted network key.
; Return values .: Success - The decrypted network key.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  The calling process must be running in the context of the LocalSystem account in order for this function to succeed.
; Related .......: _Wlan_GetProfile
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_DecryptKey($bKey)
    Local Const $CRYPTPROTECT_UI_FORBIDDEN = 0x1
	Local $tEncrKey, $tDataIn, $tDataOut, $aResult, $tDecrKey

	$tEncrKey = DllStructCreate("byte[1024]")
	DllStructSetData($tEncrKey, 1, $bKey)

	$tDataIn = DllStructCreate("int; ptr")
	DllStructSetData($tDataIn, 1, BinaryLen($bKey))
    DllStructSetData($tDataIn, 2, DllStructGetPtr($tEncrKey))

	$tDataOut = DllStructCreate("int; ptr")
    $aResult = DllCall("crypt32.dll","bool", "CryptUnprotectData", "ptr", DllStructGetPtr($tDataIn), "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0, "dword", $CRYPTPROTECT_UI_FORBIDDEN, "ptr", DllStructGetPtr($tDataOut))
    If @error Then Return SetError(1, @error, False)
	If Not $aResult[0] Then Return SetError(2, _WinAPI_GetLastError(), False)

	$tDecrKey = DllStructCreate("char[" & DllStructGetData($tDataOut, 1) & "]", DllStructGetData($tDataOut, 2))
	Return DllStructGetData($tDecrKey, 1)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_DeleteProfile
; Description ...: Deletes a profile from the profile list.
; Syntax.........: _Wlan_DeleteProfile($sProfileName)
; Parameters ....: $sProfileName - The name of the profile to delete.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
; Related .......: _Wlan_SetProfile
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_DeleteProfile($sProfileName)
	_WinAPI_WlanDeleteProfile($hClientHandle, $pGUID, $sProfileName)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanDeleteprofile"))
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_Disconnect
; Description ...: Disconnects an interface from its current network.
; Syntax.........: _Wlan_Disconnect($fWait = False, $iTimeout = 5)
; Parameters ....: $fWait - Specifies if the function should wait for the connection to be disconnected before returning
;                  $iTimeout - The maximum length of time in seconds the function should wait before returning
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |5 - The function timed out.
;                  |6 - Notification module is not running.
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  If $fWait is True then the notification module must be running and accepting ACM notifications.
;                  If the network to be disconnected is associated with an all-user profile, the WlanDisconnect caller must have execute access on the profile.
;                  On Windows XP, WlanDisconnect modifies the associated profile to have a manual connection type (on-demand profile).
;                  There is no need to call WlanDisconnect before calling WlanConnect. Any existing network connection is dropped automatically when WlanConnect is called.
; Related .......: _Wlan_Connect
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_Disconnect($fWait = False, $iTimeout = 5)
	Local $avVersion = _Wlan_APIVersion(), $iDisconnectCount, $iTimer, $avNotification
	If $fWait < 0 Or $fWait = Default Then $fWait = False
	If $iTimeout < 0 Or $iTimeout = Default Then $iTimeout = 5
	;Check if disconnected.
	_WinAPI_WlanDisconnect($hClientHandle, $pGUID)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanDisconnect"))
	If Not $fWait Then Return True
	$iTimer = TimerInit()
	While TimerDiff($iTimer) < $iTimeout * 1000
		$avNotification = _Wlan_GetNotification()
		If @error And @error <> 3 Then Return SetError(6, 0, False)
		If @error = 3 Then ContinueLoop
		If $avNotification[0] = $WLAN_NOTIFICATION_SOURCE_ACM And $avNotification[1] = $WLAN_NOTIFICATION_ACM_DISCONNECTED Then
			If $avVersion[2] > 1 Then Return True
			$iDisconnectCount += 1
			If $iDisconnectCount = 3 Then Return True
		EndIf
	WEnd
	Return SetError(5, 0, False)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _Wlan_EndSession
; Description ...: Cleans up the wireless session.
; Syntax.........: _Wlan_EndSession()
; Parameters ....:
; Return values .: none.
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is hard coded into the UDF as an exit function.
; Related .......: _Wlan_StartSession
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_EndSession()
	_WinAPI_WlanCloseHandle($hClientHandle)
	If @error Then _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanCloseHandle")
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_EnumInterfaces
; Description ...: Enumerates all of the wireless LAN interfaces currently enabled on the local computer.
; Syntax.........: _Wlan_EnumInterfaces()
; Parameters ....:
; Return values .: Success - An array of interfaces.
;                  |$asInterfaces[$iIndex][0] - Interface GUID
;                  |$asInterfaces[$iIndex][1] - Interface Description
;                  |$asInterfaces[$iIndex][2] - Interface State
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |3 - There is no data to return.
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  Interfaces must be enabled to be enumerated.
; Related .......: _Wlan_SelectInterface
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_EnumInterfaces()
	Local $pInterfaceList, $tInterface, $iItems
	$pInterfaceList = _WinAPI_WlanEnumInterfaces($hClientHandle)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanEnumInterfaces"))
	$tInterface = DllStructCreate("dword Items", $pInterfaceList)
	$iItems = DllStructGetData($tInterface, "Items")
	If Not $iItems Then
		_WinAPI_WlanFreeMemory($pInterfaceList)
		Return SetError(3, 0, "")
	EndIf

	Local $asInterfaces[$iItems][3], $pInterface

	For $i = 0 To $iItems - 1
		$pInterface = Ptr($i * 532 + Number($pInterfaceList) + 8)
		$tInterface = DllStructCreate("byte GUID[16]; wchar Desc[256]; dword State", $pInterface)
		$asInterfaces[$i][0] = _Wlan_pGUIDToString($pInterface)
		$asInterfaces[$i][1] = DllStructGetData($tInterface, "Desc")
		$asInterfaces[$i][2] = _Wlan_EnumToString("WLAN_INTERFACE_STATE", DllStructGetData($tInterface, "State"))
	Next

	_WinAPI_WlanFreeMemory($pInterfaceList)
	Return $asInterfaces
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _Wlan_GenerateProfileObject
; Description ...: Generates a profile object from an XML profile.
; Syntax.........: _Wlan_GenerateProfileObject($sProfile)
; Parameters ....: $sProfile - An XML profile
; Return values .: Success - A profile object
;                  Failure - False
;                  @Error - 0 - No error.
;                  |6 - A dependency is missing. (@extended - _AutoItObject_Create error code.)
; Author ........: MattyD
; Modified.......:
; Remarks .......:
; Related .......: _Wlan_GenerateXMLProfile _Wlan_ConvertProfile
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_GenerateProfileObject($sProfile)
	Local $oProfile, $asSREXResult, $asProfileSnippet
	$oProfile = _Wlan_CreateProfileObject()
	If @error Then Return SetError(6, @error, False)

	With $oProfile
		.XML = $sProfile
		$asSREXResult = StringRegExp($sProfile, "<name" & "[^>]{0,}>([^<]{0,})<", 3)
		If Not @error Then
			.Name = $asSREXResult[0]
			For $i = 1 To UBound($asSREXResult) - 1
				.SSID.Add($asSREXResult[$i])
			Next
		EndIf
		$asSREXResult = StringRegExp($sProfile, "<connectionType" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .Type = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<authentication" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .Auth = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<encryption" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .Encr = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<protected" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .Key.Protected = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<keyType" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .Key.Type = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<keyMaterial" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .Key.Material = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<keyIndex" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .Key.Index = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<nonBroadcast" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .Options.NonBroadcast = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<connectionMode" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .Options.ConnMode = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<autoSwitch" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .Options.Autoswitch = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<phyType" & "[^>]{0,}>([^<]{0,})<", 3)
		If Not @error Then
			For $i = 0 To UBound($asSREXResult) - 1
				.Options.PhyTypes.Add($asSREXResult[$i])
			Next
		EndIf
		$asSREXResult = StringRegExp($sProfile, "<useOneX" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.Enabled = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<authMode" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.AuthMode = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<authPeriod" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.AuthPeriod = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<cacheUserData" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.CacheUserData = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<heldPeriod" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.HeldPeriod = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<maxAuthFailures" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.MaxAuthFailures = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<maxStart" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.MaxStart = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<startPeriod" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.StartPeriod = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<supplicantMode" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.SuppMode = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<type" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.SSO.Type = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<maxDelay" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.SSO.MaxDelay = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<userBasedVirtualLan" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.SSO.UserBasedVLAN = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<allowAdditionalDialogs" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .OneX.SSO.AllowMoreDialogs = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<PMKCacheMode" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .PMK.CacheEnabled = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<PMKCacheTTL" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .PMK.CacheTTL = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<PMKCacheSize" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .PMK.CacheSize = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<preAuthMode" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .PMK.PreAuthEnabled = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<preAuthThrottle" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .PMK.PreAuthThrottle = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<FIPSMode" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .FIPS.Enabled = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<ConfigBlob" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then .EAP.Blob = $asSREXResult[0]
		$asSREXResult = StringRegExp($sProfile, "<Type" & "[^>]{0,}>([^<]{0,})<", 3)
		If @error Then $asSREXResult = StringRegExp($sProfile, "<[^/]{0,}:Type" & "[^>]{0,}>([^<]{0,})<", 3)
		If Not @error Then
			.EAP.BaseType = $asSREXResult[0]
			For $i = 1 To UBound($asSREXResult) - 1
				.EAP.Type = .EAP.Type & $asSREXResult[$i]
			Next
		EndIf
		If .EAP.BaseType = "25" Then
			$asProfileSnippet = StringRegExp($sProfile, "<Eap [^>]{0,}>([[:print:][:space:]]{1,})<Eap [^>]{0,}>([[:print:][:space:]]{1,})</Eap>([[:print:][:space:]]{1,})</Eap>", 3)
			If @error Then $asProfileSnippet = StringRegExp($sProfile, "<[^/]{0,}:Eap>([[:print:][:space:]]{1,})<[^/]{0,}:Eap>([[:print:][:space:]]{1,})</[^:]{0,}:Eap>([[:print:][:space:]]{1,})</[^:]{0,}:Eap>", 1)
			If Not @error Then
				$asProfileSnippet[0] &= $asProfileSnippet[2]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<FastReconnect" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:FastReconnect" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.FastReconnect = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<EnableQuarantineChecks" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:EnableQuarantineChecks" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.QuarantineChecks = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<RequireCryptoBinding" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:RequireCryptoBinding" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.RequireCryptoBinding = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<EnableIdentityPrivacy" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:EnableIdentityPrivacy" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.EnableIdentityPrivacy = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<AnonymousUserName" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:AnonymousUserName" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.AnonUsername = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<DisableUserPromptForServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:DisableUserPromptForServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.ServerValidation.NoUserPrompt = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<ServerNames" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:ServerNames" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.ServerValidation.ServerNames = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<TrustedRootCA" & "[^>]{0,}>([^<]{0,})<", 3)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:TrustedRootCA" & "[^>]{0,}>([^<]{0,})<", 3)
				If Not @error Then
					For $i = 0 To UBound($asSREXResult) - 1
						.EAP.PEAP.ServerValidation.ThumbPrints.Add = $asSREXResult[$i]
					Next
				EndIf
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<PerformServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:PerformServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.ServerValidation.Enabled = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<AcceptServerName" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:AcceptServerName" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.ServerValidation.AcceptServerNames = $asSREXResult[0]

				If StringInStr($asProfileSnippet[1], "CertificateStore", 1) Then .EAP.PEAP.TLS.Source = "Certificate Store"
				If StringInStr($asProfileSnippet[1], "SmartCard", 1) Then .EAP.PEAP.TLS.Source = "Smart Card"
				$asSREXResult = StringRegExp($asProfileSnippet[1], "<SimpleCertSelection" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:SimpleCertSelection" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.TLS.SimpleCertSel = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[1], "<DifferentUsername" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:DifferentUsername" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.TLS.DiffUsername = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[1], "<DisableUserPromptForServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:DisableUserPromptForServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.TLS.ServerValidation.NoUserPrompt = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[1], "<ServerNames" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:ServerNames" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.TLS.ServerValidation.ServerNames = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[1], "<TrustedRootCA" & "[^>]{0,}>([^<]{0,})<", 3)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:TrustedRootCA" & "[^>]{0,}>([^<]{0,})<", 3)
				If Not @error Then
					For $i = 0 To UBound($asSREXResult) - 1
						.EAP.PEAP.TLS.ServerValidation.ThumbPrints.Add = $asSREXResult[$i]
					Next
				EndIf
				$asSREXResult = StringRegExp($asProfileSnippet[1], "<PerformServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:PerformServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.TLS.ServerValidation.Enabled = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[1], "<AcceptServerName" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:AcceptServerName" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.TLS.ServerValidation.AcceptServerNames = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[1], "<UseWinLogonCredentials" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:UseWinLogonCredentials" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.PEAP.MSCHAP.UseWinLogonCreds = $asSREXResult[0]
			EndIf
		EndIf
		If .EAP.BaseType = "13" Then
			$asProfileSnippet = StringRegExp($sProfile, "<Eap [^>]{0,}>([[:print:][:space:]]{1,})</Eap>", 1)
			If @error Then $asProfileSnippet = StringRegExp($sProfile, "<[^/]{0,}:Eap>([[:print:][:space:]]{1,})</[^:]{0,}:Eap>", 1)
			If Not @error Then
				If StringInStr($asProfileSnippet[0], "CertificateStore", 1) Then .EAP.TLS.Source = "Certificate Store"
				If StringInStr($asProfileSnippet[0], "SmartCard", 1) Then .EAP.TLS.Source = "Smart Card"
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<SimpleCertSelection" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:SimpleCertSelection" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.TLS.SimpleCertSel = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<DifferentUsername" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:DifferentUsername" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.TLS.DiffUsername = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<DisableUserPromptForServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:DisableUserPromptForServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.TLS.ServerValidation.NoUserPrompt = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<ServerNames" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:ServerNames" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.TLS.ServerValidation.ServerNames = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<TrustedRootCA" & "[^>]{0,}>([^<]{0,})<", 3)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:TrustedRootCA" & "[^>]{0,}>([^<]{0,})<", 3)
				If Not @error Then
					For $i = 0 To UBound($asSREXResult) - 1
						.EAP.TLS.ServerValidation.ThumbPrints.Add = $asSREXResult[$i]
					Next
				EndIf
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<PerformServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:PerformServerValidation" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.TLS.ServerValidation.Enabled = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<AcceptServerName" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:AcceptServerName" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .EAP.TLS.ServerValidation.AcceptServerNames = $asSREXResult[0]
			EndIf
		EndIf

		If .Type = "ESS" Then .Type = "Infrastructure"
		If .Type = "IBSS" Then .Type = "Ad Hoc"
		If .Auth = "open" Then .Auth = "Open"
		If .Auth = "shared" Then .Auth  = "Shared Key"
		If .Auth = "WPAPSK" Then .Auth = "WPA-PSK"
		If .Auth = "WPA2PSK" Then .Auth = "WPA2-PSK"
		If .Encr = "none" Then .Encr = "Unencrypted"
		If .Key.Protected == "true" Then .Key.Protected = True
		If .Key.Protected == "false" Then .Key.Protected = False
		If .Key.Type = "networkKey" Then .Key.Type = "Network Key"
		If .Key.Type = "passPhrase" Then .Key.Type = "Pass Phrase"
		If .Key.Index <> "" Then .Key.Index = Number(.Key.Index) + 1
		If .Options.NonBroadcast == "true" Then .Options.NonBroadcast = True
		If .Options.NonBroadcast == "false" Then .Options.NonBroadcast = False
		If .Options.ConnMode = "auto" Then .Options.ConnMode = "Automatic"
		If .Options.ConnMode = "manual" Then .Options.ConnMode = "Manual"
		If .Options.Autoswitch == "true" Then .Options.Autoswitch = True
		If .Options.Autoswitch == "false" Then .Options.Autoswitch = False
		If .OneX.Enabled == "true" Then .OneX.Enabled = True
		If .OneX.Enabled == "false" Then .OneX.Enabled = False
		If .OneX.AuthMode = "machineOrUser" Then .OneX.AuthMode = "Machine Or User"
		If .OneX.AuthMode = "machine" Then .OneX.AuthMode = "Machine"
		If .OneX.AuthMode = "user" Then .OneX.AuthMode = "User"
		If .OneX.AuthMode = "guest" Then .OneX.AuthMode = "Guest"
		If .OneX.AuthPeriod <> "" Then .OneX.AuthPeriod = Number(.OneX.AuthPeriod)
		If .OneX.CacheUserData == "true" Then .OneX.CacheUserData = True
		If .OneX.CacheUserData == "false" Then .OneX.CacheUserData = False
		If .OneX.HeldPeriod <> "" Then .OneX.HeldPeriod = Number(.OneX.HeldPeriod)
		If .OneX.MaxAuthFailures <> "" Then .OneX.MaxAuthFailures = Number(.OneX.MaxAuthFailures)
		If .OneX.MaxStart <> "" Then .OneX.MaxStart = Number(.OneX.MaxStart)
		If .OneX.StartPeriod <> "" Then .OneX.StartPeriod = Number(.OneX.StartPeriod)
		If .OneX.SuppMode = "inhibitTransmission" Then .OneX.SuppMode = "Inhibit Transmission"
		If .OneX.SuppMode = "includeLearning" Then .OneX.SuppMode = "Include Learning"
		If .OneX.SuppMode = "compliant" Then .OneX.SuppMode = "Compliant"
		If .OneX.SSO.Type = "preLogon" Then .OneX.SSO.Type = "Pre Logon"
		If .OneX.SSO.Type = "postLogon" Then .OneX.SSO.Type = "Post Logon"
		If .OneX.SSO.MaxDelay <> "" Then .OneX.SSO.MaxDelay = Number(.OneX.SSO.MaxDelay)
		If .OneX.SSO.UserBasedVLAN == "true" Then .OneX.SSO.UserBasedVLAN = True
		If .OneX.SSO.UserBasedVLAN == "false" Then .OneX.SSO.UserBasedVLAN = False
		If .OneX.SSO.AllowMoreDialogs == "true" Then .OneX.SSO.AllowMoreDialogs = True
		If .OneX.SSO.AllowMoreDialogs == "false" Then .OneX.SSO.AllowMoreDialogs = False
		If .PMK.CacheEnabled == "enabled" Then .PMK.CacheEnabled = True
		If .PMK.CacheEnabled == "disabled" Then .PMK.CacheEnabled = False
		If .PMK.CacheTTL <> "" Then .PMK.CacheTTL = Number(.PMK.CacheTTL)
		If .PMK.CacheSize <> "" Then .PMK.CacheSize = Number(.PMK.CacheSize)
		If .PMK.PreAuthEnabled == "enabled" Then .PMK.PreAuthEnabled = True
		If .PMK.PreAuthEnabled == "disabled" Then .PMK.PreAuthEnabled = False
		If .PMK.PreAuthThrottle <> "" Then .PMK.PreAuthThrottle = Number(.PMK.PreAuthThrottle)
		If .FIPS.Enabled == "true" Then .FIPS.Enabled = True
		If .FIPS.Enabled == "false" Then .FIPS.Enabled = False
		If .EAP.Blob <> "" Then .EAP.Blob = Binary("0x" & .EAP.Blob)
		If .EAP.BaseType = "13" Then .EAP.BaseType = "TLS"
		If .EAP.BaseType = "25" Then .EAP.BaseType = "PEAP"
		If .EAP.Type = "13" Then .EAP.Type = "TLS"
		If .EAP.Type = "2513" Then .EAP.Type = "PEAP-TLS"
		If .EAP.Type = "2526" Then .EAP.Type = "PEAP-MSCHAP"
		If .EAP.PEAP.FastReconnect == "true" Then .EAP.PEAP.FastReconnect = True
		If .EAP.PEAP.FastReconnect == "false" Then .EAP.PEAP.FastReconnect = False
		If .EAP.PEAP.QuarantineChecks == "true" Then .EAP.PEAP.QuarantineChecks = True
		If .EAP.PEAP.QuarantineChecks == "false" Then .EAP.PEAP.QuarantineChecks = False
		If .EAP.PEAP.RequireCryptoBinding == "true" Then .EAP.PEAP.RequireCryptoBinding = True
		If .EAP.PEAP.RequireCryptoBinding == "false" Then .EAP.PEAP.RequireCryptoBinding = False
		If .EAP.PEAP.EnableIdentityPrivacy == "true" Then .EAP.PEAP.EnableIdentityPrivacy = True
		If .EAP.PEAP.EnableIdentityPrivacy == "false" Then .EAP.PEAP.EnableIdentityPrivacy = False
		If .EAP.PEAP.ServerValidation.NoUserPrompt == "true" Then .EAP.PEAP.ServerValidation.NoUserPrompt = True
		If .EAP.PEAP.ServerValidation.NoUserPrompt == "false" Then .EAP.PEAP.ServerValidation.NoUserPrompt = False
		If .EAP.PEAP.ServerValidation.Enabled == "true" Then .EAP.PEAP.ServerValidation.Enabled = True
		If .EAP.PEAP.ServerValidation.Enabled == "false" Then .EAP.PEAP.ServerValidation.Enabled = False
		If .EAP.PEAP.ServerValidation.AcceptServerNames == "true" Then .EAP.PEAP.ServerValidation.AcceptServerNames = True
		If .EAP.PEAP.ServerValidation.AcceptServerNames == "false" Then .EAP.PEAP.ServerValidation.AcceptServerNames = False
		If .EAP.PEAP.TLS.SimpleCertSel == "true" Then .EAP.PEAP.TLS.SimpleCertSel = True
		If .EAP.PEAP.TLS.SimpleCertSel == "false" Then .EAP.PEAP.TLS.SimpleCertSel = False
		If .EAP.PEAP.TLS.DiffUsername == "true" Then .EAP.PEAP.TLS.DiffUsername = True
		If .EAP.PEAP.TLS.DiffUsername == "false" Then .EAP.PEAP.TLS.DiffUsername = False
		If .EAP.PEAP.TLS.ServerValidation.NoUserPrompt == "true" Then .EAP.PEAP.TLS.ServerValidation.NoUserPrompt = True
		If .EAP.PEAP.TLS.ServerValidation.NoUserPrompt == "false" Then .EAP.PEAP.TLS.ServerValidation.NoUserPrompt = False
		If .EAP.PEAP.TLS.ServerValidation.Enabled == "true" Then .EAP.PEAP.TLS.ServerValidation.Enabled = True
		If .EAP.PEAP.TLS.ServerValidation.Enabled == "false" Then .EAP.PEAP.TLS.ServerValidation.Enabled = False
		If .EAP.PEAP.TLS.ServerValidation.AcceptServerNames == "true" Then .EAP.PEAP.TLS.ServerValidation.AcceptServerNames = True
		If .EAP.PEAP.TLS.ServerValidation.AcceptServerNames == "false" Then .EAP.PEAP.TLS.ServerValidation.AcceptServerNames = False
		If .EAP.PEAP.MSCHAP.UseWinLogonCreds == "true" Then .EAP.PEAP.MSCHAP.UseWinLogonCreds = True
		If .EAP.PEAP.MSCHAP.UseWinLogonCreds == "false" Then .EAP.PEAP.MSCHAP.UseWinLogonCreds = False
		If .EAP.TLS.SimpleCertSel == "true" Then .EAP.TLS.SimpleCertSel = True
		If .EAP.TLS.SimpleCertSel == "false" Then .EAP.TLS.SimpleCertSel = False
		If .EAP.TLS.DiffUsername == "true" Then .EAP.TLS.DiffUsername = True
		If .EAP.TLS.DiffUsername == "false" Then .EAP.TLS.DiffUsername = False
		If .EAP.TLS.ServerValidation.NoUserPrompt == "true" Then .EAP.TLS.ServerValidation.NoUserPrompt = True
		If .EAP.TLS.ServerValidation.NoUserPrompt == "false" Then .EAP.TLS.ServerValidation.NoUserPrompt = False
		If .EAP.TLS.ServerValidation.Enabled == "true" Then .EAP.TLS.ServerValidation.Enabled = True
		If .EAP.TLS.ServerValidation.Enabled == "false" Then .EAP.TLS.ServerValidation.Enabled = False
		If .EAP.TLS.ServerValidation.AcceptServerNames == "true" Then .EAP.TLS.ServerValidation.AcceptServerNames = True
		If .EAP.TLS.ServerValidation.AcceptServerNames == "false" Then .EAP.TLS.ServerValidation.AcceptServerNames = False
	EndWith

	Return $oProfile
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _Wlan_GenerateUserDataObject
; Description ...: Generates XML EAP user data from a user data object.
; Syntax.........: _Wlan_GenerateUserDataObject($sUserData)
; Parameters ....: $sUserData - A string containing the XML user data
; Return values .: Success - A user data object
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |6 - A dependency is missing. (@extended - _AutoItObject_Create error code.)
; Author ........: MattyD
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_GenerateUserDataObject($sUserData)
	Local $oUserData, $asSREXResult, $asProfileSnippet

	$oUserData = _Wlan_CreateUserDataObject()
	If @error Then Return SetError(@error, @extended, False)

	With $oUserData
		$asSREXResult = StringRegExp($sUserData, "<Type" & "[^>]{0,}>([^<]{0,})<", 3)
		If @error Then $asSREXResult = StringRegExp($sUserData, "<[^/]{0,}:Type" & "[^>]{0,}>([^<]{0,})<", 3)
		If Not @error Then
			.BaseType = $asSREXResult[0]
			For $i = 1 To UBound($asSREXResult) - 1
				.Type = .Type & $asSREXResult[$i]
			Next
		EndIf
		$asSREXResult = StringRegExp($sUserData, "<CredentialsBlob" & "[^>]{0,}>([^<]{0,})<", 1)
		If Not @error Then $oUserData.Blob = $asSREXResult[0]

		If .BaseType = "25" Then
			$asProfileSnippet = StringRegExp($sUserData, "<Eap [^>]{0,}>([[:print:][:space:]]{1,})<Eap [^>]{0,}>([[:print:][:space:]]{1,})</Eap>([[:print:][:space:]]{1,})</Eap>", 3)
			If @error Then $asProfileSnippet = StringRegExp($sUserData, "<[^/]{0,}:Eap>([[:print:][:space:]]{1,})<[^/]{0,}:Eap>([[:print:][:space:]]{1,})</[^:]{0,}:Eap>([[:print:][:space:]]{1,})</[^:]{0,}:Eap>", 1)
			If Not @error Then
				$asProfileSnippet[0] &= $asProfileSnippet[2]
				$asSREXResult = StringRegExp($asProfileSnippet[0], "<RoutingIdentity" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[0], "<[^/]{0,}:RoutingIdentity" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .PEAP.Username = $asSREXResult[0]
				If .Type = "2513" Then
					$asSREXResult = StringRegExp($asProfileSnippet[1], "<Username" & "[^>]{0,}>([^<]{0,})<", 1)
					If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:Username" & "[^>]{0,}>([^<]{0,})<", 1)
					If Not @error Then .PEAP.TLS.Username = $asSREXResult[0]
					$asSREXResult = StringRegExp($asProfileSnippet[1], "<UserCert" & "[^>]{0,}>([^<]{0,})<", 1)
					If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:UserCert" & "[^>]{0,}>([^<]{0,})<", 1)
					If Not @error Then .PEAP.TLS.Cert = $asSREXResult[0]
				ElseIf .Type = "2526" Then
					$asSREXResult = StringRegExp($asProfileSnippet[1], "<Username" & "[^>]{0,}>([^<]{0,})<", 1)
					If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:Username" & "[^>]{0,}>([^<]{0,})<", 1)
					If Not @error Then .PEAP.MSCHAP.Username = $asSREXResult[0]
					$asSREXResult = StringRegExp($asProfileSnippet[1], "<Password" & "[^>]{0,}>([^<]{0,})<", 1)
					If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:Password" & "[^>]{0,}>([^<]{0,})<", 1)
					If Not @error Then .PEAP.MSCHAP.Password = $asSREXResult[0]
					$asSREXResult = StringRegExp($asProfileSnippet[1], "<LogonDomain" & "[^>]{0,}>([^<]{0,})<", 1)
					If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:LogonDomain" & "[^>]{0,}>([^<]{0,})<", 1)
					If Not @error Then .PEAP.MSCHAP.Domain = $asSREXResult[0]
				EndIf
			EndIf
		EndIf
		If .BaseType = "13" Then
			$asProfileSnippet = StringRegExp($sUserData, "<Eap [^>]{0,}>([[:print:][:space:]]{1,})</Eap>", 1)
			If @error Then $asProfileSnippet = StringRegExp($sUserData, "<[^/]{0,}:Eap>([[:print:][:space:]]{1,})</[^:]{0,}:Eap>", 1)
			If Not @error Then
				$asSREXResult = StringRegExp($asProfileSnippet[1], "<Username" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:Username" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .TLS.Username = $asSREXResult[0]
				$asSREXResult = StringRegExp($asProfileSnippet[1], "<UserCert" & "[^>]{0,}>([^<]{0,})<", 1)
				If @error Then $asSREXResult = StringRegExp($asProfileSnippet[1], "<[^/]{0,}:UserCert" & "[^>]{0,}>([^<]{0,})<", 1)
				If Not @error Then .TLS.Cert = $asSREXResult[0]
			EndIf
		EndIf

		If .BaseType = "13" Then .BaseType = "TLS"
		If .BaseType = "25" Then .BaseType = "PEAP"
		If .Type = "13" Then .Type = "TLS"
		If .Type = "2513" Then .Type = "PEAP-TLS"
		If .Type = "2526" Then .Type = "PEAP-MSCHAP"
		If .Blob <> "" Then .Blob = Binary("0x" & .Blob)
		If StringInStr(.TLS.UserName, "\") Then $asSREXResult = StringSplit(.TLS.UserName, "\", 2)
		If Not @error Then
			.TLS.Domain = $asSREXResult[0]
			.TLS.UserName = $asSREXResult[1]
		EndIf
		If StringInStr(.PEAP.TLS.UserName, "\") Then $asSREXResult = StringSplit(.PEAP.TLS.UserName, "\", 2)
		If Not @error Then
			.PEAP.TLS.Domain = $asSREXResult[0]
			.PEAP.TLS.UserName = $asSREXResult[1]
		EndIf
	EndWith

	Return $oUserData
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _Wlan_GenerateXMLProfile
; Description ...: Generates an XML profile from a profile object.
; Syntax.........: _Wlan_GenerateXMLProfile($oProfile)
; Parameters ....: $oProfile - A profile object
; Return values .: Success - A string containing the XML profile
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |4 - Invalid parameter.
; Author ........: MattyD
; Modified.......:
; Remarks .......:
; Related .......: _Wlan_GenerateProfileObject _Wlan_ConvertProfile
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_GenerateXMLProfile($oProfile)
	If Not IsObj($oProfile) Then Return SetError(4, 0, False)

	Local Const $sEL_BASE_START = 'WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1"+|name|SSIDConfig+|SSID+|name|-|nonBroadcast|-|' & _
			'connectionType|connectionMode|autoSwitch|MSM+|connectivity+|phyType|-|security+|authEncryption+|authentication|encryption|useOneX|' & _
			'FIPSMode xmlns="http://www.microsoft.com/networking/WLAN/profile/v2"|-|sharedKey+|keyType|protected|keyMaterial|-|keyIndex|PMKCacheMode|PMKCacheTTL|' & _
			'PMKCacheSize|preAuthMode|PreAuthThrottle|'
	Local Const $sEL_ONEX_START = 'OneX xmlns="http://www.microsoft.com/networking/OneX/v1"+|cacheUserData|heldPeriod|authPeriod|startPeriod|maxStart|' & _
			'maxAuthFailures|supplicantMode|authMode|singleSignOn+|type|maxDelay|allowAdditionalDialogs|userBasedVirtualLan|-|EAPConfig+|' & _
			'EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig"' & @CRLF & 'xmlns:eapCommon="http://www.microsoft.com/provisioning/EapCommon"+|' & _
			'EapMethod+|eapCommon:Type|eapCommon:AuthorId|-|Config ' & _
			'xmlns:baseEap="http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1"' & @CRLF & _
			'xmlns:msPeap="http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV1"' & @CRLF & _
			'xmlns:eapTls="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV1"' & @CRLF & _
			'xmlns:msChapV2="http://www.microsoft.com/provisioning/MsChapV2ConnectionPropertiesV1"' & @CRLF & _
			'xmlns:msPeapV2="http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2"' & @CRLF & _
			'xmlns:eapTlsV2="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2"+|'
	Local Const $sEL_PEAP_START = 'baseEap:Eap+|baseEap:Type|msPeap:EapType+|msPeap:ServerValidation+|msPeap:DisableUserPromptForServerValidation|' & _
			'msPeap:ServerNames|msPeap:TrustedRootCA|-|msPeap:FastReconnect|msPeap:InnerEapOptional|'
	Local Const $sEL_TLS = 'baseEap:Eap+|baseEap:Type|eapTls:EapType+|eapTls:CredentialsSource+|eapTls:SmartCard|eapTls:CertificateStore+|' & _
			'eapTls:SimpleCertSelection|-|-|eapTls:ServerValidation+|eapTls:DisableUserPromptForServerValidation|eapTls:ServerNames|eapTls:TrustedRootCA|' & _
			'-|eapTls:DifferentUsername|eapTlsV2:PerformServerValidation|eapTlsV2:AcceptServerName|-|-|'
	Local Const $sEL_MSCHAP = 'baseEap:Eap+|baseEap:Type|msChapV2:EapType+|msChapV2:UseWinLogonCredentials|-|-|'
	Local Const $sEL_PEAP_END = 'msPeap:EnableQuarantineChecks|msPeap:RequireCryptoBinding|msPeap:PeapExtensions+|msPeapV2:PerformServerValidation|msPeapV2:AcceptServerName|' & _
			'msPeapV2:IdentityPrivacy+|msPeapV2:EnableIdentityPrivacy|msPeapV2:AnonymousUserName|-|-|-|-|'
	Local Const $sEL_ONEX_END = '-|ConfigBlob|-|-|-|'
	Local Const $sEL_BASE_END = '-|-|-'

	Local $sEl_Start = $sEL_BASE_START
	Local $sEl_End = $sEL_BASE_END
	Local $sProfile = '<?xml version="1.0"?>' & @CRLF, $avStack[1] = [-1], $asElements

	With $oProfile
		If .Type = "Infrastructure" Then .Type = "ESS"
		If .Type = "Ad Hoc" Then .Type = "IBSS"
		.Auth = StringReplace(StringUpper(.Auth), "-", "")
		If .Auth = "OPEN" Then .Auth = "open"
		If .Auth = "SHARED KEY" Then .Auth  = "shared"
		.Encr = StringUpper(.Encr)
		If .Encr = "UNENCRYPTED" Then .Encr = "none"
		If .Key.Protected == True Then .Key.Protected = "true"
		If .Key.Protected == False Then .Key.Protected = "false"
		If .Key.Type = "Network Key" Then .Key.Type = "networkKey"
		If .Key.Type = "Pass Phrase" Then .Key.Type = "passPhrase"
		If .Key.Index <> "" Then .Key.Index = String(Number(.Key.Index) - 1)
		If .Key.Index = "0" Then .Key.Index = ""
		If .Options.NonBroadcast == True Then .Options.NonBroadcast = "true"
		If .Options.NonBroadcast == False Then .Options.NonBroadcast = "false"
		If .Options.ConnMode = "Automatic" Then .Options.ConnMode = "auto"
		If .Options.ConnMode = "Manual" Then .Options.ConnMode = "manual"
		If .Options.Autoswitch == True Then .Options.Autoswitch = "true"
		If .Options.Autoswitch == False Then .Options.Autoswitch = "false"
		If .OneX.Enabled == True Then .OneX.Enabled = "true"
		If .OneX.Enabled == False Then .OneX.Enabled = "false"
		.OneX.AuthMode = StringLower(.OneX.AuthMode)
		If .OneX.AuthMode = "machine or user" Then .OneX.AuthMode = "machineOrUser"
		If .OneX.AuthPeriod <> "" Then .OneX.AuthPeriod = String(Number(.OneX.AuthPeriod))
		If .OneX.CacheUserData == True Then .OneX.CacheUserData = "true"
		If .OneX.CacheUserData == False Then .OneX.CacheUserData = "false"
		If .OneX.HeldPeriod <> "" Then .OneX.HeldPeriod = String(Number(.OneX.HeldPeriod))
		If .OneX.MaxAuthFailures <> "" Then .OneX.MaxAuthFailures = String(Number(.OneX.MaxAuthFailures))
		If .OneX.MaxStart <> "" Then .OneX.MaxStart = String(Number(.OneX.MaxStart))
		If .OneX.StartPeriod <> "" Then .OneX.StartPeriod = String(Number(.OneX.StartPeriod))
		If .OneX.SuppMode = "Inhibit Transmission" Then .OneX.SuppMode = "inhibitTransmission"
		If .OneX.SuppMode = "Include Learning" Then .OneX.SuppMode = "includeLearning"
		If .OneX.SuppMode = "Compliant" Then .OneX.SuppMode = "compliant"
		If .OneX.SSO.Type = "Pre Logon" Then .OneX.SSO.Type = "preLogon"
		If .OneX.SSO.Type = "Post Logon" Then .OneX.SSO.Type = "postLogon"
		If .OneX.SSO.MaxDelay <> "" Then .OneX.SSO.MaxDelay = String(Number(.OneX.SSO.MaxDelay))
		If .OneX.SSO.UserBasedVLAN == True Then .OneX.SSO.UserBasedVLAN = "true"
		If .OneX.SSO.UserBasedVLAN == False Then .OneX.SSO.UserBasedVLAN = "false"
		If .OneX.SSO.AllowMoreDialogs == True Then .OneX.SSO.AllowMoreDialogs = "true"
		If .OneX.SSO.AllowMoreDialogs == False Then .OneX.SSO.AllowMoreDialogs = "false"
		If .PMK.CacheEnabled == True Then .PMK.CacheEnabled = "enabled"
		If .PMK.CacheEnabled == False Then .PMK.CacheEnabled = "disabled"
		If .PMK.CacheTTL <> "" Then .PMK.CacheTTL = String(Number(.PMK.CacheTTL))
		If .PMK.CacheSize <> "" Then .PMK.CacheSize = String(Number(.PMK.CacheSize))
		If .PMK.PreAuthEnabled == True Then .PMK.PreAuthEnabled = "enabled"
		If .PMK.PreAuthEnabled == False Then .PMK.PreAuthEnabled = "disabled"
		If .PMK.PreAuthThrottle <> "" Then .PMK.PreAuthThrottle = String(Number(.PMK.PreAuthThrottle))
		If .FIPS.Enabled == True Then .FIPS.Enabled = "true"
		If .FIPS.Enabled == False Then .FIPS.Enabled = "false"
		If .EAP.Blob <> "" Then .EAP.Blob = StringReplace(String(.EAP.Blob), "0x", "")
		If .EAP.BaseType = "TLS" Then .EAP.BaseType = "13"
		If .EAP.BaseType = "PEAP" Then .EAP.BaseType = "25"
		If .EAP.Type = "TLS" Then .EAP.Type = "13"
		If .EAP.Type = "PEAP-TLS" Then .EAP.Type = "2513"
		If .EAP.Type = "PEAP-MSCHAP" Then .EAP.Type = "2526"
		If .EAP.PEAP.FastReconnect == True Then .EAP.PEAP.FastReconnect = "true"
		If .EAP.PEAP.FastReconnect == False Then .EAP.PEAP.FastReconnect = "false"
		If .EAP.PEAP.QuarantineChecks == True Then .EAP.PEAP.QuarantineChecks = "true"
		If .EAP.PEAP.QuarantineChecks == False Then .EAP.PEAP.QuarantineChecks = "false"
		If .EAP.PEAP.RequireCryptoBinding == True Then .EAP.PEAP.RequireCryptoBinding = "true"
		If .EAP.PEAP.RequireCryptoBinding == False Then .EAP.PEAP.RequireCryptoBinding = "false"
		If .EAP.PEAP.EnableIdentityPrivacy == True Then .EAP.PEAP.EnableIdentityPrivacy = "true"
		If .EAP.PEAP.EnableIdentityPrivacy == False Then .EAP.PEAP.EnableIdentityPrivacy = "false"
		If .EAP.PEAP.ServerValidation.NoUserPrompt == True Then .EAP.PEAP.ServerValidation.NoUserPrompt = "true"
		If .EAP.PEAP.ServerValidation.NoUserPrompt == False Then .EAP.PEAP.ServerValidation.NoUserPrompt = "false"
		If .EAP.PEAP.ServerValidation.Enabled == True Then .EAP.PEAP.ServerValidation.Enabled = "true"
		If .EAP.PEAP.ServerValidation.Enabled == False Then .EAP.PEAP.ServerValidation.Enabled = "false"
		If .EAP.PEAP.ServerValidation.AcceptServerNames == True Then .EAP.PEAP.ServerValidation.AcceptServerNames = "true"
		If .EAP.PEAP.ServerValidation.AcceptServerNames == False Then .EAP.PEAP.ServerValidation.AcceptServerNames = "false"
		If .EAP.PEAP.TLS.SimpleCertSel == True Then .EAP.PEAP.TLS.SimpleCertSel = "true"
		If .EAP.PEAP.TLS.SimpleCertSel == False Then .EAP.PEAP.TLS.SimpleCertSel = "false"
		If .EAP.PEAP.TLS.DiffUsername == True Then .EAP.PEAP.TLS.DiffUsername = "true"
		If .EAP.PEAP.TLS.DiffUsername == False Then .EAP.PEAP.TLS.DiffUsername = "false"
		If .EAP.PEAP.TLS.ServerValidation.NoUserPrompt == True Then .EAP.PEAP.TLS.ServerValidation.NoUserPrompt = "true"
		If .EAP.PEAP.TLS.ServerValidation.NoUserPrompt == False Then .EAP.PEAP.TLS.ServerValidation.NoUserPrompt = "false"
		If .EAP.PEAP.TLS.ServerValidation.Enabled == True Then .EAP.PEAP.TLS.ServerValidation.Enabled = "true"
		If .EAP.PEAP.TLS.ServerValidation.Enabled == False Then .EAP.PEAP.TLS.ServerValidation.Enabled = "false"
		If .EAP.PEAP.TLS.ServerValidation.AcceptServerNames == True Then .EAP.PEAP.TLS.ServerValidation.AcceptServerNames = "true"
		If .EAP.PEAP.TLS.ServerValidation.AcceptServerNames == False Then .EAP.PEAP.TLS.ServerValidation.AcceptServerNames = "false"
		If .EAP.PEAP.MSCHAP.UseWinLogonCreds == True Then .EAP.PEAP.MSCHAP.UseWinLogonCreds = "true"
		If .EAP.PEAP.MSCHAP.UseWinLogonCreds == False Then .EAP.PEAP.MSCHAP.UseWinLogonCreds = "false"
		If .EAP.TLS.SimpleCertSel == True Then .EAP.TLS.SimpleCertSel = "true"
		If .EAP.TLS.SimpleCertSel == False Then .EAP.TLS.SimpleCertSel = "false"
		If .EAP.TLS.DiffUsername == True Then .EAP.TLS.DiffUsername = "true"
		If .EAP.TLS.DiffUsername == False Then .EAP.TLS.DiffUsername = "false"
		If .EAP.TLS.ServerValidation.NoUserPrompt == True Then .EAP.TLS.ServerValidation.NoUserPrompt = "true"
		If .EAP.TLS.ServerValidation.NoUserPrompt == False Then .EAP.TLS.ServerValidation.NoUserPrompt = "false"
		If .EAP.TLS.ServerValidation.Enabled == True Then .EAP.TLS.ServerValidation.Enabled = "true"
		If .EAP.TLS.ServerValidation.Enabled == False Then .EAP.TLS.ServerValidation.Enabled = "false"
		If .EAP.TLS.ServerValidation.AcceptServerNames == True Then .EAP.TLS.ServerValidation.AcceptServerNames = "true"
		If .EAP.TLS.ServerValidation.AcceptServerNames == False Then .EAP.TLS.ServerValidation.AcceptServerNames = "false"
	EndWith


	If $oProfile.OneX.Enabled = "true" Then
		$sEl_Start &= $sEL_ONEX_START
		$sEl_End = $sEL_ONEX_END & $sEl_End
	EndIf

	If StringInStr($oProfile.EAP.Type, "25") Then
		$sEl_Start &= $sEL_PEAP_START
		$sEl_End = $sEL_PEAP_END & $sEl_End
	EndIf

	If StringInStr($oProfile.EAP.Type, "13") Then $sEl_Start &= $sEL_TLS
	If StringInStr($oProfile.EAP.Type, "26") Then $sEl_Start &= $sEL_MSCHAP

	$asElements = StringSplit($sEl_Start & $sEl_End, "|")
	For $i = 1 To UBound($asElements) - 1
		If StringInStr($asElements[$i], @CRLF) Then
			For $j = 0 To $avStack[0]
				$asElements[$i] = StringReplace($asElements[$i], @CRLF, @CRLF & @TAB)
			Next
		EndIf
		If StringInStr($asElements[$i], "+") Then
			$sProfile &= "<" & StringReplace($asElements[$i], "+", "") & ">" & @CRLF
			Redim $avStack[Ubound($avStack) + 1]
			$avStack[Ubound($avStack) - 1] = StringReplace($asElements[$i], "+", "")
			$avStack[0] += 1
		ElseIf $asElements[$i] == "-" Then
			$sProfile &= "</" & StringRegExpReplace($avStack[Ubound($avStack) - 1], " [^>]{0,}", "") & ">" & @CRLF
			Redim $avStack[Ubound($avStack) - 1]
		Else
			$sProfile &= "<" & $asElements[$i] & "></" & StringRegExpReplace($asElements[$i], " [^>]{0,}", "") & ">" & @CRLF
		EndIf
		If $i < UBound($asElements) - 1 And $asElements[$i + 1] == "-" Then $avStack[0] -= 1
		For $j = 0 To $avStack[0]
			$sProfile &= "	"
		Next
	Next

	$sProfile = StringReplace($sProfile, "<name>", "<name>" & $oProfile.Name, 1)
	For $sSSID In $oProfile.SSID
		$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<SSID>[^<]{0,}<name><[^<]{0,}</SSID>\r", "\0\0", 1)
		$sProfile = StringReplace($sProfile, "<name><", "<name>" & $sSSID & "<", 1)
	Next
	$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<SSID>[^<]{0,}<name><[^<]{0,}</SSID>\r", "", 1)
	$sProfile = StringReplace($sProfile, "<connectionType>", "<connectionType>" & $oProfile.Type, 1)
	$sProfile = StringReplace($sProfile, "<authentication>", "<authentication>" & $oProfile.Auth, 1)
	$sProfile = StringReplace($sProfile, "<encryption>", "<encryption>" & $oProfile.Encr, 1)
	If Not $oProfile.Key.Material Then $sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<sharedKey>[[:print:][:space:]]{0,}</keyIndex>\r", "", 1)
	$sProfile = StringReplace($sProfile, "<protected>", "<protected>" & $oProfile.Key.Protected, 1)
	$sProfile = StringReplace($sProfile, "<keyType>", "<keyType>" & $oProfile.Key.Type, 1)
	$sProfile = StringReplace($sProfile, "<keyMaterial>", "<keyMaterial>" & $oProfile.Key.Material, 1)
	$sProfile = StringReplace($sProfile, "<keyIndex>", "<keyIndex>" & $oProfile.Key.Index, 1)
	$sProfile = StringReplace($sProfile, "<nonBroadcast>", "<nonBroadcast>" & $oProfile.Options.NonBroadcast, 1)
	$sProfile = StringReplace($sProfile, "<connectionMode>", "<connectionMode>" & $oProfile.Options.ConnMode, 1)
	$sProfile = StringReplace($sProfile, "<autoSwitch>", "<autoSwitch>" & $oProfile.Options.Autoswitch, 1)
	For $sPhyType In $oProfile.Options.PhyTypes
		$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<phyType><[^\r]{0,}\r", "\0\0", 1)
		$sProfile = StringReplace($sProfile, "<phyType><", "<phyType>" & $sPhyType & "<", 1)
	Next
	If Not $oProfile.Options.PhyTypes.Count Then $sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<connectivity>[[:print:][:space:]]{0,}</connectivity>\r", "", 1)
	$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<phyType><[^\r]{0,}\r", "", 1)
	$sProfile = StringReplace($sProfile, "<useOneX>", "<useOneX>" & $oProfile.OneX.Enabled, 1)
	$sProfile = StringReplace($sProfile, "<authMode>", "<authMode>" & $oProfile.OneX.AuthMode, 1)
	$sProfile = StringReplace($sProfile, "<authPeriod>", "<authPeriod>" & $oProfile.OneX.AuthPeriod, 1)
	$sProfile = StringReplace($sProfile, "<cacheUserData>", "<cacheUserData>" & $oProfile.OneX.CacheUserData, 1)
	$sProfile = StringReplace($sProfile, "<heldPeriod>", "<heldPeriod>" & $oProfile.OneX.HeldPeriod, 1)
	$sProfile = StringReplace($sProfile, "<maxAuthFailures>", "<maxAuthFailures>" & $oProfile.OneX.MaxAuthFailures, 1)
	$sProfile = StringReplace($sProfile, "<maxStart>", "<maxStart>" & $oProfile.OneX.MaxStart, 1)
	$sProfile = StringReplace($sProfile, "<startPeriod>", "<startPeriod>" & $oProfile.OneX.StartPeriod, 1)
	$sProfile = StringReplace($sProfile, "<supplicantMode>", "<supplicantMode>" & $oProfile.OneX.SuppMode, 1)
	$sProfile = StringReplace($sProfile, "<type>", "<type>" & $oProfile.OneX.SSO.Type, 1)
	$sProfile = StringReplace($sProfile, "<maxDelay>", "<maxDelay>" & $oProfile.OneX.SSO.MaxDelay, 1)
	$sProfile = StringReplace($sProfile, "<allowAdditionalDialogs>", "<allowAdditionalDialogs>" & $oProfile.OneX.SSO.AllowMoreDialogs, 1)
	$sProfile = StringReplace($sProfile, "<userBasedVirtualLan>", "<userBasedVirtualLan>" & $oProfile.OneX.SSO.UserBasedVLAN, 1)
	$sProfile = StringReplace($sProfile, "<PMKCacheMode>", "<PMKCacheMode>" & $oProfile.PMK.CacheEnabled, 1)
	$sProfile = StringReplace($sProfile, "<PMKCacheTTL>", "<PMKCacheTTL>" & $oProfile.PMK.CacheTTL, 1)
	$sProfile = StringReplace($sProfile, "<PMKCacheSize>", "<PMKCacheSize>" & $oProfile.PMK.CacheSize, 1)
	$sProfile = StringReplace($sProfile, "<preAuthMode>", "<preAuthMode>" & $oProfile.PMK.PreAuthEnabled, 1)
	$sProfile = StringReplace($sProfile, "<PreAuthThrottle>", "<PreAuthThrottle>" & $oProfile.PMK.PreAuthThrottle, 1)
	$sProfile = StringReplace($sProfile, '/WLAN/profile/v2">', '/WLAN/profile/v2">' & $oProfile.FIPS.Enabled)
	If $oProfile.EAP.Blob Then
		$sProfile = StringRegExpReplace($sProfile, "<ConfigBlob>", "<ConfigBlob>" & $oProfile.EAP.Blob)
		$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<Config [^>]{0,}>([^\r]{0,}\r){2}", "")
	EndIf
	$sProfile = StringReplace($sProfile, "<eapCommon:AuthorId>", "<eapCommon:AuthorId>0")
	$sProfile = StringReplace($sProfile, "<eapCommon:Type><", "<eapCommon:Type>" & $oProfile.EAP.BaseType & "<", 1)
	$sProfile = StringReplace($sProfile, "<baseEap:Type><", "<baseEap:Type>" & StringLeft($oProfile.EAP.Type, 2) & "<", 1)
	$sProfile = StringReplace($sProfile, "<baseEap:Type><", "<baseEap:Type>" & StringRight($oProfile.EAP.Type, 2) & "<", 1)
	If $oProfile.OneX.Enabled == "false" Or $oProfile.EAP.Blob Then Return StringRegExpReplace($sProfile, "\n[^>]{0,}><[^\r]{0,}\r", "")

	$sProfile = StringReplace($sProfile, "msPeap:DisableUserPromptForServerValidation><", "msPeap:DisableUserPromptForServerValidation>" & $oProfile.EAP.PEAP.ServerValidation.NoUserPrompt & "<", 1)
	$sProfile = StringReplace($sProfile, "msPeap:ServerNames><", "msPeap:ServerNames>" & $oProfile.EAP.PEAP.ServerValidation.ServerNames & "<", 1)
	For $sThumbprint In $oProfile.EAP.PEAP.ServerValidation.Thumbprints
		$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<msPeap:TrustedRootCA><[^\r]{0,}\r", "\0\0", 1)
		$sProfile = StringReplace($sProfile, "TrustedRootCA><", "TrustedRootCA>" & $sThumbprint & "<", 1)
	Next
	$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<msPeap:TrustedRootCA><[^\r]{0,}\r", "", 1)
	$sProfile = StringReplace($sProfile,"msPeapV2:PerformServerValidation><", "msPeapV2:PerformServerValidation>" & $oProfile.EAP.PEAP.ServerValidation.Enabled & "<")
	$sProfile = StringReplace($sProfile,"msPeapV2:AcceptServerName><", "msPeapV2:AcceptServerName>" & $oProfile.EAP.PEAP.ServerValidation.AcceptServerNames & "<")
	$sProfile = StringReplace($sProfile, "<msPeap:FastReconnect><", "<msPeap:FastReconnect>" & $oProfile.EAP.PEAP.FastReconnect & "<", 1)
	$sProfile = StringReplace($sProfile, "<msPeap:InnerEapOptional><", "<msPeap:InnerEapOptional>false<", 1)
	$sProfile = StringReplace($sProfile, "<msPeap:EnableQuarantineChecks><", "<msPeap:EnableQuarantineChecks>" & $oProfile.EAP.PEAP.QuarantineChecks & "<", 1)
	$sProfile = StringReplace($sProfile, "<msPeap:RequireCryptoBinding><", "<msPeap:RequireCryptoBinding>" & $oProfile.EAP.PEAP.RequireCryptoBinding & "<", 1)
	$sProfile = StringReplace($sProfile, "<msPeapV2:EnableIdentityPrivacy><", "<msPeapV2:EnableIdentityPrivacy>" & $oProfile.EAP.PEAP.EnableIdentityPrivacy & "<", 1)
	$sProfile = StringReplace($sProfile, "<msPeapV2:AnonymousUserName><", "<msPeapV2:AnonymousUserName>" & $oProfile.EAP.PEAP.AnonUsername & "<", 1)

	$sProfile = StringReplace($sProfile, "eapTls:DisableUserPromptForServerValidation><", "eapTls:DisableUserPromptForServerValidation>" & $oProfile.EAP.PEAP.TLS.ServerValidation.NoUserPrompt & "<", 1)
	$sProfile = StringReplace($sProfile, "eapTls:ServerNames><", "eapTls:ServerNames>" & $oProfile.EAP.PEAP.TLS.ServerValidation.ServerNames & "<", 1)
	For $sThumbprint In $oProfile.EAP.PEAP.TLS.ServerValidation.Thumbprints
		$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<eapTls:TrustedRootCA><[^\r]{0,}\r", "\0\0", 1)
		$sProfile = StringReplace($sProfile, "TrustedRootCA><", "TrustedRootCA>" & $sThumbprint & "<", 1)
	Next
	$sProfile = StringReplace($sProfile,"eapTlsV2:PerformServerValidation><", "eapTlsV2:PerformServerValidation>" & $oProfile.EAP.PEAP.TLS.ServerValidation.Enabled & "<")
	$sProfile = StringReplace($sProfile,"eapTlsV2:AcceptServerName><", "eapTlsV2:AcceptServerName>" & $oProfile.EAP.PEAP.TLS.ServerValidation.AcceptServerNames & "<")
	$sProfile = StringReplace($sProfile, "<eapTls:DifferentUsername><", "<eapTls:DifferentUsername>" & $oProfile.EAP.PEAP.TLS.DiffUsername & "<", 1)

	$sProfile = StringReplace($sProfile, "eapTls:DisableUserPromptForServerValidation><", "eapTls:DisableUserPromptForServerValidation>" & $oProfile.EAP.TLS.ServerValidation.NoUserPrompt & "<", 1)
	$sProfile = StringReplace($sProfile, "eapTls:ServerNames><", "eapTls:ServerNames>" & $oProfile.EAP.TLS.ServerValidation.ServerNames & "<", 1)
	For $sThumbprint In $oProfile.EAP.TLS.ServerValidation.Thumbprints
		$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<eapTls:TrustedRootCA><[^\r]{0,}\r", "\0\0", 1)
		$sProfile = StringReplace($sProfile, "TrustedRootCA><", "TrustedRootCA>" & $sThumbprint & "<", 1)
	Next
	$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<eapTls:TrustedRootCA><[^\r]{0,}\r", "", 1)
	$sProfile = StringReplace($sProfile,"eapTlsV2:PerformServerValidation><", "eapTlsV2:PerformServerValidation>" & $oProfile.EAP.TLS.ServerValidation.Enabled & "<")
	$sProfile = StringReplace($sProfile,"eapTlsV2:AcceptServerName><", "eapTlsV2:AcceptServerName>" & $oProfile.EAP.TLS.ServerValidation.AcceptServerNames & "<")
	$sProfile = StringReplace($sProfile, "<eapTls:DifferentUsername><", "<eapTls:DifferentUsername>" & $oProfile.EAP.TLS.DiffUsername & "<", 1)

	If $oProfile.EAP.PEAP.TLS.Source = "Certificate Store" Or $oProfile.EAP.TLS.Source = "Certificate Store" Then
		If $oProfile.EAP.TLS.Source = "Certificate Store" Then $sProfile = StringReplace($sProfile, "<eapTls:SimpleCertSelection><", "<eapTls:SimpleCertSelection>" & $oProfile.EAP.TLS.SimpleCertSel & "<", 1)
		If $oProfile.EAP.PEAP.TLS.Source = "Certificate Store" Then $sProfile = StringReplace($sProfile, "<eapTls:SimpleCertSelection><", "<eapTls:SimpleCertSelection>" & $oProfile.EAP.PEAP.TLS.SimpleCertSel & "<", 1)
		$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<eapTls:SmartCard><[^\r]{0,}\r", "", 1)
	ElseIf $oProfile.EAP.PEAP.TLS.Source = "Smart Card" Or $oProfile.EAP.TLS.Source = "Smart Card" Then
		$sProfile = StringReplace($sProfile, "<eapTls:SmartCard></eapTls:SmartCard>", "<eapTls:SmartCard />", 1)
		$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<eapTls:CertificateStore>[[:print:][:space:]]{0,}</eapTls:CertificateStore>\r", "", 1)
	EndIf

	$sProfile = StringReplace($sProfile, "<msChapV2:UseWinLogonCredentials><", "<msChapV2:UseWinLogonCredentials>" & $oProfile.EAP.PEAP.MSCHAP.UseWinLogonCreds & "<", 1)

	$sProfile = StringRegExpReplace($sProfile, "\n[^>]{0,}><[^\r]{0,}\r", "")
	$sProfile = StringRegExpReplace($sProfile, "\n[^:]{0,}:ServerValidation>\r[[:space:]]{0,}[^:]{0,}:ServerValidation>\r", "")
	$sProfile = StringRegExpReplace($sProfile, "\n[^:]{0,}:IdentityPrivacy>\r[[:space:]]{0,}[^:]{0,}:IdentityPrivacy>\r", "")
	$sProfile = StringRegExpReplace($sProfile, "\n[^:]{0,}:PeapExtensions>\r[[:space:]]{0,}[^:]{0,}:PeapExtensions>\r", "")
	$sProfile = StringRegExpReplace($sProfile, "\n[^<]{0,}<singleSignOn>\r[[:space:]]{0,}[^<]{0,}</singleSignOn>\r", "")
	Return $sProfile
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _Wlan_GenerateXMLUserData
; Description ...: Generates XML EAP user data from a user data object.
; Syntax.........: _Wlan_GenerateXMLUserData($oUserData)
; Parameters ....: $oUserData - A user data object
; Return values .: Success - A string containing the XML user data.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |4 - Invalid parameter.
; Author ........: MattyD
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_GenerateXMLUserData($oUserData)
	If Not IsObj($oUserData) Then Return SetError(4, 0, False)

	Local Const $sEL_BASE_START = 'EapHostUserCredentials xmlns="http://www.microsoft.com/provisioning/EapHostUserCredentials"' & @CRLF & _
			'xmlns:eapCommon="http://www.microsoft.com/provisioning/EapCommon"+|EapMethod+|eapCommon:Type|eapCommon:AuthorId|-|'
	Local Const $sEL_CREDS_START = 'Credentials xmlns:baseEap="http://www.microsoft.com/provisioning/BaseEapUserPropertiesV1"' & @CRLF & _
			'xmlns:MsPeap="http://www.microsoft.com/provisioning/MsPeapUserPropertiesV1"' & @CRLF & _
			'xmlns:eapTls="http://www.microsoft.com/provisioning/EapTlsUserPropertiesV1"' & @CRLF & _
			'xmlns:MsChapV2="http://www.microsoft.com/provisioning/MsChapV2UserPropertiesV1"+|'
	Local Const $sEL_PEAP_START = 'baseEap:Eap+|baseEap:Type|MsPeap:EapType+|MsPeap:RoutingIdentity|'
	Local Const $sEL_TLS = 'baseEap:Eap+|baseEap:Type|eapTls:EapType+|eapTls:Username|eapTls:UserCert|-|-|'
	Local Const $sEL_MSCHAP = 'baseEap:Eap+|baseEap:Type|MsChapV2:EapType+|MsChapV2:Username|MsChapV2:Password|MsChapV2:LogonDomain|-|-|'
	Local Const $sEL_PEAP_END = '-|-|'
	Local Const $sEL_CREDS_END = '-|'
	Local Const $sEL_BASE_END = 'CredentialsBlob|-'

	Local $sEl_Start = $sEL_BASE_START
	Local $sEl_End = $sEL_BASE_END
	Local $sUserData = '<?xml version="1.0"?>' & @CRLF, $avStack[1] = [-1], $asElements

	With $oUserData
		If .BaseType = "TLS" Then .BaseType = "13"
		If .BaseType = "PEAP" Then .BaseType = "25"
		If .Type = "TLS" Then .Type = "13"
		If .Type = "PEAP-TLS" Then .Type = "2513"
		If .Type = "PEAP-MSCHAP" Then .Type = "2526"
		If .TLS.Domain Then .TLS.Username = .TLS.Domain & "\" & .TLS.Username
		If .PEAP.TLS.Domain Then .PEAP.TLS.Username = .PEAP.TLS.Domain & "\" & .PEAP.TLS.Username
		.Blob = String(.Blob)
	EndWith

	If Not $oUserData.Blob Then
		$sEl_Start &= $sEL_CREDS_START
		$sEl_End = $sEL_CREDS_END & $sEl_End

		If StringInStr($oUserData.Type, "25") Then
			$sEl_Start &= $sEL_PEAP_START
			$sEl_End = $sEL_PEAP_END & $sEl_End
		EndIf

		If StringInStr($oUserData.Type, "13") Then $sEl_Start &= $sEL_TLS
		If StringInStr($oUserData.Type, "26") Then $sEl_Start &= $sEL_MSCHAP
	EndIf

	$asElements = StringSplit($sEl_Start & $sEl_End, "|")
	For $i = 1 To UBound($asElements) - 1
		If StringInStr($asElements[$i], @CRLF) Then
			For $j = 0 To $avStack[0]
				$asElements[$i] = StringReplace($asElements[$i], @CRLF, @CRLF & @TAB)
			Next
		EndIf
		If StringInStr($asElements[$i], "+") Then
			$sUserData &= "<" & StringReplace($asElements[$i], "+", "") & ">" & @CRLF
			Redim $avStack[Ubound($avStack) + 1]
			$avStack[Ubound($avStack) - 1] = StringReplace($asElements[$i], "+", "")
			$avStack[0] += 1
		ElseIf $asElements[$i] == "-" Then
			$sUserData &= "</" & StringRegExpReplace($avStack[Ubound($avStack) - 1], " [^>]{0,}", "") & ">" & @CRLF
			Redim $avStack[Ubound($avStack) - 1]
		Else
			$sUserData &= "<" & $asElements[$i] & "></" & StringRegExpReplace($asElements[$i], " [^>]{0,}", "") & ">" & @CRLF
		EndIf
		If $i < UBound($asElements) - 1 And $asElements[$i + 1] == "-" Then $avStack[0] -= 1
		For $j = 0 To $avStack[0]
			$sUserData &= "	"
		Next
	Next

	$sUserData = StringReplace($sUserData, "<CredentialsBlob>", "<CredentialsBlob>" & $oUserData.Blob)
	$sUserData = StringReplace($sUserData, "<eapCommon:Type>", "<eapCommon:Type>" & $oUserData.BaseType)
	$sUserData = StringReplace($sUserData, "<baseEap:Type><", "<baseEap:Type>" & StringLeft($oUserData.Type, 2) & "<", 1)
	$sUserData = StringReplace($sUserData, "<baseEap:Type><", "<baseEap:Type>" & StringRight($oUserData.Type, 2) & "<", 1)
	$sUserData = StringReplace($sUserData, "<eapCommon:AuthorId>", "<eapCommon:AuthorId>0")
	$sUserData = StringReplace($sUserData, "<MsPeap:RoutingIdentity>", "<MsPeap:RoutingIdentity>" & $oUserData.PEAP.Username)
	If $oUserData.PEAP.TLS.Username Then $sUserData = StringReplace($sUserData, "<eapTls:Username>", "<eapTls:Username>" & $oUserData.PEAP.TLS.Username)
	If $oUserData.PEAP.TLS.Cert Then $sUserData = StringReplace($sUserData, "<eapTls:UserCert>", "<eapTls:UserCert>" & $oUserData.PEAP.TLS.Cert)
	If $oUserData.TLS.Username Then $sUserData = StringReplace($sUserData, "<eapTls:Username>", "<eapTls:Username>" & $oUserData.TLS.Username)
	If $oUserData.TLS.Cert Then $sUserData = StringReplace($sUserData, "<eapTls:UserCert>", "<eapTls:UserCert>" & $oUserData.TLS.Cert)
	$sUserData = StringReplace($sUserData, "<MsChapV2:Username>", "<MsChapV2:Username>" & $oUserData.PEAP.MSCHAP.Username)
	$sUserData = StringReplace($sUserData, "<MsChapV2:Password>", "<MsChapV2:Password>" & $oUserData.PEAP.MSCHAP.Password)
	$sUserData = StringReplace($sUserData, "<MsChapV2:LogonDomain>", "<MsChapV2:LogonDomain>" & $oUserData.PEAP.MSCHAP.Domain)

	$sUserData = StringRegExpReplace($sUserData, "\n[^>]{0,}><[^\r]{0,}\r", "")

	Return $sUserData
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_GetInterfaceCapability
; Description ...: Retrieves the capabilities of an interface.
; Syntax.........: _Wlan_GetInterfaceCapability()
; Parameters ....:
; Return values .: Success - An list of capability indications.
;                  |$avIntCapability[$iIndex][0] - Type of interface
;                  |$avIntCapability[$iIndex][1] - Indicates whether 802.11d is supported
;                  |$avIntCapability[$iIndex][2] - Maximum size of the SSID list
;                  |$avIntCapability[$iIndex][3] - Maximum size of the DSSID list
;                  |$avIntCapability[$iIndex][4 to n] - Supported PHY types
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |3 - There is no data to return.
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  As the order of phy types is the same though all functions, a returned Phy index of 0 refers to the element at $avIntCapability[$iIndex][4]
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_GetInterfaceCapability()
	Local $pIntCapability, $tIntCapability, $iNoPhyTypes
	$pIntCapability = _WinAPI_WlanGetInterfaceCapability($hClientHandle, $pGUID)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanGetInterfaceCapability"))

	$tIntCapability	= DllStructCreate("dword Type; dword Dot11d; dword MaxSSIDList; dword MaxBSSIDList; dword NoPhyTypes", $pIntCapability)
	$iNoPhyTypes = DllStructGetData($tIntCapability, "NoPhyTypes")
	Local $avIntCapability[4 + $iNoPhyTypes]
	$avIntCapability[0] = _Wlan_EnumToString("WLAN_INTERFACE_TYPE", DllStructGetData($tIntCapability, "Type"))
	$avIntCapability[1] = "802.11d Unsupported"
	If DllStructGetData($tIntCapability, "Dot11d") Then $avIntCapability[1] = "802.11d Supported"
	$avIntCapability[2] = DllStructGetData($tIntCapability, "MaxSSIDList") & " SSID(s) Supported"
	$avIntCapability[3] = DllStructGetData($tIntCapability, "MaxBSSIDList") & " BSSID(s) Supported"
	$tIntCapability = DllStructCreate("dword PhyType[" & $iNoPhyTypes & "]", Ptr(Number($pIntCapability) + 20))
	For $i = 1 To $iNoPhyTypes
		$avIntCapability[$i + 3] = _Wlan_EnumToString("DOT11_PHY_TYPE", DllStructGetData($tIntCapability, "PhyType", $i))
	Next

	_WinAPI_WlanFreeMemory($pIntCapability)
	Return $avIntCapability
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_GetNetworks
; Description ...: Retrieves the list of available networks on an interface.
; Syntax.........: _Wlan_GetNetworks($fScan = False, $iFlags = 0, $iUDFFlags = 1)
; Parameters ....: $fScan - If True the function will initiate a scan and wait for its completion before returning a list of networks.
;                  $iFlags - Provides flags to the API about what to return.
;                  |0 - Return all found infratsucture and ad-hoc networks and add etries for their corresponding profiles.
;                  |1 - Include all ad hoc profiles in the list even if they cannot be found.
;                  |2 - Include all "manual" profiles in the list that are marked to connect if the SSID is not bradcasting.
;                  $iUDFFlags - Provides options to make the returned list more relevant.
;                  |0 - Leave the list as provided by the API.
;                  |1 - Filter out entries that have a corresponding profile already listed.
;                  |2 - Modify the authentication and encryption fields of a profile entry if they conflict with the detected network.
; Return values .: Success - An array of available networks
;                  |$asNetworks[$iIndex][0] - Profile name
;                  |$asNetworks[$iIndex][1] - SSID of the network
;                  |$asNetworks[$iIndex][2] - Network type (Infratructure or Ad Hoc)
;                  |$asNetworks[$iIndex][3] - Connectability (Connectable or Not Connectable)
;                  |$asNetworks[$iIndex][4] - The reason why the network is not connectable
;                  |$asNetworks[$iIndex][5] - Signal strength (0-100)
;                  |$asNetworks[$iIndex][6] - Security status (Security Enabled Or Security Disabled)
;                  |$asNetworks[$iIndex][7] - Authentication method
;                  |$asNetworks[$iIndex][8] - Encryption method
;                  |$asNetworks[$iIndex][9] - Flags
;                  C - The interface is currently connected to this network
;                  P - This is a profile entry
;                  U - The profile for this network is a per-user profile
;                  |$asNetworks[$iIndex][10] - Number of BSSIDs associated with the Network
;                  |$asNetworks[$iIndex][11] - Information on the radio types listed
;                  |$asNetworks[$iIndex][12] - The radio types of network
;                  |$asNetworks[$iIndex][13] - UDF Flags
;                  number - The associated profile entry can be found at this index
;                  C - There is a authentication and/or encryption conflict between the profile and what was detected from the network.
;                  M - The authentication and/or encryption fields of the entry have been modified to coincide with the detected network.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |3 - There is no data to return.
;                  |6 - Then notification module is not running.
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  Flags on the input can be combined to specify multiple options.
;                  Extra profiles in the list included by specifying API flags on input are not affected by the UDFs "Filter" flag.
; Related .......: _Wlan_Scan
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_GetNetworks($fScan = False, $iFlags = 0, $iUDFFlags = 1)
	Local $pNetwork, $tNetwork, $iItems

	If $fScan < 0 Or $fScan = Default Then $fScan = True
	If $iFlags < 0 Or $fScan = Default Then $iFlags = 0
	If $iUDFFlags < 0 Or $fScan = Default Then $iUDFFlags = 1

	If $fScan Then _Wlan_Scan(True)
	If @error And @error <> 5 Then Return SetError(@error, @extended, False)

	$pNetwork = _WinAPI_WlanGetAvailableNetworkList($hClientHandle, $pGUID, $iFlags)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanGetAvailableNetworkList"))

	$tNetwork = DllStructCreate("dword Items", $pNetwork)
	$iItems = DllStructGetData($tNetwork, "Items")
	If Not $iItems Then
		_WinAPI_WlanFreeMemory($pNetwork)
		Return SetError(3, 0, False)
	EndIf

	Local $asNetworks[$iItems][14], $pNetworkItem, $iData, $iFirstNet = -1, $iFiltered

	For $i = 0 To $iItems - 1
		$pNetworkItem = Ptr($i * 628 + Number($pNetwork) + 8)

		$tNetwork = DllStructCreate("wchar ProfName[256]; dword SSIDLen; char SSID[32]; dword BSSType; dword NoBSSIDs; dword Connectable; dword RsnCode; dword NoPhyTypes; " & _
		"dword PhyTypes[8]; dword MorePhyTypes; dword Signal; dword SecEnabled; dword Auth; dword Ciph; dword Flags", $pNetworkItem)

		$asNetworks[$i - $iFiltered][0] = DllStructGetData($tNetwork, "ProfName")
		If $iFirstNet = -1 And $asNetworks[$i - $iFiltered][0] == "" Then $iFirstNet = $i - $iFiltered

		$asNetworks[$i - $iFiltered][1] = DllStructGetData($tNetwork, "SSID")
		$asNetworks[$i - $iFiltered][2] = _Wlan_EnumToString("DOT11_BSS_TYPE", DllStructGetData($tNetwork, "BSSType"))
		$asNetworks[$i - $iFiltered][3] = "Not Connectable"
		If DllStructGetData($tNetwork, "Connectable") Then $asNetworks[$i - $iFiltered][3] = "Connectable"
		$asNetworks[$i - $iFiltered][4] = _Wlan_ReasonCodeToString(DllStructGetData($tNetwork, "RsnCode"))
		$asNetworks[$i - $iFiltered][5] = DllStructGetData($tNetwork, "Signal")
		$asNetworks[$i - $iFiltered][6] = "Security Disabled"
		If DllStructGetData($tNetwork, "SecEnabled") Then $asNetworks[$i - $iFiltered][6] = "Security Enabled"
		$asNetworks[$i - $iFiltered][7] = _Wlan_EnumToString("DOT11_AUTH_ALGORITHM", DllStructGetData($tNetwork, "Auth"))
		$asNetworks[$i - $iFiltered][8] = _Wlan_EnumToString("DOT11_CIPHER_ALGORITHM", DllStructGetData($tNetwork, "Ciph"))
		$iData = DllStructGetData($tNetwork, "Flags")
		$asNetworks[$i - $iFiltered][9] = ""
		If BitAND($iData, $WLAN_AVAILABLE_NETWORK_CONNECTED) Then $asNetworks[$i - $iFiltered][9] &= "C"
		If BitAND($iData, $WLAN_AVAILABLE_NETWORK_HAS_PROFILE) Then $asNetworks[$i - $iFiltered][9] &= "P"
		If BitAND($iData, $WLAN_AVAILABLE_NETWORK_CONSOLE_USER_PROFILE) Then $asNetworks[$i - $iFiltered][9] &= "U"
		$asNetworks[$i - $iFiltered][10] = DllStructGetData($tNetwork, "NoBSSIDs") & " BSSID(s)"
		$asNetworks[$i - $iFiltered][11] = "All Phy Types Listed"
		If DllStructGetData($tNetwork, "MorePhyTypes") Then $asNetworks[$i - $iFiltered][11] = ">8 Phy Types Exist"
		$iData = DllStructGetData($tNetwork, "NoPhyTypes")
		$asNetworks[$i - $iFiltered][12] = ""
		For $j = 1 To $iData
			$asNetworks[$i - $iFiltered][12] &= _Wlan_EnumToString("DOT11_PHY_TYPE", DllStructGetData($tNetwork, "PhyTypes", $j)) & ","
		Next
		$asNetworks[$i - $iFiltered][12] = StringTrimRight($asNetworks[$i - $iFiltered][12], 1)
		$asNetworks[$i - $iFiltered][13] = ""
		$iData = 0
		For $j = 0 To $iFirstNet - 1
			If Not ($asNetworks[$i - $iFiltered][1] == $asNetworks[$j][1]) Then ContinueLoop
			If $asNetworks[$i - $iFiltered][2] = $asNetworks[$j][2] And $asNetworks[$i - $iFiltered][6] = $asNetworks[$j][6] Then
				$iData = 1
				$asNetworks[$i - $iFiltered][13] &= $j ;Corresponding profile here
				If $asNetworks[$i - $iFiltered][7] <> $asNetworks[$j][7] Or $asNetworks[$i - $iFiltered][8] <> $asNetworks[$j][8] Then
					$asNetworks[$i - $iFiltered][13] &= "C" ;Auth and or Cipher conflict.
					$asNetworks[$j][13] &= "C" ;Auth and or Cipher conflict.
					If BitAND($iUDFFlags, 2) Then
						$asNetworks[$j][7] = $asNetworks[$i - $iFiltered][7]
						$asNetworks[$j][8] = $asNetworks[$i - $iFiltered][8]
						$asNetworks[$j][13] &= "M" ;Auth and or Cipher Modified.
					EndIf
				EndIf
			EndIf
		Next
		If BitAND($iUDFFlags, 1) And $iData Then $iFiltered += 1
	Next
	If BitAND($iUDFFlags, 1) Then ReDim $asNetworks[UBound($asNetworks) - $iFiltered][14]
	_WinAPI_WlanFreeMemory($pNetwork)
	Return $asNetworks
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_GetNotification
; Description ...: Retrieves notifications from cache.
; Syntax.........: _Wlan_GetNotification($fInterfaceFilter = True)
; Parameters ....: $fInterfaceFilter - If True the function will only return notifications from the selected interface
; Return values .: Success - a notification array
;                  |$avNotification[0] - The notification source.
;                  |$avNotification[1] - The notification code.
;                  |$avNotification[2] - The GUID of the interface to which the notification corresponds.
;                  |$avNotification[3] - A string representation of the notification.
;                  |$avNotification[4 to n] - notification data.
;                  Failure - none.
;                  @Error
;                  |0 - No error.
;                  |3 - There is no data to return.
; Author ........: MattyD
; Modified.......:
; Remarks .......:
; Related .......: _Wlan_StartNotificationModule
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_GetNotification($fInterfaceFilter = True)
	Sleep(20)
	Local $sNotification, $avNotification
	For $i = 1 To UBound($asNotificationCache) - 1
		If TimerDiff($asNotificationCache[$i][0]) <= $iNotifKeepTime Then
			$sNotification = $asNotificationCache[$i][1]
			$asNotificationCache[$i][0] -= TimerInit()
			ExitLoop
		EndIf
	Next
	If Not $sNotification Then Return SetError(3, 0, "")

	$avNotification = StringSplit($sNotification, ",", 2)
	If $fInterfaceFilter Then
		If $avNotification[2] <> _Wlan_pGUIDToString($pGUID) Then Return SetError(3, 0, "")
	EndIf
	Return($avNotification)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_GetProfile
; Description ...: Starts the notification module.
; Syntax.........: _Wlan_GetProfile($sProfileName, ByRef $iFlags, $fXML = False)
; Parameters ....: $sProfileName - The name of the profile to retrieve.
;                  $iFlags - Provides additional information about the request. (Vista, 2008 and up)
;                  |$WLAN_PROFILE_GET_PLAINTEXT_KEY - (input) If the caller has the apropriate privlages, the key material is returned unencrypted. (7, 2008 R2 and up)
;                  |$WLAN_PROFILE_GROUP_POLICY - (output) The profile was created by group policy.
;                  |$WLAN_PROFILE_USER - (output) The profile is a per-user profile.
;                  $fXML - Specifies the format of the returned profile.
;                  |True - Return the profile in XML format.
;                  |False - Return a profile object. (see _Wlan_GenerateXMLProfile)
; Return values .: Success - The profile in the specified format.
;                  @extended - The access mask of the all user profile. (Use BitAnd to test the level of access)
;                  |$WLAN_READ_ACCESS - The user can view the contents of the profile.
;                  |$WLAN_EXECUTE_ACCESS - The user has read access, and the user can also connect to and disconnect from a network using the profile.
;                  |$WLAN_WRITE_ACCESS - The user has execute access and the user can also modify the content of the profile or delete the profile.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |6 - A dependency is missing. (@extended - _AutoItObject_Create error code.)
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  Windows XP always returns an unprotected key, Vista and server 2008 always returns an protected key.
;                  If the calling process is running in the context of the LocalSystem account, a key can be unencrypted using _Wlan_DecryptKey.
; Related .......: _Wlan_SetProfile _Wlan_DecryptKey
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_GetProfile($sProfileName, ByRef $iFlags, $fXML = False)
	Local $oProfile, $sProfile, $tFlags, $iPermissions
	$tFlags = DllStructCreate("dword Flags")
	DllStructSetData($tFlags, "Flags", $iFlags)

	$sProfile = _WinAPI_WlanGetProfile($hClientHandle, $pGUID, $sProfileName, DllStructGetPtr($tFlags))
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanGetProfile"))
	$iPermissions = @extended

	$iFlags = DllStructGetData($tFlags, "Flags")
	If $fXML Then Return SetExtended($iPermissions, $sProfile)

	$oProfile = _Wlan_GenerateProfileObject($sProfile)
	Return SetExtended($iPermissions, $oProfile)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_GetProfileList
; Description ...: Retrieves the list of profiles in preference order.
; Syntax.........: _Wlan_GetProfileList($fExteded = False)
; Parameters ....:
; Return values .: Success - An array of profiles.
;                  If $fExteded = False:
;                  $asProfileList[$iIndex] - Profile name
;                  If $fExteded = True:
;                  |$asProfileListEx[$iIndex][0] - Profile name
;                  |$asProfileListEx[$iIndex][1] - Flags (Vista, 2008 and up)
;                  G - The profile is a group policy profile
;                  U - The profile is a per-user profile
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |3 - There is no data to return.
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
; Related .......: _Wlan_SetProfileList _Wlan_SetProfilePosition
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_GetProfileList($fExteded = False)
	Local $pProfileList, $tProfileList, $iItems
	$pProfileList = _WinAPI_WlanGetProfileList($hClientHandle, $pGUID)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanGetProfileList"))

	$tProfileList = DllStructCreate("dword Items", $pProfileList)
	$iItems = DllStructGetData($tProfileList, "Items")
	If Not $iItems Then
		_WinAPI_WlanFreeMemory($pProfileList)
		Return SetError(3, 0, "")
	EndIf

	Local $asProfileList[$iItems], $asProfileListEx[$iItems][2], $pProfile
	For $i = 0 To $iItems - 1
		$pProfile = Ptr($i * 516 + Number($pProfileList) + 8)
		$tProfileList = DllStructCreate("wchar Name[256]; dword Flags", $pProfile)
		$asProfileListEx[$i][0] = DllStructGetData($tProfileList, "Name")
		$asProfileList[$i] = $asProfileListEx[$i][0]
		If BitAND(DllStructGetData($tProfileList, "Flags"), $WLAN_PROFILE_GROUP_POLICY) Then $asProfileListEx[$i][1] &= "G"
		If BitAND(DllStructGetData($tProfileList, "Flags"), $WLAN_PROFILE_USER) Then $asProfileListEx[$i][1] &= "U"
	Next

	_WinAPI_WlanFreeMemory($pProfileList)
	If $fExteded Then Return $asProfileListEx
	Return $asProfileList
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_HNQueryProperty
; Description ...: Queries the current static properties of the wireless Hosted Network.
; Syntax.........: _Wlan_HNQueryProperty($iOpCode, ByRef $iValueType)
; Parameters ....: $iOpCode - A WLAN_HOSTED_NETWORK_OPCODE value to identify the property to be queried:
;                  |$WLAN_HOSTED_NETWORK_OPCODE_CONNECTION_SETTINGS
;                  |$WLAN_HOSTED_NETWORK_OPCODE_SECURITY_SETTINGS
;                  |$WLAN_HOSTED_NETWORK_OPCODE_STATION_PROFILE
;                  |$WLAN_HOSTED_NETWORK_OPCODE_ENABLE
;                  $iValueType - On output, A WLAN_OPCODE_VALUE_TYPE value that indicates the returned value type:
;                  |$WLAN_OPCODE_VALUE_TYPE_QUERY_ONLY
;                  |$WLAN_OPCODE_VALUE_TYPE_SET_BY_GROUP_POLICY
;                  |$WLAN_OPCODE_VALUE_TYPE_SET_BY_USER
;                  |$WLAN_OPCODE_VALUE_TYPE_INVALID
; Return values .: Success - Data
;                  $WLAN_HOSTED_NETWORK_OPCODE_CONNECTION_SETTINGS - The SSID associated with the wireless Hosted Network
;                  @extended - The maximum number of concurrent peers allowed by the wireless Hosted Network
;                  $WLAN_HOSTED_NETWORK_OPCODE_SECURITY_SETTINGS - The security settings on the wireless Hosted Network
;                  |$vData[0] - The authentication algorithm used by the wireless Hosted Network
;                  |$vData[1] - The cipher algorithm used by the wireless Hosted Network
;                  $WLAN_HOSTED_NETWORK_OPCODE_STATION_PROFILE - The XML profile for connecting to the wireless Hosted Network
;                  $WLAN_HOSTED_NETWORK_OPCODE_ENABLE - a boolean that indicates if wireless Hosted Network is enabled
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |4 - Invalid parameter.
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is only supported from Windows 7 and Server 2008 R2.
; Related .......: _Wlan_HNSetProperty
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_HNQueryProperty($iOpCode, ByRef $iValueType)
	Local $iDataSz, $pData, $tData, $vData, $iExtended

	_WinAPI_WlanHostedNetworkQueryProperty($hClientHandle, $iOpCode, $iDataSz, $pData, $iValueType)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanHostedNetworkQueryProperty"))

	Switch $iOpCode
		Case $WLAN_HOSTED_NETWORK_OPCODE_CONNECTION_SETTINGS
			$tData = DllStructCreate("dword SSIDLen; char SSID[32]; dword MaxNoPeers", $pData)
			$vData = DllStructGetData($tData, "SSID")
			$iExtended = DllStructGetData($tData, "MaxNoPeers")
		Case $WLAN_HOSTED_NETWORK_OPCODE_SECURITY_SETTINGS
			Local $vData[2]
			$tData = DllStructCreate("dword Auth; dword Ciph", $pData)
			$vData[0] = _Wlan_EnumToString("DOT11_AUTH_ALGORITHM", DllStructGetData($tData, "Auth"))
			$vData[1] = _Wlan_EnumToString("DOT11_CIPHER_ALGORITHM", DllStructGetData($tData, "Ciph"))
		Case $WLAN_HOSTED_NETWORK_OPCODE_STATION_PROFILE
			$tData = DllStructCreate("wchar[" & $iDataSz / 2 & "]", $pData)
			$vData = DllStructGetData($tData, 1)
		Case $WLAN_HOSTED_NETWORK_OPCODE_ENABLE
			$tData = DllStructCreate("bool", $pData)
			If DllStructGetData($tData, 1) Then
				$vData = True
			Else
				$vData = False
			EndIf
		Case Else
			Return SetError(4, 0, False)
	EndSwitch

	Return SetExtended($iExtended, $vData)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_HNSetProperty
; Description ...: Sets static properties of the wireless Hosted Network.
; Syntax.........: _Wlan_HNSetProperty($iOpCode, ByRef $sReason, $vData, $iMaxPeers = 0)
; Parameters ....: $iOpCode - A WLAN_HOSTED_NETWORK_OPCODE value to identify the property to set (the expected data type of $vData in brackets):
;                  |WLAN_HOSTED_NETWORK_OPCODE_CONNECTION_SETTINGS (the SSID of the network to connect to)
;                  |WLAN_HOSTED_NETWORK_OPCODE_ENABLE (Boolean)
;                  $sReason - Provides a reason why the function failed. (output)
;                  $vData - See above.
;                  $iMaxPeers - The maximum number of concurrent peers allowed by the Hosted Network. This parameter is only valid when $iOpCode = WLAN_HOSTED_NETWORK_OPCODE_CONNECTION_SETTINGS.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |4 - Invalid parameter.
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is only supported from Windows 7 and Server 2008 R2.
; Related .......: _Wlan_HNQueryProperty
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_HNSetProperty($iOpCode, ByRef $sReason, $vData, $iMaxPeers = 0)
	Local $tData, $iReasonCode, $iError, $iExtended

	Switch $iOpCode
		Case $WLAN_HOSTED_NETWORK_OPCODE_CONNECTION_SETTINGS
			$tData = DllStructCreate("dword SSIDLen; char SSID[32]; dword MaxNoPeers")
			DllStructSetData($tData, "SSIDLen", StringLen($vData))
			DllStructSetData($tData, "SSID", $vData)
			DllStructSetData($tData, "MaxNoPeers", $iMaxPeers)
		Case $WLAN_HOSTED_NETWORK_OPCODE_ENABLE
			$tData = DllStructCreate("bool")
			If $vData Then
				DllStructSetData($tData, 1, True)
			Else
				DllStructSetData($tData, 1, False)
			EndIf
		Case Else
			Return SetError(4, 0, False)
	EndSwitch

	_WinAPI_WlanHostedNetworkSetProperty($hClientHandle, $iOpCode, DllStructGetSize($tData), DllStructGetPtr($tData), $iReasonCode)

	If @error Then
		$iError = @error
		$iExtended = @extended
		If $iReasonCode Then $sReason = _Wlan_EnumToString("WLAN_HOSTED_NETWORK_REASON", $iReasonCode)
		Return SetError(@error, @extended, _Wlan_ReportAPIError($iError, $iExtended, 0, @ScriptLineNumber, "_WinAPI_WlanHostedNetworkSetProperty"))
	EndIf

	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_HNStart
; Description ...: Starts the wireless Hosted Network.
; Syntax.........:  _Wlan_HNStart(ByRef $sReason, $fForce = False)
; Parameters ....: $sReason - Provides a reason why the function failed. (output)
;                  $fForce - If True the Hosted Network will start without associating the request with the application's calling handle.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  This function is only supported from Windows 7 and Server 2008 R2.
;                  When called for the first time, the operating system installs a virtual device if a capable wireless adapter is present.
;                  The virtual device is used exclusively for performing SoftAP connections and is not present in the list returned by WlanEnumInterfaces.
;                  The lifetime of the virtual device is tied to the physical wireless adapter. If the physical wireless adapter is disabled, this virtual device will be removed as well.
;                  Successful calls must be matched by calls to _Wlan_HNStop. If forced to start, the Hosted Network should be forced to stop also.
;                  If the Hosted Network was not forced to start, any state change caused by this function would be automatically undone when the process ends.
;                  If forced to start, the user (not the owner of the process) must have the appropriate associated privilege.
; Related .......: _Wlan_HNStop
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_HNStart(ByRef $sReason, $fForce = False)
	Local $iReasonCode, $iError, $iExtended
	If Not $fForce Then
		_WinAPI_WlanHostedNetworkStartUsing($hClientHandle, $iReasonCode)
		If @error Then
			$iError = @error
			$iExtended = @extended
			If $iReasonCode Then $sReason = _Wlan_EnumToString("WLAN_HOSTED_NETWORK_REASON", $iReasonCode)
			Return SetError(@error, @extended, _Wlan_ReportAPIError($iError, $iExtended, 0, @ScriptLineNumber, "_WinAPI_WlanHostedNetworkStartUsing"))
		EndIf
	Else
		_WinAPI_WlanHostedNetworkForceStart($hClientHandle, $iReasonCode)
		If @error Then
			$iError = @error
			$iExtended = @extended
			If $iReasonCode Then $sReason = _Wlan_EnumToString("WLAN_HOSTED_NETWORK_REASON", $iReasonCode)
			Return SetError(@error, @extended, _Wlan_ReportAPIError($iError, $iExtended, 0, @ScriptLineNumber, "_WinAPI_WlanHostedNetworkForceStart"))
		EndIf
	EndIf
	_WinAPI_WlanHostedNetworkInitSettings($hClientHandle, $iReasonCode)
	If @error Then
		$iError = @error
		$iExtended = @extended
		If $iReasonCode Then $sReason = _Wlan_EnumToString("WLAN_HOSTED_NETWORK_REASON", $iReasonCode)
		Return SetError(@error, @extended, _Wlan_ReportAPIError($iError, $iExtended, 0, @ScriptLineNumber, "_WinAPI_WlanHostedNetworkInitSettings"))
	EndIf
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_HNStop
; Description ...: Stops the wireless Hosted Network.
; Syntax.........:  _Wlan_HNStop(ByRef $sReason, $fForce = False)
; Parameters ....: $sReason - Provides a reason why the function failed. (output)
;                  $fForce - If True the Hosted Network will stop without associating the request with the application's calling handle.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  This function is only supported from Windows 7 and Server 2008 R2.
;                  If the Hosted Network was not forced to stop, any state change caused by this function would be automatically undone when the process ends.
; Related .......: _Wlan_HNStart
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_HNStop(ByRef $sReason, $fForce = False)
	Local $iReasonCode, $iError, $iExtended
	If Not $fForce Then
		_WinAPI_WlanHostedNetworkStopUsing($hClientHandle, $iReasonCode)
		If @error Then
			$iError = @error
			$iExtended = @extended
			If $iReasonCode Then $sReason = _Wlan_EnumToString("WLAN_HOSTED_NETWORK_REASON", $iReasonCode)
			Return SetError(@error, @extended, _Wlan_ReportAPIError($iError, $iExtended, 0, @ScriptLineNumber, "_WinAPI_WlanHostedNetworkStartUsing"))
		EndIf
	Else
		_WinAPI_WlanHostedNetworkForceStop($hClientHandle, $iReasonCode)
		If @error Then
			$iError = @error
			$iExtended = @extended
			If $iReasonCode Then $sReason = _Wlan_EnumToString("WLAN_HOSTED_NETWORK_REASON", $iReasonCode)
			Return SetError(@error, @extended, _Wlan_ReportAPIError($iError, $iExtended, 0, @ScriptLineNumber, "_WinAPI_WlanHostedNetworkForceStart"))
		EndIf
	EndIf
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _Wlan_OnNotifHandler
; Description ...: Calls registered "On Notification" functions.
; Syntax.........: _Wlan_OnNotifHandler()
; Parameters ....:
; Return values .: Success - The value of the registered function.
;                  Failure - False or a blank string with @error set not to 0.
; Author ........: MattyD
; Modified.......:
; Remarks .......:
; Related .......: _Wlan_OnNotification _Wlan_CacheNotification
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_OnNotifHandler()
	Local $avNotif = _Wlan_GetNotification()
	If @error Then Return SetError(@error, @extended, $avNotif)
	For $i = 0 To UBound($avOnNotif) - 1
		If $avNotif[0] = $avOnNotif[$i][0] And $avNotif[1] = $avOnNotif[$i][1] Then
			If $avOnNotif[$i][2] And $avNotif[2] <> _Wlan_pGUIDToString($pGUID) Then ExitLoop
			Return Execute($avOnNotif[$i][3] & "($avNotif)")
		EndIf
	Next
	Return SetError(3, 0, False)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_OnNotification
; Description ...: Registers or deregisters a function to be called on the arrival of a notification.
; Syntax.........: _Wlan_OnNotification($iSource, $iNotif, $sFunction = "", $fInterfaceFilter = True)
; Parameters ....: $iSource - The notification source.
;                  $iNotif - The notification code.
;                  $sFunction - A string containing the function name to register, or an empty string ("") to deregister a function.
;                  $fInterfaceFilter - If True the registered function will only be called if the notification is associated with the selected interface.
; Return values .: Success - True
; Author ........: MattyD
; Modified.......:
; Remarks .......: Registered functions should be defined with one parameter to recieve a notification array. (see _Wlan_GetNotification)
;                  On notification functions should not be used in conjuntion with a _Wlan_GetNotification loop.
;                  If all functions are deregistered a _Wlan_GetNotification loop will become useable again.
; Related .......: _Wlan_GetNotification
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_OnNotification($iSource, $iNotif, $sFunction = "", $fInterfaceFilter = True)
	Local $fAtten = False
	For $i = 0 To UBound($avOnNotif) - 1
		If $iSource = $avOnNotif[$i][0] And $iNotif = $iSource = $avOnNotif[$i][1] Then
			If $sFunction Then ExitLoop
			$fAtten = True
		ElseIf $fAtten Then
			For $j = 0 To 3
				$avOnNotif[$i - 1][$j] = $avOnNotif[$i][$j]
			Next
		EndIf
	Next

	If $fAtten Then
		If Not UBound($avOnNotif) - 1 Then
			$fOnNotif = False
		Else
			ReDim $avOnNotif[UBound($avOnNotif) - 1][4]
		EndIf
		Return True
	ElseIf $i = UBound($avOnNotif) Then
		If Not $fOnNotif Then
			$fOnNotif = True
			$i = 0
		Else
			ReDim $avOnNotif[UBound($avOnNotif) + 1][4]
		EndIf
	EndIf

	$avOnNotif[$i][0] = $iSource
	$avOnNotif[$i][1] = $iNotif
	$avOnNotif[$i][2] = $fInterfaceFilter
	$avOnNotif[$i][3] = $sFunction

	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_QueryACParameter
; Description ...: Queries for the parameters of the auto configuration service.
; Syntax.........: _Wlan_QueryACParameter($iOpCode)
; Parameters ....: $iOpCode - A WLAN_AUTOCONF_OPCODE value that specifies the configuration parameter to be queried:
;                  |$WLAN_AUTOCONF_OPCODE_SHOW_DENIED_NETWORKS
;                  |$WLAN_AUTOCONF_OPCODE_POWER_SETTING
;                  |$WLAN_AUTOCONF_OPCODE_ONLY_USE_GP_PROFILES_FOR_ALLOWED_NETWORKS
;                  |$WLAN_AUTOCONF_OPCODE_ALLOW_EXPLICIT_CREDS
;                  |$WLAN_AUTOCONF_OPCODE_BLOCK_PERIOD
;                  |$WLAN_AUTOCONF_OPCODE_ALLOW_VIRTUAL_STATION_EXTENSIBILITY
; Return values .: Success - Data
;                  $WLAN_AUTOCONF_OPCODE_SHOW_DENIED_NETWORKS, $WLAN_AUTOCONF_OPCODE_ONLY_USE_GP_PROFILES_FOR_ALLOWED_NETWORKS,
;                  $WLAN_AUTOCONF_OPCODE_ALLOW_EXPLICIT_CREDS, $WLAN_AUTOCONF_OPCODE_ALLOW_VIRTUAL_STATION_EXTENSIBILITY - Boolean
;                  $WLAN_AUTOCONF_OPCODE_POWER_SETTING - One of the following strings:
;                  |"None" - No power saving
;                  |"Low" - Low power saving
;                  |"Medium" - Medium power saving
;                  |"Maximum" - Maximum power saving
;                  $WLAN_AUTOCONF_OPCODE_BLOCK_PERIOD - Integer
;                  @extended - The type of opcode returned
;                  |0 - Undetermined
;                  |1 - Set by group policy
;                  |2 - Set by user
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  This function is not supported in Windows XP.
; Related .......: _Wlan_SetACParameter
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_QueryACParameter($iOpCode)
	Local $tData, $pData, $vData, $iOpcodeValueType
	$pData = _WinAPI_WlanQueryAutoConfigParameter($hClientHandle, $iOpCode)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanQueryAutoConfigParameter"))

	$iOpcodeValueType = @extended
	$tData = DllStructCreate("dword DATA", $pData)
	$vData = DllStructGetData($tData, "DATA")

	Switch $iOpCode
		Case $WLAN_AUTOCONF_OPCODE_POWER_SETTING
			$vData = _Wlan_EnumToString("WLAN_POWER_SETTING", $vData)
		Case $WLAN_AUTOCONF_OPCODE_BLOCK_PERIOD
		Case Else
			If $vData Then
				$vData = True
			Else
				$vData = False
			EndIf
	EndSwitch
	Return SetExtended($iOpcodeValueType, $vData)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_QueryInterface
; Description ...: Queries various parameters of an interface.
; Syntax.........: _Wlan_QueryInterface($iOpCode = $WLAN_INTF_OPCODE_INTERFACE_STATE)
; Parameters ....:  $iOpCode - A WLAN_INTF_OPCODE value that specifies the parameter to be queried (the supported platforms in brackets):
;                  |$WLAN_INTF_OPCODE_AUTOCONF_ENABLED                           (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_BACKGROUND_SCAN_ENABLED                    (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_RADIO_STATE                                (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_BSS_TYPE                                   (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_INTERFACE_STATE                            (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_CURRENT_CONNECTION                         (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_CHANNEL_NUMBER                             (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_SUPPORTED_INFRASTRUCTURE_AUTH_CIPHER_PAIRS (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_SUPPORTED_ADHOC_AUTH_CIPHER_PAIRS          (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_SUPPORTED_COUNTRY_OR_REGION_STRING_LIST    (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_MEDIA_STREAMING_MODE                       (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_STATISTICS                                 (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_RSSI                                       (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_CURRENT_OPERATION_MODE                     (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_SUPPORTED_SAFE_MODE                        (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_CERTIFIED_SAFE_MODE                        (Vista, 2008 and up)
; Return values .: Success - Data
;                  $WLAN_INTF_OPCODE_AUTOCONF_ENABLED, $WLAN_INTF_OPCODE_BACKGROUND_SCAN_ENABLED, $WLAN_INTF_OPCODE_MEDIA_STREAMING_MODE,
;                  $WLAN_INTF_OPCODE_SUPPORTED_SAFE_MODE, $WLAN_INTF_OPCODE_CERTIFIED_SAFE_MODE - Boolean
;                  $WLAN_INTF_OPCODE_RADIO_STATE - A radio state array
;                  |$avRadioState[$iIndex][0] - Index of the PHY type on which the radio state is being set or queried
;                  |$avRadioState[$iIndex][1] - Software switch state
;                  |$avRadioState[$iIndex][2] - Hardware switch state
;                  $WLAN_INTF_OPCODE_BSS_TYPE - The type of networks the interface is permitted to connect to
;                  $WLAN_INTF_OPCODE_INTERFACE_STATE - Interface state
;                  $WLAN_INTF_OPCODE_CURRENT_CONNECTION - An informational array about current connection
;                  |$avConnAttrib[$iIndex][0] - Connection status
;                  |$avConnAttrib[$iIndex][1] - Connection mode
;                  |$avConnAttrib[$iIndex][2] - Profile name
;                  |$avConnAttrib[$iIndex][3] - SSID
;                  |$avConnAttrib[$iIndex][4] - BSS Type (Network Type)
;                  |$avConnAttrib[$iIndex][5] - BSSID (MAC of the host)
;                  |$avConnAttrib[$iIndex][6] - PHY type (Physical radio type)
;                  |$avConnAttrib[$iIndex][7] - PHY type index
;                  |$avConnAttrib[$iIndex][8] - Signal strength (0-100)
;                  |$avConnAttrib[$iIndex][9] - Recieve rate
;                  |$avConnAttrib[$iIndex][10] - Transmit rate
;                  |$avConnAttrib[$iIndex][11] - Security status
;                  |$avConnAttrib[$iIndex][12] - 802.1x status
;                  |$avConnAttrib[$iIndex][13] - Authentication method
;                  |$avConnAttrib[$iIndex][14] - Encryption method
;                  $WLAN_INTF_OPCODE_CHANNEL_NUMBER - Current channel on which the wireless interface is operating
;                  $WLAN_INTF_OPCODE_SUPPORTED_INFRASTRUCTURE_AUTH_CIPHER_PAIRS,
;                  $WLAN_INTF_OPCODE_SUPPORTED_ADHOC_AUTH_CIPHER_PAIRS - An array of supported authentication and encryption pairs on the interface.
;                  |$asACPairs[$iIndex][0] - Authentication method
;                  |$asACPairs[$iIndex][1] - Encryption method
;                  $WLAN_INTF_OPCODE_SUPPORTED_COUNTRY_OR_REGION_STRING_LIST - A list of supported country or region strings
;                  $WLAN_INTF_OPCODE_STATISTICS - An array of driver statistics
;                  |$aiStats[0][0] - Four way handshake failures
;                  |$aiStats[0][1] - TKIP counter measures invoked
;                  |$aiStats[1][n] - Unicast counters
;                  |$aiStats[2][n] - Multicast counters
;                  |$aiStats[1-2][0] - Transmitted frame count
;                  |$aiStats[1-2][1] - Received frame count
;                  |$aiStats[1-2][2] - WEP excluded count
;                  |$aiStats[1-2][3] - TKIP local MIC failures
;                  |$aiStats[1-2][4] - TKIP replays
;                  |$aiStats[1-2][5] - TKIP ICV error count
;                  |$aiStats[1-2][6] - CCMP replays
;                  |$aiStats[1-2][7] - CCMP decrypt errors
;                  |$aiStats[1-2][8] - WEP undecryptable count
;                  |$aiStats[1-2][9] - WEP ICV error count
;                  |$aiStats[1-2][10] - Decrypt success count
;                  |$aiStats[1-2][11] - Decrypt failure count
;                  |$aiStats[3-n][n] - PHY counters
;                  |$aiStats[3-n][0] - Transmitted frame count
;                  |$aiStats[3-n][1] - Multicast transmitted frame count
;                  |$aiStats[3-n][2] - Failed count
;                  |$aiStats[3-n][3] - Retry count
;                  |$aiStats[3-n][4] - Multiple retry count
;                  |$aiStats[3-n][5] - Max TX lifetime exceeded count
;                  |$aiStats[3-n][6] - Transmitted fragment count
;                  |$aiStats[3-n][7] - RTS success count
;                  |$aiStats[3-n][8] - RTS failure count
;                  |$aiStats[3-n][9] - ACK failure count
;                  |$aiStats[3-n][10] - Received frame count
;                  |$aiStats[3-n][11] - Multicast received frame count
;                  |$aiStats[3-n][12] - Promiscuous received frame count
;                  |$aiStats[3-n][13] - Max RX lifetime exceeded count
;                  |$aiStats[3-n][14] - Frame duplicate count
;                  |$aiStats[3-n][15] - Received fragment count
;                  |$aiStats[3-n][16] - Promiscuous received fragment count
;                  |$aiStats[3-n][17] - FCS error count
;                  $WLAN_INTF_OPCODE_RSSI - The received signal strength
;                  $WLAN_INTF_OPCODE_CURRENT_OPERATION_MODE - The current operation mode of the interfacce
;                  @extended - The type of opcode returned
;                  0 - Undetermined
;                  1 - Set by group policy
;                  2 - Set by user
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |4 - Invalid parameter.
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  Not all queries are supported on all interfaces.
; Related .......: _Wlan_SetInterface
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_QueryInterface($iOpCode = $WLAN_INTF_OPCODE_INTERFACE_STATE)
	Local $tData, $pData, $vData, $iOpcodeValueType, $iItems
	$pData = _WinAPI_WlanQueryInterface($hClientHandle, $pGUID, $iOpCode)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanQueryInterface"))

	$iOpcodeValueType = @extended
	$tData = DllStructCreate("dword DATA", $pData)
	$vData = DllStructGetData($tData, "DATA")

	Switch $iOpCode
		Case $WLAN_INTF_OPCODE_RADIO_STATE
			$iItems = $vData
			Local $vData[$iItems][3]
			For $i = 0 To $iItems -1
				$tData = DllStructCreate("dword Index; dword SWRadioState; dword HWRadioState", Ptr($i * 12 + Number($pData) + 4))
				$vData[$i][0] = DllStructGetData($tData, "Index")
				$vData[$i][1] = "Software " & _Wlan_EnumToString("DOT11_RADIO_STATE", DllStructGetData($tData, "SWRadioState"))
				$vData[$i][2] = "Hardware " & _Wlan_EnumToString("DOT11_RADIO_STATE", DllStructGetData($tData, "HWRadioState"))
			Next
		Case $WLAN_INTF_OPCODE_BSS_TYPE
			$vData = _Wlan_EnumToString("DOT11_BSS_TYPE", $vData)
		Case $WLAN_INTF_OPCODE_INTERFACE_STATE
			$vData = _Wlan_EnumToString("WLAN_INTERFACE_STATE", $vData)
		Case $WLAN_INTF_OPCODE_CURRENT_CONNECTION
			Local $vData[15]
			$tData = DllStructCreate("dword IntState; dword ConnMode; wchar ProfName[256]; dword SSIDLen; char SSID[32]; dword BSSType; byte BSSID[6]; " & _
			"dword PhyType; dword PhyIndex; dword Signal; dword RxRate; dword TxRate; dword SecEnabled; dword OneXEnabled; dword Auth; dword Ciph", $pData)
			$vData[0] = _Wlan_EnumToString("WLAN_INTERFACE_STATE", DllStructGetData($tData, "IntState"))
			$vData[1] = _Wlan_EnumToString("WLAN_CONNECTION_MODE", DllStructGetData($tData, "ConnMode"))
			$vData[2] = DllStructGetData($tData, "ProfName")
			$vData[3] = DllStructGetData($tData, "SSID")
			$vData[4] = _Wlan_EnumToString("DOT11_BSS_TYPE", DllStructGetData($tData, "BSSType"))
			$vData[5] = _Wlan_bMACToString(DllStructGetData($tData, "BSSID"))
			$vData[6] = _Wlan_EnumToString("DOT11_PHY_TYPE", DllStructGetData($tData, "PhyType"))
			$vData[7] = DllStructGetData($tData, "PhyIndex")
			$vData[8] = DllStructGetData($tData, "Signal")
			$vData[9] = DllStructGetData($tData, "RxRate")
			$vData[10] = DllStructGetData($tData, "TxRate")
			$vData[11] = "Security Disabled"
			If DllStructGetData($tData, "SecEnabled") Then $vData[11] = "Security Enabled"
			$vData[12] = "802.1x Disabled"
			If  DllStructGetData($tData, "OneXEnabled") Then  $vData[12] = "802.1x Enabled"
			$vData[13] = _Wlan_EnumToString("DOT11_AUTH_ALGORITHM", DllStructGetData($tData, "Auth"))
			$vData[14] = _Wlan_EnumToString("DOT11_CIPHER_ALGORITHM", DllStructGetData($tData, "Ciph"))
		Case $WLAN_INTF_OPCODE_SUPPORTED_INFRASTRUCTURE_AUTH_CIPER_PAIRS, $WLAN_INTF_OPCODE_SUPPORTED_ADHOC_AUTH_CIPER_PAIRS
			$iItems = $vData
			Local $vData[$iItems][2]
			For $i = 0 To $iItems -1
				$tData = DllStructCreate("dword Auth; dword Ciph", Ptr($i * 8 + Number($pData) + 4))
				$vData[$i][0] = _Wlan_EnumToString("DOT11_AUTH_ALGORITHM", DllStructGetData($tData, "Auth"))
				$vData[$i][1] = _Wlan_EnumToString("DOT11_CIPHER_ALGORITHM", DllStructGetData($tData, "Ciph"))
			Next
		Case $WLAN_INTF_OPCODE_SUPPORTED_COUNTRY_OR_REGION_STRING_LIST
			$iItems = $vData
			Local $vData[$iItems]
			For $i = 0 To $iItems -1
				$tData = DllStructCreate("char Region[3]", Ptr($i * 3 + Number($pData) + 4))
				$vData[$i][1] = DllStructGetData($tData, "Region")
			Next
		Case $WLAN_INTF_OPCODE_STATISTICS
			$tData = DllStructCreate("UINT64 4WayHSFails; UINT64 TKIPCMInv; UINT64 Reserved; UINT64 MacUcastCntrs[12]; " & _
					"UINT64 MacMcastCntrs[12]; dword noPhys; UINT64 PhyCntrs[18]", $pData)
			Local $vData[3 + DllStructGetData($tData, "noPhys")][18]
			$vData[0][0] = DllStructGetData($vData, "4WayHSFails")
			$vData[0][1] = DllStructGetData($vData, "TKIPCMInv")
			For $i = 1 To 12
				$vData[1][$i - 1] = DllStructGetData($vData, "MacUcastCntrs", $i)
				$vData[2][$i - 1] = DllStructGetData($vData, "MacMcastCntrs", $i)
			Next
			For $i = 1 To 18
				For $j = 3 To UBound($vData) - 1
					$vData[$j][$i - 1] = DllStructGetData($vData, "PhyCntrs", $i)
				Next
			Next
		Case $WLAN_INTF_OPCODE_CURRENT_OPERATION_MODE
			$vData = _Wlan_Dot11OpModeToString($vData)
		Case $WLAN_INTF_OPCODE_AUTOCONF_ENABLED, $WLAN_INTF_OPCODE_BACKGROUND_SCAN_ENABLED, $WLAN_INTF_OPCODE_MEDIA_STREAMING_MODE, _
				$WLAN_INTF_OPCODE_SUPPORTED_SAFE_MODE, $WLAN_INTF_OPCODE_CERTIFIED_SAFE_MODE
			If $vData Then
				$vData = True
			Else
				$vData = False
			EndIf
		Case $WLAN_INTF_OPCODE_CHANNEL_NUMBER, $WLAN_INTF_OPCODE_RSSI
		Case $WLAN_INTF_OPCODE_IHV_START To $WLAN_INTF_OPCODE_IHV_END
			_WinAPI_WlanFreeMemory($pData)
			Return SetError(4, 0, False)
		Case Else
			_WinAPI_WlanFreeMemory($pData)
			Return SetError(4, 0, False)
	EndSwitch

	_WinAPI_WlanFreeMemory($pData)
	Return SetExtended($iOpcodeValueType, $vData)
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _Wlan_ReasonCodeToString
; Description ...: Retrieves a string that describes a specified reason code.
; Syntax.........: _Wlan_ReasonCodeToString($iReasonCode)
; Parameters ....: $iReasonCode - A WLAN_REASON_CODE value of which the string description is requested.
; Return values .: Success - A string that describes the specified reason code.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_ReasonCodeToString($iReasonCode)
	If Not $iReasonCode Then Return ""
	Local $tReason = DllStructCreate("wchar Reason[256]")
	_WinAPI_WlanReasonCodeToString($iReasonCode, DllStructGetSize($tReason), DllStructGetPtr($tReason))
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanReasonCodeToString"))
	Return DllStructGetData($tReason, "Reason")
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_RenameProfile
; Description ...: Renames an existing profile.
; Syntax.........: _Wlan_RenameProfile($sOldProfileName, $sNewProfileName)
; Parameters ....: $sOldProfileName - The name of the profile to change.
;                  $sNewProfileName - The new name of the profile.
; Return values .: Success - The profile in the specified format.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is not supported in Windows XP.
; Related .......: _Wlan_GetProfile _Wlan_SetProfile _Wlan_DeleteProfile
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_RenameProfile($sOldProfileName, $sNewProfileName)
	_WinAPI_WlanRenameProfile($hClientHandle, $pGUID, $sOldProfileName, $sNewProfileName)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanRenameProfile"))
	Return True
EndFunc

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: _Wlan_ReportAPIError
; Description ...: Writes API error messages to the console.
; Syntax.........: _Wlan_ReportAPIError($iErrType, $iErrCode, $iReasonCode = 0, $iLine = 0, $sFunction = "")
; Parameters ....: $iErrType - Must be 2
;                  $iErrCode - The error code of the _WinAPI_Wlan* function.
;                  $iReasonCode - A WLAN_REASON_CODE value.
;                  $iLine - The line where the error occured.
;                  $sFunction - The function that failed.
; Return values .: Success - False
;                  |True - $iErrCode is null
;                  Failure - False
; Author ........: MattyD
; Modified.......:
; Remarks .......: $fDebugWifi must not be null for messages to be written to the console.
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_ReportAPIError($iErrType, $iErrCode, $iReasonCode = 0, $iLine = 0, $sFunction = "")
	If Not $iErrCode Then Return True
	If Not $fDebugWifi Or $iErrType <> 2 Then Return False
	Local $tBuffer, $sErrMsg, $sReasonCode
	ConsoleWrite("!APIError ")
	If $iLine > 0 Then ConsoleWrite("@Ln[" & $iLine & "] ")
	If $sFunction Then ConsoleWrite($sFunction & " - ")

	$tBuffer = DllStructCreate("wchar Msg[128]")
	DllCall("Kernel32.dll", "int", "FormatMessageW", "int", 0x1000, "hwnd", 0, "int", $iErrCode, "int", 0, "ptr", DllStructGetPtr($tBuffer), "int", DllStructGetSize($tBuffer) / 2, "ptr", 0)
	$sErrMsg = DllStructGetData($tBuffer, "Msg")
	If Not $sErrMsg Then ConsoleWrite(@CRLF)

	If $iReasonCode Then
		$tBuffer = DllStructCreate("wchar Msg[128]")
		_WinAPI_WlanReasonCodeToString($iReasonCode, DllStructGetSize($tBuffer) / 2, DllStructGetPtr($tBuffer))
		$sReasonCode = DllStructGetData($tBuffer, "Msg")
		If $sReasonCode Then ConsoleWrite($sErrMsg & "!Because: " & $sReasonCode & @CRLF)
	Else
		ConsoleWrite($sErrMsg)
	EndIf
	Return False
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_ReportUDFError
; Description ...: Writes error messages to the console.
; Syntax.........: _Wlan_ReportUDFError($iError = @error, $iExtended = @extended, $iLine = @ScriptLineNumber)
; Parameters ....: $iError - The error code of the _Wlan* function.
;                  $iExtended - The extended value of the _Wlan* function.
;                  $iLine - The line where the error occured.
; Return values .: Success - False
;                  |True - $iError is null
;                  Failure - False
; Author ........: MattyD
; Modified.......:
; Remarks .......: $fDebugWifi must not be null for messages to be written to the console.
;                  The returned @error and @extended outputs are the same as $iError and $iExtended
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_ReportUDFError($iError = @error, $iExtended = @extended, $iLine = @ScriptLineNumber)
	If Not $iError Then Return SetError($iError, $iExtended, True)
	If Not $fDebugWifi Then Return SetError($iError, $iExtended, False)
	ConsoleWrite("!UDFError ")
	If $iLine > 0 Then ConsoleWrite("@Ln[" & $iLine & "] ")
	Switch $iError
		Case 1
			ConsoleWrite("Could not call the dll. DllCall() error[" & $iExtended & "]" & @CRLF)
		Case 2
			ConsoleWrite("An API error occurred. API error[" & $iExtended & "]" & @CRLF)
		Case 3
			ConsoleWrite("The output is null." & @CRLF)
		Case 4
			ConsoleWrite("Invalid parameter." & @CRLF)
		Case 5
			ConsoleWrite("The function timed out." & @CRLF)
		Case 6
			ConsoleWrite("A dependancy is missing or not running." & @CRLF)
	EndSwitch
	Return SetError($iError, $iExtended, False)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_SaveTemporaryProfile
; Description ...: Saves a temporary profile (specified when using _Wlan_Connect) to the profile store.
; Syntax.........: _Wlan_SaveTemporaryProfile($sProfileName, $iFlags = 0, $fOverwrite = True)
; Parameters ....: $sProfileName - The name to call the profile.
;                  $iFlags - The flags to set on the profile.
;                  |0 - The profile is an all-user profile.
;                  |$WLAN_PROFILE_USER (0x02) - The profile is a per-user profile.
;                  |$WLAN_PROFILE_CONNECTION_MODE_SET_BY_CLIENT (0x10000) - The profile was created by the client.
;                  |$WLAN_PROFILE_CONNECTION_MODE_AUTO (0x20000) - The profile was created by the automatic configuration module.
;                  $fOverwrite - If True, any existing profile with the same name as $sProfileName will be overwritten.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  This function is not supported in Windows XP.
; Related .......: _Wlan_Connect
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_SaveTemporaryProfile($sProfileName, $iFlags = 0, $fOverwrite = True)
	_WinAPI_WlanSaveTemporaryProfile($hClientHandle, $pGUID, $sProfileName, $iFlags, 0, $fOverwrite)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanDeleteprofile"))
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_Scan
; Description ...: Requests a scan for available networks on the indicated interface.
; Syntax.........: _Wlan_Scan($fWait = False, $iTimeout = 6, $sSSID = "", $pWLAN_RAW_DATA = 0)
; Parameters ....: $fWait - If True the function will wait for the scan to finish before returning.
;                  $iTimeout - The maximum length of time in seconds the function should wait before returning.
;                  $sSSID - The SSID of the network to be scanned (Vista, 2008 and up)
;                  $pWLAN_RAW_DATA - A pointer to an information element to include in probe requests. (Vista, 2008 and up)
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |5 - The function timed out.
;                  |6 - Then notification module is not running.
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  In Windows XP the $sSSID and $pWLAN_RAW_DATA parameters must be null.
;                  If $fWait is true in Windows XP the fuction will always time out.
;                  Certified drivers must be able to complete a scan in 4 seconds.
; Related .......: _Wlan_GetNetworks
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_Scan($fWait = False, $iTimeout = 6, $sSSID = "", $pWLAN_RAW_DATA = 0)
	Local $tSSID, $pSSID, $iTimer, $avNotification

	If $sSSID Then
		$tSSID = DllStructCreate("ulong uSSIDLength; char ucSSID[32]")
		DllStructSetData($tSSID, "ucSSID", $sSSID)
		DllStructSetData($tSSID, "uSSIDLength", StringLen($sSSID))
		$pSSID = DllStructGetPtr($tSSID)
	EndIf

	_WinAPI_WlanScan($hClientHandle, $pGUID, $pSSID, $pWLAN_RAW_DATA)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanScan"))
	If Not $fWait Then Return True

	$iTimer = TimerInit()
	While TimerDiff($iTimer) < $iTimeout * 1000
		$avNotification = _Wlan_GetNotification()
		If @error And @error <> 3 Then Return SetError(6, 0, False)
		If @error = 3 Then ContinueLoop
		If $avNotification[0] = $WLAN_NOTIFICATION_SOURCE_ACM And $avNotification[1] = $WLAN_NOTIFICATION_ACM_SCAN_COMPLETE Then Return True
	WEnd
	Return SetError(5, 0, False)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_SelectInterface
; Description ...: Selects an interface for following functions to interact with.
; Syntax.........: _Wlan_SelectInterface($sGUID)
; Parameters ....: $sGUID - The GUID of the desired interface.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |4 - Invalid parameter.
; Author ........: MattyD
; Modified.......:
; Remarks .......: The GUIDs of compatible interfaces can be found by calling _Wlan_EnumInterfaces
; Related .......: _Wlan_EnumInterfaces
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_SelectInterface($sGUID)
	Local $asGUID
	$sGUID = StringRegExpReplace($sGUID, "[}{]", "")
	$asGUID = StringSplit($sGUID, "-")
	If UBound($asGUID) <> 6 Then Return SetError(4, 0, False)

	$tGUID = DllStructCreate("ulong data1; ushort data2; ushort data3; ubyte data4[8]")
	$pGUID = DllStructGetPtr($tGUID)
	DllStructSetData($tGUID, "data1", Binary(Number("0x" & $asGUID[1])))
	DllStructSetData($tGUID, "data2", Binary(Number("0x" & $asGUID[2])))
	DllStructSetData($tGUID, "data3", Binary(Number("0x" & $asGUID[3])))
	DllStructSetData($tGUID, "data4", Binary("0x" & $asGUID[4] & $asGUID[5]))
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_QueryACParameter
; Description ...: Sets parameters of the auto configuration service.
; Syntax.........: _Wlan_QueryACParameter($iOpCode)
; Parameters ....: $iOpCode - A WLAN_AUTOCONF_OPCODE value that specifies the configuration parameter to be set (the expected data type $vData in brackets):
;                  |$WLAN_AUTOCONF_OPCODE_SHOW_DENIED_NETWORKS (Boolean)
;                  |$WLAN_AUTOCONF_OPCODE_ALLOW_EXPLICIT_CREDS (Boolean)
;                  |$WLAN_AUTOCONF_OPCODE_BLOCK_PERIOD (Integer)
;                  |$WLAN_AUTOCONF_OPCODE_ALLOW_VIRTUAL_STATION_EXTENSIBILITY (Boolean)
;                  $vData - an integer or boolean, depending on the $iOpCode value - see above.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  This function is not supported in Windows XP.
; Related .......: _Wlan_QueryACParameter
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_SetACParameter($iOpCode, $vData)
	Local $tData

	$tData = DllStructCreate("dword DATA")
	DllStructSetData($tData, "DATA", Number($vData))

	_WinAPI_WlanSetAutoConfigParameter($hClientHandle, $iOpCode, DllStructGetSize($tData), DllStructGetPtr($tData))
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanSetAutoConfigParameter"))
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_SetInterface
; Description ...: Sets user-configurable parameters for a specified interface.
; Syntax.........: _Wlan_SetInterface($iOpCode, $vData, $iPhyIndex = 0)
; Parameters ....: $iOpCode - A value that specifies the parameter to be set (the expected data type of $vData in brackets):
;                  |$WLAN_INTF_OPCODE_AUTOCONF_ENABLED        (Boolean) (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_BACKGROUND_SCAN_ENABLED (Boolean) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_RADIO_STATE             (Boolean) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_BSS_TYPE                ($DOT11_BSS_TYPE_INFRASTRUCTURE, $DOT11_BSS_TYPE_INDEPENDENT or $DOT11_BSS_TYPE_ANY) (XP, 2008 and up)
;                  |$WLAN_INTF_OPCODE_MEDIA_STREAMING_MODE    (Boolean) (Vista, 2008 and up)
;                  |$WLAN_INTF_OPCODE_CURRENT_OPERATION_MODE  ($DOT11_OPERATION_MODE_EXTENSIBLE_STATION or $DOT11_OPERATION_MODE_NETWORK_MONITOR) (Vista, 2008 and up)
;                  $vData - See above.
;                  $iPhyIndex - The Phy index to change the radio state on.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  Changing the radio state on one phy index usually results in all the indexies following suit.
;                  Changing the radio state will cause related changes of the wireless Hosted Network or virtual wireless adapter radio states.
; Related .......: _Wlan_QueryInterface
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_SetInterface($iOpCode, $vData, $iPhyIndex = 0)
	Local $tData

	Switch $iOpCode
		Case $WLAN_INTF_OPCODE_AUTOCONF_ENABLED, $WLAN_INTF_OPCODE_BACKGROUND_SCAN_ENABLED, $WLAN_INTF_OPCODE_MEDIA_STREAMING_MODE, _
				$WLAN_INTF_OPCODE_INTERFACE_STATE
			$tData = DllStructCreate("dword DATA")
			DllStructSetData($tData, "DATA", Number($vData))
		Case $WLAN_INTF_OPCODE_BSS_TYPE
			If $vData = "Infrastructure" Then $vData = $DOT11_BSS_TYPE_INFRASTRUCTURE
			If $vData = "Ad Hoc" Then $vData = $DOT11_BSS_TYPE_INDEPENDENT
			If $vData = "Any BSS Type" Then $vData = $DOT11_BSS_TYPE_ANY
			$tData = DllStructCreate("dword DATA")
			DllStructSetData($tData, "DATA", $vData)
		Case $WLAN_INTF_OPCODE_RADIO_STATE
			$tData = DllStructCreate("dword Index; dword SWRadioState; dword HWRadioState")
			DllStructSetData($tData, "SWRadioState", $vData)
			DllStructSetData($tData, "Index", $iPhyIndex)
		Case $WLAN_INTF_OPCODE_CURRENT_OPERATION_MODE
			If $vData = "Extensible Station" Then $vData = $DOT11_OPERATION_MODE_EXTENSIBLE_STATION
			If $vData = "Network Monitor" Then $vData = $DOT11_OPERATION_MODE_NETWORK_MONITOR
			$tData = DllStructCreate("dword DATA")
			DllStructSetData($tData, "DATA", Number($vData))
		Case $WLAN_INTF_OPCODE_IHV_START To $WLAN_INTF_OPCODE_IHV_END
			Return SetError(4, 0, False)
		Case Else
			Return SetError(4, 0, False)
	EndSwitch

	_WinAPI_WlanSetInterface($hClientHandle, $pGUID, $iOpCode, DllStructGetSize($tData), DllStructGetPtr($tData))
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanSetInterface"))
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_SetProfile
; Description ...: Starts the notification module.
; Syntax.........: _Wlan_SetProfile($vProfile, ByRef $sReason, $iFlags = 0, $fOverwrite = True)
; Parameters ....: $vProfile - The profile to set in XML or object format.
;                  $sReason - Provides a reason why the function failed. (output)
;                  $iFlags - The flags to be set on the profile. (Vista, 2008 and up)
;                  |0 - The profile is a group policy profile.
;                  |$WLAN_PROFILE_GROUP_POLICY (1) - The profile is a group policy profile.
;                  |$WLAN_PROFILE_USER (2) - The profile is a per-user profile.
;                  $fOverwrite - Specifies whether this profile is overwriting an existing profile.
;                  |True - Overwrite the existing profile.
;                  |False - Do not overwrite the existing profile.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |6 - A dependency is missing. (@extended - _AutoItObject_Create error code.)
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  A new profile is added at the top of the list after the group policy profiles.
;                  A profile's position in the list is not changed if an existing profile is overwritten.
;                  In Windows XP, ad hoc profiles appear after the infrastructure profiles in the profile list.
;                  In Windows XP, new ad hoc profiles are placed at the top of the ad hoc list, after the group policy and infrastructure profiles.
;                  Only one SSID is supported per profile in Windows XP.
;                  Infrastructure profile names in Windows XP must be the same as the SSID.
;                  Ad Hoc profile names in Windows XP must be the same as the SSID with a "-adhoc" suffix.
;                  The profile object is defined as follows:
;                  For profiles using a shared key, the key type is deemed to be a Network Key if either:
;                  1. Key material value is in a hex format
;                  2. Authentication is set to Shared Key
;                  3. Encryption is set to WEP
;                  The key type is a Pass Phrase if the authentication method is WPA-PSK or WPA2-PSK and the key material in ASCII format.
;                  Elements of a list type should be treated as below:
;                  The add method should be used to add an item to the list (e.g. $oProfile.SSID.Add("MySSID"))
;                  Items in the list should be retrieved using a For...In...Next loop.
;                  General: ($oProfile)
;                  |.XML - The XML representation of the profile (Ignored by _Wlan_SetProfile) (String) (Opt)
;                  |.Name - Name of the profile (String) (Req)
;                  |.SSID - A list of SSIDs to connect to (List of strings) (Req)
;                  |.Type - The network type ("Infrastructure" or "Ad Hoc") (Req)
;                  |.Auth - Authentication method ("Open", "Shared Key", "WEP", "WPA-PSK", "WPA2-PSK", "WPA" or "WPA2") (Req)
;                  |.Encr - Encryption method ("AES" or "TKIP") (Req)
;                  Key: ($oProfile.Key)
;                  |.Protected - Specifies if the Material property is encrypted (Boolean) (Req if using a Shared Key)
;                  |.Type - Specifies the format of the Material property ("Network Key" or "Pass Phrase") (Req if using a Shared Key)
;                  |.Material - The key (String) (Req if using a Shared Key)
;                  |.Index - Specifies the key index to use for WEP  authentication (integer 1 - 4) (Req if using WEP)
;                  General Options: ($oProfile.Options)
;                  |.NonBroadcast - Specifies whether the service should attempt to connect to the network even if it is not broadcasting a SSID (Boolean) (Opt)
;                  |.ConnMode - Specifies whether the service should automatically connect to the network ("Automatic" or "Manual") (Req)
;                  |.Autoswitch - Specifies whether the service should connect to a more preferred network if it becomes available (Boolean) (Opt - Vista, 2008 and up)
;                  |.PhyTypes - Specifies the radio types the network must have before it becomes connectable (List of strings - "a", "b", "g" or "n") (Opt - Vista, 2008 and up)
;                  802.1x Options: ($oProfile.OneX)
;                  |.Enabled - Specifies if 802.1x authentication should be used (Boolean) (Req)
;                  |.AuthMode - The type of credentials used for authentication ("Machine Or User", "Machine", "User" or "geust") (Opt - Vista, 2008 and up)
;                  |.SuppMode - The method of transmission used for EAPOL-Start messages ("Inhibit Transmission", "Include Learning" or "Compliant") (Opt - Vista, 2008 and up)
;                  |.CacheUserData - Specifies whether the user credentials are cached for subsequent connections (Boolean) (Opt - Vista, 2008 and up)
;                  |.AuthPeriod - The maximum number of seconds a client should wait for a response from the authenticator (Integer 1 - 3600) (Opt - Vista, 2008 and up)
;                  |.HeldPeriod - The number of seconds a client should wait before re-attempting to authenticate after a failure (Integer 1 - 3600) (Opt - Vista, 2008 and up)
;                  |.MaxAuthFailures - The maximum number of authentication failures allowed for a set of credentials (Integer 1 - 100) (Opt - Vista, 2008 and up)
;                  |.MaxStart - The number of EAPOL-Start messages the client should send before assuming there is no authenticator (Integer 1 - 100) (Opt - Vista, 2008 and up)
;                  |.StartPeriod - The number of seconds to wait before an EAPOL-Start is sent (Integer 1 - 3600) (Opt - Vista, 2008 and up)
;                  Single Sign On Options: ($oProfile.OneX.SSO)
;                  |.Type - Specifies when single sign on should be performed ("Pre Logon", "Post Logon") (Req if using SSO - Vista, 2008 and up)
;                  |.MaxDelay - The maximum number of seconds the before the single sign on connection attempt fails (Integer 0 - 120) (Opt - Vista, 2008 and up)
;                  |.UserBasedVLAN - Specifies if the virtual LAN used by the device changes based on the user's credentials (Boolean) (Opt - Vista, 2008 and up)
;                  |.AllowMoreDialogs - Secifies if additional dialogs should be allowed to be displayed during single sign on (Boolean) (Opt - 7, 2008 R2 and up)
;                  Pairwise Master Key Options: ($oProfile.PMK)
;                  |.CacheEnabled - Specifies if PMK caching is enabled (Boolean) (Opt if using WPA2 - Vista, 2008 and up)
;                  |.CacheTTL - The number of minutes a PMK cache should be kept (Integer 5 - 1440) (Opt if using WPA2 - Vista, 2008 and up)
;                  |.CacheSize - The number of entries in the PMK cache (Integer 1 - 255) (Opt if using WPA2 - Vista, 2008 and up)
;                  |.PreAuthEnabled - Specifies whether pre-authentication should be used (Boolean) (Opt if using WPA2 - Vista, 2008 and up)
;                  |.PreAuthThrottle - The number pre-authentication attempts to try on neighboring APs (Integer 1 - 16) (Opt if using WPA2 - Vista, 2008 and up)
;                  Federal Information Processing Standards Options: ($oProfile.FIPS)
;                  |.Enabled - Specifies is FIPS mode is enabled (Boolean) (Opt if using WPA2 - Vista, 2008 and up)
;                  EAP Options: ($oProfile.EAP)
;                  |.BaseType - The base EAP type the network is using ("PEAP" or "TLS") (Req if using EAP)
;                  |.Type - The EAP type the network is using ("PEAP-MSCHAP", "PEAP-TLS" or "TLS") (Req if using EAP without blob)
;                  |.Blob - A binary representation of the EAP configuration of the network (Req if using EAP without further configuration)
;                  Server Validation Options: ($oProfile.EAP.PEAP.ServerValidation, $oProfile.EAP.PEAP.TLS.ServerValidation, $oProfile.EAP.TLS.ServerValidation)
;                  |.NoUserPrompt - Indicates whether the user should be asked for server validation (Boolean) (Opt if using EAP without blob)
;                  |.ServerNames - A list of servers the client trusts delimited by semicolons (regular expressions may be used) (String) (Opt if using EAP without blob)
;                  |.ThumbPrints - Thumb prints of root certificate authorities (CAs) that are trusted by the client (List of strings) (Opt if using EAP without blob)
;                  |.Enabled - Indicates whether server validation is performed (Boolean) (Opt if using EAP without blob - 7, 2008 R2 and up)
;                  |.AcceptServerNames - Indicates whether the name of a server is read (Boolean) (Opt if using EAP without blob - 7, 2008 R2 and up)
;                  PEAP Options: ($oProfile.EAP.PEAP)
;                  |.FastReconnect - Indicates whether to perform a fast reconnect (Boolean) (Opt if using PEAP without blob)
;                  |.QuarantineChecks - Indicates whether to perform Network Access Protection (NAP) checks (Boolean) (Opt if using PEAP without blob)
;                  |.RequireCryptoBinding - Indicates whether to authenticate exclusively with servers that support cryptobinding (Boolean) (Opt if using PEAP without blob)
;                  |.EnableIdentityPrivacy - Indicates if an anonymous identity should be used (Boolean) (Opt if using PEAP without blob - 7, 2008 R2 and up)
;                  |.AnonUsername - Specifies the username to be sent in place of a user's true username (String) (Opt if using PEAP without blob - 7, 2008 R2 and up)
;                  TLS Options: ($oProfile.EAP.PEAP.TLS, $oProfile.EAP.TLS)
;                  |.Source - Specifies the certificate source ("Certificate Store" or "Smart Card") (Req if using TLS without blob)
;                  |.SimpleCertSel - Determines if TLS should perform a certificate search without any drop-down lists for selection (Boolean) (Opt if using TLS without a smat card and without blob)
;                  |.DiffUsername - Determines if TLS should use a user name other than the name that appears on the certificate (Boolean) (Opt if using TLS without blob)
;                  MSCHAP Options: ($oProfile.EAP.PEAP.MSCHAP)
;                  |.UseWinLogonCreds - Determines if MSCHAP obtains credentials from winlogon othe the user (Boolean) (Opt if using PEAP-MSCHAP without blob)
; Related .......: _Wlan_GetProfile _WlanSetProfileUserData
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_SetProfile($vProfile, ByRef $sReason, $iFlags = 0, $fOverwrite = True)
	Local $iReasonCode, $iError, $iExtended
	If IsObj($vProfile) Then
		$vProfile = _Wlan_GenerateXMLProfile($vProfile)
		If @error Then Return _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_Wlan_GenerateXMLProfile")
	EndIf

	_WinAPI_WlanSetProfile($hClientHandle, $pGUID, $iFlags, $vProfile, $iReasonCode, 0, $fOverwrite)
	If @error Then
		$iError = @error
		$iExtended = @extended
		$sReason = $iReasonCode
		If $iReasonCode Then
			$sReason = _Wlan_ReasonCodeToString($iReasonCode)
			Return _Wlan_ReportAPIError($iError, $iExtended, $iReasonCode, @ScriptLineNumber, "_WinAPI_WlanSetProfile")
		EndIf
		Return _Wlan_ReportAPIError($iError, $iExtended, 0, @ScriptLineNumber, "_WinAPI_WlanSetProfile")
	EndIf

	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_SetProfileList
; Description ...: Sets a list of profiles in order of preference.
; Syntax.........: _Wlan_SetProfileList($asProfileNames)
; Parameters ....: $asProfileNames - An array of profile names in order of preference.
; Return values .: Success - True
;                  Failure - False
;                  @Error - 0 - No error.
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |4 - Invalid parameter.
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  The position of group policy profiles cannot be changed.
;                  In Windows XP, ad hoc profiles always appear below Infrastructure profiles.
; Related .......: _Wlan_GetProfileList _Wlan_SetProfileList _Wlan_DeleteProfile
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_SetProfileList($asProfileNames)
	Local $tagProfileNames, $tProfileNames, $pProfileNames, $iItems = UBound($asProfileNames)
	If Not $iItems Then Return SetError(4, 0, False)

	For $i = 0 To $iItems - 1
		$tagProfileNames &= "ptr;"
	Next
	For $i = 0 To $iItems - 1
		$tagProfileNames &= "wchar[256];"
	Next
	$tagProfileNames = StringTrimRight($tagProfileNames, 1)

	$tProfileNames = DllStructCreate($tagProfileNames)
	$pProfileNames = DllStructGetPtr($tProfileNames)
	For $i = 0 To $iItems - 1
		DllStructSetData($tProfileNames, $i + 1, Ptr(4 * $iItems + $i * 512 + Number($pProfileNames)))
		DllStructSetData($tProfileNames, $iItems + $i + 1, $asProfileNames[$i])
	Next

	_WinAPI_WlanSetProfileList($hClientHandle, $pGUID, $iItems, $pProfileNames)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanSetProfileList"))

	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_SetProfilePosition
; Description ...: Sets the position of a single, specified profile in the preference list.
; Syntax.........: _Wlan_SetProfilePosition($sProfileName, $iPosition)
; Parameters ....: $sProfileName - The name of the profile to move.
;                  $iPosition - Indicates the position in the preference list that the profile should be shifted to. (0 is the first position)
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  The position of group policy profiles cannot be changed.
;                  In Windows XP, ad hoc profiles always appear below Infrastructure profiles.
; Related .......: _Wlan_GetProfileList _Wlan_SetProfileList _Wlan_DeleteProfile
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_SetProfilePosition($sProfileName, $iPosition)
	_WinAPI_WlanSetProfilePosition($hClientHandle, $pGUID, $sProfileName, $iPosition)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanSetProfilePosition"))
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_SetProfileUserData
; Description ...: Sets the EAP user credentials as specified by an XML string.
; Syntax.........: _Wlan_SetProfileUserData($sProfileName, $vUserData, $iFlags = 0)
; Parameters ....: $sProfile - The name of the profile associated with the EAP user data.
;                  $vUserData - User credentials in a XML or object format.
;                  $iFlags - The flags to set on the profile. (7, 2008 R2 and up)
;                  |$WLAN_SET_EAPHOST_DATA_ALL_USERS (0x01) - Set EAP host data for all users of this profile.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: On Vista and Server 2008, these credentials can only be used by the caller.
;                  If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  The profile object is defined as follows:
;                  General: ($oUserData)
;                  |.BaseType - The base EAP type the network is using ("PEAP" or "TLS") (Req)
;                  |.Type - The EAP type the network is using ("PEAP-MSCHAP", "PEAP-TLS" or "TLS") (Req if using EAP without blob)
;                  |.Blob - A binary representation of the host user data (Req if there is no further configuration)
;                  PEAP options: ($oUserData.PEAP)
;                  |.Username - The username to use for routing
;                  TLS options: ($oUserData.TLS, $oUserData.PEAP.TLS)
;                  |.Domain - The domain to use for authentication
;                  |.Username - The username to use for authentication
;                  |.Cert - The user certificate thumbprint to use for authentication
;                  MSCHAP options: ($oUserData.PEAP.MSCHAP)
;                  |.Domain - The domain to use for authentication
;                  |.Username - The username to use for authentication
;                  |.Password - The password to use for authentication
; Related .......: _Wlan_SetProfile
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_SetProfileUserData($sProfileName, $vUserData, $iFlags = 0)
	If IsObj($vUserData) Then $vUserData = _Wlan_GenerateXMLUserData($vUserData)
	_WinAPI_WlanSetProfileEapXmlUserData($hClientHandle, $pGUID, $sProfileName, $iFlags, $vUserData)
	If @error Then Return _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanSetProfileEapXmlUserData")
	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_StartNotificationModule
; Description ...: Starts the notification module.
; Syntax.........: _Wlan_StartNotificationModule($sNotifPath = "WlanNotify.exe", $iSource = $WLAN_NOTIFICATION_SOURCE_ALL, $iCheckfq = 250, $iKeepTime = 4000)
; Parameters ....: $sNotifPath - The file path of the notification module.
;                  $iSource - Specifies the notification source(s) to register for.
;                  |$WLAN_NOTIFICATION_SOURCE_ALL
;                  |$WLAN_NOTIFICATION_SOURCE_ACM
;                  |$WLAN_NOTIFICATION_SOURCE_MSM
;                  |$WLAN_NOTIFICATION_SOURCE_SECURITY (Currently unused)
;                  |$WLAN_NOTIFICATION_SOURCE_IHV
;                  |$WLAN_NOTIFICATION_SOURCE_HNWK
;                  |$WLAN_NOTIFICATION_SOURCE_ONEX
;                  $iCheckfq - The frquency in which messages from the notification module are cached (in milliseconds).
;                  $iKeepTime - Specifies how long to keep cached messages before they are discarded (in milliseconds).
; Return values .: Success - The PID of the module
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |4 - Invalid parameter.
;                  |6 - The notification module is not running.
; Author ........: MattyD
; Modified.......:
; Remarks .......: BitOr can be used to register for multiple notification sources.
;                  _Wlan_GetNotification should be called to read messages from the notification module.
; Related .......: _Wlan_StopNotificationModule
;                  _Wlan_GetNotification
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_StartNotificationModule($sNotifPath = "WlanNotify.exe", $iSource = $WLAN_NOTIFICATION_SOURCE_ALL, $iCheckfq = 250, $iKeepTime = $iNotifKeepTime)
	Local $iLastError, $tStartupInfo, $tProcessInfo, $sNotifPipe = "\\.\pipe\NWifi" & Random(1, 100, 1)
	Local Const $ERROR_PIPE_LISTENING = 536
	Local Const $ERROR_PIPE_CONNECTED = 535
	Local Const $ERROR_IO_PENDING = 997

	If ProcessExists($iNotifPID) Or $hNotifPipe Then
		_Wlan_StopNotificationModule()
		OnAutoItExitUnRegister("_Wlan_StopNotificationModule")
	EndIf
	If Not FileExists($sNotifPath) Then Return SetError(4, 0, False)

	$tNotifOverlap = DllStructCreate($tagOVERLAPPED)
	$pNotifOverlap = DllStructGetPtr($tNotifOverlap)

	$hNotifPipe = _NamedPipes_CreateNamedPipe($sNotifPipe, 0, 2, 0, 1, 1, 1, 1, 0, 4096, 5000, 0)
	If $hNotifPipe = -1 Then
		Return SetError(6, 0, False)
	EndIf

	_NamedPipes_ConnectNamedPipe($hNotifPipe, $pNotifOverlap)
	$iLastError = _WinAPI_GetLastError()
	If $iLastError <> $ERROR_PIPE_LISTENING And $iLastError <> $ERROR_PIPE_CONNECTED And $iLastError <> $ERROR_IO_PENDING Then
		_WinAPI_CloseHandle($hNotifPipe)
		$hNotifPipe = 0
		Return SetError(6, 0, False)
	EndIf

	$tStartupInfo = DllStructCreate($tagSTARTUPINFO)
	$tProcessInfo = DllStructCreate($tagPROCESS_INFORMATION)
	DllStructSetData($tStartupInfo, "Size", DllStructGetSize($tStartupInfo))

	If Not _WinAPI_CreateProcess("", $sNotifPath & " " & $sNotifPipe & " "  & $iSource, 0, 0, True, 0, 0, "", DllStructGetPtr($tStartupInfo), DllStructGetPtr($tProcessInfo)) Then
		_WinAPI_CloseHandle($hNotifPipe)
		$hNotifPipe = 0
		Return SetError(6, 0, False)
	EndIf

	$hNotifThread = DllStructGetData($tProcessInfo, "hthread")
	$iNotifPID = DllStructGetData($tProcessInfo, "ProcessID")

	$iNotifKeepTime = $iKeepTime

	AdlibRegister("_Wlan_CacheNotification", $iCheckfq)
	OnAutoItExitRegister("_Wlan_StopNotificationModule")
	Sleep(3000)
	Return $iNotifPID
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_StartSession
; Description ...: Prepares the script for following functions.
; Syntax.........: _Wlan_StartSession($vClientVersion = -1)
; Parameters ....: $vClientVersion - The version of the API to use.
;                  |< 1 - Request the highest version of the API that the client supports.
;                  |1.0 - XP SP2 with Wireless LAN API (KB918997), XP SP3
;                  |2.0 - Vista, Server 2008 and above
;                  |32-bit integer >= 1 - The high-order word designates the minor version whilst the low designates the major.
; Return values .: Success - An interface array.
;                  |$asInterfaces[$iIndex][0] - Interface GUID
;                  |$asInterfaces[$iIndex][1] - Interface Description
;                  |$asInterfaces[$iIndex][2] - Interface State
;                  @extended - Negotiated Version. See _Wlan_APIVersion.
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (@extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
;                  |3 - There is no data to return.
;                  |4 - Invalid parameter.
; Author ........: MattyD
; Modified.......:
; Remarks .......: If an API error occurs and $fDebugWifi is not null, a reason for the error will be written to the console.
;                  A Vista or 2008 and above platform may request to use version 1.0 of the API.
;                  Currently there are no minor versions of the API for versions 1 or 2.
;                  The interface at index 0 is set as the default for following functions. This can be changed with _Wlan_SelectInterface.
;                  If no interfaces are found, a program may wait for an "interface arrival" notification before calling _Wlan_EnumInterfaces and _Wlan_SelectInterface. (Vista, 2008 and up)
; Related .......: _Wlan_APIVersion
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_StartSession($vClientVersion = -1)
	Local $avInterfaces, $iClientVersion
	If $hClientHandle Then
		_WinAPI_WlanCloseHandle($hClientHandle)
		If @error Then _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanCloseHandle")
		OnAutoItExitUnregister("_Wlan_EndSession")
		$iNegotiatedVersion = 0
	EndIf

	If $vClientVersion < 1 Or $vClientVersion = Default Then
		$iClientVersion = 2
		If @OSVersion = "WIN_XP" Then $iClientVersion = 1
	Else
		$vClientVersion = _Wlan_APIVersion($vClientVersion)
		If @error Then Return SetError(@error, @extended, $vClientVersion)
		$iClientVersion = $vClientVersion[1]
	EndIf

	$hClientHandle = _WinAPI_WlanOpenHandle($iClientVersion)
	If @error Then Return SetError(@error, @extended, _Wlan_ReportAPIError(@error, @extended, 0, @ScriptLineNumber, "_WinAPI_WlanOpenHandle"))
	$iNegotiatedVersion = @extended
	OnAutoItExitRegister("_Wlan_EndSession")

	_AutoitObject_Startup()
	If @error Then Return SetError(6, @error, False)

	$avInterfaces = _Wlan_EnumInterfaces()
	If @error Then Return SetError(@error, @extended, False)

	_Wlan_SelectInterface($avInterfaces[0][0])
	Return SetExtended($iNegotiatedVersion, $avInterfaces)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_StopNotificationModule
; Description ...: Stops the Notification Module.
; Syntax.........: _Wlan_StopNotificationModule()
; Parameters ....:
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |6 - Notification module is not running.
; Author ........: MattyD
; Modified.......:
; Remarks .......:
; Related .......: _Wlan_StartNotificationModule
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_StopNotificationModule()
	Local $aResult
	AdlibUnRegister("_Wlan_CacheNotification")
	_WinAPI_CloseHandle($hNotifPipe)
	$hNotifPipe = 0
	If Not ProcessExists($iNotifPID) Then Return SetError(6, 0, False)
	$aResult = DllCall("kernel32.dll", "dword", "ResumeThread", "ptr", $hNotifThread)
	If @error Or Not $aResult[0] Then
		ProcessClose($iNotifPID)
	EndIf
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_UIEditProfile
; Description ...: Displays the wireless profile user interface (UI).
; Syntax.........: _Wlan_UIEditProfile($sProfileName, $iStartPage, ByRef $sReason, $hWindow = 0)
; Parameters ....: $sProfileName - Contains the name of the profile to be viewed or edited.
;                  $iStartPage - A WL_DISPLAY_PAGES value that specifies the active tab when the UI dialog box appears.
;                  |$WLConnectionPage (0) - Displays the Connection tab.
;                  |$WLSecurityPage (1) - Displays the Security tab.
;                  |$WLAdvPage (2) - Displays the advanced dialouge under the Security tab.
;                  $sReason - Provides a reason why the function failed. (output)
;                  $hWindow - The handle of the application window requesting the UI display. (opt)
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |1 - DllCall error. (@extended - DllCall error code.)
;                  |2 - API error. (extended - API error code. (http://msdn.microsoft.com/en-us/library/ms681381.aspx))
; Author ........: MattyD
; Modified.......:
; Remarks .......: This function is not supported in Windows XP.
;                  Any changes to the profile made in the UI will be saved in the profile store.
; Related .......: _Wlan_SetProfile
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_UIEditProfile($sProfileName, $iStartPage, ByRef $sReason, $hWindow = 0)
	Local $iClientVersion = $WLAN_UI_API_VERSION, $iReasonCode, $iError, $iExtended
	_WinAPI_WlanUIEditProfile($iClientVersion, $sProfileName, $pGUID, $hWindow, $iStartPage, $iReasonCode)
	If @error Then
		$iError = @error
		$iExtended = @extended
		$sReason = $iReasonCode
		If $iReasonCode Then
			$sReason = _Wlan_ReasonCodeToString($iReasonCode)
			Return _Wlan_ReportAPIError($iError, $iExtended, $iReasonCode, @ScriptLineNumber, "_WinAPI_WlanUIEditProfile")
		EndIf
		Return _Wlan_ReportAPIError($iError, $iExtended, 0, @ScriptLineNumber, "_WinAPI_WlanUIEditProfile")
	EndIf

	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _Wlan_WaitForNotification
; Description ...: Pauses a script until a specific notification is recieved.
; Syntax.........: _Wlan_WaitForNotification($iSource, $iNotification, $fInterfaceFilter = True, $iTimeout = -1)
; Parameters ....: $iSource - The notification source.
;                  $iNotif - The notification code.
;                  $fInterfaceFilter - If True the registered function will only be called if the notification is associated with the selected interface.
;                  $iTimeout - The maximum length of time in seconds to wait for a notification before resuming the script.
; Return values .: Success - True
;                  Failure - False
;                  @Error
;                  |0 - No error.
;                  |5 - The function timed out.
; Author ........: MattyD
; Modified.......:
; Remarks .......: If $iTimeout = -1 then the script will not time out.
; Related .......: _Wlan_GetNotification _Wlan_OnNotification
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Wlan_WaitForNotification($iSource, $iNotification, $fInterfaceFilter = True, $iTimeout = -1)
	Local $iTimer, $asNotification
	$iTimer = TimerInit()
	While 1
		$asNotification = _Wlan_GetNotification($fInterfaceFilter)
		If @error And @error <> 3 Then Return SetError(@error, @extended, $asNotification)
		If @error = 3 Then ContinueLoop
		If $asNotification[0] = $iSource And $asNotification[1] = $iNotification Then Return $asNotification
		If $iTimeout <> -1 And TimerDiff($iTimer) > $iTimeout * 1000 Then Return SetError(5, 0, False)
	WEnd
EndFunc

