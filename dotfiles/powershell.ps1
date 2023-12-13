Clear-Host
$env:PYTHONIOENCODING = 'utf-8'
$ENV:FZF_DEFAULT_OPTS=@"
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#a6e3a1
--color=fg:#cdd6f4,header:#a6e3a1,info:#94e2d5,pointer:#f5e0dc
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#94e2d5,hl+:#a6e3a1
"@

# Alises 
Set-Alias vim nvim
Set-Alias yt yt-dlp
Set-Alias gdl gallery-dl 
Set-Alias n pnpm
Set-Alias f fuck

# function aliase
function Edit-History { vim (Get-PSReadLineOption).HistorySavePath }
function s. { Start-Process . }
function vsc { code . }
function vimconfig { vim $Home\Appdata\local\nvim\lua\custom }
function ff { Get-ChildItem | ForEach-Object { $_.Name } | fzf }


# Custom Command



function ss ([int]$lines = 10) {
    if (-not $MyInvocation.ExpectingInput) {
        Write-Host "No Input provided"
        return
    }

    $pattern = $input | fzf --preview="$input | grep -A $lines"
    

    Write-Host $content
    Write-Host $content.Length
}

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

    if ($confirmation.ToLower() -ne "y") {
        return Write-Host "Didn't delete any history." -ForegroundColor Green
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
    Remove-Item (Get-PSReadLineOption).HistorySavePath 

    Write-Host("Powershell history has been deleted.") -ForegroundColor Yellow
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

function wifi ($Name) {
    if ($Name) {
        $profileinfo = netsh wlan show profile name="$Name" key=clear
        $ssids =  $profileinfo | Select-String  "Name" | ForEach-Object { $_.tostring().split(":")[1].trim() }
        $password = $profileinfo | Select-String "key content" | ForEach-Object { $_.tostring().split(":")[1].trim() }


        if ($ssids.GetType().BaseType.Name -eq "Array") {
            $Name = $ssids[0]
        }
        elseif ($ssids.GetType().Name -eq "String") {
            $Name = $ssids
        }

        Write-Host "ssid: $name"
        Write-Host "password: $password"
	
        # pip install qrcode
        qr --error-correction=H "WIFI:T:WPA;S:$name;P:$password;;"
        return
    }

    $networks = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }

    if ($networks.Count -eq 0) {
        return Write-Host "No WiFi networks found." -ForegroundColor Yellow
    }

    if ($networks.GetType().Name -eq "String") {
        return wifi $networks
    }

    Write-Host "Available WiFi Networks: $($networks.Count)"
    for ($i = 0; $i -lt $networks.Count; $i++) {
        Write-Host "$($i + 1). $($networks[$i])"
    }

    $choice = [int](Read-Host "Enter the number of the network you want to share")

    if ($choice -ge 1 -and $choice -le $networks.Count) {
        return wifi $networks[$choice - 1]
    }
    else {
        Write-Host "Invalid selection. Please choose a valid option." -ForegroundColor Red
    }
}

function dog ($path) {
    if ($MyInvocation.ExpectingInput -and -not $path) { $path = $input }

    if (-not $path) {
        Write-Host "Path argument is missing." -ForegroundColor Red
        Write-Host "dog [file_path]"
    }

    #pip install catppuccin[pygments] pygments
    pygmentize -g -O style="catppuccin-mocha" $path
}

Set-Alias cat dog

function pt ($file, $rarFile, $key) {
    if (-not ($rarFile -and $file -and $key)) {
        Write-Host "One or more parameters are missing." -ForegroundColor Red
        Write-Host "pt [rar_file_path] [target_file_path] [password]"
        return
    }

    Start-Process -FilePath "C:\Program Files\WinRAR\rar.exe" -ArgumentList "a", "-hp$key", $rarFile, $file -NoNewWindow -Wait
}


function video {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Url,
        [string]$Sections = "",
        [ValidateSet("mp4", "webm", "mkv")]
        [string]$Format = "mp4",
        [string]$CookiesFile,
        [switch]$UseBraveCookies,
        [switch]$NoSponserBlock
    )

    $outputPath = "%USERPROFILE%\Downloads\Videos\%(title)s-%(id)s.%(ext)s"

    $arguments = @(
        "-f", "bv[height<=1080]+ba/b",
        "--merge-output-format", $Format,
        "-o", $outputPath,
        "--add-metadata",
        "--embed-chapters",
        "--list-formats",
        "--no-simulate"
    )

    if ($Sections -ne "") { $arguments = $arguments + "--download-sections" + $Sections }

    if ($CookiesFile) { $arguments = $arguments + "--cookies" + $CookiesFile }

    if ($UseBraveCookies) { $arguments = $arguments + "--cookies-from-browser" + "brave" }

    if (-not $NoSponserBlock) { $arguments = $arguments + "--sponsorblock-remove" + "all" }

    $validUrl = [System.Uri]::TryCreate($url, [System.UriKind]::Absolute, [ref]$null)
    if (-not $validUrl) {
        $url = "ytsearch:`"$Url`""
    }

    Write-Host("Running:")
    Write-Host("yt-dlp $($arguments -join " ") $Url") -ForegroundColor Cyan

    yt-dlp $arguments $Url
}

function audio {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Url,
        [string]$Sections = "",
        [string]$CookiesFile,
        [switch]$UseBraveCookies,
        [switch]$NoSponserBlock,
        [switch]$YouTubeMusic
    )

    $outputPath = "%USERPROFILE%\Downloads\Audios\%(title)s-%(id)s.%(ext)s"

    $arguments = @(
        "--extract-audio",
        "--format", "ba/best",
        "--audio-format", "mp3",
        "-o", $outputPath,
        "--no-playlist",
        "--audio-quality", "0",
        "--add-metadata",
        "--embed-thumbnail",
        "--list-formats",
        "--no-simulate"
    )

    if ($Sections -ne "") { $arguments = $arguments + "--download-sections" + $Sections }

    if ($CookiesFile) { $arguments = $arguments + "--cookies" + $CookiesFile }

    if ($UseBraveCookies) { $arguments = $arguments + "--cookies-from-browser" + "brave" }

    if (-not $NoSponserBlock) { $arguments = $arguments + "--sponsorblock-remove" + "all" }

    $validUrl = [System.Uri]::TryCreate($Url, [System.UriKind]::Absolute, [ref]$null)

    if (-not $validUrl) {
        if ($YouTubeMusic) {
            $arguments = $arguments + "--playlist-end" + "1"
            $Url = "https://music.youtube.com/search?q=$Url"
        }
        else {
            $arguments.Add("-x")
            $Url = "ytsearch:`"$Url`""
        }
    } 
    else {
        $arguments.Add("-x")
    }

    Write-Host("Running:")
    Write-Host("yt-dlp $($arguments -join " ") $Url") -ForegroundColor Cyan 

    yt-dlp $arguments $Url
}

