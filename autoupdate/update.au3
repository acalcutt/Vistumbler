#Include <Array.au3>
$CurrentVersionFile = @ScriptDir & '\versions.ini'
$NewVersionFile = @ScriptDir & '\temp\versions.ini'
$SVN_ROOT = 'http://vistumbler.svn.sourceforge.net/svnroot/vistumbler/autoupdate/'
$VIEWSVN_ROOT = 'http://vistumbler.svn.sourceforge.net/viewvc/vistumbler/autoupdate/'
;Vistumbler.au3?revision=51

DirCreate(@ScriptDir & '\temp\')
FileDelete($NewVersionFile)
InetGet($SVN_ROOT & 'versions.ini', $NewVersionFile)
If FileExists($NewVersionFile) Then
	$fv = IniReadSection($NewVersionFile, "FileVersions")
	If Not @error Then 
		For $i = 1 To $fv[0][0]
			$filename = $fv[$i][0]
			$filename_web = StringReplace($filename, '\', '/')
			$version = $fv[$i][1]
			If IniRead($CurrentVersionFile, "FileVersions", $filename, '0') <> $version Or FileExists(@ScriptDir & '\' & $filename) = 0 Then
				If StringInStr($filename, '\') Then
					$struct = StringSplit($filename, '\')
					For $cp = 1 to $struct[0] - 1
						If $cp = 1 Then 
							$dirstruct = $struct[$cp]
						Else
							$dirstruct &= '\' & $struct[$cp]
						EndIf
						DirCreate(@ScriptDir & '\' & $dirstruct)
					Next
				EndIf
				$getfile = InetGet($VIEWSVN_ROOT & $filename_web & '?revision=' & $version, @ScriptDir & '\' & $filename)
				If $getfile = 1 Then
					IniWrite($CurrentVersionFile, "FileVersions", $filename, $version)
					ConsoleWrite('New File:' & $filename & @CRLF)
				Else
					ConsoleWrite('Error Downloading New File:' & $filename & @CRLF)
				EndIf
			Else
				ConsoleWrite('No Change In File:' & $filename & @CRLF)
			EndIf
		Next
	EndIf
EndIf