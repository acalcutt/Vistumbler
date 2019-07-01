#include-once

;===============================================================================
;
; AutoIt Version: 3.2.3.0
; Language:       English
; Description:    Dll wrapper functions for dealing with Unix timestamps.
; Requirement(s): CrtDll.dll
; Notes:          If CrtDll.dll is not available then functions will return false
;                 and set @error = 99.
;
;===============================================================================


;===============================================================================
;
; Description:      _TimeGetStamp - Get current time as Unix timestamp value.
; Parameter(s):     None
; Return Value(s):  On Success - Returns Unix timestamp
;                   On Failure - Returns False, sets @error = 99
; Author(s):        Rob Saunders (admin@therks.com)
; User Calltip:		_TimeGetStamp() - Get current time as Unix timestamp value. (required: <_UnixTime.au3>)
;
;===============================================================================

Func _TimeGetStamp()
	Local $av_Time
	$av_Time = DllCall('CrtDll.dll', 'long:cdecl', 'time', 'ptr', 0)
	If @error Then
		SetError(99)
		Return False
	EndIf
	Return $av_Time[0]
EndFunc

;===============================================================================
;
; Description:		_TimeMakeStamp - Create Unix timestamp from input values.
; Syntax:			_TimeMakeStamp( [ second [, minute [, hour [, day [, month [, year [, isDST ]]]]]]] )
; Parameter(s):     Second - Second for timestamp (0 - 59)
;					Minute - Minute for timestamp (0 - 59)
;					Hour   - Hour for timestamp (0 - 23)
;					Day    - Day for timestamp (1 - 31)
;					Month  - Month for timestamp (1 - 12)
;					Year   - Year for timestamp (1970 - 2038)
;					* All the above values default to the 'Default' keyword, where the current
;					  time/date value will be used.
;					IsDST  - Set to 1 during Daylight Saving Time (DST)
;						   - Set to 0 not during DST
;						   - Set to -1 if unknown, function will try to figure it out
;						   - Default is -1
; Return Value(s):  On Success - Returns Unix timestamp
;		   			On Failure - Parameter error, returns -1
;			      			   - Dll error, returns False, sets @error = 99
; Notes:			The function will try and calculate dates for numbers outside of the
;					usual range.
;					For example: _TimeMakeStamp(0, 0, 0, 32, 1, 1995)
;					32nd day of January? Obviously that's not a valid date, but the function
;					automatically calculates this to be February 1st. A date of 0 will return
;					the last day of the previous month.
; User CallTip:		_TimeMakeStamp($i_Sec = Default, $i_Min = Default, $i_Hour = Default, $i_Day = Default, $i_Mon = Default, $i_Year = Default, $i_IsDST = -1) - Create a UNIX timestamp from input values. (required: <_UnixTime.au3>)
; Author(s):		Rob Saunders (admin@therks.com)
;
;===============================================================================
Func _TimeMakeStamp($i_Sec = Default, $i_Min = Default, $i_Hour = Default, $i_Day = Default, $i_Mon = Default, $i_Year = Default, $i_IsDST = -1)
	Local $struct_Time, $ptr_Time, $av_Time
	$struct_Time = DllStructCreate('uint;uint;uint;uint;uint;uint;uint;uint;uint')

	Select
		Case $i_Sec = Default
			$i_Sec = @SEC
			ContinueCase
		Case $i_Min = Default
			$i_Min = @MIN
			ContinueCase
		Case $i_Hour = Default
			$i_Hour = @HOUR
			ContinueCase
		Case $i_Day = Default
			$i_Day = @MDAY
			ContinueCase
		Case $i_IsDST = Default
			$i_IsDST = -1
	EndSelect
	; The following is done because the mktime function demands
	; that the month be in 0-11 (Jan = 0) format instead of 1-12.
	Select
		Case $i_Mon = Default
			$i_Mon = (@MON - 1)
		Case $i_Mon <> Default
			$i_Mon -= 1
	EndSelect
	; The following is done because the mktime function expects the year in format
	; (full year - 1900), thus 99 = 1999 and 100 = 2005. The function will try
	; to figure out what year the user is trying to use. Thus if the function recieves
	; 70, it's untouched, but if the user gives 1970, 1900 is subtracted automatically.
	; Any year above 99 has 1900 automatically subtracted.
	Select
		Case $i_Year = Default
			$i_Year = (@YEAR - 1900)
		Case $i_Year < 70
			$i_Year += 100
		Case $i_Year > 99
			$i_Year -= 1900
	EndSelect

	DllStructSetData($struct_Time, 1, $i_Sec)
	DllStructSetData($struct_Time, 2, $i_Min)
	DllStructSetData($struct_Time, 3, $i_Hour)
	DllStructSetData($struct_Time, 4, $i_Day)
	DllStructSetData($struct_Time, 5, $i_Mon)
	DllStructSetData($struct_Time, 6, $i_Year)
	DllStructSetData($struct_Time, 9, $i_IsDST)

	$ptr_Time = DllStructGetPtr($struct_Time)
	$av_Time = DllCall('CrtDll.dll', 'long:cdecl', 'mktime', 'ptr', $ptr_Time)
	If @error Then
		SetError(99)
		Return False
	EndIf

	Return $av_Time[0]
