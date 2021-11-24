param (
    [switch]$Reset
)

function mklink-if-not-exists {
    param (
        [string]$destination,
        [string]$source,
        [bool]$override = $false
    )
    if ($Reset -and (Test-Path $destination)) {
        Remove-Item -Path $destination
    }
    $exists = Test-Path $destination
    $notSymlink = $true
    if ($exists) {
        $linkType = (dir $destination).LinkType
        $notSymlink = ($linkType -ne $null) -and ($linkType.ToString() -ne "SymbolicLink")
        if ($notSymlink) {
            echo "[WARNING] Skipped making link because $destination is already a file, but it's not a symlink"
        } elseif ($notSymlink -and (!$override)) {
            echo "[OK] Skipped making link because $destination is already a symlink"
        } else {
            rm $destination
            cmd /c mklink $destination $source
        }
    } else {
        cmd /c mklink $destination $source
    }
}

## Make links to RC files
mklink-if-not-exists $HOME\_vimrc (Join-Path -Path (pwd) -ChildPath "vimrc")
mklink-if-not-exists $HOME\_vsvimrc (Join-Path -Path (pwd) -ChildPath "vsvimrc")
mklink-if-not-exists $HOME\_gvimrc (Join-Path -Path (pwd) -ChildPath "gvimrc")
mklink-if-not-exists $HOME\.gitignore (Join-Path -Path (pwd) -ChildPath "gitignore")
mklink-if-not-exists $HOME\.gitconfig (Join-Path -Path (pwd) -ChildPath "gitconfig")

if (!(Test-Path -path (Split-Path $PROFILE))) {
    New-Item -Type directory (Split-Path $PROFILE)
}
mklink-if-not-exists $PROFILE (Join-Path -Path (pwd) -ChildPath "Microsoft.PowerShell_profile.ps1")

$winTermSettings = "C:\Users\adam.hintz\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$dir = Split-Path -Parent $winTermSettings
if (Test-Path -Path $dir) {
    mklink-if-not-exists $winTermSettings (Join-Path -Path (pwd) -ChildPath "Windows Terminal\settings.json") $true
}
