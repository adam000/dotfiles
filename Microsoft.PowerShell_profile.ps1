$ProfileImportsFile = (Join-Path -Path $PSScriptRoot -ChildPath 'profile-imports.txt')
if (Test-Path $ProfileImportsFile) {
    # You need a local script in the same dir as $PROFILE with one line each for things to import, like this for posh-git, other local things
    # C:\path\to\posh-git\src\posh-git.psd1
    # I set it up this way because I don't want the specific posh-git location on any machine to force the same location on other machines. And I didn't know a better way. This seems fine.
    Get-Content $ProfileImportsFile | ForEach-Object {
        Import-Module $_
    }
}

$GitPromptSettings.DefaultPromptPrefix.Text = '$(Get-Date -f "HH:mm:ss") '
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $false
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'

function prompt {
    $lastResult = Invoke-Expression '$?'
    $dateColorization = @{
        ForegroundColor = "Green"
        NoNewline = $True
    }
    if (!$lastResult) {
        $dateColorization.ForegroundColor = "Red"
    }
    # Normally one would use Write-Output to return the formatted string, but Write-Output does not have the -ForegroundColor parameter
    $lastResultString = ""
    if ($lastResult -eq $False) {
        $lastResultString = "!!! "
    } elseif ($lastResult -ne $True) {
        $lastResultString = "($lastResult) "
    }
    Write-Host
    Write-Host @dateColorization $lastResultString
    # This is returned as the prompt
    & $GitPromptScriptBlock
}

# Adopted from my zshrc
function st() {
    git rev-parse --git-dir 2>&1 | Out-Null
    if ($?) {
        # List stashes
        git stash list | Select-String -Pattern (git rev-parse --abbrev-ref HEAD)
        git status -sb

        git diff --quiet | Out-Null
        if (!$?) {
            $changes = git diff --numstat | ConvertFrom-Csv -Header "Adds", "Dels", "File" -Delimiter "`t"
            $totals = [PSCustomObject]@{
                Adds = $changes | Foreach-Object { $adds = 0 } { $adds += $_.Adds } { $adds };
                Dels = $changes | Foreach-Object { $dels = 0 } { $dels += $_.Dels } { $dels };
                File = "TOTAL";
            }
            # Add a dashed line above total, and make sure it's an Object array because one change would be Object, not Object[]
            [Object[]]$changes += ([PSCustomObject]@{Adds="-"; Dels="-"; File="-"}, $totals)
            $changes | Format-Table
        }
    } else {
        Throw "Not in a git repo"
    }
}

# fg - gives a Powershell Core equivalent for foregrounding processes
function fg {
    Get-Job | Where-Object { $_.State -ne "Completed" -or $_.HasMoreData } | Select-Object -first 1 | Receive-Job
}

function lsfunc() {
    Get-ChildItem $args | Sort | Format-Wide
}
# Deleting an alias only does so for the current session
del alias:ls
Set-Alias ls lsfunc

del alias:sl -Force
Set-Alias sl ls

# Vi experience
Set-PSReadLineOption -EditMode vi
# Setting the cursor based on normal vs insert mode
if ($PSVersionTable.PsEdition -eq 'Core') {
    Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler {
        if ($args[0] -eq 'Command') {
            # Set the cursor to a blinking block.
            Write-Host -NoNewLine "`e[1 q"
        } else {
            # Set the cursor to a blinking line.
            Write-Host -NoNewLine "`e[5 q"
        }
    }
}
function :q { exit }

# More like Bash tab completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# vim: set ff=dos :