EndFunc

;===============================================================================
;
; Description:      _StringFormatTime - Get a string representation of a timestamp
;					according to the format string given to the function.
; Syntax:			_StringFormatTime( "format" [, timestamp [, max length ]] )
; Parameter(s):     Format String - A format string to convert the timestamp to.
; 									See notes for some of the values that can be
; 									used in this string.
; 					Timestamp     - A timestamp to format, possibly returned from
; 									_TimeMakeStamp. If left empty, default, or less
;									than 0, the current time is used. (default is -1)
; 					Max Length    - Maximum length of the string to be returned.
; 									Default is 255.
; Return Value(s):  On Success - Returns string formatted timestamp.
;		   			On Failure - Returns False, sets @error = 99
; Requirement(s):	_TimeGetStamp
; Notes:			The date/time specifiers for the Format String:
; 						%a	- Abbreviated weekday name (Fri)
; 						%A	- Full weekday name (Friday)
; 						%b	- Abbreviated month name (Jul)
; 						%B	- Full month name (July)
; 						%c	- Date and time representation (MM/DD/YY hh:mm:ss)
; 						%d	- Day of the month (01-31)
; 						%H	- Hour in 24hr format (00-23)
; 						%I	- Hour in 12hr format (01-12)
; 						%j	- Day of the year (001-366)
; 						%m	- Month number (01-12)
; 						%M	- Minute (00-59)
; 						%p	- Ante meridiem or Post Meridiem (AM / PM)
; 						%S	- Second (00-59)
; 						%U	- Week of the year, with Sunday as the first day of the week (00 - 53)
; 						%w	- Day of the week as a number (0-6; Sunday = 0)
; 						%W	- Week of the year, with Monday as the first day of the week (00 - 53)
; 						%x	- Date representation (MM/DD/YY)
; 						%X	- Time representation (hh:mm:ss)
; 						%y	- 2 digit year (99)
; 						%Y	- 4 digit year (1999)
; 						%z, %Z	- Either the time-zone name or time zone abbreviation, depending on registry settings; no characters if time zone is unknown
; 						%%	- Literal percent character
;	 				The # character can be used as a flag to specify extra settings:
; 						%#c	- Long date and time representation appropriate for current locale. (ex: "Tuesday, March 14, 1995, 12:41:29")
; 						%#x	- Long date representation, appropriate to current locale. (ex: "Tuesday, March 14, 1995")
; 						%#d, %#H, %#I, %#j, %#m, %#M, %#S, %#U, %#w, %#W, %#y, %#Y	- Remove leading zeros (if any).
;
; User CallTip:		_StringFormatTime($s_Format, $i_Timestamp = -1, $i_MaxLen = 255) - Get a string representation of a timestamp according to the format string given to the function. (required: <_UnixTime.au3>)
; Author(s):        Rob Saunders (admin@therks.com)
;
;===============================================================================
Func _StringFormatTime($s_Format, $i_Timestamp = -1, $i_MaxLen = 255)
	Local $struct_Time, $ptr_Time, $av_Time, $av_StrfTime

	If $i_Timestamp = default OR $i_Timestamp < 0 Then
		$i_Timestamp = _TimeGetStamp()
	EndIf
	$ptr_Time = DllCall('CrtDll.dll', 'ptr:cdecl', 'localtime', 'long*', $i_Timestamp)
	If @error Then
		SetError(99)
		Return False
	EndIf

	$av_StrfTime = DllCall('CrtDll.dll', 'int:cdecl', 'strftime', _
		'str', '', _
		'int', $i_MaxLen, _
		'str', $s_Format, _
		'ptr', $ptr_Time[0])
	Return $av_StrfTime[1]
EndFunc