function touch ($path) {
    if ($MyInvocation.ExpectingInput -and -not $path) { $path = $input }

    if (-not $path) {
        Write-Host "Please provide a file path"
        Write-Host "dog [file_path]"
        return
    }

    if (-not (Test-Path -Path $path)) { New-Item -ItemType File -Path $path -Force }
    else { Write-Output "File already exists" }
}

function CropVideo {
    param(
        [Parameter(position = 0, Mandatory = $true)]
        [string]$InputPath,
        [Parameter(position = 1, Mandatory = $false)]
        [string]$OutputPath,
        [Parameter(position = 2, Mandatory = $false)]
        [int]$RatioWidth,
        [Parameter(position = 3, Mandatory = $false)]
        [int]$RatioHeight,
        [int]$Top = 0,
        [int]$Bottom = 0,
        [int]$Left = 0,
        [int]$Right = 0,
        [ValidateSet("white", "black")]
        [string]$BarColor = "black"
    )

    if (-not $OutputPath) {
        $uuid = New-Guid 
        
        $OutputPath = "$($uuid.Guid).mp4"
    }

    $videoSize = ffprobe -v error -select_streams "v:0" -show_entries stream="width,height" -of "csv=s=x:p=0" $InputPath

    $videoWidth = [int]($videoSize.ToString().Split("x")[0])
    $videoHeight = [int]($videoSize.ToString().Split("x")[1])

    if ($RatioWidth -and $RatioHeight) {

        $wr = $videoWidth / $RatioWidth
        $hr = $videoHeight / $RatioHeight

        $width = ($wr, $hr | Measure-Object -Minimum).Minimum * $RatioWidth
        $height = ($width / $RatioWidth) * $RatioHeight

        $x = ($videoWidth - $width) / 2
        $y = ($videoHeight - $height) / 2

        $crop = "$($width):$($height):$($x):$($y)"
    } else {
        if ($BarColor -eq "black") {
            $cropValues = ffmpeg -i $InputPath -t 2 -vf "eq=contrast=1.8,cropdetect" -f null - 2>&1 | Select-String '(?<=crop=).*?(?=$)' 
        } else {
            $cropValues = ffmpeg -i $InputPath -t 2 -vf "eq=contrast=1.8,negate,cropdetect" -f null - 2>&1 | Select-String '(?<=crop=).*?(?=$)' 
        }

        $crop = $cropValues | ForEach-Object {$_.Matches} | ForEach-Object {$_.Value} | Sort-Object | Get-Unique

        $cropSplit = $crop.Split(":")

        $width = [int]$cropSplit[0] + $Left + $Right
        $height = [int]$cropSplit[1] + $Top + $Bottom
        $x = [int]$cropSplit[2] - $Left
        $y = [int]$cropSplit[3] - $Top 

        if ($x + $width -gt $videoWidth) {
            $width = $videoWidth - $x
        }

        if ($y + $height -gt $videoHeight) {
            $height = $videoHeight - $y
        }

        $crop = "$($width):$($height):$($x):$($y)"
    }


    Write-Host "Running:"
    Write-Host "ffmpeg -i '$InputPath' -vf 'crop=$crop' $OutputPath\n" -ForegroundColor Cyan

    ffmpeg -i $InputPath -vf "crop=$crop" $OutputPath

    Write-Host "Rerun (with fixes) this command to fix mistakes: "
    Write-Host "ffmpeg -i '$InputPath' -y -vf 'crop=$crop' $OutputPath" -ForegroundColor Cyan
}


# Plugins
Import-Module PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+f'

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

Clear-Host
Write-Host @"
 _____ ____  _   _ _____ __  __ _____ ____      _    _     
| ____|  _ \| | | | ____|  \/  | ____|  _ \    / \  | |    
|  _| | |_) | |_| |  _| | |\/| |  _| | |_) |  / _ \ | |    
| |___|  __/|  _  | |___| |  | | |___|  _ <  / ___ \| |___ 
|_____|_|   |_| |_|_____|_|  |_|_____|_| \_\/_/   \_\_____|

"@ -ForegroundColor Green

# winfetch

