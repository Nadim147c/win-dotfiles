Clear-Host
$env:PYTHONIOENCODING = 'utf-8'

# Alises 
Set-Alias vim nvim
Set-Alias yt yt-dlp
Set-Alias gdl gallery-dl 
Set-Alias grep findstr
Set-Alias n pnpm
Set-Alias f fuck

# function aliase
function s. { Start-Process . }
function vsc { code . }
function vimconfig { vim $Home\Appdata\local\nvim\lua\custom }

# Custom Command
function ws {
    $query = $args -join ' ';
    Write-Host("Searching for `"$args`"");
    winget search "$query"
}

function cs {
    $query = $args -join ' ';
    Write-Host("Searching for `"$args`"");
    choco search "$query"
}

function wi {
    $query = $args -join ' ';
    Write-Host("Searching for `"$args`"");
    winget install "$query"
}

function ci {
    $query = $args -join ' ';
    Write-Host("Searching for `"$args`"");
    sudo choco install "$query"
}

function config ([switch]$vsc) {
    if ($vsc) { code $profile } else { vim $profile }
}

function reload {
    $currentDir = Get-Location
    Start-Process "C:\Program Files\PowerShell\7\pwsh.exe" -WorkingDirectory $currentDir 
    Start-Sleep -Seconds 1
    Exit
}

function reset { 
    Write-Host("This will parmanently delete all powershell history.") -ForegroundColor Yellow
    $confirmation = Read-Host("Do you want to continue (Y/N): ")

    if ($confirmation.ToLower() -eq "y") {
        [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
        Remove-Item (Get-PSReadLineOption).HistorySavePath 

        Write-Host("Powershell history has been deleted.") -ForegroundColor Yellow
    }
}

function zip ($path, $destination = "") {
    if ($destination -eq "") {
        $destination = [System.IO.Path]::Combine((Get-Location).Path, [System.IO.Path]::GetFileNameWithoutExtension($path) + ".zip")
    }
    Compress-Archive -Path $path -DestinationPath $destination
}

function unzip ($path, $destination = "") {
    if ($destination -eq "") {
        $destination = [System.IO.Path]::Combine((Get-Location).Path, [System.IO.Path]::GetFileNameWithoutExtension($path))
    }
    Expand-Archive -Path $path -DestinationPath $destination
}

function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 - $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }
function mhash ($algorithm, $filePath, $fileHash) {
    if (-not ($algorithm -and $filePath -and $fileHash)) {
        Write-Host "One or more parameters are missing." -ForegroundColor Red
        Write-Host "mhash [Algorithm: MD5|SHA1|SHA256|SHA384|SHA512] [file_path] [existing_hash]"
        return
    }

    $hashValue = Get-FileHash -Algorithm $algorithm $filePath
    $hashValue
    if ($hashValue.Hash -eq $fileHash) {
        Write-Host("File hash matched.") -ForegroundColor Green
    }
    else {
        Write-Host("File hash didn't match.") -ForegroundColor Red
    }
}

function wifi {
    $networks = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }

    if ($networks.Count -eq 0) {
        Write-Host "No WiFi networks found." -ForegroundColor Yellow
        return
    }

    if ($networks.GetType().Name -eq "String") {
	 
        $profileinfo = netsh wlan show profile name="$($networks)" key=clear
        $password = $profileinfo | Select-String "key content" | ForEach-Object { $_.toString().Split(":")[1].Srim() }

        Write-Host "ssid: $($networks)"
        Write-Host "password: $($password)"
	
        # pip install qrcode
        qr --error-correction=H "WIFI:T:WPA;S:$($networks);P:$($password);;"

        return
    }

    Write-Host "Available WiFi Networks: $($networks.Count)"
    for ($i = 0; $i -lt $networks.Count; $i++) {
        Write-Host "$($i + 1). $($networks[$i])"
    }

    $choice = [int](Read-Host "Enter the number of the network you want to share")

    if ($choice -ge 1 -and $choice -le $networks.Count) {
        $selectedNetwork = $networks[$choice - 1]
	 
        $profileinfo = netsh wlan show profile name="$($selectednetwork)" key=clear
        $password = $profileinfo | Select-String "key content" | ForEach-Object { $_.tostring().split(":")[1].trim() }

        Write-Host "ssid: $($selectednetwork)"
        Write-Host "password: $($password)"
	
        # pip install qrcode
        qr --error-correction=H "WIFI:T:WPA;S:$($selectednetwork);P:$($password);;"

    }
    else {
        Write-Host "Invalid selection. Please choose a valid option." -ForegroundColor Red
    }
}

function dog ($path) {
    if (-not $path) {
        Write-Host "Please provide a file path" -ForegroundColor Red
        Write-Host "dog [file_path]"
        return
    }
    # pip install pygments
    pygmentize -g -O style=colorful $path
}

function pt ($file, $rarFile, $key) {
    if (-not ($rarFile -and $file -and $key)) {
        Write-Host "One or more parameters are missing." -ForegroundColor Red
        Write-Host "pt [rar_file_path] [target_file_path] [password]"
        return
    }
    Start-Process -FilePath "C:\Program Files\WinRAR\rar.exe" -ArgumentList "a", "-hp$key", $rarFile, $file -NoNewWindow -Wait
}


function video ($url, $sections = "") {
    $validUrl = [System.Uri]::TryCreate($url, [System.UriKind]::Absolute, [ref]$null)

    $outputPath = "%USERPROFILE%\Downloads\Video\%(title)s-%(id)s.%(ext)s"

    if ($validUrl) {
        if ($sections -eq "") {
            yt-dlp -f "bv[height<=1080]+ba/b" --merge-output-format mkv $url -o $outputPath --add-metadata --list-formats --no-simulate --sponsorblock-remove all
        }
        else {
            yt-dlp -f "bv[height<=1080]+ba/b" --merge-output-format mkv $url -o $outputPath --add-metadata --list-formats --no-simulate --sponsorblock-remove all --download-sections $sections
        }
    }
    else {
        $searchUrl = "ytsearch:`"$url`""
        yt-dlp -f "bv[height<=1080]+ba/b" --merge-output-format mkv $searchUrl -o $outputPath --add-metadata --list-formats --no-simulate --sponsorblock-remove all
    }
}

function audio ($url, $sections = "") {
    $validUrl = [System.Uri]::TryCreate($url, [System.UriKind]::Absolute, [ref]$null)
    
    $outputPath = "%USERPROFILE%\Downloads\Audio\%(title)s-%(id)s.%(ext)s"

    if ($validUrl) {
        if ($sections -eq "") {
            yt-dlp -x --audio-format "ba[ext=mp3]" $url -o $outputPath --audio-quality 0 --add-metadata --embed-thumbnail --list-formats --no-simulate --sponsorblock-remove all
        }
        else {
            yt-dlp -x --audio-format "ba[ext=mp3]" $url -o $outputPath --audio-quality 0 --add-metadata --embed-thumbnail --list-formats --no-simulate --sponsorblock-remove all --download-sections $sections
        }
    }
    else {
        $searchUrl = "ytsearch:`"$url`""
        yt-dlp -x --audio-format "ba[ext=mp3]" $searchUrl -o $outputPath --audio-quality 0 --add-metadata --embed-thumbnail --list-formats --no-simulate --sponsorblock-remove all
    }
}

function touch ($path) {
    if (-not $path) {
        Write-Host "Please provide a file path"
        Write-Host "dog [file_path]"
        return
    }
    if (-not (Test-Path -Path $path)) {
        $null = New-Item -ItemType File -Path $path -Force
    }
    else {
        $null = (Get-ChildItem -Path $path).LastWriteTime = Get-Date
        Write-Output "File already exists"
    }
}


# Plugins

Import-Module PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView

Invoke-Expression (&starship init powershell)
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

# Clear-Host
# Printing the name
# Write-Host @"
#  _____ ____  _   _ _____ __  __ _____ ____      _    _     
# | ____|  _ \| | | | ____|  \/  | ____|  _ \    / \  | |    
# |  _| | |_) | |_| |  _| | |\/| |  _| | |_) |  / _ \ | |    
# | |___|  __/|  _  | |___| |  | | |___|  _ <  / ___ \| |___ 
# |_____|_|   |_| |_|_____|_|  |_|_____|_| \_\/_/   \_\_____|
#
# "@ -ForegroundColor Green

# winfetch

