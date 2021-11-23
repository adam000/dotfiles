$ProfileImportsFile = (Join-Path -Path $PSScriptRoot -ChildPath 'profile-imports.txt')
# Set this to "true" to make sure importing of modules is working
$verboseLoading = $false
if (Test-Path $ProfileImportsFile) {
    # You need a local script in the same dir as $PROFILE with one line each for things to import, like this for posh-git, other local things
    # I set it up this way because I don't want the specific posh-git location on any machine to force the same location on other machines. And I didn't know a better way. This seems fine.
    Get-Content $ProfileImportsFile | ForEach-Object {
        if ($_.substring(0,1) -ne '#') {
            Import-Module $_
            if ($verboseLoading) {
                Write-Host "Loaded module $_"
            }
        }
    }
} elseif ($verboseLoading) {
    Write-Host "No such file $ProfileImportsFile"
}

if (!$EDITOR) {
    $EDITOR = "gvim"
}

if ($GitPromptSettings -ne $null) {
    $lastResult = Invoke-Expression '$?'
    $GitPromptSettings.DefaultPromptPrefix.Text = '$(Get-Date -f "HH:mm:ss") '
    $GitPromptSettings.DefaultPromptPrefix.ForegroundColor = 'Green'
    $GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $false
    $GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'
}

function prompt {
    $lastResult = Invoke-Expression '$?'
    $fgColor = "Green"
    if (!$lastResult) {
        $fgColor = "Red"
    }
    # Normally one would use Write-Output to return the formatted string, but Write-Output does not have the -ForegroundColor parameter
    $lastResultString = ""
    if ($lastResult -eq $False) {
        $lastResultString = "!!! "
    } elseif ($lastResult -ne $True) {
        $lastResultString = "($lastResult) "
    }
    Write-Host
    Write-Host -ForegroundColor $fgColor -NoNewline $lastResultString
    $GitPromptSettings.DefaultPromptPrefix.ForegroundColor = $fgColor
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

# touch - A command I miss from bash
function touch {
    param (
        [string] $Path
    )
    if (Test-Path $Path) {
        # It exists, so update timestamp
        (Get-Item $Path).LastWriteTime = Get-Date
    } else {
        New-Item -Type 'File' $Path
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

# Predictive completion - https://www.hanselman.com/blog/adding-predictive-intellisense-to-my-windows-terminal-powershell-prompt-with-psreadline and then some
function Set-PredictionList-On {
    Set-PSReadLineOption -PredictionViewStyle ListView
}
function Set-PredictionList-Off {
    Set-PSReadLineOption -PredictionViewStyle InlineView
}
Set-PSReadLineOption -PredictionSource History
Set-PredictionList-On

# More like Bash tab completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Aliases for accessing Powershell history

function Get-History-File() { echo ((Get-PSReadLineOption).HistorySavePath) }
function View-History() { & $EDITOR (Get-History-File) }
function History-Nuke {
    param(
        [Parameter(mandatory=$true)]
        [string]$query
    )
    $results = Get-Content (Get-History-File) | Where-Object {$_ -match $query}
    $numResults = $results.length
    if ($results -is [array]) {
        $results | Select -SkipLast 1 | ForEach-Object { Write-Host $_ }
        $confirmation = Read-Host "Are you sure you would like to remove the above $numResults lines? [y/N]"
        if ($confirmation -ne 'y') {
            # Only get rid of History-Nuke lines
            $query = "History-Nuke"
        }
        $backup = Join-Path -Path (Split-Path -Parent (Get-History-File)) -ChildPath "ConsoleHost_history_old.txt"
        Copy-Item (Get-History-File) $backup
        Get-Content $backup | Where-Object {$_ -notmatch $query} | Set-Content (Get-History-File)
    }
}

Set-Alias grep rg

Set-Alias Real-Vim vim.bat
Set-Alias vim gvim

function gg() { git grep -i @args }

function mkcd($dir) { mkdir $dir && cd $dir }

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# vim: set ff=dos :
