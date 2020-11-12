# Comment this out unless testing -- reset

#Remove-Item $HOME\_gvimrc -ErrorAction SilentlyContinue
#Remove-Item $PROFILE -ErrorAction SilentlyContinue
#Remove-Item $HOME\_vimrc -ErrorAction SilentlyContinue

# END Comment this out...

## Make links

cmd /c mklink $HOME\_vimrc (Join-Path -Path (pwd) -ChildPath "vimrc")
cmd /c mklink $HOME\_gvimrc (Join-Path -Path (pwd) -ChildPath "gvimrc")
if (!(Test-Path -path (Split-Path $PROFILE))) {
    New-Item -Type directory (Split-Path $PROFILE)
}
cmd /c mklink $PROFILE (Join-Path -Path (pwd) -ChildPath "Microsoft.PowerShell_profile.ps1")

