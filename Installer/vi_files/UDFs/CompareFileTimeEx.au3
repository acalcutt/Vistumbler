Func _CompareFileTimeEx($hSource, $hDestination, $iMethod)
    ;Parameters ....:       $hSource -      Full path to the first file
    ;                       $hDestination - Full path to the second file
    ;                       $iMethod -      0   The date and time the file was modified
    ;                                       1   The date and time the file was created
    ;                                       2   The date and time the file was accessed
    ;Return values .:                       -1  The Source file time is earlier than the Destination file time
    ;                                       0   The Source file time is equal to the Destination file time
    ;                                       1   The Source file time is later than the Destination file time
    ;Author ........:       Ian Maxwell (llewxam @ AutoIt forum)
    $aSource = FileGetTime($hSource, $iMethod, 0)
    $aDestination = FileGetTime($hDestination, $iMethod, 0)
    For $a = 0 To 5
        If $aSource[$a] <> $aDestination[$a] Then
            If $aSource[$a] < $aDestination[$a] Then
                Return -1
            Else
                Return 1
            EndIf
        EndIf
    Next
    Return 0
EndFunc   ;==>_CompareFileTimeEx