#include-once
; =======================================================================
; Project Manager 3.0 Preprocessed - Date 25:04:2007 Time 14:28
; =======================================================================
; ------------------------------------------------------------------------------
;
; AutoIt Version: 	3.0
; Language: 		English
; Description: 		Functions that assist with using xml files
;					Stephen Podhajecki <gehossafats@netmdc.com>
; Dec 15, 2005, Update Jan10,2006, Update Feb 5,8,14-15, 2006
; Feb 24, 2006 Updated _XMLCreateCDATA, code cleaned up Gary Frost (custompcs@charter.net)
; Feb 24, 2006 bug fix in re-init COM error handler, rewrote _XMLCreateChildNodeWAttr()
; Jun 20, 2006 Added count to index[0] of the _XMLGetValue return value
; Jun 26, 2006 Changed _XMLCreateFile to include option flag for UTF-8 encoding
; Jun 29, 2006 Added count to index[0] of the _XMLGetValue return
;					Changed _XMLFileOpen and _XMLFileCreate
; Mar 30, 2007 Rewrote _AddFormat function to break up tags( no indentation)
;					Added _XMLTransform() which runs the document against a xsl(t) style sheet for indentation.
;					Changed _XMLCreateRootChildWAttr() to use new formatting
;					Changed _XMLChreateChildNode() to use new formatting
; Apr 02, 2007 Added _XMLReplaceChild()
; Apr 03, 2007 Changed other node creating function to use new formatting
;					Changed _XMLFileOpen() _XMLFileCreate to take an optional version number of MSXML to use.
;					Changed _XMLFileOpen() _XMLFileCreate find latest MSXML version logic.
; Apr 24, 2007 Fixed _XMLCreateChileNodeWAttr() - Instead of removal, It points to the function that replaced it.
; Apr 25, 2007 Added _XMLCreateAttrib()
;					Fixed bug with _XMLCreateRootNodeWAttr , _XMLCreateChild[Node]WAttr() where an extra node with same name was added.
;					Stripped extrenous comments.
;					Removed dependency on Array.au3 (I added the func from Array.au3 and renamed it to avoid conflicts.)
; May 03, 2007	Changed method of msxml version lookup.  Updated api call tips.
; May 11, 2007 Fixed missing \
; Jun 08, 2007 Fixed Namespace issue with _XMLCreateChildNode() and _XMLCreateChildNodeWAttr()
; Jun 12, 2007 Added workaround for MSXML6 to parse file with DTD's
; Jun 13, 2007 Fixed bug in _XMLGetField() where all text was returned in one node.
;						Actually this is not a bug, because it is the way that WC3 says it will be returned
;						However, it will now return in a way that is expected.
;					_XMLGetValue now returns just the text associated with the node or empty string.
; Jul 20, 2007 Fixed bug where failure to open the xml file would return an empty xml object, it now returns 0(no object).
;					Added object check to all applicable functions.	
; Aug 08, 2007 Add a _XMLSetAutoSave() to turn off/on forced saving within each function. --Thanks drlava
;					Added check for previous COM error handler.		--Thanks Lukasz Suleja
; Aug 27,2007  Changed property setting order for _XMLFileOpen.  The previous order was causing a problem with default namespaces.
;					-- It seems that "selectionLanguage" needs to be declared before some other properties.
; Aug 31,2007 Fixed bug where _XMLUpdateField would inadvertantly erase child nodes.
; Sep 07,2007 Fixed _XMLDeleteNode bug where non-existant node cause COM error.
;				  Added _XMLNodeExist function to check for the existence of node or nodes matching the specified path
; Jan 05,2008 Fixed documentation problem in function header with _XMLGetAttrib.
; Feb 25,2008 Fixed dimensioning bug in _XMLGetChildren  --Thanks oblique
; Mar 05,2008 Return values fixed for the following functions: --Thanks oblique
;             _XMLFileOpen ,_XMLLoadXML,_XMLCreateFile,
;             Documentation fixed for _XMLGetNodeCount,_XMLGetChildren --Thanks oblique
; Mar 07,2008 Small changes.
;             Fixed an issue point out by lgr.             
; ------------------------------------------------------------------------------
;===============================================================================
; XML DOM Wrapper functions
;
; These funtions require BETA as they need support for COM
;
;===============================================================================
#cs defs to add to au3.api
	_XMLCreateFile($sPath, $sRootNode, [$bOverwrite = False]) Creates an XML file with the given name and root.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLFileOpen($sXMLFile,[$sNamespace=""],[$ver=-1]) Creates an instance of an XML file.(Requires: #include <_XMLDomWrapper.au3>)
	;==============================================================================
	_XMLGetChildNodes ( strXPath ) Selects XML child Node(s) of an element based on XPath input from root node. (Requires: #include <_XMLDomWrapper.au3>)
	_XMLGetNodeCount ( strXPath, strQry = "", iNodeType = 1 ) Get node count for specified path and type. (Requires: #include <_XMLDomWrapper.au3>)
	_XMLGetPath ( strXPath ) Returns a nodes full path based on XPath input from root node. (Requires: #include <_XMLDomWrapper.au3>)
	;==============================================================================
	_XMLSelectNodes ( strXPath ) Selects XML Node(s) based on XPath input from root node. (Requires: #include <_XMLDomWrapper.au3>)
	_XMLGetField ( strXPath ) Get XML Field(s) based on XPath input from root node.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLGetValue ( strXPath ) Get XML Field based on XPath input from root node. (Requires: #include <_XMLDomWrapper.au3>)
	_XMLGetChildText ( strXPath ) Selects XML child Node(s) of an element based on XPath input from root node. (Requires: #include <_XMLDomWrapper.au3>)
	_XMLUpdateField ( strXPath, strData ) Update existing node(s) based on XPath specs.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLReplaceChild ( objOldNode, objNewNode, ns = "" ) Replaces a node with a new node. (Requires: #include <_XMLDomWrapper.au3>)
	;==============================================================================
	_XMLDeleteNode ( strXPath ) Delete specified XPath node.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLDeleteAttr ( strXPath, strAttrib ) Delete attribute for specified XPath(Requires: #include <_XMLDomWrapper.au3>)
	_XMLDeleteAttrNode ( strXPath, strAttrib ) Delete attribute node for specified XPath(Requires: #include <_XMLDomWrapper.au3>)
	;==============================================================================
	_XMLGetAttrib ( strXPath, strAttrib, strQuery = "" ) Get XML attribute based on XPath input from root node.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLGetAllAttrib ( strXPath, ByRef aName, ByRef aValue, strQry = "" ) Get all XML Field(s) attributes based on XPath input from root node.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLGetAllAttribIndex ( strXPath, ByRef aName, ByRef aValue, strQry = "", NodeIndex = 0 ) Get all XML Field(s) attributes based on Xpathn and specific index.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLSetAttrib ( strXPath, strAttrib, strValue = "" ) Set XML Field(s) attributes based on XPath input from root node.(Requires: #include <_XMLDomWrapper.au3>)
	;==============================================================================
	_XMLCreateCDATA ( strNode, strCDATA, strNameSpc = "" ) Create a CDATA SECTION node directly under root. (Requires: #include <_XMLDomWrapper.au3>)
	_XMLCreateComment ( strNode, strComment ) Create a COMMENT node at specified path.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLCreateAttrib ( strXPath,strAttrName,strAttrValue="" ) Creates an attribute for the specified node. (Requires: #include <_XMLDomWrapper.au3>)
	;==============================================================================
	_XMLCreateRootChild ( strNode, strData = "", strNameSpc = "" ) Create node directly under root.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLCreateRootNodeWAttr ( strNode, aAttr, aVal, strData = "", strNameSpc = "" ) Create a child node under root node with attributes.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLCreateChildNode ( strXPath, strNode, strData = "", strNameSpc = "" )  Create a child node under the specified XPath Node.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLCreateChildWAttr ( strXPath, strNode, aAttr, aVal, strData = "", strNameSpc = "" ) Create a child node under the specified XPath Node with Attributes. (Requires: #include <_XMLDomWrapper.au3>)
	;==============================================================================
	_XMLSchemaValidate ( sXMLFile, ns, sXSDFile ) 	_XMLSchemaValidate($sXMLFile, $ns, $sXSDFile) Validate a document against a DTD. (Requires: #include <_XMLDomWrapper.au3>)
	_XMLGetDomVersion (  ) Returns the XSXML version currently in use. (Requires: #include <_XMLDomWrapper.au3>)
	_XMLError ( sError = "" ) Sets or Gets XML error message generated by XML functions.(Requires: #include <_XMLDomWrapper.au3>)
	_XMLUDFVersion (  ) eturns the UDF Version number. (Requires: #include <_XMLDomWrapper.au3>)
	_XMLTransform ( oXMLDoc, Style = "",szNewDoc="" ) Transfroms the document using built-in sheet or xsl file passed to function. (Requires: #include <_XMLDomWrapper.au3>)
	_XMLNodeExists( $strXPath) Checks for the existence of the specified path. (Requires: #include <_XMLDomWrapper.au3>)
#ce
;===============================================================================
;Global variables
Global Const $_XMLUDFVER = "1.0.3.87"
Global Const $NODE_ELEMENT = 1
Global Const $NODE_ATTRIBUTE = 2
Global Const $NODE_TEXT = 3
Global Const $NODE_CDATA_SECTION = 4
Global Const $NODE_ENTITY_REFERENCE = 5
Global Const $NODE_ENTITY = 6
Global Const $NODE_PROCESSING_INSTRUCTION = 7
Global Const $NODE_COMMENT = 8
Global Const $NODE_DOCUMENT = 9
Global Const $NODE_DOCUMENT_TYPE = 10
Global Const $NODE_DOCUMENT_FRAGMENT = 11
Global Const $NODE_NOTATION = 12
Global $strFile
Global $objDoc
Global $oXMLMyError ;COM error handler OBJ ; Initialize SvenP 's error handler
Global $sXML_error
Global $debugging
Global $DOMVERSION = -1
Global $bXMLAUTOSAVE = True
;===============================================================================
;UDF functions
;===============================================================================
; Function Name:	 _XMLFileOpen
; Description:		Creates an instance of an XML file.
; Parameter(s):	$strXMLFile - the XML file to open
;						$strNameSpc - the namespace to specifiy if the file uses one.
;						$iVer - specifically try to use the version supplied here.
;						$bValOnParse - validate the document as it is being parsed
; Syntax:			 _XMLFileOpen($strXMLFile, [$strNameSpc], [$iVer], [$bValOnParse] )
; Return Value(s): On Success - 1
;						 On Failure - -1 and set
;							@Error to:
;								0 - No error
;								1 - Parse error, @Extended = MSXML reason	
;								2 - No object
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
;===============================================================================
Func _XMLFileOpen($strXMLFile, $strNameSpc = "", $iVer = -1, $bValOnParse = True)
	;==== pick your poison
	If $iVer <> -1 Then
		If $iVer > -1 And $iVer < 7 Then
			$objDoc = ObjCreate("Msxml2.DOMDocument." & $iVer & ".0")
			If IsObj($objDoc) Then
				$DOMVERSION = $iVer
			EndIf
		Else
			MsgBox(266288, "Error:", "Failed to create object with MSXML version " & $iVer)
			SetError(1)
			Return 0
		EndIf
	Else
		For $x = 8 To 0 Step - 1
			If FileExists(@SystemDir & "\msxml" & $x & ".dll") Then
				$objDoc = ObjCreate("Msxml2.DOMDocument." & $x & ".0")
				If IsObj($objDoc) Then
					$DOMVERSION = $x
					ExitLoop
				EndIf
			EndIf
		Next
	EndIf
	If Not IsObj($objDoc) Then
		_XMLError("Error: MSXML not found. This object is required to use this program.")
		SetError(2)
		Return -1
	EndIf
	;Thanks Lukasz Suleja
	$oXMLMyError = ObjEvent("AutoIt.Error")
	If $oXMLMyError = "" Then
		$oXMLMyError = ObjEvent("AutoIt.Error", "_XMLCOMEerr") ; ; Initialize SvenP 's error handler
	EndIf
	$strFile = $strXMLFile
	$objDoc.async = False
	$objDoc.preserveWhiteSpace = True
	$objDoc.validateOnParse = $bValOnParse
	if $DOMVERSION > 4 Then $objDoc.setProperty ("ProhibitDTD",false)
	$objDoc.Load ($strFile)
	$objDoc.setProperty ("SelectionLanguage", "XPath")
	$objDoc.setProperty ("SelectionNamespaces", $strNameSpc)
	if $objDoc.parseError.errorCode >0 Then consoleWrite($objDoc.parseError.reason&@LF)
	If $objDoc.parseError.errorCode <> 0 Then
		_XMLError("Error opening specified file: " & $strXMLFile & @CRLF & $objDoc.parseError.reason)
		;Tom Hohmann 2008/02/29
		SetError(1,$objDoc.parseError.errorCode,-1)
		$objDoc = 0
		Return -1
	EndIf
	;Tom Hohmann 2008/02/29
	Return 1
EndFunc   ;==>_XMLFileOpen
;===============================================================================
; Function Name:	 _XMLLoadXML
; Description:		Creates an instance for a string of XML .
; Parameters:		$strXML - The XML to load into the document
; Syntax:			 _XMLLoadXML($strXML)
; Return Value(s): On Success - 1 
;                  On Failure - -1 and set @error to
;                     1 - failed to create object, @Extended = MSXML reason
;                     2 - no object found (MSXML required for _XML functions
;
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>,Lukasz Suleja,Tom Hohmann
;===============================================================================
Func _XMLLoadXML($strXML,$strNameSpc="", $iVer = -1, $bValOnParse = True)
	If $iVer <> -1 Then
		If $iVer > -1 And $iVer < 7 Then
			$objDoc = ObjCreate("Msxml2.DOMDocument." & $iVer & ".0")
			If IsObj($objDoc) Then
				$DOMVERSION = $iVer
			EndIf
		Else
			MsgBox(266288, "Error:", "Failed to create object with MSXML version " & $iVer)
			SetError(1)
			Return 0
		EndIf
	Else
		For $x = 8 To 0 Step - 1
			If FileExists(@SystemDir & "\msxml" & $x & ".dll") Then
				$objDoc = ObjCreate("Msxml2.DOMDocument." & $x & ".0")
				If IsObj($objDoc) Then
					$DOMVERSION = $x
					ExitLoop
				EndIf
			EndIf
		Next
	EndIf
	If Not IsObj($objDoc) Then
		_XMLError("Error: MSXML not found. This object is required to use this program.")
		SetError(2)
		Return -1
	EndIf
	;Thanks Lukasz Suleja
	$oXMLMyError = ObjEvent("AutoIt.Error")
	If $oXMLMyError = "" Then
		$oXMLMyError = ObjEvent("AutoIt.Error", "_XMLCOMEerr") ; ; Initialize SvenP 's error handler
	EndIf	
	$objDoc.async = False
	$objDoc.preserveWhiteSpace = True
	$objDoc.validateOnParse = $bValOnParse
	if $DOMVERSION > 4 Then $objDoc.setProperty ("ProhibitDTD",false)
	$objDoc.LoadXml ($strXML)
	$objDoc.setProperty ("SelectionLanguage", "XPath")
	$objDoc.setProperty ("SelectionNamespaces", $strNameSpc); "xmlns:ms='urn:schemas-microsoft-com:xslt'"
	If $objDoc.parseError.errorCode <> 0 Then
		_XMLError("Error loading the XML data: " & @CRLF & $objDoc.parseError.reason)
		;Tom Hohmann 2008/02/29
		SetError(1,$objDoc.parseError.errorCode, -1)
		Return -1
	EndIf
	;Tom Hohmann 2008/02/29
	Return 1
EndFunc   ;==>_MSXMLLoadXML

;===============================================================================
; Function Name:	_XMLCreateFile
; Description:		Create a new blank metafile with header.
; Parameter(s):	$strPath - The xml filename with full path to create
;						$strRoot - The root of the xml file to create
;				   	$bOverwrite -  boolean flag to auto overwrite existing file of same name.
;						$bUTF8 - boolean flag to specify UTF-8 encoding in header.
; Syntax:			_XMLCreateFile($strPath,$strRoot,[$bOverwrite],[$bUTF8]) 
; Return Value(s):	On Success - 1
;							On Failure  - -1 and sets
;								@Error to:
;									0 = No error
;									1 = Failed to create file
;									2 = No object
;									3 = File creation failed MSXML error
;									4 = File exists
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
;===============================================================================
Func _XMLCreateFile($strPath, $strRoot, $bOverwrite = False, $bUTF8 = False, $ver = -1)
	Local $retval, $fe, $objPI, $objDoc, $rootElement
	$fe = FileExists($strPath)
	If $fe And Not $bOverwrite Then
		$retval = (MsgBox(4097, "File Exists:", "The specified file exits." & @CRLF & "Click OK to overwrite file or cancel to exit."))
		If $retval = 1 Then
			FileCopy($strPath, $strPath & @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "-" & @MIN & "-" & @SEC & ".bak", 1)
			FileDelete($strPath)
			$fe = False
		Else
			_XMLError("Error failed to create file: " & $strPath & @CRLF & "File exists.")
			SetError(4)
			Return -1
		EndIf
	Else
		FileCopy($strPath, $strPath & ".old", 1)
		FileDelete($strPath)
		$fe = False
	EndIf
	If $fe = False Then
		If $ver <> -1 Then
			If $ver > -1 And $ver < 7 Then
				$objDoc = ObjCreate("Msxml2.DOMDocument." & $ver & ".0")
				If IsObj($objDoc) Then
					$DOMVERSION = $ver
				EndIf
			Else
				MsgBox(266288, "Error:", "Failed to create object with MSXML version " & $ver)
				SetError(3)
				Return 0
			EndIf
		Else
			For $x = 8 To 0 Step - 1
				If FileExists(@SystemDir & "\msxml" & $x & ".dll") Then
					$objDoc = ObjCreate("Msxml2.DOMDocument." & $x & ".0")
					If IsObj($objDoc) Then
						$DOMVERSION = $x
						ExitLoop
					EndIf
				EndIf
			Next
		EndIf
		If Not IsObj($objDoc) Then
			Return SetError(2)
		EndIf
		If $bUTF8 Then
			$objPI = $objDoc.createProcessingInstruction ("xml", "version=""1.0"" encoding=""UTF-8""")
		Else
			$objPI = $objDoc.createProcessingInstruction ("xml", "version=""1.0""")
		EndIf
		$objDoc.appendChild ($objPI)
		$rootElement = $objDoc.createElement ($strRoot)
		$objDoc.documentElement = $rootElement
		$objDoc.save ($strPath)
		If $objDoc.parseError.errorCode <> 0 Then
			_XMLError("Error Creating specified file: " & $strPath)
;			Tom Hohmann 2008/02/29
			SetError(1, $objDoc.parseError.errorCode, -1)
			Return -1
		EndIf
		Return 1
	Else
		_XMLError("Error! Failed to create file: " & $strPath)
		SetError(1)
		Return 0
	EndIf
	Return 1
EndFunc   ;==>_XMLCreateFile
;===============================================================================
; Function Name:	_XMLSelectNodes
; Description:		Selects XML Node(s) based on XPath input from root node.
; Parameter(s):	$strXPath - xml tree path from root node (root/child/child..)
; Syntax:			_XMLSelectNode($strXPath)
; Return Value(s):	On Success - An array of Nodes(count is in first element) 
;							On Failure - -1 and set @Error = 1 
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
;===============================================================================
Func _XMLSelectNodes($strXPath)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLSelectNodes")
		Return SetError(2,0,-1)
	EndIf
	Local $objNode, $objNodeList, $arrResponse[1], $xmlerr
	$objNodeList = $objDoc.selectNodes ($strXPath)
		If Not IsObj($objNodeList) Then
			_XMLError("\nNo matching nodes found")
			Return SetError(1,0,-1)
		EndIf
		If $objNodeList.length < 1 Then
			_XMLError("\nNo matching nodes found")
			Return SetError(1,0,-1)
		EndIf
		For $objNode In $objNodeList
			_XMLArrayAdd($arrResponse, $objNode.nodeName)
			_DebugWrite($objNode.nodeName)
			_DebugWrite($objNode.namespaceURI)
		Next
		$arrResponse[0] = $objNodeList.length
		Return $arrResponse
	_XMLError("Error Selecting Node(s): " & $strXPath & $xmlerr)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLSelectNodes

;===============================================================================
; Function Name:	_XMLGetField
; Description:		Get XML Field(s) based on XPath input from root node.
; Parameter(s):		$path	xml tree path from root node (root/child/child..)
; Syntax:			_XMLGetField($path)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s):	On Success  An array of fields text values(count is in first element)
;							On Failure -1 set @Error = 1
;===============================================================================
Func _XMLGetField($strXPath)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLGetField")
		Return SetError(1,2,-1)
	EndIf
	Local $objNodeList, $arrResponse[1], $xmlerr, $szNodePath
		$objNodeList = $objDoc.selectSingleNode ($strXPath)
		If Not IsObj($objNodeList) Then
			_XMLError("\nNo Matching Nodes found")
			$arrResponse[0] = 0
			Return SetError(2,0,-1)
		EndIf
		If $objNodeList.hasChildNodes () Then
			Local $count = $objNodeList.childNodes.length
			For $x =1 to $count
				$objChild = $objNodeList.childNodes($x)
					_DebugWrite("ParentNode="&$objNodeList.parentNode.nodeType)
					If $objNodeList.parentNode.nodeType =$NODE_DOCUMENT Then
						$szNodePath="/"&$objNodeList.baseName &"/*["&$x&"]"
					Else
						$szNodePath = $objNodeList.baseName &"/*["&$x&"]"
					EndIf
					
					$aRet = _XMLGetValue($szNodePath)
					If IsArray($aRet) Then
						If UBound($aRet) > 1 Then
							_XMLArrayAdd($arrResponse, $aRet[1])
							_DebugWrite("GetField>Text:" & $aRet[1])
						EndIf
					Else
						_XMLArrayAdd($arrResponse, "")
						_DebugWrite("GetField>Text:" & "")
					EndIf
			Next
			$arrResponse[0] = UBound($arrResponse) - 1
			Return $arrResponse
		Else
			$arrResponse[0] = 0
			_XMLError("\nNo Child Nodes found")
			Return SetError(1,0,-1)
		EndIf
		_XMLError("Error Selecting Node(s): " & $strXPath & $xmlerr)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLGetField
;===============================================================================
; Function Name: 	_XMLGetValue
; Description: 	Get XML values based on XPath input from root node.
; Parameter(s): 	$strXPath - xml tree path from root node (root/child/child..)
; Syntax: 			_XMLGetValue($strXPath)
; Author(s): 		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s):	On Success  An array of fields text values(count is in first element)
;							On Failure -1 set 
;								@Error = 1 
;								@Extended to:
;										0 = No matching node
;										1 = No object passed
;===============================================================================
Func _XMLGetValue($strXPath)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLGetValue")
		Return SetError(1,1,-1)
	EndIf
	Local $objNodeList, $arrResponse[1], $objNodeChild, $xmlerr
		_DebugWrite("GetValue>$strXPath:"&$strXPath)
		$objNodeList = $objDoc.documentElement.selectNodes ($strXPath)
		If $objNodeList.length > 0 Then
			_DebugWrite("GetValue list length:" & $objNodeList.length)
			For $objNode In $objNodeList
				If $objNode.hasChildNodes () = False Then
					_XMLArrayAdd($arrResponse, $objNode.nodeValue)
				Else
					For $objNodeChild In $objNode.childNodes ()
						If $objNodeChild.nodeType = $NODE_CDATA_SECTION Then
							_XMLArrayAdd($arrResponse, $objNodeChild.data)
							_DebugWrite("GetValue>CData:" & $objNodeChild.data)
						ElseIf $objNodeChild.nodeType = $NODE_TEXT Then
							_XMLArrayAdd($arrResponse, $objNodeChild.Text)
							_DebugWrite("GetValue>Text:" & $objNodeChild.Text)
						EndIf
					Next
				EndIf
			Next
			$arrResponse[0] = UBound($arrResponse) - 1
			Return $arrResponse
		Else
			$xmlerr = @CRLF & "No matching node(s)found!"
			Return SetError(1,0,-1)
		EndIf
	_XMLError("Error Retrieving: " & $strXPath & $xmlerr)
	
	Return SetError(1,0, -1)
EndFunc   ;==>_XMLGetValue
;===============================================================================
; Function Name:	_XMLDeleteNode
; Description:		Deletes XML Node based on XPath input from root node.
; Parameter(s):		$path	xml tree path from root node (root/child/child..)
; Syntax:			_XMLDeleteNode($path)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s):	On Success 1
;							On Failure -1 and Sets
;									@Error to:
;										0 = No error
;										1 = Deletion error
;										2 = No object passed
;===============================================================================
Func _XMLDeleteNode($strXPath)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLDeleteNode")
		Return SetError(2,0,-1)
	EndIf
	Local $objNode, $xmlerr
	$objNode = $objDoc.selectNodes ($strXPath)
	If Not IsObj($objNode) Then $xmlerr = @CRLF & "Node Not found"
	if @error = 0 Then
		For $objChild in $objNode
			ConsoleWrite("Delete node " & $objChild.nodeName & @LF)			
			$objChild.parentNode.removeChild ($objChild)
		Next
		If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
		Return 1
	EndIf
	_XMLError("Error Deleting Node: " & $strXPath & $xmlerr)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLDeleteNode

;===============================================================================
; Function Name:	_XMLDeleteAttr
; Description:		Delete XML Attribute based on XPath input from root node.
; Parameter(s):	$strXPath xml tree path from root node (root/child/child..)
;						$strAttribute The attribute node to delete
; Syntax:			_XMLDeleteAttr($strPath,$strAttribute)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s):	On Success  1
;							On Failure -1 and sets
;								@Error to:
;									0 = No error
;									1 = Error removing attribute
;									2 = No object
;===============================================================================
Func _XMLDeleteAttr($strXPath, $strAttrib)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLDeleteAttr")
		Return SetError(2,0,-1)
	EndIf
Local $objNode, $objAttr, $xmlerr
	$objNode = $objDoc.selectSingleNode ($strXPath)
	If IsObj($objNode) Then
		$objAttr = $objNode.getAttributeNode ($strAttrib)
		If Not (IsObj($objAttr)) Then
			_XMLError("Attribute " & $strAttrib & " does not exist!")
			Return SetError(2,0,-1)
		EndIf
		$objAttr = $objNode.removeAttribute ($strAttrib)
				If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
		Return 1
	EndIf
	_XMLError("Error Removing Attribute: " & $strXPath & " - " & $strAttrib & @CRLF & $xmlerr)
	$xmlerr = ""
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLDeleteAttr
;===============================================================================
; Function Name:	_XMLDeleteAttrNode
; Description:		Delete XML Attribute node based on XPath input from root node.
; Parameter(s):	$strXpath xml tree path from root node (root/child/child..)
;						$strAttribute The attribute node to delete
; Syntax:			_XMLDeleteAttrNode($strXPath,$strAttribute)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s):	On Success  1
;							On Failure -1 and sets
;								@Error to:
;									0 = No error
;									1 = Error removing node
;									2 = No object
;===============================================================================
Func _XMLDeleteAttrNode($strXPath, $strAttrib)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLDeleteAttrNode")
		Return SetError(2,0,-1)
	EndIf
	Local $objNode, $objAttr, $xmlerr
	$objNode = $objDoc.selectSingleNode ($strXPath)
	If Not IsObj($objNode) Then
		_XMLError("\nSpecified node not found!")
		Return SetError(2,0,-1)
	EndIf
	$objAttr = $objNode.removeAttributeNode ($objNode.getAttributeNode ($strAttrib))
	If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
	If Not (IsObj($objAttr)) Then
		_XMLError("\nUnspecified error:!")
		Return SetError(1,0,-1)
	EndIf
	Return 1
EndFunc   ;==>_XMLDeleteAttrNode
;===============================================================================
; Function Name:	_XMLGetAttrib
; Description:		Get XML Field based on XPath input from root node.
; Parameter(s):		$path	xml tree path from root node (root/child/child..)
; Syntax:			_XMLGetAttrib($path,$attrib)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s): On Success  The attribute value.
;						 On Failure -1 and sets
;								@Error to:
;									0 = No error
;									1 = Attribute not found.
;									2 = No object
;===============================================================================
Func _XMLGetAttrib($strXPath, $strAttrib, $strQuery = "")
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLGetAttrib")
		Return SetError(2,0,-1)
	EndIf
	;Local $objNodeList, $arrResponse[1], $i, $xmlerr, $objAttr
	Local $objNodeList, $arrResponse, $i, $xmlerr, $objAttr
	$objNodeList = $objDoc.documentElement.selectNodes ($strXPath & $strQuery)
	_DebugWrite("Get Attrib length= " & $objNodeList.length)
	If $objNodeList.length > 0 Then
		For $i = 0 To $objNodeList.length - 1
			$objAttr = $objNodeList.item ($i).getAttribute ($strAttrib)
			$arrResponse = $objAttr
			_DebugWrite("RET>>" & $objAttr)
		Next
		Return $arrResponse
	EndIf
	$xmlerr = "\nNo qualified items found"
	_XMLError("Attribute " & $strAttrib & " not found for: " & $strXPath & $xmlerr)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLGetAttrib
;===============================================================================
; Function Name:	_XMLSetAttrib
; Description:		Set XML Field(s) based on XPath input from root node.
; Parameter(s):		$path xml tree path from root node (root/child/child..)
;					$attrib the attribute to set.
;					$value the value to give the attribute defaults to ""
; Syntax:			_XMLSetAttrib($path,$attrib,$value)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com> 
; Return Value(s)			array of fields text values
;					on error returns -1 and sets error to 1
;===============================================================================
Func _XMLSetAttrib($strXPath, $strAttrib, $strValue = "", $iIndex =-1)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLSetAttrib")
		Return SetError(1,8,-1)
	EndIf
	Local $objNodeList, $arrResponse[1], $i
	$objNodeList = $objDoc.selectNodes ($strXPath)
	_DebugWrite(" Node list Length: " & $objNodeList.length)
	If @error = 0 And $objNodeList.length > 0 Then
		If $iIndex > 0 Then
			$arrResponse[0] = $objNodeList.item ($iIndex).SetAttribute ($strAttrib, $strValue)
		Else
			ReDim $arrResponse[$objNodeList.length]
			For $i = 0 To $objNodeList.length - 1
				$arrResponse[$i] = $objNodeList.item ($i).SetAttribute ($strAttrib, $strValue)
				If $objDoc.parseError.errorCode <> 0 Then ExitLoop
			Next
		EndIf
		If $objDoc.parseError.errorCode <> 0 Then
			_XMLError("Error setting attribute for: " & $strXPath & @CRLF & $objDoc.parseError.reason)
			Return SetError(1,$objDoc.parseError.errorCode,-1)
		EndIf
		If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
		Return $arrResponse
	EndIf
	_XMLError("Error failed to set attribute for: " & $strXPath & @CRLF)
	SetError(1)
	Return -1
EndFunc   ;==>_XMLSetAttrib
;===============================================================================
; Function Name:	_XMLGetAllAttrib
; Description:		Get all XML Field(s) attributes based on XPath input from root node.
; Parameter(s):		$path	xml tree path from root node (root/child/child..)
;					$query the query string in xml format
;					$names the array to return the attrib names
;					$value the array to return the attrib values
;					[$query] DOM compliant query string (not really necessary as it becomes
;part of the path
; Syntax:			_XMLGetAllAttrib($path,$query)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			array of fields text values(number of items is in [0][0]
;					on error set error to 1 and returns -1
;===============================================================================
Func _XMLGetAllAttrib($strXPath, ByRef $aName, ByRef $aValue, $strQry = "")
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLGetAllAttrib")
		Return SetError(1,9,-1)
	EndIf
	Local $objNodeList, $objQueryNodes, $objNode, $arrResponse[2][1], $i
	$objQueryNodes = $objDoc.selectNodes ($strXPath & $strQry)
	If $objQueryNodes.length > 0 Then
		For $objNode In $objQueryNodes
			$objNodeList = $objNode.attributes
			If ($objNodeList.length) Then
				_DebugWrite("Get all attrib " & $objNodeList.length)
				ReDim $arrResponse[2][$objNodeList.length + 2]
				ReDim $aName[$objNodeList.length]
				ReDim $aValue[$objNodeList.length]
				For $i = 0 To $objNodeList.length - 1
					$arrResponse[0][$i + 1] = $objNodeList.item ($i).nodeName
					$arrResponse[1][$i + 1] = $objNodeList.item ($i).Value
					$aName[$i] = $objNodeList.item ($i).nodeName
					$aValue[$i] = $objNodeList.item ($i).Value
				Next
			Else
				_XMLError("No Attributes found for node")
				Return SetError(1,0, -1)
			EndIf
		Next
		$arrResponse[0][0] = $objNodeList.length
		Return $arrResponse
	EndIf
	_XMLError("Error retrieving attributes for: " & $strXPath & @CRLF)
	return SetError(1,0 ,-1)
	;	EndIf
EndFunc   ;==>_XMLGetAllAttrib
;===============================================================================
; Function Name:	_XMLUpdateField
; Description:		Update existing node(s) based on XPath specs.
; Parameter(s):		$path	Path from root node
;					$new_data	Data to update node with
; Syntax:			_XMLUpdateField($path,$new_data)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			on error set error to 1 and returns -1
;===============================================================================
Func _XMLUpdateField($strXPath, $strData)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLUpdateField")
		Return SetError(1,9,-1)
	EndIf
	Local $objField, $bUpdate, $objNode
	#forceref $objField
	$objField = $objDoc.selectSingleNode ($strXPath)
	If IsObj($objField) Then
		If $objField.hasChildNodes Then
			For $objChild In $objField.childNodes ()
				If $objChild.nodetype = $NODE_TEXT Then
					$objChild.Text = $strData
					$bUpdate = True
					ExitLoop
				EndIf
			Next
		EndIf
		if $bUpdate = False Then
			$objNode = $objDoc.createTextNode($strData)
			$objField.appendChild($objNode)
		EndIf
		If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
		$objField = ""
		Return
	EndIf
	_XMLError("Failed to update field for: " & $strXPath & @CRLF)
	Return SetError(1,0,-1)

EndFunc   ;==>_XMLUpdateField
;===============================================================================
; Function Name: _XMLCreateCDATA
; Description: Create a CDATA SECTION node directly under root.
; Parameter(s): $node name of node to create
; $data CDATA value
; Syntax: _XMLCreateCDATA($node,$data)
; Author(s): Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s):on error set error to 1 and returns -1
; fixme, won't append to exisiting node. must create new node.
;===============================================================================
Func _XMLCreateCDATA($strNode, $strCDATA, $strNameSpc = "")
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLCreateCDATA")
		Return SetError(1,10,-1)
	EndIf
	Local $objChild, $objNode
	$objNode = $objDoc.createNode ($NODE_ELEMENT, $strNode, $strNameSpc)
	If IsObj($objNode)Then
		If Not ($objNode.hasChildNodes ()) Then
			_AddFormat($objDoc, $objNode)
		EndIf
		$objChild = $objDoc.createCDATASection ($strCDATA)
		$objNode.appendChild ($objChild)
		$objDoc.documentElement.appendChild ($objNode)
				If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
		_AddFormat($objDoc)
		$objChild = ""
		Return 1
	EndIf
	_XMLError("Failed to create CDATA Section: " & $strNode & @CRLF)
	Return SetError(1, 0 ,-1)
EndFunc   ;==>_XMLCreateCDATA
;===============================================================================
; Function Name:	_XMLCreateComment
; Description:		Create a COMMENT node at specified path.
; Parameter(s):		$node	name of node to create
;					$comment the comment to add the to the xml file
; Syntax:			_XMLCreateComment($node,$comment)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			on error set error to 1 and returns -1
;===============================================================================
Func _XMLCreateComment($strNode, $strComment)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLCreateComment")
		Return SetError(1,11,-1)
	EndIf
	Local $objChild, $objNode

	$objNode = $objDoc.selectSingleNode ($strNode)
	If IsObj($objNode) Then
		If Not ($objNode.hasChildNodes ()) Then
			_AddFormat($objDoc, $objNode)
		EndIf
		$objChild = $objDoc.createComment ($strComment)
		$objNode.insertBefore ($objChild, $objNode.childNodes (0))
				If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
		_AddFormat($objDoc)
		$objChild = ""
		Return 1
	EndIf
	_XMLError("Failed to root child: " & $strNode & @CRLF)
	Return SetError(1,0, -1)
EndFunc   ;==>_XMLCreateComment
;===============================================================================
; Function Name:	_XMLCreateAttribute
; Description:
; Parameter(s):		$strXPath xml tree path from root node (root/child/child..)
;						$strAttrName the attribute to set.
;						$strAttrValue the value to give the attribute defaults to ""
; Syntax:			 _XMLCreateAttrib($strXPath,$strAttrName,$strAttrValue="")
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			1 on success, 0 on error
;===============================================================================
Func _XMLCreateAttrib($strXPath, $strAttrName, $strAttrValue = "")
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLCreateAttrib")
		Return SetError(1,12,-1)
	EndIf
	Local $objNode, $objAttr, $objAttrVal, $err
	$objNode = $objDoc.selectSingleNode ($strXPath)
	If IsObj($objNode) Then
		$objAttr = $objDoc.createAttribute ($strAttrName);, $strNameSpc)
		$objNode.SetAttribute ($strAttrName, $strAttrValue)
				If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
		$objAttr = 0
		$objAttrVal = 0
		$objNode = 0
		$err = $objDoc.parseError.errorCode
		If $err = 0 Then Return 1
	EndIf
	_XMLError("Error creating Attribute: " & $strAttrName & @CRLF & $strXPath & " does not exist." & @CRLF)
	Return 0
EndFunc   ;==>_XMLCreateAttrib
;===============================================================================
; Function Name:	_XMLCreateRootChild
; Description:		Create node directly under root.
; Parameter(s):		$node	name of node to create
;					$value optional value to create
; Syntax:			_XMLCreateRootChild($node,[$value])
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			on error set error to 1 and returns -1
;===============================================================================
Func _XMLCreateRootChild($strNode, $strData = "", $strNameSpc = "")
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLCreateRootChild")
		Return SetError(1,14,-1)
	EndIf
	ConsoleWrite("_XMLCreateRootChild:"&$strNode&@LF)
	Local $objChild
	If Not ($objDoc.documentElement.hasChildNodes ()) Then
		_AddFormat($objDoc)
	EndIf
	$objChild = $objDoc.createNode ($NODE_ELEMENT, $strNode, $strNameSpc)
	If IsObj($objChild) Then
	If $strData <> "" Then $objChild.text = $strData
		$objDoc.documentElement.appendChild ($objChild)
				If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
		_AddFormat($objDoc)
		$objChild = 0
		Return 1
	EndIf
	_XMLError("Failed to root child: " & $strNode & @CRLF)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLCreateRootChild
;===============================================================================
; Function Name:	_XMLCreateRootNodeWAttr
; Description:		Create a child node under root node with attributes.
; Parameter(s):		$node node to add with attibute(s)
;					$[array]attrib attribute name(s) -- can be array
;					$[array]value	attribute value(s) -- can be array
;					$data 	optional value to give the node.
; Requirements		This function requires that each attribute name has
;					a corresponding value.
; Syntax:			_XMLCreateRootNodeWAttr($node,$array_attribs,$array_value)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			on error set error to 1 or 2 and returns -1
;===============================================================================
Func _XMLCreateRootNodeWAttr($strNode, $aAttr, $aVal, $strData = "", $strNameSpc = "")
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLCreateRootNodeWAttr")
		Return SetError(1,15,-1)
	EndIf
	Local $objChild, $objAttr, $objAttrVal
	$objChild = $objDoc.createNode ($NODE_ELEMENT, $strNode, $strNameSpc)
	If IsObj($objChild) Then
		If $strData <> "" Then $objChild.text = $strData
		If Not ($objDoc.documentElement.hasChildNodes ()) Then
			_AddFormat($objDoc)
		EndIf
		If IsArray($aAttr) And IsArray($aVal) Then
			If UBound($aAttr) <> UBound($aVal) Then
				_XMLError("Attribute and value mismatch" & @CRLF & "Please make sure each attribute has a matching value.")
				SetError(2)
				Return -1
			Else
				Local $i
				For $i = 0 To UBound($aAttr) - 1
					If $aAttr[$i] = "" Then
						_XMLError("Error creating child node: " & $strNode & @CRLF & " Attribute Name Cannot be NULL." & @CRLF)
						Return SetError(1,0,-1)
					EndIf
					$objAttr = $objDoc.createAttribute ($aAttr[$i]);, $strNameSpc)
					$objChild.SetAttribute ($aAttr[$i], $aVal[$i])
				Next
			EndIf
		Else
			$objAttr = $objDoc.createAttribute ($aAttr)
			$objChild.SetAttribute ($aAttr, $aVal)
		EndIf
		$objDoc.documentElement.appendChild ($objChild)
				If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
		_AddFormat($objDoc)
		$objChild = 0
		Return 1
	EndIf
	_XMLError("Failed to create root child with attributes: " & $strNode & @CRLF)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLCreateRootNodeWAttr
;===============================================================================
; Function Name:	_XMLCreateChildNode
; Description:		Create a child node under the specified XPath Node.
; Parameter(s):		$path	Path from root
;					$node	Node to add
; Syntax:			_XMLCreateChildNode($path,$node)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			on error set error to 1 and returns -1
;===============================================================================
Func _XMLCreateChildNode($strXPath, $strNode, $strData = "", $strNameSpc = "")
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLCreateChildNode")
		Return SetError(1,16,-1)
	EndIf
	Local $objParent, $objChild, $objNodeList
		$objNodeList = $objDoc.selectNodes ($strXPath)
		If IsObj($objNodeList) And $objNodeList.length > 0 Then
			For $objParent In $objNodeList
				If Not ($objParent.hasChildNodes ()) Then
					_AddFormat($objDoc, $objParent)
				EndIf
				If $strNameSpc = "" Then
					If Not ($objParent.namespaceURI = 0 Or $objParent.namespaceURI = "") Then $strNameSpc = $objParent.namespaceURI
				EndIf
				;ConsoleWrite("$strNameSpc=" & $strNameSpc & @LF)
				$objChild = $objDoc.createNode ($NODE_ELEMENT, $strNode, $strNameSpc)
				If $strData <> "" Then $objChild.text = $strData
				$objParent.appendChild ($objChild)
				_AddFormat($objDoc, $objParent)
			Next
			If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
			$objParent = ""
			$objChild = ""
			Return 1
		EndIf
	_XMLError("Error creating child node: " & $strNode & @CRLF & $strXPath & " does not exist." & @CRLF)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLCreateChildNode
;===============================================================================
; Function Name:	_XMLCreateChildNodeWAttr
; Description:		Create a child node(s) under the specified XPath Node with attributes.
; Parameter(s):		$sPath Path from root
; 					$sNode node to add with attibute(s)
;					$[array]attrib attribute name(s) -- can be array
;					$[array]value	attribute value(s) -- can be array
;					$data 			Optional value to give the child node.
; Requirements		This function requires that each attribute name has
;					a corresponding value.
; Syntax:			_XMLCreateChildNodeWAttr($path,$node,$[array]attrib,$]array]value)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			0 on error and set error 1 or 2
;===============================================================================
Func _XMLCreateChildNodeWAttr($strXPath, $strNode, $aAttr, $aVal, $strData = "", $strNameSpc = "")
	Return _XMLCreateChildWAttr($strXPath, $strNode, $aAttr, $aVal, $strData, $strNameSpc)
EndFunc   ;==>_XMLCreateChildNodeWAttr
;===============================================================================
; Function Name:	_XMLCreateChildWAttr
; Description:		Create a child node(s) under the specified XPath Node with attributes.
; Parameter(s):		$sPath Path from root
; 					$sNode node to add with attibute(s)
;					$[array]attrib attribute name(s) -- can be array
;					$[array]value	attribute value(s) -- can be array
;					$data 			Optional value to give the child node.
; Requirements		This function requires that each attribute name has
;					a corresponding value.
; Syntax:			_XMLCreateChildWAttr($path,$node,$[array]attrib,$]array]value)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			0 on error and set error 1 or 2
;===============================================================================
Func _XMLCreateChildWAttr($strXPath, $strNode, $aAttr, $aVal, $strData = "", $strNameSpc = "")
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLCreateChildWAttr")
		Return SetError(1,18,-1)
	EndIf
	Local $objParent, $objChild, $objAttr, $objAttrVal, $objNodeList
		$objNodeList = $objDoc.selectNodes ($strXPath)
		_DebugWrite("Node Selected")
		If IsObj($objNodeList) And $objNodeList.length <> 0 Then
			_DebugWrite("Entering if")
			For $objParent In $objNodeList
				If Not ($objParent.hasChildNodes ()) Then
					_AddFormat($objDoc, $objParent)
				EndIf
				_DebugWrite("Entering for")
				If $strNameSpc = "" Then
					If Not ($objParent.namespaceURI = 0 Or $objParent.namespaceURI = "") Then $strNameSpc = $objParent.namespaceURI
				EndIf
				$objChild = $objDoc.createNode ($NODE_ELEMENT, $strNode, $strNameSpc)
				If @error Then Return -1
				If $strData <> "" Then $objChild.text = $strData
				If IsArray($aAttr) And IsArray($aVal) Then
					If UBound($aAttr) <> UBound($aVal) Then
						_XMLError("Attribute and value mismatch" & @CRLF & "Please make sure each attribute has a matching value.")
						Return SetError(2,0,-1)
					Else
						Local $i
						For $i = 0 To UBound($aAttr) - 1
							_DebugWrite("Entering inside for")
							If $aAttr[$i] = "" Then
								_XMLError("Error creating child node: " & $strNode & @CRLF & " Attribute Name Cannot be NULL." & @CRLF)
								SetError(1)
								Return -1
							EndIf
							_DebugWrite($aAttr[$i] & " " & $strNameSpc)
							$objAttr = $objDoc.createAttribute ($aAttr[$i]);, $strNameSpc)
							If @error Then ExitLoop
							$objChild.SetAttribute ($aAttr[$i], $aVal[$i])
							If @error <> 0 Then
								_XMLError("Error creating child node: " & $strNode & @CRLF & $strXPath & " does not exist." & @CRLF)
								Return SetError(1,0,-1)
							EndIf
							_DebugWrite("Looping inside for")
						Next
					EndIf
				Else
					If IsArray($aAttr) Or IsArray($aVal) Then
						_XMLError("Type non-Array and Array detected" & @LF)
						Return SetError(1,0,-1)
					EndIf
					If $aAttr = "" Then
						_XMLError("Attribute Name cannot be empty string." & @LF)
						Return SetError(5,0,-1)
					EndIf
					_DebugWrite($aAttr & " " & $strNameSpc)
					$objAttr = $objDoc.createAttribute ($aAttr);, $strNameSpc)
					$objChild.SetAttribute ($aAttr, $aVal)
				EndIf
				$objParent.appendChild ($objChild)
				_DebugWrite("Looping for")
			Next
			_AddFormat($objDoc, $objParent)
					If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
			_DebugWrite("Saved")
			$objParent = ""
			$objChild = ""
			_DebugWrite("Returning")
			Return
		EndIf
	_XMLError("Error creating child node: " & $strNode & @CRLF & $strXPath & " does not exist." & @CRLF)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLCreateChildWAttr
;===============================================================================
; Function Name:	_XMLGetChildText
; Description:		Selects XML child Node(s) of an element based on XPath input from root node.
; Parameter(s):		$path	xml tree path from root node (root/child/child..)
; Syntax:			_XMLGetChildText($path)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			array of Nodes or -1 on failure
;===============================================================================
Func _XMLGetChildText($strXPath)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLGetChildText")
		Return SetError(1,19,-1)
	EndIf
	Local $objNodeList, $arrResponse[1], $xmlerr
		$objNodeList = $objDoc.selectSingleNode ($strXPath)
		If Not IsObj($objNodeList) Then
			_XMLError(@CRLF & "No Matching Nodes found")
			$arrResponse[0] = 0
			Return SetError(1,0,-1)
		EndIf
		If $objNodeList.hasChildNodes () Then
			For $objChild In $objNodeList.childNodes ()
				If $objChild.nodeType = $NODE_ELEMENT Then
					_XMLArrayAdd($arrResponse, $objChild.baseName)
				ElseIf $objChild.nodeType = $NODE_TEXT Then
					_XMLArrayAdd($arrResponse, $objChild.text)
				EndIf
			Next
			$arrResponse[0] = UBound($arrResponse) - 1
			Return $arrResponse
		EndIf
	$arrResponse[0] = 0
	$xmlerr = @CRLF & "No Child Text Nodes found"
	_XMLError("Error Selecting Node(s): " & $strXPath & $xmlerr)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLGetChildText
;===============================================================================
; Function Name:	_XMLGetChildNodes
; Description:		Selects XML child Node(s) of an element based on XPath input from root node.
; Parameter(s):		$path	xml tree path from root node (root/child/child..)
; Syntax:			_XMLGetChildNodes($path)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			array of Nodes or -1 on failure
;===============================================================================
Func _XMLGetChildNodes($strXPath)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLGetChildNodes")
		Return SetError(1,20,-1)
	EndIf
	Local $objNodeList, $arrResponse[1], $xmlerr
	$objNodeList = $objDoc.selectSingleNode ($strXPath)
	If Not IsObj($objNodeList) Then
		_XMLError(@LF & "No Matching Nodes found")
		$arrResponse[0] = 0
		Return SetError(1,0,-1)
	EndIf
	If $objNodeList.hasChildNodes () Then
		For $objChild In $objNodeList.childNodes ()
			If $objChild.nodeType () = $NODE_ELEMENT Then
				_DebugWrite($objChild.NamespaceURI &"::"& $objChild.baseName &@LF)
				_XMLArrayAdd($arrResponse, $objChild.baseName)
			EndIf
		Next
		$arrResponse[0] = UBound($arrResponse) - 1
		Return $arrResponse
	EndIf
	$arrResponse[0] = 0
	$xmlerr = @LF & "No Child Nodes found"
	_XMLError("Error Selecting Node(s): " & $strXPath & $xmlerr)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLGetChildNodes
;===============================================================================
; Function Name:	_XMLGetChildren
; Description:		Selects XML child Node(s) of an element based on XPath input from root node.
;						And returns there text values.
; Parameter(s):		$path	xml tree path from root node (root/child/child..)
; Syntax:			_XMLGetChildren($path)
; Return Value(s): 	On Success an array where
;						$array[0][0] = Size of array 
;						$array[1][0] = Name
;						$array[1][1] = Text
;						$array[1][2] = NameSpaceURI
;						...
;						$array[n][0] = Name
;						$array[n][1] = Text
;						$array[n][2] = NamespaceURI
;					On Failure	- Returns -1 and sets @ERROR to
;						1 - Failure 
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
;===============================================================================
Func _XMLGetChildren($strXPath)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLGetChildren")
		Return SetError(1,21,-1)
	EndIf
	Local $objNodeList, $arrResponse[1][3], $xmlerr
	$objNodeList = $objDoc.selectSingleNode ($strXPath)
	If Not IsObj($objNodeList) Then
		_XMLError(@LF & "No Matching Nodes found")
		$arrResponse[0][0]= 0
		Return SetError(1,0,-1)
	EndIf
	If $objNodeList.hasChildNodes () Then
		For $objChild In $objNodeList.childNodes ()
			If $objChild.nodeType () = $NODE_ELEMENT Then
				Local $dims = UBound($arrResponse,1)
				ReDim $arrResponse[$dims+1][3]
				$arrResponse[$dims][0] = $objChild.baseName
				$arrResponse[$dims][1] = $objChild.text
				$arrResponse[$dims][2] = $objChild.NamespaceURI
				;_XMLArrayAdd($arrResponse, $objChild.baseName)
			EndIf
		Next
		$arrResponse[0][0] = UBound($arrResponse,1) - 1
		Return $arrResponse
	EndIf
	$arrResponse[0][0] = 0
	$xmlerr = @LF & "No Child Nodes found"
	_XMLError("Error Selecting Node(s): " & $strXPath & $xmlerr)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLGetChildren

;===============================================================================
; Function Name: _XMLGetNodeCount
; Description: Get Node Count based on XPath input from root node.
; Parameter(s): $path xml tree path from root node (root/child/child..)
; [$query] DOM compliant query string (not really necessary as it becomes part of the path
;					$iNodeType The type of node to count. (element, attrib, comment etc.)
; Syntax: _XMLGetNodeCount($path,$query,$iNodeType)
; Author(s): Stephen Podhajecki <gehossafats@netmdc.com> & DickB
; Return Value(s):0 or Number of Nodes found
; on error set error to 1 and returns -1
;===============================================================================
Func _XMLGetNodeCount($strXPath, $strQry = "", $iNodeType = 1)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLGetNodeCount")
		Return SetError(1,22,-1)
	EndIf
	Local $objQueryNodes, $objNode, $nodeCount = 0, $errMsg
	$objQueryNodes = $objDoc.selectNodes ($strXPath & $strQry)
	If @error = 0 And $objQueryNodes.length > 0 Then
		For $objNode In $objQueryNodes
			If $objNode.nodeType = $iNodeType Then $nodeCount = $nodeCount + 1
		Next
		Return $nodeCount
	Else
		$errMsg = "No nodes of specified type found."
	EndIf
	_XMLError("Error retrieving node count for: " & $strXPath & @CRLF & $errMsg & @CRLF)
	SetError(1)
	Return -1
	; EndIf
EndFunc   ;==>_XMLGetNodeCount
;===============================================================================
; Function Name:	_XMLGetAllAttribIndex
; Description:		Get all XML Field(s) attributes based on Xpathn and specific index.
; Parameter(s):		$sXpath	xml tree path from root node (root/child/child..)
;					$aNames the array to return the attrib names
;					$aValue the array to return the attrib values
;					[$sQuery] DOM compliant query string (not really necessary as it becomes
;					[$iNode] node index.
;part of the path
; Syntax:			_XMLGetAllAttribIndex($path,$aNames,$aValues,[$sQuery="",$iNode=0]])
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			array of attrib node names, array of attrib values
;					on error set error to 1 and returns -1
;===============================================================================
Func _XMLGetAllAttribIndex($strXPath, ByRef $aName, ByRef $aValue, $strQry = "", $NodeIndex = 0)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLGetAllAttribIndex")
		Return SetError(1,23,-1)
	EndIf
	Local $objNodeList, $objQueryNodes, $arrResponse[2][1], $i
	$objQueryNodes = $objDoc.selectNodes ($strXPath & $strQry)
	If $objQueryNodes.length > 0 Then
		$objNodeList = $objQueryNodes.item($NodeIndex).attributes
		_DebugWrite("GetAllAttribIndex " & $objNodeList.length)
		ReDim $arrResponse[2][$objNodeList.length + 1]
		ReDim $aName[$objNodeList.length]
		ReDim $aValue[$objNodeList.length]
		For $i = 0 To $objNodeList.length - 1
			$arrResponse[0][$i] = $objNodeList.item ($i).nodeName
			$arrResponse[1][$i] = $objNodeList.item ($i).Value
			$aName[$i] = $objNodeList.item ($i).nodeName
			$aValue[$i] = $objNodeList.item ($i).Value
		Next
		Return $arrResponse
	EndIf
	_XMLError("Error retrieving attributes for: " & $strXPath & @CRLF)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLGetAllAttribIndex
;===============================================================================
; Function Name: _XMLGetPath
; Description: Return a nodes full path based on XPath input from root node.
; Parameter(s): $path xml tree path from root node (root/child/child..)
; Syntax: _XMLGetPath($path)
; Author(s): Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s): array of fields text values -1 on failure
;===============================================================================
Func _XMLGetPath($strXPath)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLGetPath")
		Return SetError(1,24,-1)
	EndIf
	If $DOMVERSION < 4 Then
		_XMLError("Error DOM Version: " & "MSXML Version 4 or greater required for this function")
		Return SetError(1,0,-1)
	EndIf
	Local $objNodeList, $arrResponse[1], $objNodeChild, $xmlerr, $nodepath, $ns
	$objNodeList = $objDoc.selectNodes ($strXPath)
	If $objNodeList.length > 0 Then
		_DebugWrite("GetPath list length:" & $objNodeList.length)
		For $objNode In $objNodeList
			Local $objNode1 = $objNode
			$nodepath = ""
			$nodepathtag = ""
			If $objNode.nodeType <> $NODE_DOCUMENT Then
				$ns = $objNode.namespaceURI ()
				If $ns <> ""  Then
					$ns = StringRight($ns, StringLen($ns) - StringInStr($ns, "/", 0, -1)) & ":"
				EndIf
				if $ns =0 then $ns =""
				$nodepath = "/" & $ns & $objNode.nodeName () & $nodepath
			EndIf
			Do
				$objParent = $objNode1.parentNode ()
				_DebugWrite("parent " & $objParent.nodeName () & @LF)
				If $objParent.nodeType <> $NODE_DOCUMENT Then
					$ns = $objParent.namespaceURI ()
					If $ns <> "" Then
						;$ns = StringRight($ns, StringLen($ns) - StringInStr($ns, "/", 0, -1)) & ":"
						$ns &=":"
					EndIf
					if $ns =0 then $ns= ""
					$nodepath = "/" &$ns  & $objParent.nodeName ()& $nodepath
					$objNode1 = $objParent
				Else
					$objNode1 = 0
				EndIf
				$objParent = 0
			Until (Not (IsObj($objNode1)))
			_DebugWrite("Path node> " & $nodepath & @LF)
			_XMLArrayAdd($arrResponse, $nodepath)
		Next
		$arrResponse[0] = UBound($arrResponse) - 1
		Return $arrResponse
	EndIf
	$xmlerr = @CRLF & "No matching node(s)found!"
	_XMLError("Error Retrieving: " & $strXPath & $xmlerr)
	Return SetError(1,0,-1)
EndFunc   ;==>_XMLGetPath

;===============================================================================
; Function Name	:	_XMLGetPathInternal
; Description		:	Returns the path of a valid node object.
; Parameter(s)		:	$objNode		A valid node object
; Requirement(s)	:	
; Return Value(s)	:	A string path,  an empty string and set error on fail.
; User CallTip		:	
; Author(s)			:	Stephen Podhajecki <gehossafats at netmdc.com/>
; Note(s)			:	
;===============================================================================
Func _XMLGetPathInternal($objNode)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLGetPathInternal")
		Return SetError(1,25,-1)
	EndIf
	Local $nodepath, $na, $objParent
	If IsObj($objNode) Then
		$nodepath = "/" & $objNode.baseName
		Do
			$objParent = $objNode.parentNode ()
			_DebugWrite("parent" & $objParent.nodeName () & ">" & @LF)
			If $objParent.nodeType <> $NODE_DOCUMENT Then
				$ns = $objParent.namespaceURI ()
				If $ns = 0 Then $ns = ""
				If $ns <> "" Then
					$ns = StringRight($ns, StringLen($ns) - StringInStr($ns, "/", 0, -1)) & ":"
				EndIf
				$nodepath = "/" & $ns & $objParent.nodeName () & $nodepath
				$objNode = $objParent
			Else
				$objNode = 0
			EndIf
			$objParent = 0
		Until (Not (IsObj($objNode)))
		_DebugWrite("Path node>" & $nodepath & @LF)
		Return ($nodepath)
	Else
		Return SetError(1, 0, "")
	EndIf
EndFunc   ;==>_XMLGetPathInternal
;===============================================================================
; Function Name: _XMLReplaceChild
; Description: Replaces a node with another
; Parameter(s): $oldNode Node to replace
;					 $newNode The replacement node.
; Syntax: _XMLReplaceChild(oldNode,newNode)
; Author(s): Stephen Podhajecki <gehossafats@netmdc.com> adapted from
;					http://www.perfectxml.com/msxmlAnswers.asp?Row_ID=65
; Return Value(s)
;===============================================================================
Func _XMLReplaceChild($objOldNode, $objNewNode, $ns = "")
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLReplaceChild")
		Return SetError(1,26,-1)
	EndIf
	If $objOldNode = "" Or $objNewNode = "" Then Return SetError(1)
	Local $nodeRoot
	Local $nodeOld
	Local $nodeNew
	Local $nodeTemp
	Local $bSuccess = False
	;No error handling done
	With $objDoc
		;;.Load "c:\books.xml"
		$nodeRoot = .documentElement
		$oldNodes = $nodeRoot.selectNodes ($objOldNode)
		;'For each Node
		For $nodeOld In $oldNodes
			;Create a New element
			$nodeNew = .createNode ($NODE_ELEMENT, $objNewNode, $ns)
			;Copy attributes
			For $nodeTemp In $nodeOld.Attributes
				$nodeNew.Attributes.setNamedItem ($nodeTemp.cloneNode (True))
			Next
			;Copy Child Nodes
			For $nodeTemp In $nodeOld.childNodes
				$nodeNew.appendChild ($nodeTemp)
			Next
			;Replace with the renamed node
			If IsObj($nodeOld.parentNode.replaceChild ($nodeNew, $nodeOld)) Then $bSuccess = 1
			If Not ($objDoc.parseError.errorCode = 0) Then
				_XMLError("_XMLReplaceChild:" & @LF & "Error Replacing Child: " & _
						$objDoc.parseError.errorCode & _
						" " & $objDoc.parseError.reason)
				$bSucess = False
				ExitLoop
			Else
				$bSuccess = True
			EndIf
		Next
		.save ($strFile)
	EndWith
	$nodeRoot = 0
	$nodeOld = 0
	$nodeNew = 0
	$nodeTemp = 0
	Return $bSuccess
EndFunc   ;==>_XMLReplaceChild
;===============================================================================
; Function Name:	_XMLSchemaValidate
; Description:		Validates a document against a dtd.
; Parameter(s):	$sXMLFile	The file to validate
;						$ns	 xml namespace
;						$sXSDFile	DTD file to validate against.
; Syntax:			_XMLSchemaValidate($sXMLFile, $ns, $sXSDFile)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			1 on success or SetError(errorcode) on failure
;===============================================================================
Func _XMLSchemaValidate($sXMLFile, $ns, $sXSDFile)
;~ 	If not IsObj($objDoc) then
;~ 		_XMLError("No object passed to function _XMLSchemaValidate")
;~ 		Return SetError(1,27,-1)
;~ 	EndIf
	Local $cache, $xmldoc
	$cache = ObjCreate("Msxml2.XMLSchemaCache." & $DOMVERSION & ".0")
	If Not IsObj($cache) Then
		MsgBox(266288, "XML Error", "Unable to instantiate the XML object" & @LF & "Please check your components.")
		Return SetError(-1)
	EndIf
	$cache.add ($ns, $sXSDFile)
	$xmldoc = ObjCreate("Msxml2.DOMDocument." & $DOMVERSION & ".0")
	If Not IsObj($xmldoc) Then
		MsgBox(266288, "XML Error", "Unable to instantiate the XML object" & @LF & "Please check your components.")
		Return SetError(-1)
	EndIf
	$xmldoc.async = False
	$xmldoc.schemas = $cache
	$xmldoc.load ($sXMLFile)
	If Not ($xmldoc.parseError.errorCode = 0) Then
		_XMLError("_XMLSchemaValidate:" & @LF & "Error: " & $xmldoc.parseError.errorCode & " " & $xmldoc.parseError.reason)
		Return SetError($xmldoc.parseError.errorCode)
	EndIf
	Return 0
EndFunc   ;==>_XMLSchemaValidate
;===============================================================================
; Function Name:	_XMLGetDomVersion
; Description:		Returns the version of msxml that is in use for the document.
;
; Syntax:			_XMLGetDomVersion()
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			msxml version or -1
;===============================================================================
Func _XMLGetDomVersion()
	Return $DOMVERSION
EndFunc   ;==>_XMLGetDomVersion
;===============================================================================
; Function Name:	_XMLError
; Description:		Sets error message generated by XML functs.
;					or Gets the message that was Set.
; Parameter(s):		$sError Node from root to delete
; Syntax:			_XMLError([$sError)
; Author(s):		Stephen Podhajecki <gehossafats@netmdc.com>
; Return Value(s)			Nothing or Error message
;===============================================================================
Func _XMLError($sError = "")
	If $sError = "" Then
		$sError = $sXML_error
		$sXML_error = ""
		Return $sError
	Else
		$sXML_error = StringFormat($sError)
	EndIf
	_DebugWrite($sXML_error)
EndFunc   ;==>_XMLError
;===============================================================================
; Function Name:	_XMLCOMEerr
; Description:		Displays a message box with the COM Error.
; Parameter(s):		none
; Syntax:			_XMLCOMEerr()
; Author(s):		SvenP 's error handler
; Return Value(s)
; From the forum this came.
;===============================================================================
Func _XMLCOMEerr()
	_ComErrorHandler()
	Return
EndFunc   ;==>_XMLCOMEerr
Func _ComErrorHandler($quiet = "")
	Local $COMErr_Silent, $HexNumber
	;===============================================================================
	;added silent switch to allow the func returned to the option to display custom
	;error messages
	If $quiet = True Or $quiet = False Then
		$COMErr_Silent = $quiet
		$quiet = ""
	EndIf
	;===============================================================================
	$HexNumber = Hex($oXMLMyError.number, 8)
	If @error Then Return
	Local $msg = "COM Error with DOM!" & @CRLF & @CRLF & _
			"err.description is: " & @TAB & $oXMLMyError.description & @CRLF & _
			"err.windescription:" & @TAB & $oXMLMyError.windescription & @CRLF & _
			"err.number is: " & @TAB & $HexNumber & @CRLF & _
			"err.lastdllerror is: " & @TAB & $oXMLMyError.lastdllerror & @CRLF & _
			"err.scriptline is: " & @TAB & $oXMLMyError.scriptline & @CRLF & _
			"err.source is: " & @TAB & $oXMLMyError.source & @CRLF & _
			"err.helpfile is: " & @TAB & $oXMLMyError.helpfile & @CRLF & _
			"err.helpcontext is: " & @TAB & $oXMLMyError.helpcontext
	If $COMErr_Silent <> True Then
		MsgBox(0, @AutoItExe, $msg)
	Else
		_XMLError($msg)
	EndIf
	SetError(1)
EndFunc   ;==>_ComErrorHandler
; simple helper functions
;===============================================================================
; Function Name:	- 	_DebugWrite($message)
; Description:		- Writes a message to console with a crlf on the end
; Parameter(s):		- $message the message to display
; Syntax:			- _DebugWrite($message)
; Author(s):		-
; Return Value(s)			-
;===============================================================================
Func _DebugWrite($message, $flag = @LF)
	If $debugging Then
		ConsoleWrite(StringFormat($message)&$flag)
	EndIf
EndFunc   ;==>_DebugWrite
;===============================================================================
; Function Name:	_Notifier($Notifier_msg)
; Description:		displays a simple "ok" messagebox
; Parameter(s):		$Notifier_Msg The message to display
; Syntax:			_Notifier($Notifier_msg)
; Author(s):		-
; Return Value(s)			-
;===============================================================================
Func _Notifier($Notifier_msg)
	Return MsgBox(266288, @ScriptName, $Notifier_msg)
EndFunc   ;==>_Notifier
;===============================================================================
; Function Name:	- 	_SetDebug($flag =False)
; Description:		- Writes a message to console with a crlf on the end
; Parameter(s):		- $message the message to display
; Syntax:			- _DebugWrite($message)
; Author(s):		-
; Return Value(s)			-
;===============================================================================
Func _SetDebug($debug_flag = True)
	$debugging = $debug_flag
	ConsoleWrite("Debug = " & $debugging & @LF)
EndFunc   ;==>_SetDebug
;===============================================================================
; Function Name:	_XMLUDFVersion()
; Description:		Returns UDF version number
; Parameter(s):	None
; Syntax:			_XMLUDFVersion()
; Author(s):		Stephen Podhajecki
; Return Value(s)	UDF version number
;===============================================================================
Func _XMLUDFVersion()
	Return $_XMLUDFVER
EndFunc   ;==>_XMLUDFVersion
;===============================================================================
; Function Name:	_XMLTransform
; Description:
; Parameter(s):	$oXMLDoc		The document to transform
;						$Style		(optional) The stylesheet to use
;						$szNewDoc	(optional) Save to this file.
; Return Value(s):	On Success returns 1
;							On Failure @Error = 1
; User CallTip:
; Author(s):		Stephen Podhajecki <gehossafats at netmdc dot com>
; Note(s):
;===============================================================================
Func _XMLTransform($oXMLDoc="", $Style = "", $szNewDoc = "")
	If $oXMLDoc = "" Then
		$oXMLDoc = $objDoc
	EndIf
	If not IsObj($oXMLDoc) then
		_XMLError("No object passed to function _XMLSetAttrib")
		Return SetError(1,29,-1)
	EndIf
	Local $bIndented = False
	Local $xslt = ObjCreate("MSXML2.XSLTemplate." & $DOMVERSION & ".0")
	Local $xslDoc = ObjCreate("MSXML2.FreeThreadedDOMDocument." & $DOMVERSION & ".0")
	Local $xmldoc = ObjCreate("MSXML2.DOMDocument." & $DOMVERSION & ".0")
	Local $xslProc
	$xslDoc.async = False
	If FileExists($Style) Then
		_DebugWrite("LoadXML:1:" & $xslDoc.load ($Style) & @LF)
	Else
		_DebugWrite("LoadXML:2:" & $xslDoc.loadXML (_GetDefaultStyleSheet()) & @LF)
	EndIf
	If $xslDoc.parseError.errorCode <> 0 Then
		_XMLError("Error Transforming NodeToObject: " & $xslDoc.parseError.reason)
	EndIf
	If Not FileExists("XSLFile.xsl") Then FileWrite("XSLFile.xsl", $xslDoc.xml ())
	$xslt.stylesheet = $xslDoc
	$xslProc = $xslt.createProcessor ()
	$xslProc.input = $objDoc
	$oXMLDoc.transformNodeToObject ($xslDoc, $xmldoc)
	If $oXMLDoc.parseError.errorCode <> 0 Then
		_XMLError("_XMLTransform:" & @LF & "Error Transforming NodeToObject: " & $oXMLDoc.parseError.reason)
		$bIndented = False
	Else
		$bIndented = True
	EndIf
	If $bIndented Then
		If $szNewDoc <> "" Then
			$xmldoc.save ($szNewDoc)
			If $xmldoc.parseError.errorCode <> 0 Then
				_XMLError("_XMLTransform:" & @LF & "Error Saving: " & $xmldoc.parseError.reason)
				$bIndented = False
			EndIf
		Else
			$xmldoc.save ($strFile)
			$oXMLDoc.Load ($strFile)
			If $oXMLDoc.parseError.errorCode <> 0 Then
				_XMLError("_XMLTransform:" & @LF & "Error Saving: " & $oXMLDoc.parseError.reason)
				$bIndented = False
			EndIf
		EndIf
	EndIf
	$xslProc = 0
	$xslt = 0
	$xslDoc = 0
	$xmldoc = 0
	Return $bIndented
EndFunc   ;==>_XMLTransform
;===============================================================================
; Function Name:	_GetDefaultStyleSheet
; Description:	 Internal function, returns the default indenting style sheet
; Parameter(s): Requirement(s):
; Return Value(s): Stylesheet on success for nothing on failure.
; User CallTip:
; Author(s):
; Note(s):
;===============================================================================
Func _GetDefaultStyleSheet()
	Return '<?xml version="1.0" encoding="ISO-8859-1"?>' & _
			'<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">' & _
			'<xsl:output method="xml" indent="yes"/> ' & _
			'<xsl:template match="*">' & _
			'<xsl:copy>' & _
			'<xsl:copy-of select="@*" />' & _
			'<xsl:apply-templates />' & _
			'</xsl:copy>' & _
			'</xsl:template>' & _
			'<xsl:template match="comment()|processing-instruction()">' & _
			'<xsl:copy />' & _
			'</xsl:template>' & _
			'</xsl:stylesheet>'
EndFunc   ;==>_GetDefaultStyleSheet
;===============================================================================
; Function Name:	_AddFormat
; Description:
; Parameter(s):	$objDoc	 Document to format
;						$objParent	 Optional node to add formatting to
; Requirement(s):
; Return Value(s):
; User CallTip:
; Author(s):		Stephen Podhajecki <gehossafats a t netmdc.com>
; Note(s):			just break up the tags, no indenting is done here.
;===============================================================================
Func _AddFormat($objDoc, $objParent = "")
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLAddFormat")
		Return SetError(1,30,-1)
	EndIf
	$objFormat = $objDoc.createTextNode (@CR)
	If IsObj($objParent) Then
		$objParent.appendChild ($objFormat)
	Else
		$objDoc.documentElement.appendChild ($objFormat)
	EndIf
			If ($bXMLAUTOSAVE = True) Then $objDoc.save ($strFile)
EndFunc   ;==>_AddFormat
;===============================================================================
; Function Name:	_XMLSetAutoSave
; Description:		Set the forced save to on or off
; Parameter(s):	$bSave
; Requirement(s):
; Return Value(s): previous state
; User CallTip:	
; Author(s):		Stephen Podhajecki <gehossafats a t netmdc.com>
; Note(s):			Defaults to true.
;===============================================================================
Func _XMLSetAutoSave($bSave = True)
	Local $oldSave = $bXMLAUTOSAVE
	if $bSave = False Then
		$bXMLAUTOSAVE = True
	Else
		$bXMLAUTOSAVE = False
	EndIf
	Return $oldSave
EndFunc
;===============================================================================
; Function Name:	_XMLSaveDoc
; Description:		Save the current xml doc
; Parameter(s):	$sFile - The filename to save the xml doc as.
; Requirement(s):
; Return Value(s): none
; User CallTip:	
; Author(s):		Stephen Podhajecki <gehossafats a t netmdc.com>
; Note(s):			Defaults to the current filename.
;===============================================================================
Func _XMLSaveDoc($sFile="")
	if $sFile = "" Then $sFile = $strFile
	$objDoc.save($sFile)	
EndFunc

;===============================================================================
; Function Name:	_XMLNodeExists
; Description:		Checks for the existence of a node or nodes matching the specified path
; Parameter(s):	$strXPath - Path to check for.
; Requirement(s):
; Return Value(s): 1 or Higher on success, 0 on failure
;						@Error set to
;							0 no error
;							1 No XML object @extended = 31
;							2 Node not found
; User CallTip:
; Author(s):		Stephen Podhajecki <gehossafats a t netmdc.com>
; Note(s):			Returns the number of nodes found (could be greater than 1)
;===============================================================================
Func _XMLNodeExists($strXPath)
	If not IsObj($objDoc) then
		_XMLError("No object passed to function _XMLNodeExists")
		Return SetError(1,31,0)
	EndIf
	Local $objNode, $iCount
	Local $objNode =  $objDoc.SelectNodes($strXPath)
	If IsObj($objNode) Then $iCount = $objNode.length
	$objNode = 0
	if $iCount Then Return $iCount
	Return SetError(2,0,0)
EndFunc
; =======================================================================
; Preprocessed included functions...
; =======================================================================
Func _XMLArrayAdd(ByRef $avArray, $sValue)
	If IsArray($avArray) Then
		ReDim $avArray[UBound($avArray) + 1]
		$avArray[UBound($avArray) - 1] = $sValue
		SetError(0)
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_XMLArrayAdd	
