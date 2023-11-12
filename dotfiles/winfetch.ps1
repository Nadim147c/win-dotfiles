# ===== WINFETCH CONFIGURATION =====

# $image = "~/.config/winfetch/image.png"
# $noimage = $false

# $ascii = $true
$logo = "Windows 11"

# Specify width for image/logo
$imgwidth = 35

# $alphathreshold = 50

$blink = $false

# $all = $true

# Add a custom info line
function info_custom_time {
    return @{
        title = "Time"
        content = (Get-Date)
    }
}

$ShowDisks = @("*")


$cpustyle = 'bartext'
$memorystyle = 'bartext'
$diskstyle = 'bartext'


@(
    "os"
    "computer"
    "kernel"
    "motherboard"
    "custom_time"  # use custom info line
    "uptime"
    "theme"
    "blank"
    "cpu"
    "gpu"
    "blank"
    "memory"
    "blank"
    "disk"
)
