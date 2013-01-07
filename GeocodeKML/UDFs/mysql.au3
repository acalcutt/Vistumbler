#include-once

#cs
	Function Name:    _MySQLConnect
	Description:      Initiate a connection to a MySQL database.
	Parameter(s):     $username - The username to connect to the database with.
	$password - The password to connect to the database with. $Database - Database to connect to.
	$server - The server your database is on.
	$driver (optional) the ODBC driver to use (default is "{MySQL ODBC 3.51 Driver}"
	Requirement(s):   Autoit 3 with COM support
	Return Value(s):  On success returns the connection object for subsequent functions. On failure returns 0 and sets @error
	@Error = 1
	Error opening connection
	@Error = 2
	MySQL ODBC Driver not installed.
	Author(s):        cdkid
#ce

Func _MySQLConnect($sUsername, $sPassword, $sDatabase, $sServer, $sDriver = "{MySQL ODBC 5.2a Driver}", $iPort=3306)
	Local $v = StringMid($sDriver, 2, StringLen($sDriver) - 2)
	Local $key = "HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers", $val = RegRead($key, $v)
	If @error or $val = "" Then
		SetError(2)
		Return 0
	EndIf
	$ObjConn = ObjCreate("ADODB.Connection")
	$Objconn.open ("DRIVER=" & $sDriver & ";SERVER=" & $sServer & ";DATABASE=" & $sDatabase & ";UID=" & $sUsername & ";PWD=" & $sPassword & ";PORT="&$iPort)
	If @error Then
		SetError(1)
		Return 0
	Else
		Return $ObjConn
	EndIf
EndFunc   ;==>_MySQLConnect

#cs
	Function name: _Query
	Description:     Send a query to the database
	Parameter(s):  $oConnectionObj - As returned by _MySQLConnect. $query - The query to execute
	Return Value(s):On success returns the query result. On failure returns 0 and sets @error to 1
	Requirement(s):Autoit3 with COM support
	Author(s):        cdid
#ce


Func _Query($oConnectionObj, $sQuery)
	If IsObj($oConnectionObj) Then
		Return $oConnectionobj.execute ($sQuery)
	EndIf
	If @error Then
		SetError(1)
		Return 0
	EndIf

EndFunc   ;==>_Query

#cs
	Function name: _MySQLEnd
	Description:      Closes the database connection (see notes!)
	Parameter(s):   $oConnectionObj - The connection object as returned by _MySQLConnect()
	Requirement(s):Autoit 3 with COM support
	Return Value(s):On success returns 1. On failure returns 0 and sets @error to 1
	Author(s):         cdkid
#ce

Func _MySQLEnd($oConnectionObj)
	If IsObj($oConnectionObj) Then
		$oConnectionObj.close
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_MySQLEnd

#cs
	Function name: _AddRecord
	Description:     Adds a record to the specified table
	Note(s):           to add to multiple columns use an array with one blank element at the end as the $sColumn, and $value parameter
	Parameter(s):   $oConnectionObj - As returned by _MySQL Connect. $sTable - The table to put the record in
	                $row - The row to put the record in. $value - The value to put into the row
					$vValue - OPTIONAL default will be default for the column (will not work with array, see notes)
	Requirement(s): Autoit 3 with COM support
	Return value(s): On success returns 1. If the connectionobj is not an object returns 0 and sets @error to 2. If there is any other error returns 0 and sets @error to 1.
	Author(s): cdkid
#ce

Func _AddRecord($oConnectionObj, $sTable, $vRow, $vValue = "")
	If IsObj($oConnectionObj) Then
		$query = "INSERT INTO " & $sTable & " ("

		If IsArray($vRow) Then
			For $i = 0 To UBound($vRow, 1) - 1
				If $i > 0 And $i <> UBound($vRow, 1) - 1 Then
					$query = $query & "," & $vRow[$i] & ""
				ElseIf $i = UBound($vRow, 1) - 1 And $vRow[$i] <> "" Then
					$query = $query & "," & $vRow[$i] & ") VALUES("
				ElseIf $i = 0 Then
					$query = $query & "" & $vRow[$i] & ""
				ElseIf $vRow[$i] = "" Then
					$query = $query & ") VALUES("
				EndIf
			Next
		EndIf
		If Not IsArray($vRow) And Not IsArray($vValue) And Not IsInt($vValue) Then
			$oConnectionobj.execute ("INSERT INTO " & $sTable & " (" & $vRow & ") VALUES('" & $vValue & "')")
			return 1
		ElseIf IsInt($vValue) And Not IsArray($vRow) And Not IsArray($vValue) Then
			$oconnectionobj.execute ("INSERT INTO " & $sTable & " (" & $vRow & ") VALUES(" & $vValue & ")")
			return 1
		EndIf

		If IsArray($vValue) Then
			For $i = 0 To UBound($vValue, 1) - 1
				If $i > 0 And $i <> UBound($vValue, 1) - 1 And Not IsInt($vValue[$i]) Then
					$query = $query & ",'" & $vValue[$i] & "'"
				ElseIf $i = UBound($vValue, 1) - 1 And $vValue[$i] <> "" And Not IsInt($vValue[$i]) Then
					$query = $query & ",'" & $vValue[$i] & "');"
				ElseIf $i = 0 And Not IsInt($vValue[$i]) Then
					$query = $query & "'" & $vValue[$i] & "'"
				ElseIf $vValue[$i] = "" Then
					$query = $query & ");"
				ElseIf IsInt($vValue[$i]) And $vValue[$i] <> "" Then
					$query = $query & "," & $vValue[$i]
				EndIf
			Next
		EndIf
		If StringRight($query, 2) <> ");" Then
			$query = $query & ");"

		EndIf
		$oconnectionobj.execute ($query)
	EndIf
	If Not IsObj($oConnectionObj) Then
		SetError(2)
		Return 0
	EndIf
	If @error And IsObj($oConnectionObj) Then
		Return 0
		SetError(1)
	Else
		Return 1
	EndIf

EndFunc   ;==>_AddRecord


#cs
	Function name: _DeleteRecord
	Description:     Deletes a record from the specified table
	Parameter(s):  $oConnectionObj - As returned by _MySQLConnect. $sTable - The table to delete from.
	$sColumn - The column to check value (see the example in the next post) $vRecordVal -
	The value to check in $sColumn (see example).
	$iLimit (optional) - the max number of record to delete if multiple match the criteria (default 1)
	Return Value(s): On success returns 1. If there $oConnectionObj is not an object returns 0 and sets @error to 1. If there are any other errors returns 0 and sets @error to 2
	Requirement(s): Autoit 3 with COM support
#ce

Func _DeleteRecord ($oConnectionObj, $sTable, $sColumn, $vRecordVal, $iLimit = 1)
	If IsObj($oConnectionObj) And Not IsInt($vRecordVal) Then
		$oconnectionobj.execute ("DELETE FROM " & $sTable & " WHERE " & $sColumn & " = '" & $vRecordVal & "' LIMIT " & $iLimit & ";")
	ElseIf IsInt($vRecordVal) Then
		$oconnectionobj.execute ("DELETE FROM " & $sTable & " WHERE " & $sColumn & " = " & $vRecordVal & " LIMIT " & $iLimit & ";")
		If Not @error Then
			Return 1
		ElseIf Not IsObj($oConnectionObj) Then
			SetError(1)
			Return 0
		ElseIf @error And IsObj($oConnectionObj) Then
			SetError(2)
			Return 0
		EndIf
	EndIf
EndFunc   ;==>_DeleteRecord

#cs
	Function name: _CreateTable()
	Description: Creates a table
	Parameters: $oConnectionObj - as returned by _MySQLConnect, $sTbl - The name of the table to create, $sPrimeKey - The name of the
	primary key column. $keytype - The datatype of the primary key (default is integer), $sNotNull - "yes" = must be filled out whenever
	a record is added "no" does not need to be filled out ("yes" default). $keyautoinc - "yes" = Auto incrememnts "no" = does not.
	$sType - The table type (default is InnoDB)
	Requirements: Autoit V3 with COM support
	Return value(s): on success returns 1 on failure sets @error to 1 and returns 0
	Author: cdkid
#ce

Func _CreateTable($oConnectionObj, $sTbl, $sPrimeKey, $keytype = "INTEGER", $sNotNull = "yes", $keyautoinc = "yes", $sType = "InnoDB")
	If IsObj($oConnectionObj) And Not @error Then
		$str = "CREATE TABLE " & $sTbl & " " & "(" & $sPrimeKey & " " & $keytype & " UNSIGNED"
		If $sNotNull = "yes" Then
			$str = $str & " NOT NULL"
		EndIf

		If $keyautoinc = "yes" Then
			$str = $str & " AUTO_INCREMENT,"
		EndIf

		$str = $str & " PRIMARY KEY (" & $sPrimeKey & " )" & " ) " & "TYPE = " & $sType & ";"
		$oConnectionObj.execute ($str)
		Return 1


	ElseIf @error Then
		Return 0
		SetError(1)
	EndIf

EndFunc   ;==>_CreateTable

#cs
	Function Name: _CreateColumn
	Description: Creates a column in the given table
	Requirements: AutoitV3 with COM support
	Parameters: $oConnectionObj - as returned by _MySQLConnect. $sTable - the name of the table to add the column to.
	$sAllowNull - if 'yes' then does not add 'NOT NULL' to the SQL statement (default 'yes') $sDataType - The data type of the column
	default('VARCHAR(45)').		$sAutoInc - if 'yes' adds 'AUTO_INCREMENT' to the MySQL Statement (for use with Integer types)
	default('no').		$sUnsigned - if 'yes' adds 'UNSIGNED' to the MySQL statement. default('no') $vDefault - the default value of the column
	default('')
	Author: cdkid
#ce

Func _CreateColumn($oConnectionObj, $sTable, $sColumn, $sAllowNull = "no", $sDataType = "VARCHAR(45)", $sAutoInc = "no", $sUnsigned = "no", $vDefault = '')
	If IsObj($oConnectionObj) And Not @error Then
		$str = "ALTER TABLE `" & $sTable & "` ADD COLUMN `" & $sColumn & "` " & $sDataType & " "
		If $sAllowNull = "yes" Then
			$str = $str & "NOT NULL "
		EndIf
		If $sAutoInc = 'yes' Then
			$str = $str & "AUTO_INCREMENT "
		EndIf
		If $sUnsigned = 'yes' Then
			$str = $str & "UNSIGNED "
		EndIf
		$str = $str & "DEFAULT '" & $vDefault & "';"
		$oConnectionObj.execute ($str)
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf

EndFunc   ;==>_CreateColumn

#cs
	Function Name: _DropCol()
	Description: Delete a column from the given table
	Requirements: AutoitV3 with COM support
	Parameters: $oConnectionObj - As returned by _MySQLConnect(). $sTable - The name of the table to delete the column from
	$sColumn - THe name of the column to delete
	Author: cdkid
#ce

Func _DropCol($oConnectionObj, $sTable, $sColumn)
	If IsObj($oConnectionObj) & Not @error Then
		$oConnectionObj.execute ("ALTER TABLE " & $sTable & " DROP COLUMN " & $sColumn & ";")
		Return 1
	ElseIf @error Then
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_DropCol

#cs
	Function Name: _DropTbl()
	Description: Deletes a table from the database
	Requirements: AutoitV3 with COM support
	Parameters: $oConnectionObj - As returned by _MySQLConnect. $sTable - The name of the table to delete
	Author: cdkid
#ce

Func _DropTbl($oConnectionObj, $sTable)
	If IsObj($oConnectionObj) And Not @error Then
		$oConnectionObj.execute ("DROP TABLE " & $sTable & ";")
		Return 1
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_DropTbl


#cs
	Function name: _CountRecords()
	Description: Get the number of records in the specified column
	Parameters: $oConnectionObj - As returned by _MySQLConnect. $sTable - The name of the table that the column is in
	$value - If not = "" then it is put in the select statement in the WHERE clause (default "")
	Return value(s): On success returns the number of records. On failure sets @error to 1 and returns 0
	Author: cdkid
#ce
Func _CountRecords($oConnectionObj, $sTable, $sColumn, $vValue = '')
	If IsObj($oConnectionObj) And Not @error Then

		If $sColumn <> "" And $vValue <> "" And Not IsInt($vValue) Then
			$constr = "SELECT " & $sColumn & " FROM " & $sTable & " WHERE " & $sColumn & " = '" & $vValue & "'"
		ElseIf $sColumn <> "" And $vValue = '' And Not IsInt($vValue) Then
			$constr = "SELECT " & $sColumn & " FROM " & $sTable
		ElseIf IsInt($vValue) And $sColumn <> '' And $vValue <> '' Then
			$constr = "SELECT " & $sColumn & " FROM " & $sTable & " WHERE " & $sColumn & " = " & $vValue
		EndIf
		$sql2 = ObjCreate("ADODB.Recordset")
		$sql2.cursorlocation = 3
		$sql2.open ($constr, $oConnectionObj)
		With $sql2
			$ret = .recordcount
		EndWith
		$sql2.close
		Return $ret
	Else
		SetError(1)
		Return 0
	EndIf
EndFunc   ;==>_CountRecords

#cs
	Function name: _CountTables
	Description: Counts the number of tables in the database
	Parameter(s): $oConnectionObj - As returned by _MySQLConnect
	Return value(s): if error - returns 0 and sets @error to 1. on success returns the number of tables in the database
	Author: cdkid
#ce

Func _CountTables($oConnectionObj)
	If IsObj($oConnectionObj) Then
		$quer = $oConnectionObj.execute ("SHOW TABLES;")
		$i = 0
		With $quer
			While Not .EOF
				$i = $i + 1
				.MoveNext
			WEnd
		EndWith
		Return $i
	EndIf
	If @error Then
		SetError(1)
		Return 0
	EndIf

EndFunc   ;==>_CountTables

#cs
	Function name: _GetColNames
	Description: Get's the names of all columns in a specified table
	Parameters: $oConnectionObj - As returned by _MySQLConnect. $sTable - The name of the table to get the column names from
	Return values: On success returns an array where $array[0] is the number of elements in the array and all the rest are column names.
	On failure returns 0 and sets @error to 1
	Author: cdkid
#ce
Func _GetColNames($oConnectionObj, $sTable)
	If IsObj($oConnectionObj) And Not @error Then
		Dim $ret[1], $rs

		$rs = $oConnectionObj.execute ("SHOW COLUMNS FROM " & $sTable & ";")

		With $rs
			While Not .EOF

				ReDim $ret[UBound($ret, 1) + 1]
				$ret[UBound($ret, 1) - 1] = $rs.Fields (0).Value
				.MoveNext
			WEnd
		EndWith
		$ret[0] = UBound($ret, 1) - 1
		Return $ret
	EndIf
	If @error Then
		Return 0
		SetError(1)
	EndIf
EndFunc   ;==>_GetColNames


#cs
	Function name: _GetTblNames
	Description: Gets the names of all tables in the database
	Parameters: $oConnectionObj - As returned by _MySQLConnect
	Return value(s): On success returns an array where $array[0] is the number of tables and $array[n] is the nth table's name
	on failure - returns 0 and sets @error to 1
	Author: cdkid
#ce

Func _GetTblNames($oConnectionObj)
	If IsObj($oConnectionObj) Then
		Dim $ret[1]
		$quer = $oConnectionObj.execute ("SHOW TABLES;")
		With $quer
			While Not .eof
				ReDim $ret[UBound($ret, 1) + 1]
				$ret[UBound($ret, 1) - 1] = .fields (0).value
				.movenext
			WEnd
		EndWith
		$ret[0] = UBound($ret, 1) - 1
		Return $ret
	EndIf
EndFunc   ;==>_GetTblNames

#cs
	Function name: _GetColVals
	Description: Gets all of the values of a specified column in a specified table
	Parameters: $oConnectionObj - As returned by _MySQLConnect(), $sTable - the table that the column is in
	$sColumn - the column to get values from.
	Return value(s): On success returns an array where $array[0] is the number of values and $array[n] is the Nth value
	On failure sets @error to 1 and returns 0
	Author: cdkid
#ce

Func _GetColVals($oConnectionObj, $sTable, $sColumn)
	If IsObj($oConnectionObj) Then
		Dim $ret[1]
		$quer = $oConnectionObj.execute ("SELECT " & $sColumn & " FROM " & $sTable & ";")
		With $quer
			While Not .EOF
				ReDim $ret[UBound($ret, 1) + 1]
				$ret[UBound($ret, 1) - 1] = .Fields (0).value
				.MoveNext
			WEnd
		EndWith
		$ret[0] = UBound($ret, 1) - 1
		Return $ret
	EndIf
EndFunc   ;==>_GetColVals

#cs
	Function name: _GetColCount
	Description: Gets the number of columns in the specified table
	Parameters: $oConnectionObj - As returned by _MySQLConnect(). $sTable - the table to count the columns in
	Return Value(s): On success returns the number of columns in the table. On failure returns -1 and sets @error to 1
	Author: cdkid
#ce
Func _GetColCount($oConnectionObj, $sTable)
	If IsObj($oConnectionObj) Then
		$quer = $oConnectionObj.execute ("SHOW COLUMNS IN " & $sTable)
		With $quer
			$i = 0
			While Not .eof
				$i = $i + 1
				.movenext
			WEnd
		EndWith
		Return $i
	EndIf
	If @error Then
		Return -1
		SetError(1)
	EndIf

EndFunc   ;==>_GetColCount

#cs
	Function name: _GetColType
	Description: Gets the DATA TYPE of the specified column
	Parameters: $oConnectionObj - As returned by _MySQLConnect(). $sTable - the table that the column is in. $sColumn - the column
	to retrieve the data type from.
	Return value(s): On success returns the data type of the column. On failure returns 0 and sets @error to 1
	Author: cdkid
#ce
Func _GetColType($oConnectionObj, $sTable, $sColumn)
	If IsObj($oConnectionObj) Then
		$quer = $oConnectionObj.execute ("SHOW COLUMNS IN " & $sTable)
		With $quer
			$i = 0
			While Not .eof
				If .fields (0).value = $sColumn Then
					$ret = .fields (1).value
				EndIf
				.MoveNext
			WEnd
		EndWith
		Return $ret
	EndIf
	If @error Then
		Return 0
		SetError(1)
	EndIf
EndFunc   ;==>_GetColType

#cs
	Function: _GetDBNames
	Description: Get a count and list of all databases on current server.
	Parameters: $oConObj - As returned by _MySQLConnect
	Return Value(s): Success - An array where $array[0] is the number of databases and $array[n] is the nth database name.
	Failure - -1 and sets @error to 1
	Author: cdkid
#ce
Func _GetDBNames($conobj)
	If IsObj($conobj) Then
		Local $arr[1], $m
		$m = $conobj.Execute ("SHOW DATABASES;")
		With $m
			While Not .eof
				ReDim $arr[UBound($arr, 1) + 1]
				$arr[UBound($arr, 1) - 1] = .Fields (0).Value
				.MoveNext
			WEnd
		EndWith
		$arr[0] = UBound($arr, 1) - 1
		Return $arr
	Else
		SetError(1)
		Return -1
	EndIf
EndFunc   ;==>_GetDBNames

#cs
	Function: _ChangeCon
	Description: Change your connection string
	Parameters:
	$oConnectionObj
	As returned by _MySQLConnect
	$username
	OPTIONAL: the new username to use
	If omitted, the same username will be used.
	$password
	OPTIONAL: the new password to use
	If omitted, the same password will be used.
	$database
	OPTIONAL: the new database to connect to
	If omitted, the same database will be used.
	$driver
	OPTIONAL: the new driver to use
	If omitted, the MySQL ODBC 3.51 DRIVER will be used.
	$server
	OPTIONAL: the new server to connect to
	If omitted, the same server will be used.
	$iPort
	OPTIONAL: the new port to be used to connect
	if omitted, the default port (3306) will be used
	Return Value:
	On success, a new connection object for use with subsequent functions.
	On failure, -1 and sets @error to 1
	Author: cdkid
#ce

Func _ChangeCon($oConnectionObj, $username = "", $password = "", $database = "", $driver = "", $server = "", $iPort = 0)
	Local $constr, $db, $usn, $pwd, $svr
	If IsObj($oConnectionObj) Then
		$constr = $oConnectionObj.connectionstring
		$constr = StringReplace($constr, 'Provider=MSDASQL.1;Extended Properties="', '')
		$constr = StringSplit($constr, ";")
		For $i = 1 To $constr[0]
			If StringLeft($constr[$i], 3) = "UID" Then
				If $username <> "" Then
					$usn = $username
				Else
					$usn = StringMid($constr[$i], 5)
				EndIf
				$usn = StringTrimRight($usn, 1)
			EndIf
			If StringLeft($constr[$i], 3) = "PWD" Then
				If $password <> "" Then
					$pwd = $password
				Else
					$pwd = StringMid($constr[$i], 5)
				EndIf
			EndIf
			If StringLeft($constr[$i], 8) = "DATABASE" Then
				If $database <> "" Then
					$db = $database
				Else
					$db = StringMid($constr[$i], 10)
				EndIf
			EndIf
			If StringLeft($constr[$i], 6) = "SERVER" Then
				If $server <> "" Then
					$svr = $server
				Else
					$svr = StringMid($constr[$i], 8)
				EndIf
			EndIf
			If StringLeft($constr[$i], 6) = "DRIVER" Then
				If $driver <> "" Then
					$dvr = $driver
				Else
					$dvr = "{MySQL ODBC 3.51 DRIVER}"
				EndIf
			EndIf
			If StringLeft($constr[$i], 4) = "PORT" Then
				if $iport <> 0 Then
					$port = $iport
				Else
					$port = 3306
				EndIf
			EndIf
		Next
		$oConnectionObj.close
		$oConnectionObj.Open ("DATABASE=" & $db & ";DRIVER=" & $dvr & ";UID=" & $usn & ";PWD=" & $pwd & ";SERVER=" & $svr & ";PORT=" & $port & ";")
		Return $oConnectionObj
	Else
		SetError(1)
		Return -1
	EndIf
EndFunc   ;==>_ChangeCon
