#include-once

#comments-start
	JSON.au3 – an RFC4627-compliant JSON UDF Library
	Written by Gabriel Boehme, version 0.9.1 (2009-10-19)
	Modified by guinness (02/03/2012)
	for AutoIt v3.3.0.0 or greater
	
	thanks to:
	Douglas Crockford, for writing the original JSON conversion code in Javascript (circa 2005-07-15),
	which provided the starting point for this library
	
	general notes:
	• visit http://www.JSON.org/ for more information about JSON
	• this library conforms to the official JSON specifications given in RFC4627
	? http://www.ietf.org/rfc/rfc4627.txt?number=4627
	
	system dependencies:
	• the Scripting.Dictionary ActiveX/COM object
	? used internally for testing key uniqueness in JSON objects, and generating empty AutoIt arrays
	? should be available on Windows 98 or later, or any Windows system with IE 5 or greater installed
	? Scripting.Dictionary documentation can be found online at:
	• http://www.devguru.com/Technologies/vbscript/quickref/dictionary.html
	• http://www.csidata.com/custserv/onlinehelp/VBSdocs/vbs390.htm
	• http://msdn2.microsoft.com/en-us/library/x4k5wbx4.aspx
	
	notes on decoding:
	• this decoder implements all required functionality specified in RFC4627
	• notes on decoding certain JSON data types:
	? null
	• AutoIt currently has no native “null”-type value
	• this library uses $_JSONNull to represent null, defined using the “default” keyword
	? be sure to use the JSON null abstractions provided within this library, as this definition of “null” may change in future
	? arrays
	• JSON arrays are decoded “as-is” to one-dimensional AutoIt arrays
	• empty arrays ARE possible
	? AutoIt does not currently allow us to define empty arrays within the language itself
	? nevertheless, they can be returned from functions, and processed like any other array
	? empty JSON arrays will be returned as empty AutoIt arrays
	? objects
	• a special two-dimensional array is used to represent a JSON object
	? $o[$i][0] = the key, $o[$i][1] = the value, for any $i >= 1
	• this should provide compatibility with the 2D array-handling functions in the standard Array.au3 UDF
	? to uniquely identify the 2D array as a JSON object, $o[0] will always contain the following:
	• $o[0][0] = $_JSONNull, $o[0][1] = 'JSONObject'
	• a decoding error occurs if the JSON text specifies an object with duplicate key values [RFC4627:2.2]
	? this error can be suppressed by using the optional $allowDuplicatedObjectKeys parameter
	• this means that the LAST value specified for that key “wins” (i.e., the earlier value for that key is overwritten)
	• additionally, the following (non-RFC4627-compliant) decoding extensions have been implemented:
	? objects and arrays
	• whitespace may substitute for commas between elements
	? this eliminates the annoyance of having to manage commas when manually updating indented JSON text
	? objects
	• keys can be specified without quotes, as long as they’re alphanumeric (i.e., composed of only ASCII letters, numbers, underscore)
	• unquoted keys beginning with a digit (0-9) will first be decoded as numbers, then converted to string
	? strings
	• allowed to be delimited by either single or double quotes
	• additional escape sequences allowed:
	? \' single quote – allows single quotes to be specified within a single-quoted string
	? \v vertical tab – equivalent to \u000B
	? numbers
	• allowed to have leading zeroes, which are ignored (i.e., they do NOT signal an octal number)
	• allowed to have a leading plus sign
	• hexadecimal integer notation (0x) is allowed
	? hex integers are always interpreted as unsigned
	? a negative sign should be used to indicate negative hex integers (e.g., -0xF = -15)
	? Javascript-style comments
	• // Javascript line comments are allowed
	• /* Javascript block comments are allowed */
	? whitespace between identifiers
	• \u0020 (space) and \u0009 thru \u000D (tab thru carriage return) are regarded as whitespace
	• this matches the definition of the native AutoIt3 stringIsSpace() function, which is used to determine whitespace in this library
	
	notes on encoding:
	• by default, this encoder conforms strictly to RFC4627 when producing output
	• notes on encoding AutoIt data types:
	? arrays
	• all one-dimensional AutoIt arrays will be encoded “as-is” to JSON arrays
	• for two-dimensional AutoIt arrays, only those representing JSON objects are supported
	? all JSON object keys ($a[$i][0] of the 2D array) will be encoded as strings, as required by RFC4627
	? if duplicate key strings are encountered, the FIRST one “wins” (i.e., later key duplicates will be ignored)
	? strings
	• as JSON is a unicode data format, it is assumed that nearly all characters can be encoded as themselves
	• a RegExp is used internally to escape certain characters (control characters, etc.)
	? numbers
	• the default AutoIt number-to-string conversion is used, which produces JSON-compatible output
	? booleans
	• encoded normally
	? $_JSONNull
	• encoded as “null” (obviously)
	? anything else
	• any unsupported data type will be quietly encoded as “null”, and will flag a warning
	? BitAnd(@error,1) will return 1, and @extended will contain a count of the total number of unsupported values encountered
	• use a translator function to convert unsupported values to supported values when encoding
	• NON-RFC4627-COMPLIANT OPTION: when indenting, the optional $omitCommas parameter can be used
	? produces indented output WITHOUT commas between object or array elements
	? complements the ability of this decoder to allow whitespace to substitute for commas (see above)
	
	to do:
	• continue revising & testing error handling (bit of a mess at the moment)
	? continue adding $_JSONErrorMessage asssignments
	• check against VB version, to mirror the same level of detailed error reporting where applicable
	? figure out how to make better use of AutoIt error handling in general
	• start adding UDF function comments (see String.au3 or Array.au3 for examples)
	• remove dependency on Scripting.Dictionary?
	? we’d need to figure out other ways to:
	• efficiently test key uniqueness for JSON objects
	• obtain empty AutoIt arrays
	
	legal:
	Copyright © 2007-2009 Gabriel Boehme
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the “Software”), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.
	
	The Software shall be used for Good, not Evil.
	
	THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
