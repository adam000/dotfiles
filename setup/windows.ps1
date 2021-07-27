param (
    [switch]$Reset
)

function mklink-if-not-exists {
    param (
        [string]$destination,
        [string]$source
    )
    if ($Reset -and (Test-Path $destination)) {
        Remove-Item -Path $destination
    }
    if (!(Test-Path $destination)) {
        cmd /c mklink $destination $source
    } else {
        echo "Skipped making link because $destination already exists"
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

