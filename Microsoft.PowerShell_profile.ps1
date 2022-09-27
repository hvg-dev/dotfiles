Switch([System.Diagnostics.Process]::GetCurrentProcess().ProcessName) {
    'pwsh' {
        if (!(Get-Module -ListAvailable -Name PSReadLine))
        {
            Install-Module PSReadLine -Scope CurrentUser
        }
        Import-Module PSReadLine
        if (!(Get-Module -ListAvailable -Name CompletionPredictor))
        {
            Install-Module CompletionPredictor -Scope CurrentUser
        }
        Import-Module CompletionPredictor
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    }
    'powershell' {
        if (!(Get-Module -ListAvailable -Name posh-git))
        {
            Install-Module posh-git -Scope CurrentUser
        }
        Import-Module posh-git
    }
    default {
        ###
    }
}

if (!(Get-Module -ListAvailable -Name posh-docker))
{
    Install-Module posh-docker -Scope CurrentUser
}
Import-Module posh-docker

if (!(Get-Module -ListAvailable -Name dockerComposeCompletion))
{
    Install-Module dockerComposeCompletion -Scope CurrentUser
}
Import-Module dockerComposeCompletion

if (!(Get-Module -ListAvailable -Name yarn-completion))
{
    Install-Module yarn-completion -Scope CurrentUser
}
Import-Module yarn-completion

Set-Alias -Name g -Value git

Set-Alias -Name d -Value docker

Set-Alias -Name dc -Value docker-compose

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