#comments-end

;===============================================================================
; JSON general functions
;===============================================================================

; since AutoIt does not have a native “null” value, we currently use “default” to uniquely identify null values
; always use _JSONIsNull() to test for null, as this definition may change in future
Global Const $_JSONNull = Default

Func _JSONIsNull($v)
	; uniquely identify $_JSONNull
	Return $v == Default
EndFunc   ;==>_JSONIsNull

;-------------------------------------------------------------------------------
; returns a new array, optionally populated with the parameters specified
; if no parameters are specified, returns an empty array – very handy as AutoIt doesn’t let you do this natively
;-------------------------------------------------------------------------------
Func _JSONArray($p0 = 0, $p1 = 0, $p2 = 0, $p3 = 0, $p4 = 0, $p5 = 0, $p6 = 0, $p7 = 0, $p8 = 0, $p9 = 0, $p10 = 0, $p11 = 0, $p12 = 0, $p13 = 0, $p14 = 0, $p15 = 0, $p16 = 0, $p17 = 0, $p18 = 0, $p19 = 0, $p20 = 0, $p21 = 0, $p22 = 0, $p23 = 0, $p24 = 0, $p25 = 0, $p26 = 0, $p27 = 0, $p28 = 0, $p29 = 0, $p30 = 0, $p31 = 0)
	If @NumParams Then
		; populate an array with the given values and return it
		Local $a[32] = [$p0, $p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10, $p11, $p12, $p13, $p14, $p15, $p16, $p17, $p18, $p19, $p20, $p21, $p22, $p23, $p24, $p25, $p26, $p27, $p28, $p29, $p30, $p31]
		ReDim $a[@NumParams]
		Return $a
	EndIf
	; return an empty array
	Local $d = ObjCreate('Scripting.Dictionary')
	Return $d.keys() ; this empty Dictionary object will return an empty array of keys
EndFunc   ;==>_JSONArray

Func _JSONIsArray($v)
	Return IsArray($v) And UBound($v, 0) == 1
EndFunc   ;==>_JSONIsArray

;-------------------------------------------------------------------------------
; allows the programmer to more easily invoke a Scripting.Dictionary object for JSON use
; can optionally specify key/value pairs: _JSONObject('key1','value1','key2','value2')
;-------------------------------------------------------------------------------
Func _JSONObject($p0 = 0, $p1 = 0, $p2 = 0, $p3 = 0, $p4 = 0, $p5 = 0, $p6 = 0, $p7 = 0, $p8 = 0, $p9 = 0, $p10 = 0, $p11 = 0, $p12 = 0, $p13 = 0, $p14 = 0, $p15 = 0, $p16 = 0, $p17 = 0, $p18 = 0, $p19 = 0, $p20 = 0, $p21 = 0, $p22 = 0, $p23 = 0, $p24 = 0, $p25 = 0, $p26 = 0, $p27 = 0, $p28 = 0, $p29 = 0, $p30 = 0, $p31 = 0)
	If @NumParams Then
		Local $a[32] = [$p0, $p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8, $p9, $p10, $p11, $p12, $p13, $p14, $p15, $p16, $p17, $p18, $p19, $p20, $p21, $p22, $p23, $p24, $p25, $p26, $p27, $p28, $p29, $p30, $p31]
		ReDim $a[@NumParams]
		Return _JSONObjectFromArray($a)
	EndIf
	Return _JSONObjectFromArray(0)
