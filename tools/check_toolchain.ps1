[CmdletBinding()]
param(
    [string]$OutputJsonPath = "",
    [switch]$Pretty = $true
)

$ErrorActionPreference = "SilentlyContinue"

function Test-FileTool {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Path
    )
    $exists = Test-Path -LiteralPath $Path
    return [ordered]@{
        name   = $Name
        type   = "file"
        exists = [bool]$exists
        path   = $Path
    }
}

function Test-CommandTool {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [string[]]$VersionArgs = @("--version")
    )

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        return [ordered]@{
            name         = $Name
            type         = "command"
            exists       = $false
            commandPath  = $null
            allPaths     = @()
            versionText  = $null
            versionArgs  = $VersionArgs -join " "
        }
    }

    $all = @()
    $where = (& where.exe $Name 2>$null)
    if ($where) { $all = @($where) }

    $versionText = $null
    try {
        $argLine = $VersionArgs -join " "
        $out = & $cmd.Source @VersionArgs 2>&1
        if ($out) {
            $versionText = ($out | Select-Object -First 3) -join "`n"
        } else {
            $versionText = ""
        }
    } catch {
        $versionText = $null
    }

    return [ordered]@{
        name         = $Name
        type         = "command"
        exists       = $true
        commandPath  = $cmd.Source
        allPaths     = $all
        versionText  = $versionText
        versionArgs  = $VersionArgs -join " "
    }
}

function Get-IfxVersionText {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    try {
        $out = & $Path /help 2>&1
        if (-not $out) { return "ifx executable responds, but no help output captured." }
        $line = $out | Where-Object { $_ -match "Intel\(R\) Fortran Compiler" } | Select-Object -First 1
        if ($line) { return [string]$line }
        return ($out | Select-Object -First 2) -join "`n"
    } catch {
        return $null
    }
}

$root = Split-Path -Parent $PSScriptRoot
$timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")

# Known local paths from current machine conventions.
$known = [ordered]@{
    vsDevenv   = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.com"
    vsDevCmd   = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat"
    msvcCl     = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\bin\HostX64\x64\cl.exe"
    oneapiVars = "D:\Program Files (x86)\Intel\oneAPI\setvars.bat"
    ifort      = "D:\Program Files (x86)\Intel\oneAPI\compiler\latest\windows\bin\intel64\ifort.exe"
    ifx        = "D:\Program Files (x86)\Intel\oneAPI\compiler\latest\windows\bin\ifx.exe"
}

$files = @(
    (Test-FileTool -Name "vs.devenv.com" -Path $known.vsDevenv),
    (Test-FileTool -Name "vs.VsDevCmd.bat" -Path $known.vsDevCmd),
    (Test-FileTool -Name "msvc.cl.exe" -Path $known.msvcCl),
    (Test-FileTool -Name "intel.oneapi.setvars.bat" -Path $known.oneapiVars),
    (Test-FileTool -Name "intel.ifort.exe" -Path $known.ifort),
    (Test-FileTool -Name "intel.ifx.exe" -Path $known.ifx)
)

$commands = @(
    (Test-CommandTool -Name "python" -VersionArgs @("--version")),
    (Test-CommandTool -Name "pip"    -VersionArgs @("--version")),
    (Test-CommandTool -Name "git"    -VersionArgs @("--version")),
    (Test-CommandTool -Name "cmake"  -VersionArgs @("--version")),
    (Test-CommandTool -Name "node"   -VersionArgs @("--version")),
    (Test-CommandTool -Name "npm"    -VersionArgs @("--version")),
    (Test-CommandTool -Name "java"   -VersionArgs @("-version")),
    (Test-CommandTool -Name "javac"  -VersionArgs @("-version")),
    (Test-CommandTool -Name "go"     -VersionArgs @("version")),
    (Test-CommandTool -Name "rustc"  -VersionArgs @("--version")),
    (Test-CommandTool -Name "cargo"  -VersionArgs @("--version")),
    (Test-CommandTool -Name "cl"     -VersionArgs @("/?")),
    (Test-CommandTool -Name "ifort"  -VersionArgs @("/QV")),
    (Test-CommandTool -Name "ifx"    -VersionArgs @("/help"))
)

# Explicit version probes for absolute compiler paths.
$explicitVersions = [ordered]@{
    ifortPathVersion = $null
    ifxPathVersion   = $null
}

if (Test-Path -LiteralPath $known.ifort) {
    $v = & $known.ifort /QV 2>&1
    if ($v) { $explicitVersions.ifortPathVersion = ($v | Select-Object -First 2) -join "`n" }
}
$explicitVersions.ifxPathVersion = Get-IfxVersionText -Path $known.ifx

$recommendations = [ordered]@{
    startupCmd = @(
        "call `"$($known.oneapiVars)`"",
        "call `"$($known.vsDevCmd)`" -arch=amd64"
    )
    projectBuildCmd = "`"$($known.vsDevenv)`" `"$root\vs-build\cantilever.sln`" /Build `"Release|x64`""
}

$report = [ordered]@{
    schemaVersion = "1.0"
    generatedAt   = $timestamp
    host          = [ordered]@{
        osVersion   = [System.Environment]::OSVersion.VersionString
        machineName = $env:COMPUTERNAME
        userName    = $env:USERNAME
    }
    projectRoot   = $root
    files         = $files
    commands      = $commands
    explicit      = $explicitVersions
    recommendations = $recommendations
}

$jsonDepth = 8
if ($Pretty) {
    $json = $report | ConvertTo-Json -Depth $jsonDepth
} else {
    $json = $report | ConvertTo-Json -Depth $jsonDepth -Compress
}

if ([string]::IsNullOrWhiteSpace($OutputJsonPath)) {
    # Default output path under tools/.
    $OutputJsonPath = Join-Path $PSScriptRoot "toolchain_report.json"
}

$outputDir = Split-Path -Parent $OutputJsonPath
if ($outputDir -and -not (Test-Path -LiteralPath $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
}

[System.IO.File]::WriteAllText($OutputJsonPath, $json, [System.Text.Encoding]::UTF8)
Write-Output "Toolchain report written: $OutputJsonPath"

