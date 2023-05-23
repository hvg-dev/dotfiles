$BASH_PROFILE_URL="https://gist.githubusercontent.com/felegy/ecadb9eb4f0a1b8806d2d1929b42a87e/raw/0885235f216165729e9958f2dac0d3931b607e13/hvg-dev.profile"

# Allow reboots
if(!($null -eq $Boxstarter)){
    $Boxstarter.RebootOk=$false;
    $Boxstarter.NoPassword=$false;
    $Boxstarter.AutoLogin=$false;

    Enable-RemoteDesktop
    Disable-InternetExplorerESC
    #Disable-UAC
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar

    #if (Test-PendingReboot) { throw [System.Exception] "Windows restart required!" }
}

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Basic setup
#Update-ExecutionPolicy Unrestricted;
#Install chocolatey: https://chocolatey.org/install
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

# Install softwares
cinst git -y
cinst microsoft-windows-terminal -y
cinst pwsh -y
cinst gpg4win -y
cinst vscode -y
cinst wsl2 -y
cinst docker-desktop -y

$TARGETDIR = "c:\temp";
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR;
}

Push-Location -Path $TARGETDIR 
$uriLatestWinGpgAgentZip = Invoke-RestMethod -Uri "https://api.github.com/repos/rupor-github/win-gpg-agent/releases/latest"  | Select-Object -Property assets -ExpandProperty assets |  Where-Object -FilterScript {$_.name -eq "win-gpg-agent.zip" } | Select-Object -Property browser_download_url -ExpandProperty browser_download_url 
Invoke-WebRequest  -OutFile "win-gpg-agent.zip" -Uri $uriLatestWinGpgAgentZip
Expand-Archive .\win-gpg-agent.zip
Remove-Item .\win-gpg-agent.zip
Pop-Location

Get-Item -Path "${TARGETDIR}\win-gpg-agent\*" | Move-Item -Destination "${env:ProgramData}\chocolatey\bin\" -Force;
Remove-Item "${TARGETDIR}\win-gpg-agent"


# Check User has Profile
if(!(Test-Path $profile)){
    # Create new User Profile
    New-Item -Path $profile -Type file -Force;
}

# Load User current Profile
$content = Get-Content -Path $profile;

$Output = @();
$Output += $content;

# Write User Profile
$Output | Out-file $profile -Encoding utf8 -Force;

New-Item -ItemType SymbolicLink -Path (Join-Path -Path $Env:USERPROFILE -ChildPath Documents) -Name PowerShell -Target (Join-Path -Path $Env:USERPROFILE -ChildPath Documents\WindowsPowerShell);

if(!(Test-Path "$HOME\.gpg-agent-gui")){
    # Create new User Profile
    New-Item -ItemType directory -Path "$HOME\.gpg-agent-gui" -Force;
}

if(!(Test-Path "$HOME\.gpg-agent-gui\agent-gui.conf")){
    # Create new User Profile
    New-Item -Path "$HOME\.gpg-agent-gui\agent-gui.conf" -Type file -Force;
}

$Output = @();
$Output += "gui:";
$Output += "  extra_port: 1111";

$Output | Out-file "$HOME\.gpg-agent-gui\agent-gui.conf" -Encoding utf8 -Force;


(New-Object System.Net.WebClient).DownloadFile($BASH_PROFILE_URL, "$HOME\hvg-dev.profile");

#[System.Environment]::SetEnvironmentVariable('SSH_AUTH_SOCK','\\.\pipe\ssh-pageant',[System.EnvironmentVariableTarget]::User)

# Create auto start shortcut for wsl-ssh-pageant
$ShellObject = New-Object -ComObject Wscript.Shell;
$shortcut = $ShellObject.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\agent-gui.lnk");
$shortcut.WindowStyle = 7;
$shortcut.WorkingDirectory = $HOME;
$shortcut.TargetPath="${env:ProgramData}\chocolatey\bin\agent-gui.exe";
$shortcut.Arguments="-c $HOME\.gpg-agent-gui\agent-gui.conf";
$shortcut.Save();