EndFunc   ;==>_JSONObject

Func _JSONObjectFromArray($a)
	Local $o[1][2] = [[$_JSONNull, 'JSONObject']], $len = UBound($a)
	If $len Then
		; populate with the given key/value pairs
		ReDim $o[Floor($len / 2) + 1][2]
		Local $oi = 1
		Local $d = ObjCreate('Scripting.Dictionary') ; used to check for duplicate keys
		For $ai = 1 To $len - 1 Step 2
			Local $k = String($a[$ai - 1])
			If $d.exists($k) Then
				; duplicate key specified
				Return SetError(1, $d.count + 1, 0)
			EndIf
			$d.add($k, True) ; keep track of the keys in use
			$o[$oi][0] = $k
			$o[$oi][1] = $a[$ai]
			$oi += 1
		Next
	EndIf
	Return $o
EndFunc   ;==>_JSONObjectFromArray

Func _JSONIsObject($v)
	If IsArray($v) And UBound($v, 0) == 2 And UBound($v, 2) == 2 Then
		Return _JSONIsNull($v[0][0]) And $v[0][1] == 'JSONObject'
	EndIf
	Return False
EndFunc   ;==>_JSONIsObject

; variable containing more detailed error information
Global $_JSONErrorMessage = ''

; internally-used variables for decoding/encoding
Local $__JSONTranslator
Local $__JSONReadNextFunc, $__JSONOffset, $__JSONAllowDuplicatedObjectKeys
Local $__JSONCurr, $__JSONWhitespaceWasFound
Local $__JSONDecodeString, $__JSONDecodePos
Local $__JSONIndentString, $__JSONIndentLen, $__JSONComma, $__JSONColon
Local $__JSONEncodeErrFlags, $__JSONEncodeErrCount

;===============================================================================
; JSON decoding user functions
;===============================================================================

;-------------------------------------------------------------------------------
; reads a single JSON value from a text file
;-------------------------------------------------------------------------------
Func _JSONDecodeWithReadFunc($funcName, $translator = '', $allowDuplicatedObjectKeys = False, $postCheck = False)
	; reset the error message
	$_JSONErrorMessage = ''

	If Not __JSONSetTranslator($translator) Then
		Return SetError(999, 0, 0)
	EndIf

	$__JSONReadNextFunc = $funcName
	$__JSONOffset = 0

	$__JSONAllowDuplicatedObjectKeys = $allowDuplicatedObjectKeys

	; read the first character
	__JSONReadNext()
	If @error Then
		Return SetError(@error, @extended, 0)
	EndIf

	; decode
	Local $v = __JSONDecodeInternal()
	If @error Then
		Return SetError(@error, @extended, 0)
	EndIf

	If $postCheck Then
		; make sure there’s nothing left to decode afterwards; if there is, consider it an error
		If __JSONSkipWhitespace() Then
			$_JSONErrorMessage = 'string contains unexpected text after the decoded JSON value'
			Return SetError(99, 0, 0)
		EndIf
	EndIf

	If $translator Then
		$v = __JSONDecodeTranslateWalk($_JSONNull, $_JSONNull, $v)
	EndIf
	If @error Then
		Return SetError(@error, @extended, $v)
	EndIf

	Return $v
EndFunc   ;==>_JSONDecodeWithReadFunc

;-------------------------------------------------------------------------------
; decodes a JSON string containing a single JSON value
;-------------------------------------------------------------------------------
Func _JSONDecode($s, $translator = '', $allowDuplicatedObjectKeys = False, $startPos = 1)
	$__JSONDecodeString = String($s)
	$__JSONDecodePos = $startPos
	Local $v = _JSONDecodeWithReadFunc('__JSONReadNextFromString', $translator, $allowDuplicatedObjectKeys, True)
	If @error Then
		Return SetError(@error, @extended, $v)
	EndIf
	Return $v
