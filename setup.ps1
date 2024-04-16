param(
    [switch]$NoPackageInstall,
    [switch]$NoSymblink
)

$role = [Security.Principal.WindowsBuiltInRole]::Administrator
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole($role)

if (-not $admin) {
    Write-Host "Please run this script administrative privileges..." -ForegroundColor Red
    exit 0
}

$currentDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
Set-Location $currentDirectory

function ShowText ([string]$Text,[switch]$color) {
    $MaximumLenght = ($Text.Split("`n") | ForEach-Object {$_.Length} | Measure-Object -Maximum).Maximum
    $TitleLength =  $MaximumLenght + 4
    $Border = "-" * $TitleLength

    Write-Host "$Border" -ForegroundColor Green 
    $Text.Split("`n") | ForEach-Object {
        Write-Host "| " -ForegroundColor Green -NoNewline
        if ($color) {
            Write-Host $_ -ForegroundColor Cyan -NoNewline
        } else {
            Write-Host $_ -NoNewline 
        }
        $Spaces = " " * ($MaximumLenght - $_.Length)
        Write-Host "$Spaces |" -ForegroundColor Green
    }
    Write-Host "$Border" -ForegroundColor Green
}

function IsCommandExists ([string]$cmd) {
    try {
        $command = Get-Command $cmd
        if ($command) {
            return $true 
        }
    } catch {
        return $true
    }
}


ShowText "Checking for package manager: WinGet & Chocolatey"

$wingetExists = IsCommandExists winget
if (-not $wingetExists) {
    $wingetInstallURL ="https://raw.githubusercontent.com/asheroto/winget-install/master/winget-install.ps1"  
    Write-Host "Winget isn't installed on your system" -ForegroundColor Red
    Invoke-RestMethod $wingetInstallURL | Invoke-Expression
}

$chocolateyExists = IsCommandExists choco
if (-not $chocolateyExists) {
    Write-Host "Winget isn't installed on your system" -ForegroundColor Red
    winget install --id Chocolatey.Chocolatey
    return
}

$scriptDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)

$config = Get-Content "$scriptDir\config.json" | ConvertFrom-Json

ShowText "Installing following winget packages..."
ShowText "$($config.packages.winget -join "`n")" -color
if (-not $NoPackageInstall) {
    winget install $config.packages.winget
}

ShowText "Installing following python3 packages..."
ShowText "$($config.packages.pip -join "`n")" -color
if (-not $NoPackageInstall){
    pip install $config.packages.pip
}


ShowText "Installing following chocolatey packages..."
ShowText "$($config.packages.chocolatey -join "`n")" -color 
if (-not $NoPackageInstall) {
    choco install -y $config.packages.chocolatey 
}

function CreateDirectory ([string]$path) {
    $basePath = [System.IO.Path]::GetDirectoryName($path)
    if (-not (Test-Path $basePath)) {
        try {
            New-Item $basePath -ItemType Directory | Out-Null
        } catch { 
        } 
    }
}

ShowText "Linking dotfiles from source"
foreach ($link in $config.links) {
    $destination = $link.destination.Replace("~", $HOME)
    $source = [System.IO.Path]::GetFullPath($link.source)

    if (Test-Path $destination) {
        Write-Host "`"$destination`"" -NoNewline -ForegroundColor Cyan
        Write-Host " already exists and removing it." 
        if (-not $NoSymblink) {
            Remove-Item $destination 
        }
    }

    CreateDirectory($destination)

    Write-Host "Linking: $source -> $destination `n" -ForegroundColor Green
    if (-not $NoSymblink) {
        New-Item -Path $destination -ItemType SymbolicLink -Value $source | Out-Null
    }
}

