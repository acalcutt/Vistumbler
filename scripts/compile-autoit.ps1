Param(
    [string]$SourceDir = "VistumblerMDB",
    [string]$OutDir = "artifacts/vistumblermdb-exes",
    [switch]$ForceX86
)

$ErrorActionPreference = 'Stop'

function Find-Aut2Exe {
    $candidates = @(
        "$env:ProgramFiles\AutoIt3\Aut2Exe\Aut2Exe.exe",
        "$env:ProgramFiles(x86)\AutoIt3\Aut2Exe\Aut2Exe.exe"
    )
    foreach ($c in $candidates) { if (Test-Path $c) { return $c } }
    $found = Get-ChildItem -Path "C:\Program Files*","C:\Program Files (x86)*" -Filter Aut2Exe.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) { return $found.FullName }
    return $null
}

$aut2exe = Find-Aut2Exe
if (-not $aut2exe) {
    Write-Error "Aut2Exe.exe not found. Ensure AutoIt is installed on the runner."
    exit 2
}

$srcInfo = Get-Item -LiteralPath $SourceDir -ErrorAction SilentlyContinue
if (-not $srcInfo) {
    Write-Error "Source directory '$SourceDir' not found."
    exit 2
}

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
$outResolved = (Resolve-Path $OutDir).Path

Write-Host "Using Aut2Exe: $aut2exe"
Write-Host "Source: $($srcInfo.FullName)"
Write-Host "Output: $outResolved"

$files = Get-ChildItem -Path $SourceDir -Recurse -Include *.au3 -File | Where-Object {
    # Exclude include/UDF(s) folders since those are include files, not standalone scripts
    $_.FullName -notmatch '\\UDFs?\\'
}
if (-not $files) { Write-Host "No .au3 files found under $SourceDir"; exit 0 }

$errors = @()
foreach ($f in $files) {
    $rel = $f.FullName.Substring($srcInfo.FullName.Length).TrimStart('\','/')
    $targetDir = Join-Path $outResolved (Split-Path $rel -Parent)
    if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
    # Parse AutoIt3Wrapper directives (if present) for Outfile/Icon/etc.
    function Parse-AutoIt3WrapperDirectives($filePath) {
        $result = @{}
        $lines = Get-Content -LiteralPath $filePath -ErrorAction SilentlyContinue
        $inRegion = $false
        foreach ($line in $lines) {
            if ($line -match '^\s*#Region\b.*AutoIt3Wrapper') { $inRegion = $true; continue }
            if ($inRegion -and $line -match '^\s*#EndRegion') { break }
            if ($inRegion -and $line -match '^\s*#AutoIt3Wrapper_(\w+)\s*=\s*(.*)$') {
                $key = $matches[1]
                $val = $matches[2].Trim()
                $result[$key] = $val
            }
        }
        return $result
    }

    $directives = Parse-AutoIt3WrapperDirectives($f.FullName)
    if ($directives.ContainsKey('Outfile')) {
        $outName = $directives['Outfile']
        $outExe = Join-Path $targetDir $outName
    } else {
        $outExe = Join-Path $targetDir ($f.BaseName + '.exe')
    }

    $args = @('/in', $f.FullName, '/out', $outExe, '/comp', '2')
    # Use icon directive if present
    if ($directives.ContainsKey('Icon')) {
        $iconPath = $directives['Icon']
        if (-not [IO.Path]::IsPathRooted($iconPath)) { $iconFull = Join-Path (Split-Path $f.FullName -Parent) $iconPath } else { $iconFull = $iconPath }
        if (Test-Path $iconFull) { $args += @('/icon', $iconFull) }
    }
    # Force 32-bit output when requested
    if ($ForceX86) { $args += '/x86' }
    Write-Host "Compiling $($f.FullName) -> $outExe"
    $proc = Start-Process -FilePath $aut2exe -ArgumentList $args -Wait -PassThru -NoNewWindow
    if ($proc.ExitCode -ne 0) {
        $errors += @{ File = $f.FullName; ExitCode = $proc.ExitCode }
        Write-Host "Failed $($f.FullName) exit $($proc.ExitCode)"
    } else {
        Write-Host "OK: $outExe"
    }
}

if ($errors.Count -gt 0) {
    Write-Error "Some files failed to compile"
    $errors | ForEach-Object { Write-Host "$($_.File) -> ExitCode $($_.ExitCode)" }
    exit 1
}

Write-Host "All compiled successfully."