EndFunc   ;==>_JSONDecode

;-------------------------------------------------------------------------------
; decodes a JSON string containing one or more JSON values, returning the results in an array
;-------------------------------------------------------------------------------
Func _JSONDecodeAll($s, $translator = '', $allowDuplicatedObjectKeys = False)
	; since we do not require commas for decoding,
	; we can simply enclose the JSON text in brackets, and decode the series of JSON values as an array
	Local $v = _JSONDecode('[' & $s & @LF & ']', $translator, $allowDuplicatedObjectKeys)
	If @error Then
		Return SetError(@error, @extended, $v)
	EndIf
	Return $v
EndFunc   ;==>_JSONDecodeAll


;===============================================================================
; JSON encoding user functions
;===============================================================================

;-------------------------------------------------------------------------------
; encodes a value to JSON string
;
; if $indent is specified, the encoded string will contain indentations and line breaks to show the data structure
; $linebreak is used to specify the newline separator desired when indenting
;-------------------------------------------------------------------------------
Func _JSONEncode($v, $translator = '', $indent = '', $linebreak = @CRLF, $omitCommas = False)
	; reset the error message
	$_JSONErrorMessage = ''

	If Not __JSONSetTranslator($translator) Then
		Return SetError(999, 0, 0)
	EndIf

	If $indent And $linebreak Then
		; we’re indenting
		If IsBool($indent) Then
			$__JSONIndentString = @TAB
		Else
			$__JSONIndentString = String($indent)
		EndIf
		$__JSONIndentLen = StringLen($__JSONIndentString)

		; pad colon with a space
		$__JSONColon = ': '

		; omit commas if requested (IMPORTANT: this is NOT an RFC4627-compliant option!)
		If $omitCommas Then
			$__JSONComma = ''
		Else
			$__JSONComma = ','
		EndIf
	Else
		; not indenting
		$indent = ''
		$linebreak = ''
		$__JSONColon = ':'
		$__JSONComma = ','
	EndIf

	; reset our “warning” error flags
	$__JSONEncodeErrFlags = 0
	$__JSONEncodeErrCount = 0

	Local $s = __JSONEncodeInternal($_JSONNull, $_JSONNull, $v, $linebreak) & $linebreak ; start indentation with the linebreak character
	If @error Then
		; a show-stopping error of some kind
		Return SetError(@error, @extended, '')
	EndIf
	If $__JSONEncodeErrCount Then
		; return encoded JSON string, but also indicate the presence of errors resulting in values changed to null or omitted during encoding
		Return SetError($__JSONEncodeErrFlags, $__JSONEncodeErrCount, $s)
	EndIf
	; no errors encountered
	Return $s
EndFunc   ;==>_JSONEncode


;===============================================================================
; JSON helper functions
;===============================================================================

Func __JSONSetTranslator($translator)
	If $translator Then
		; test it first
		Call($translator, 0, 0, 0)
		If @error == 0xDEAD And @extended == 0xBEEF Then
			$_JSONErrorMessage = 'translator function not defined, or defined with wrong number of parameters'
			Return False
		EndIf
	EndIf
	$__JSONTranslator = $translator
	Return True
EndFunc   ;==>__JSONSetTranslator

;===============================================================================
; JSON decoding helper functions
;===============================================================================

Func __JSONReadNext($numChars = 1)
	$__JSONCurr = Call($__JSONReadNextFunc, $numChars)
	If @error Then
		If @error == 0xDEAD And @extended == 0xBEEF Then
			$_JSONErrorMessage = 'read function not defined, or defined with wrong number of parameters'
		EndIf
		Return SetError(@error, @extended, 0)
	EndIf
	$__JSONOffset += StringLen($__JSONCurr) ; now pointing to the offset for the next read
	Return $__JSONCurr
EndFunc   ;==>__JSONReadNext

Func __JSONReadNextFromString($numChars)
	; move to the next char and return it
	Local $s = StringMid($__JSONDecodeString, $__JSONDecodePos, $numChars)
	$__JSONDecodePos += $numChars
	Return $s
EndFunc   ;==>__JSONReadNextFromString

