function IsCommandExists ([string]$cmd) {
    try {
        $command = Get-Command $cmd
        if ($command) { return $true }
    } catch {
        return $true
    }
}

$wingetExists = IsCommandExists winget
$chocolateyExists = IsCommandExists choco

if (-not $wingetExists) {
    $wingetInstallURL ="https://raw.githubusercontent.com/asheroto/winget-install/master/winget-install.ps1"  
    Write-Host "Winget isn't installed on your system" -ForegroundColor Red
    Write-Host "Running: `"" -NoNewline
    Write-Host "irm $wingetInstallURL | iex" -ForegroundColor Cyan -NoNewline
    Write-Host "`""
    Invoke-RestMethod $wingetInstallURL | Invoke-Expression
}

if (-not $chocolateyExists) {
    Write-Host "Winget isn't installed on your system" -ForegroundColor Red
    Write-Host "Run: `"" -NoNewline
    Write-Host "winget install --id Chocolatey.Chocolatey" -ForegroundColor Cyan -NoNewline
    Write-Host "`""
    winget install --id Chocolatey.Chocolatey
    return
}

$scriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)

$config = Get-Content "$scriptDir\config.json" | ConvertFrom-Json

winget install $config.packages.winget
pip install $config.packages.pip

$role = [Security.Principal.WindowsBuiltInRole]::Administrator
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole($role)

if (-not $admin) {
    Write-Host "Requesting administrative privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 0
}

choco install -y $config.packages.chocolatey 

function CreateDirectory ([string]$path) {
    $basePath = [System.IO.Path]::GetDirectoryName($path)
    if (-not (Test-Path $basePath)) {
        try {
            New-Item $basePath -ItemType Directory | Out-Null
        } catch { 
        } 
    }
}

foreach ($link in $config.links) {
    $destination = $link.destination.Replace("~", $HOME)
    $source = [System.IO.Path]::GetFullPath($link.source)

    if (Test-Path $destination) {
        Write-Host "`"$destination`"" -NoNewline -ForegroundColor Cyan
        Write-Host " already exists and removing it." 
        Remove-Item $destination 
    }
    CreateDirectory($destination)

    Write-Host "Links $source -> $destination `n" -ForegroundColor Green
    New-Item -Path $destination -ItemType SymbolicLink -Value $source | Out-Null
}

