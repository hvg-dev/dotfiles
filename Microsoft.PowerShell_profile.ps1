Switch([System.Diagnostics.Process]::GetCurrentProcess().ProcessName) {
    'pwsh' {
        if (!(Get-Module -ListAvailable -Name PSReadLine)) 
        {
            Install-Module PSReadLine
        }
        Import-Module PSReadLine
        if (!(Get-Module -ListAvailable -Name CompletionPredictor)) 
        {
            Install-Module CompletionPredictor
        }
        Import-Module CompletionPredictor
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    }
    'powershell' {
        # Running on Powershell
    }
    default {
        ###
    }
}

if (!(Get-Module -ListAvailable -Name yarn-completion)) 
{
    Install-Module yarn-completion
}
Import-Module yarn-completion

Set-Alias -Name g -Value git

Set-Alias -Name d -Value docker

Set-Alias -Name dc -Value docker-compose

Function Admin-Terminal {
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
Set-Alias -Name at -Value Admin-Terminal