Func __JSONSkipWhitespace()
	$__JSONWhitespaceWasFound = False
	While $__JSONCurr
		If StringIsSpace($__JSONCurr) Then
			; whitespace, skip
			$__JSONWhitespaceWasFound = True
		ElseIf $__JSONCurr == '/' Then
			; check for comments to skip (decoding extension)
			Switch __JSONReadNext()
				Case '/'
					; line comment, skip until end-of-line (or no more characters)
					While __JSONReadNext() And Not StringRegExp($__JSONCurr, "[\n\r]", 0)
					WEnd
					If $__JSONCurr Then
						$__JSONWhitespaceWasFound = True
					Else
						; we’ve reached the end
						Return ''
					EndIf
				Case '*'
					; start of block comment, skip until end of block comment found
					__JSONReadNext()
					While $__JSONCurr
						If $__JSONCurr == '*' Then
							If __JSONReadNext() == '/' Then
								; end of block comment found
								ExitLoop
							EndIf
						Else
							__JSONReadNext()
						EndIf
					WEnd
					If Not $__JSONCurr Then
						$_JSONErrorMessage = 'unterminated block comment'
						ExitLoop
					EndIf
				Case Else
					$_JSONErrorMessage = 'bad comment syntax'
					ExitLoop
			EndSwitch
		Else
			; this is neither whitespace nor a comment, so we return it
			Return $__JSONCurr
		EndIf

		; if we make it here, we’re still looping, so proceed to the next character
		__JSONReadNext()
	WEnd

	Return SetError(2, 0, 0)
EndFunc   ;==>__JSONSkipWhitespace

Func __JSONDecodeObject()
	Local $d = ObjCreate('Scripting.Dictionary'), $key
	Local $o = _JSONObject(), $len = 1, $i

	If $__JSONCurr == '{' Then
		__JSONReadNext()
		If __JSONSkipWhitespace() == '}' Then
			; empty object
			__JSONReadNext()
			Return $o
		EndIf

		While $__JSONCurr
			$key = __JSONDecodeObjectKey()
			If @error Then
				Return SetError(@error, @extended, 0)
			EndIf

			If __JSONSkipWhitespace() <> ':' Then
				$_JSONErrorMessage = 'expected ":", encountered "' & $__JSONCurr & '"'
				ExitLoop
			EndIf

			If $d.exists($key) Then
				; this key is defined more than once for this object
				If $__JSONAllowDuplicatedObjectKeys Then
					; replace the current key value with the upcoming value
					$i = $d.item($key)
				Else
					$_JSONErrorMessage = 'duplicate key specified for object: "' & $key & '"'
					ExitLoop
				EndIf
			Else
				; adding a new key/value pair
				$i = $len
				$len += 1
				ReDim $o[$len][2]

				$o[$i][0] = $key
				$d.add($key, $i) ; keep track of key index
			EndIf

			__JSONReadNext()
			$o[$i][1] = __JSONDecodeInternal()
			If @error Then
				Return SetError(@error, @extended, 0)
			EndIf

			Switch __JSONSkipWhitespace()
				Case '}'
					; end of object
					__JSONReadNext()
					Return $o
				Case ','
					__JSONReadNext()
					__JSONSkipWhitespace()
				Case Else
					If Not $__JSONWhitespaceWasFound Then
						; badly-formatted object
						$_JSONErrorMessage = 'expected "," or "}", encountered "' & $__JSONCurr & '"'
						ExitLoop
					EndIf
			EndSwitch
		WEnd
	EndIf

	Return SetError(3, 0, 0)
EndFunc   ;==>__JSONDecodeObject

Func __JSONDecodeObjectKey()
	If $__JSONCurr == '"' Or $__JSONCurr == "'" Then
		; decode string as normal
		Return __JSONDecodeString()
	EndIf

	If StringIsDigit($__JSONCurr) Then
		; decode number as normal, returning string representation of number to use as key
		Return String(__JSONDecodeNumber())
	EndIf

	; decode quoteless key string
	Local $s = ''
	While (StringIsAlNum($__JSONCurr) Or $__JSONCurr == '_')
		$s &= $__JSONCurr
		__JSONReadNext()
	WEnd
	If Not $s Then
		$_JSONErrorMessage = 'expected object key, encountered "' & $__JSONCurr & '"'
		Return SetError(13, 0, 0)
	EndIf
	Return $s
EndFunc   ;==>__JSONDecodeObjectKey

