
if (Get-Command kubectl -ErrorAction SilentlyContinue)
{
    Set-Alias -Name k -Value kubectl
    kubectl completion powershell | Out-String | Invoke-Expression
    Register-ArgumentCompleter -CommandName k -ScriptBlock $__kubectlCompleterBlock
}

if (Get-Command helm -ErrorAction SilentlyContinue)
{
    helm completion powershell | Out-String | Invoke-Expression
}

if (Get-Command k3d -ErrorAction SilentlyContinue)
{
    k3d completion powershell | Out-String | Invoke-Expression
}

if (Get-Command k9s -ErrorAction SilentlyContinue)
{
    k9s completion powershell | Out-String | Invoke-Expression
}

if (Get-Command k3sup -ErrorAction SilentlyContinue)
{
    k3sup completion powershell | Out-String | Invoke-Expression
}

if (!(Get-Module -ListAvailable -Name yarn-completion))
{
    Install-Module yarn-completion -Scope CurrentUser -Force
}
Import-Module yarn-completion

