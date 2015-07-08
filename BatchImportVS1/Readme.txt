<<ImportVS1_mdb.exe Readme>>

Switches:
/f - filename or directory to import
/o - output mdb file

Example:
-- Import Single File --
ImportVS1_mdb.exe /f="c:\PathToSourceFile\input.vs1" /o="c:\OutputDir\out.mdb"

-- Import Folder Of VS1 files--
ImportVS1_mdb.exe /f="c:\PathToFolderWithVS1s\" /o="c:\OutputDir\out.mdb"

-- Prompt for directory and Import Folder Of VS1 files--
ImportVS1_mdb.exe /o="c:\OutputDir\out.mdb"

-- Prompt for directory, output to VS1_Import.mdb--
ImportVS1_mdb.exe