Func __JSONDecodeArray()
	Local $a = _JSONArray(), $len = 0

	If $__JSONCurr == '[' Then
		__JSONReadNext()
		If __JSONSkipWhitespace() == ']' Then
			; empty array
			__JSONReadNext()
			Return $a
		EndIf

		While $__JSONCurr
			$len += 1
			ReDim $a[$len]
			$a[$len - 1] = __JSONDecodeInternal()
			If @error Then
				Return SetError(@error, @extended, 0)
			EndIf

			Switch __JSONSkipWhitespace()
				Case ']'
					; end of array
					__JSONReadNext()
					Return $a
				Case ','
					__JSONReadNext()
					__JSONSkipWhitespace()
				Case Else
					If Not $__JSONWhitespaceWasFound Then
						; badly-formatted array
						$_JSONErrorMessage = 'expected "," or "]", encountered "' & $__JSONCurr & '"'
						ExitLoop
					EndIf
			EndSwitch
		WEnd
	EndIf

	Return SetError(4, 0, 0)
EndFunc   ;==>__JSONDecodeArray

Func __JSONDecodeString()
	Local $s = '', $q = $__JSONCurr ; save our beginning quote char so we know what we’re matching

	If $q == '"' Or $q == "'" Then
		While $__JSONCurr
			__JSONReadNext()
			Select
				Case $__JSONCurr == $q
					; we’ve reached the matching end quote char, so we’re done
					__JSONReadNext()
					Return $s
				Case $__JSONCurr == '\'
					; interpret the escaped char
					Switch __JSONReadNext()
						Case '\', '/', '"', "'"
							$s &= $__JSONCurr
						Case 't'
							$s &= @TAB
						Case 'n'
							$s &= @LF
						Case 'r'
							$s &= @CR
						Case 'f'
							$s &= ChrW(0xC) ; form feed / page break
						Case 'b'
							$s &= ChrW(0x8) ; backspace
						Case 'v'
							$s &= ChrW(0xB) ; vertical tab (decoding extension)
						Case 'u'
							; unicode escape sequence
							If StringIsXDigit(__JSONReadNext(4)) Then
								$s &= ChrW(Dec($__JSONCurr))
							Else
								; invalid unicode escape sequence
								ExitLoop
							EndIf
						Case Else
							; unrecognized escape character
							ExitLoop
					EndSwitch
				Case AscW($__JSONCurr) >= 0x20 ; always use ascw() to compare on unicode value (locale-specific string compares seem to be unreliable)
					; append this character
					$s &= $__JSONCurr
				Case Else
					; error – control characters should always be escaped within a string, we should never encounter them raw like this
					ExitLoop
			EndSelect
		WEnd
	EndIf

	Return SetError(5, 0, 0)
EndFunc   ;==>__JSONDecodeString

Func __JSONDecodeHexNumber($negative)
	; we decode hex integers “manually” like this, to avoid the limitations of AutoIt’s built-in 32-bit signed integer interpretation
	Local $n = 0

	While StringIsXDigit(__JSONReadNext())
		$n = $n * 0x10 + Dec($__JSONCurr)
	WEnd

	If $negative Then
		Return -$n
	EndIf
	Return $n
EndFunc   ;==>__JSONDecodeHexNumber

Func __JSONDecodeNumber()
	Local $s = ''

	If $__JSONCurr == '+' Or $__JSONCurr == '-' Then
		; leading sign
		$s &= $__JSONCurr
		__JSONReadNext()
	EndIf

	; code added to allow parsing of 0x hex integer notation (decoding extension)
	If $__JSONCurr == '0' Then
		$s &= $__JSONCurr
		__JSONReadNext()
		If StringLower($__JSONCurr) == 'x' Then
			; we have a hex integer
			Return __JSONDecodeHexNumber(StringLeft($s, 1) == '-')
		EndIf
	EndIf

	; decimal number, collect digits
	While StringIsDigit($__JSONCurr)
		$s &= $__JSONCurr
		__JSONReadNext()
	WEnd

	If $__JSONCurr == '.' Then
		; decimal point found, collect digits
		$s &= $__JSONCurr
		While StringIsDigit(__JSONReadNext())
			$s &= $__JSONCurr
		WEnd
	EndIf

	If StringLower($__JSONCurr) == 'e' Then
		; exponent found, collect sign and digits
		$s &= $__JSONCurr
		__JSONReadNext()
		If $__JSONCurr == '+' Or $__JSONCurr == '-' Then
			$s &= $__JSONCurr
			__JSONReadNext()
		EndIf
		While StringIsDigit($__JSONCurr)
			$s &= $__JSONCurr
			__JSONReadNext()
		WEnd
		; number() doesn’t handle exponential notation, so we use execute() here
		Return Execute($s)
	EndIf

	Return Number($s)
