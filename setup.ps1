param([switch]$NoPackageInstall, [switch]$NoSymblink)

$role = [Security.Principal.WindowsBuiltInRole]::Administrator
$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole($role)


# Setting execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

if (-not $admin) {
    Write-Host "Please run this script administrative privileges..." -ForegroundColor Red
    exit 1
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
    $wingetJob = Start-Job -ScriptBlock {
        $wingetInstallURL ="https://raw.githubusercontent.com/asheroto/winget-install/master/winget-install.ps1"  
        Invoke-RestMethod $wingetInstallURL | Invoke-Expression
    }

    Write-Host "Winget isn't installed on your system" -ForegroundColor Red
    Wait-Job -Job $wingetJob
    Write-Host (Receive-Job -Job $wingetJob)
}

$chocolateyExists = IsCommandExists choco
if (-not $chocolateyExists) {
    $chocoJob = Start-Job -ScriptBlock {
        $chocoInstallURL = "https://community.chocolatey.org/install.ps1"  
        Invoke-RestMethod $chocoInstallURL | Invoke-Expression
        return
    }

    Write-Host "Chocolatey isn't installed on your system" -ForegroundColor Red
    Wait-Job -Job $chocoJob
    Write-Host (Receive-Job -Job $chocoJob)
}


$chocolateyExists = IsCommandExists choco
$wingetExists = IsCommandExists winget
if (-not ($wingetExists -and $chocolateyExists)){
    Write-Host "winget and chocolatey command isn't found restart powershell or system"
    exit 1
}

ShowText "Cloning .dotfile repository"

# Installing git

$gitExitst = IsCommandExists git
if (-not $gitExitst) {
    Write-Host "Installing git" -ForegroundColor Green
    winget install -s winget --id Git.Git
}

Write-Host "Please select a Directory to clone the .dotfile git repository" -ForegroundColor Cyan
Add-Type -AssemblyName System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$dialogResult = $folderBrowser.ShowDialog()

if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $selectedDirPath = $folderBrowser.SelectedPath
    $scriptDir = "$selectedDirPath\win-dotfiles"
} else {
    Write-Host "No folder selected."
    exit 1
}

Write-Host "Cloning .dotfile repository to $scriptDir"
git clone "https://github.com/Nadim147c/win-dotfiles" $scriptDir
Set-Location $scriptDir

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

