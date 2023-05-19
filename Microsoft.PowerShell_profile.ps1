$dotfiles = "$ENV:USERPROFILE\.dotfiles"

Switch([System.Diagnostics.Process]::GetCurrentProcess().ProcessName) {
    'pwsh' {
        if (!(Get-Module -ListAvailable -Name posh-git))
        {
            Install-Module posh-git -Scope CurrentUser -Force
        }
        Import-Module posh-git
        if (!(Get-Module -ListAvailable -Name PSReadLine))
        {
            Install-Module PSReadLine -MinimumVersion 2.2.0 -Scope CurrentUser -Force
        }
        Import-Module PSReadLine
        if (!(Get-Module -ListAvailable -Name CompletionPredictor))
        {
            Install-Module CompletionPredictor -Scope CurrentUser -Force
        }
        Import-Module CompletionPredictor
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    }
    'powershell' {
        if (!(Get-Module -ListAvailable -Name posh-git))
        {
            Install-Module posh-git -Scope CurrentUser -Force
        }
        Import-Module posh-git
    }
    default {
        ###
    }
}

if (!(Get-Module -ListAvailable -Name devtoolbox))
{
    Install-Module devtoolbox -Scope CurrentUser -Force
}
Import-Module devtoolbox

. "$dotfiles\completion.ps1"

Function Open-Admin-Terminal
{
    Switch ( $Args.Count ) {
        0 {
            Start-Process wt -Verb runAs
        }
        1 {
            Start-Process wt -Verb runAs -ArgumentList @("-d", $Args[0])
        }
        default {
            Start-Process wt -Verb runAs -ArgumentList $Args
        }
    }
}
Set-Alias -Name at -Value Open-Admin-Terminal