EndFunc   ;==>__JSONDecodeNumber

Func __JSONDecodeLiteral()
	Switch $__JSONCurr
		Case 't'
			If __JSONReadNext(3) == 'rue' Then
				__JSONReadNext()
				Return True
			EndIf
		Case 'f'
			If __JSONReadNext(4) == 'alse' Then
				__JSONReadNext()
				Return False
			EndIf
		Case 'n'
			If __JSONReadNext(3) == 'ull' Then
				__JSONReadNext()
				Return $_JSONNull
			EndIf
	EndSwitch

	Return SetError(7, 0, 0)
EndFunc   ;==>__JSONDecodeLiteral

Func __JSONDecodeInternal()
	Local $v
	Switch __JSONSkipWhitespace()
		Case '{'
			$v = __JSONDecodeObject()
		Case '['
			$v = __JSONDecodeArray()
		Case '"', "'" ; allow strings to be single- or double-quoted (decoding extension)
			$v = __JSONDecodeString()
		Case '0' To '9', '-', '+' ; allow numbers to start with a plus sign (decoding extension)
			$v = __JSONDecodeNumber()
		Case Else
			$v = __JSONDecodeLiteral()
	EndSwitch
	If @error Then
		Return SetError(@error, @extended, $v)
	EndIf
	Return $v
EndFunc   ;==>__JSONDecodeInternal

; here, we walk through the raw results from our JSON decoding, calling the translator function for each value
Func __JSONDecodeTranslateWalk(Const ByRef $holder, Const ByRef $key, $value)
	Local $v

	If IsArray($value) Then
		If _JSONIsObject($value) Then
			For $i = 1 To UBound($value) - 1
				$v = __JSONDecodeTranslateWalk($value, $value[$i][0], $value[$i][1])
				Switch @error
					Case 0
						; no error, assign returned value
						$value[$i][1] = $v
					Case 4627
						; remove this key/value pair
						$value[$i][0] = $_JSONNull ; wipe out key (placeholder logic for now)
					Case Else
						; an error
						Return SetError(@error, @extended, 0)
				EndSwitch
			Next
		Else ; this can only be a one-dimensional array
			For $i = 0 To UBound($value) - 1
				$v = __JSONDecodeTranslateWalk($value, $i, $value[$i])
				Switch @error
					Case 0
						; no error, assign returned value
						$value[$i] = $v
					Case 4627
						; we can’t completely remove values from arrays (as that could disrupt element positioning), so set to JSON null instead
						$value[$i] = $_JSONNull
					Case Else
						; an error
						Return SetError(@error, @extended, 0)
				EndSwitch
			Next
		EndIf
	EndIf

	$v = Call($__JSONTranslator, $holder, $key, $value)
	If @error Then
		Return SetError(@error, @extended, 0)
	EndIf
	Return $v
EndFunc   ;==>__JSONDecodeTranslateWalk


;===============================================================================
; JSON encoding helper functions
;===============================================================================

Func __JSONEncodeObject($o, Const ByRef $indent)
	Local $result = '', $inBetween = $__JSONComma & $indent, $d = ObjCreate('Scripting.Dictionary')

	For $i = 1 To UBound($o) - 1
		Local $key = $o[$i][0]
		If Not _JSONIsNull($key) Then ; avoid “deleted” keys
			$key = String($key)
			If $d.exists($key) Then
				; duplicate key – add flag to error status and ignore value (earlier value for this key “wins”)
				$__JSONEncodeErrFlags = BitOR($__JSONEncodeErrFlags, 2)
				$__JSONEncodeErrCount += 1
			Else
				$d.add($key, True) ; keep track of the keys in use
				Local $s = __JSONEncodeInternal($o, $key, $o[$i][1], $indent)
				If @error Then
					Return SetError(@error, @extended, $result)
				EndIf
				If $s Then
					$result &= $inBetween & __JSONEncodeString($key) & $__JSONColon & $s
				EndIf
			EndIf
		EndIf
	Next
	If $indent And $result Then
		; we’re indenting, and we don’t have an empty JSON object, so append the appropriate closing indentation
		$result &= StringTrimRight($indent, $__JSONIndentLen)
	EndIf

	; remove the initial comma and return the result
	Return '{' & StringTrimLeft($result, StringLen($__JSONComma)) & '}'
