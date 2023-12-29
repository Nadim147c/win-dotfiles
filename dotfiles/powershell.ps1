Clear-Host
$env:PYTHONIOENCODING = 'utf-8'
# $ENV:FZF_DEFAULT_OPTS=@"
# --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#a6e3a1
# --color=fg:#cdd6f4,header:#a6e3a1,info:#94e2d5,pointer:#f5e0dc
# --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#94e2d5,hl+:#a6e3a1
# "@

# Alises 
Set-Alias vim nvim
Set-Alias yt yt-dlp
Set-Alias gd gallery-dl 
Set-Alias f fuck
Set-Alias n pnpm
Set-Alias pm pm2
Set-Alias code codium

# function aliase
function Edit-History {
    vim (Get-PSReadLineOption).HistorySavePath 
}
function s. {
    Start-Process . 
}
function vsc {
    code . 
}
function vimconfig {
    vim $Home\Appdata\local\nvim\lua\custom 
}
function ff {
    Get-ChildItem | ForEach-Object { $_.Name } | fzf 
}
function config ([switch]$vsc) {
    if ($vsc) {
        code $profile 
    } else {
        vim $profile 
    }
}
function md5 {
    Get-FileHash -Algorithm MD5 $args 
}
function sha1 {
    Get-FileHash -Algorithm SHA1 - $args 
}
function sha256 {
    Get-FileHash -Algorithm SHA256 $args 
}

function reset { 
    Write-Host("This will parmanently delete all powershell history.") -ForegroundColor Yellow
    $confirmation = Read-Host("Do you want to continue (Y/N): ")

    if ($confirmation.ToLower() -ne "y") {
        return Write-Host "Didn't delete any history." -ForegroundColor Green
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
    Remove-Item (Get-PSReadLineOption).HistorySavePath 

    Write-Host("Powershell history has been deleted.") -ForegroundColor Yellow
}


# Plugins
Import-Module PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+f'

Invoke-Expression (&starship init powershell)

# pip install git+https://github.com/nvbn/thefuck
Invoke-Expression "$(thefuck --alias)"

# winget completion

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# Chocolatey
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

Write-Host @"
 _____ ____  _   _ _____ __  __ _____ ____      _    _     
| ____|  _ \| | | | ____|  \/  | ____|  _ \    / \  | |    
|  _| | |_) | |_| |  _| | |\/| |  _| | |_) |  / _ \ | |    
| |___|  __/|  _  | |___| |  | | |___|  _ <  / ___ \| |___ 
|_____|_|   |_| |_|_____|_|  |_|_____|_| \_\/_/   \_\_____|

"@ -ForegroundColor Green

# winfetch

