
$file = "36519194_2015-01-20_21-47-20.VS1"

$fileopen = FileOpen($file,128)
$fileread = FileRead($fileopen)
FileClose($fileopen)

ConsoleWrite("### START ###" & @CRLF & StringReplace($fileread, @CRLF, "[CRLF]" & @CRLF) & @CRLF & "### END ###")