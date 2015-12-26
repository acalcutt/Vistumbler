
#include "UDFs\MD5.au3"

$file = "C:\Users\Andrew.EIRI\Documents\GitHub\Vistumbler\WifiDB_Uploader\test\test3.VS1"

$loadfileMD5 = _MD5ForFile($file)
ConsoleWrite('MD5:' & $loadfileMD5 & ' | Size:' & Round(FileGetSize ($file)/1024) & 'kB' & @CRLF)

;ConsoleWrite("### START ###" & @CRLF & StringReplace(FileRead($file), @CRLF, "[CRLF]" & @CRLF) & @CRLF & "### END ###")

$fileopen = FileOpen($file,16)
$fileread = FileRead($fileopen)
;ConsoleWrite("### START ###" & @CRLF & StringReplace($fileread, @CRLF, "[CRLF]" & @CRLF) & @CRLF & "### END ###")

FileClose($fileopen)



$sFileRead = BinaryToString($fileread)
$readMD5 = _MD5($sFileRead)
ConsoleWrite('MD5:' & $readMD5 & @CRLF)
ConsoleWrite($sFileRead & @CRLF)



