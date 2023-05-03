; Vistumbler.nsi
;
; This script is based on example1.nsi, but it remember the directory, 
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install example2.nsi into a directory that the user selects,

;--------------------------------
; The name of the installer
Name "Vistumbler"

; The file to write
OutFile "Vistumbler_v10-8-1.exe"

; The default installation directory
InstallDir $PROGRAMFILES\Vistumbler

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\Vistumbler" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "Vistumbler (required)"

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File /r vi_files\*.*
  
  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\Vistumbler "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vistumbler" "DisplayName" "Vistumbler"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vistumbler" "DisplayVersion" "10.8.1"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vistumbler" "Publisher" "Vistumbler.net"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vistumbler" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vistumbler" "DisplayIcon" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vistumbler" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vistumbler" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\Vistumbler"
  CreateShortcut "$SMPROGRAMS\Vistumbler\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortcut "$SMPROGRAMS\Vistumbler\Vistumbler.lnk" "$INSTDIR\Vistumbler.exe" "" "$INSTDIR\Vistumbler.exe" 0
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vistumbler"
  DeleteRegKey HKLM SOFTWARE\Vistumbler

  ; Remove directories used
  RMDir /r $SMPROGRAMS\Vistumbler
  RMDir /r /REBOOTOK $INSTDIR
  RMDir /r /REBOOTOK $APPDATA\Vistumbler

SectionEnd