EndFunc   ;==>__JSONEncodeObject

Func __JSONEncodeArray($a, Const ByRef $indent)
	Local $result = '', $inBetween = $__JSONComma & $indent

	If UBound($a) Then
		For $i = 0 To UBound($a) - 1
			Local $s = __JSONEncodeInternal($a, $i, $a[$i], $indent)
			If @error Then
				Return SetError(@error, @extended, $result)
			EndIf
			If Not $s Then
				; we can’t completely remove values from arrays (as that could disrupt element positioning), so set to null instead
				$s = 'null'
			EndIf
			$result &= $inBetween & $s
		Next
		If $indent Then
			; we’re indenting, so append the appropriate closing indentation
			$result &= StringTrimRight($indent, $__JSONIndentLen)
		EndIf
	EndIf

	; remove the initial comma and return the result
	Return '[' & StringTrimLeft($result, StringLen($__JSONComma)) & ']'
EndFunc   ;==>__JSONEncodeArray

Func __JSONEncodeString($s)
	Local Const $escape = '[\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]'
	Local $result, $ch, $u

	; use a regExp replace to escape any backslash or double-quote characters
	; (also implicitly converts $s to a string, if it isn’t one already)
	$s = StringRegExpReplace($s, '([\"\\])', '\\\0')

	If StringRegExp($s, $escape, 0) Then
		; we have control characters to escape, so we need to reconstruct the string to encode them
		$result = ''

		For $i = 1 To StringLen($s)
			$ch = StringMid($s, $i, 1)

			If StringRegExp($ch, $escape, 0) Then
				; encode
				$u = AscW($ch)
				Switch $u
					Case 0x9 ; tab
						$ch = '\t'
					Case 0xA ; newline
						$ch = '\n'
					Case 0xD ; carriage return
						$ch = '\r'
					Case 0xC ; form feed / page break
						$ch = '\f'
					Case 0x8 ; backspace
						$ch = '\b'
					Case Else
						; encode as unicode character number
						$ch = '\u' & Hex($u, 4)
				EndSwitch
			EndIf

			; write our encoded character
			$result &= $ch
		Next
	Else
		; no control chars present, so our string is already encoded properly
		$result = $s
	EndIf

	Return '"' & $result & '"'
EndFunc   ;==>__JSONEncodeString

Func __JSONEncodeInternal($holder, $k, $v, $indent)
	; encode a variable into its JSON string representation
	Local $s

	If $indent Then
		; append another indentation to the given indent string, and check how deep we are
		$indent &= $__JSONIndentString
		; arbitrary maximum depth check to help identify cyclical data structure errors (e.g., a dictionary containing itself)
		If StringLen($indent) / $__JSONIndentLen > 255 Then
			$_JSONErrorMessage = 'max depth exceeded – possible data recursion'
			Return SetError(1, 0, 0)
		EndIf
	EndIf

	If $__JSONTranslator Then
		; call the translator function first
		$v = Call($__JSONTranslator, $holder, $k, $v)
		Switch @error
			Case 0
				; no error
			Case 4627
				; signal to remove this value entirely from encoded output, if possible
				Return ''
			Case Else
				; some other error
				Return SetError(@error, @extended, '')
		EndSwitch
	EndIf

	Select
		Case _JSONIsObject($v)
			$s = __JSONEncodeObject($v, $indent)

		Case _JSONIsArray($v)
			$s = __JSONEncodeArray($v, $indent)

		Case IsString($v)
			$s = __JSONEncodeString($v)

		Case IsNumber($v)
			; AutoIt’s native number-to-string conversion will produce valid JSON-compatible numeric output
			$s = String($v)

		Case IsBool($v)
			$s = StringLower($v)

		Case _JSONIsNull($v)
			$s = 'null'

		Case Else
			; unsupported variable type; encode as null, flag presence of error
			$__JSONEncodeErrFlags = BitOR($__JSONEncodeErrFlags, 1)
			$__JSONEncodeErrCount += 1
			$s = 'null'

	EndSelect

	If @error Then
		Return SetError(@error, @extended, $s)
	EndIf
	Return $s
EndFunc   ;==>__JSONEncodeInternal