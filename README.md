# Dotfiles

[TOC]

## Using in vscode devcontainers

```console
$
```



## WSL Ubuntu install

Install `wsl` Ubuntu 22.04 distro

```console
$ wsl --install -d Ubuntu
Ubuntu is already installed.
Launching Ubuntu...
Installing, this may take a few minutes...
Please create a default UNIX user account. The username does not need to match your Windows username.
For more information visit: https://aka.ms/wslusers
Enter new UNIX username: felegy
New password:
Retype new password:
passwd: password updated successfully
The operation completed successfully.
Installation successful!
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

Welcome to Ubuntu 22.04.2 LTS (GNU/Linux 5.15.90.1-microsoft-standard-WSL2 x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage


This message is shown once a day. To disable it please create the
/home/felegy/.hushlogin file.
felegy@DESKTOP-IS3TA4B:~$
```

Firth steep set sudo passwordless

```console
$ echo "$USER ALL = (ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$USER"
[sudo] password for felegy:
felegy ALL = (ALL) NOPASSWD: ALL
```

Install latest upgrades and install `socat` for relaying between windows and linux sockets (GPG agent socket, SSH agent socket .. etc)

```console
$ sudo apt update && sudo apt dist-upgrade -y

$ sudo apt install -y socat
```

Linking .dotfiles from host os (from windows side) and upgrade `/etc/wsl.conf`

```console
$ ln -sn "/mnt/c/Users/$USER/.dotfiles" ~/.dotfiles

$ sudo cp /etc/wsl.conf /etc/wsl.conf.old

$ cat ~/.dotfiles/wsl.conf | sudo tee /etc/wsl.conf
[automount]
enabled = true
options = "metadata,uid=1000,gid=1000,umask=22,fmask=11,case=off"
mountFsTab = false
crossDistro = true

[filesystem]
umask = 0022

[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true

[boot]
systemd=true

```

After this steep need to be restart wsl "vm" (process) because boot configuration modified

```console
$ exit

$ wsl --shutdown

$ wsl --set-default Ubuntu
The operation completed successfully.

$ wsl
felegy@DESKTOP-IS3TA4B:/mnt/c/Users/felegy$ cd
felegy@DESKTOP-IS3TA4B:~$
```

 We  need to be modify  `~/.ssh` folders windows security settings, right click on a folder and Properties /  Security and click on [Advanced] button. Click on [Disable inheritance] button and remove all other user except own self.

<https://www.shellhacks.com/bad-owner-or-permissions-on-ssh-config-solved/>

The .dotfiles repo contains a bash script for connect relaying between Windows Gpg Agent (windows socket) and WSL Linux GPG Agent (Unix socket) , weary important for ssh and gpg in wsl environment. 

Lets check:

```console
$ ~/.dotfiles/win-gpg-agent-relay
Usage: win-gpg-agent-relay [OPTIONS] COMMAND

  SUMMARY: Relay local GPG sockets to win-gpg-agent's ones in order to integrate WSL2 and host.
           Do debug use foreground command

  OPTIONS:
    -h|--help     this page

    -v|--verbose  verbose mode

  COMMAND: start, stop, foreground
Exiting.
```

Ok it works properly, after that run with `foreground` mode:

```console
$ ~/.dotfiles/win-gpg-agent-relay foreground
Using gpg-agent sockets in: C:/Users/felegy/AppData/Local/gnupg
Using agent-gui sockets in: C:/Users/felegy/AppData/Local/gnupg/agent-gui
socat running with PID: 1303
socat running with PID: 1305
socat running with PID: 1307
Polling remote ssh-agent...OK
Polling remote gpg-agent... OK
Entering wait...
```

CTRL + C to exit process and lets run in background with debug settings, the repo contains profile.d feature switch script `~/.dotfiles/profile.d/wsl-gpg.sh` :

```console
$ GPG_AGENT_DEBUG=1 . ~/.dotfiles/profile.d/wsl-gpg.sh

$ cat error.log
Using gpg-agent sockets in: C:/Users/felegy/AppData/Local/gnupg
Using agent-gui sockets in: C:/Users/felegy/AppData/Local/gnupg/agent-gui
socat running with PID: 1362
socat running with PID: 1364
socat running with PID: 1366
Polling remote ssh-agent...OK
Polling remote gpg-agent... OK
Entering wait...
```

Currently the `ssh` and `gpg` have agent connection when in windows side `gpg-agent-gui` up and running.

Lets check it :

```console
$ gpg --card-status
Reader ...........: Yubico YubiKey OTP FIDO CCID 0
Application ID ...: D2760001240100000006120338060000
Application type .: OpenPGP
Version ..........: 0.0
Manufacturer .....: Yubico
Serial number ....: 120*****
Name of cardholder: [not set]
Language prefs ...: [not set]
Salutation .......:
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: not forced
Key attributes ...: rsa4096 rsa4096 rsa4096
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 3 3
Signature counter : 1667
KDF setting ......: off
Signature key ....: 4E9D 0770 92F2 E88C 11E6  81A3 20DD D592 E2AD 2C12
      created ....: 2020-07-13 10:53:41
Encryption key....: 98F2 9E6C 2043 A5E4 B33F  49D6 76F4 6D09 8EFD 31C7
      created ....: 2020-07-13 05:55:59
Authentication key: D08B 54E4 197C B174 C2D1  4F31 B9EE 1FE4 F0CF 8F5D
      created ....: 2020-07-13 10:54:06
General key info..: sub  rsa4096/0x20DDD592E2AD2C12 2020-07-13 Gabor FELEGYHAZI <felegy@pm.me>
sec#  rsa4096/0x45A8240C14DE6D58  created: 2020-07-13  expires: never
ssb>  rsa4096/0x76F46D098EFD31C7  created: 2020-07-13  expires: never
                                  card-no: 0006 12033806
ssb>  rsa4096/0x20DDD592E2AD2C12  created: 2020-07-13  expires: never
                                  card-no: 0006 12033806
ssb>  rsa4096/0xB9EE1FE4F0CF8F5D  created: 2020-07-13  expires: never
                                  card-no: 0006 12033806
$ ssh-add -L
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjYWNvu5RpvaL9VWUeFUWl565p5jBQXvSWHBHqEImTQjZopV5vuOYME2jwTP2fLlHF/L3zxyQAsispaoTEfZ/I5Nq1oq8HubWpxEZtwtCdjnbE04WN8a9xQkBj2udgh3vORnJYTCfiEcU08WVFXhuwR3ldrFKvzzOTLUeqlkz59JIRUNzsGKaA1VIz2K/EhBqjdur2l+Uz7XqDUFh5cgVmPAP6IeM96Zch6hxdys6UJjwqcWE7AWGdXK0e/PQBx7ITwZBAOXu8LZm/e0l/vO9Z19dsTYOKma2nPUNUQrff3BhoXpOL0qTwOhfWVBXPaKZztUcilijL7vN8j/M2E9388ovETKtJ5URv1JXWXWBitNiqii21L4hzQZYgawgecsFPerVGVSiGsa2D32PyIszgTnTeQ5k2VUKWy8ed1w+Q3AuFi+DAwmFs3nR0dd6tv/cLjIUtEgj9Wf+Gx7vcwNiYEAmZFebo4rH1VJf9wk0W3A791Ow0rt2s6l9KtFXi4xWJKxZIHw47pNChiuW58U1rcdTuBK34Gpc2lDqArN3HHigAb02skuJu9qrqA4UKfnlLRJPjJpDms8bJWpn2hytSwPHj9De/oXN5atKToqYVug7zfH/i/rFjDazn7dEfYni9kcSP/4XTxVZ3QXcB3UfvRn10TJi2z/KHPbWmCazcaQ== cardno:12_0**** 
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAaL00l/uKsUSDI1BwS8OxjK6Bu7dYc78rhhSFT+8iJwy6pBLjb7IjXqr+mgej+aWQtKYkpTbqxnI2DmL6Jj4GM= cardno:12_0****
```

Should be ssh working,  lets check it:

```console
ssh git@github.com
The authenticity of host 'github.com (140.82.121.3)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'github.com' (ED25519) to the list of known hosts.
PTY allocation request failed on channel 0
Hi felegy! You've successfully authenticated, but GitHub does not provide shell access.
Connection to github.com closed.
```

For a better usability I usually link ssh config from windows side: 

```console
$ ln -sn "/mnt/c/Users/$USER/.ssh/config" ~/.ssh

$ chmod -R 600 ~/.ssh/*
$ chmod 700 ~/.ssh

$ ssh git@github.com
The authenticity of host '[ssh.github.com]:443 ([140.82.121.35]:443)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:1: [hashed name]
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[ssh.github.com]:443' (ED25519) to the list of known hosts.
PTY allocation request failed on channel 0
Hi felegy! You've successfully authenticated, but GitHub does not provide shell access.
Connection to ssh.github.com closed.
```

Now ssh configured, next steep the GPG configuration, check or create GPGHOME:

```console
$ gpg -K
gpg: keybox '/home/felegy/.gnupg/pubring.kbx' created
gpg: /home/felegy/.gnupg/trustdb.gpg: trustdb created
```

And import your own gpg public key, I use keybase.io for this (<https://keybase.io/felegy>):

> **More about keybase.io**
>
> <https://book.keybase.io/docs/linux>
>
> <https://github.com/pstadler/keybase-gpg-github>

```console
$ curl https://keybase.io/felegy/pgp_keys.asc | gpg --import
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 14668  100 14668    0     0  24488      0 --:--:-- --:--:-- --:--:-- 24528
gpg: key 45A8240C14DE6D58: public key "Gabor FELEGYHAZI <felegy@pm.me>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

This repo contains gpg configuration tool, link it in GPGHOME folder:

```console
$ ln -sn ~/.dotfiles/gpg.conf ~/.gnupg/

$ gpg -K
/home/felegy/.gnupg/pubring.kbx
-------------------------------
sec#  rsa4096/0x45A8240C14DE6D58 2020-07-13 [SC]
      Key fingerprint = 3DEB 942F 4491 EA02 CDB1  B3D7 45A8 240C 14DE 6D58
uid                   [ unknown] Gabor FELEGYHAZI <felegy@pm.me>
uid                   [ unknown] Gabor FELEGYHAZI <felegy@hvg.hu>
uid                   [ unknown] Gabor FELEGYHAZI <felegy@gmail.com>
ssb>  rsa4096/0x76F46D098EFD31C7 2020-07-13 [E]
ssb>  rsa4096/0x20DDD592E2AD2C12 2020-07-13 [S]
ssb>  rsa4096/0xB9EE1FE4F0CF8F5D 2020-07-13 [A]
```

Based on `gpg -K` output my key id is: `0x45A8240C14DE6D58`, set to KEY_ID (`KEY_ID=0x45A8240C14DE6D58`) and set trust level:

```console
$ gpg --edit-key $KEY_ID
Secret subkeys are available.

pub  rsa4096/0x45A8240C14DE6D58
     created: 2020-07-13  expires: never       usage: SC
     trust: unknown       validity: unknown
ssb  rsa4096/0x76F46D098EFD31C7
     created: 2020-07-13  expires: never       usage: E
     card-no: 0006 12033806
ssb  rsa4096/0x20DDD592E2AD2C12
     created: 2020-07-13  expires: never       usage: S
     card-no: 0006 12033806
ssb  rsa4096/0xB9EE1FE4F0CF8F5D
     created: 2020-07-13  expires: never       usage: A
     card-no: 0006 12033806
[ unknown] (1). Gabor FELEGYHAZI <felegy@pm.me>
[ unknown] (2)  Gabor FELEGYHAZI <felegy@hvg.hu>
[ unknown] (3)  Gabor FELEGYHAZI <felegy@gmail.com>

gpg> trust
pub  rsa4096/0x45A8240C14DE6D58
     created: 2020-07-13  expires: never       usage: SC
     trust: unknown       validity: unknown
ssb  rsa4096/0x76F46D098EFD31C7
     created: 2020-07-13  expires: never       usage: E
     card-no: 0006 12033806
ssb  rsa4096/0x20DDD592E2AD2C12
     created: 2020-07-13  expires: never       usage: S
     card-no: 0006 12033806
ssb  rsa4096/0xB9EE1FE4F0CF8F5D
     created: 2020-07-13  expires: never       usage: A
     card-no: 0006 12033806
[ unknown] (1). Gabor FELEGYHAZI <felegy@pm.me>
[ unknown] (2)  Gabor FELEGYHAZI <felegy@hvg.hu>
[ unknown] (3)  Gabor FELEGYHAZI <felegy@gmail.com>

Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y

pub  rsa4096/0x45A8240C14DE6D58
     created: 2020-07-13  expires: never       usage: SC
     trust: ultimate      validity: unknown
ssb  rsa4096/0x76F46D098EFD31C7
     created: 2020-07-13  expires: never       usage: E
     card-no: 0006 12033806
sub  rsa4096/0xACD9EACB3E9893BE
     created: 2020-07-13  expires: never       usage: S
sub  rsa4096/0x90649B93993C5D8B
     created: 2020-07-13  expires: never       usage: A
ssb  rsa4096/0x20DDD592E2AD2C12
     created: 2020-07-13  expires: never       usage: S
     card-no: 0006 12033806
ssb  rsa4096/0xB9EE1FE4F0CF8F5D
     created: 2020-07-13  expires: never       usage: A
     card-no: 0006 12033806
[ unknown] (1). Gabor FELEGYHAZI <felegy@pm.me>
[ unknown] (2)  Gabor FELEGYHAZI <felegy@hvg.hu>
[ unknown] (3)  Gabor FELEGYHAZI <felegy@gmail.com>
Please note that the shown key validity is not necessarily correct
unless you restart the program.

gpg> q

$ gpg -K
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
/home/felegy/.gnupg/pubring.kbx
-------------------------------
sec#  rsa4096/0x45A8240C14DE6D58 2020-07-13 [SC]
      Key fingerprint = 3DEB 942F 4491 EA02 CDB1  B3D7 45A8 240C 14DE 6D58
uid                   [ultimate] Gabor FELEGYHAZI <felegy@pm.me>
uid                   [ultimate] Gabor FELEGYHAZI <felegy@hvg.hu>
uid                   [ultimate] Gabor FELEGYHAZI <felegy@gmail.com>
ssb>  rsa4096/0x76F46D098EFD31C7 2020-07-13 [E]
ssb>  rsa4096/0x20DDD592E2AD2C12 2020-07-13 [S]
ssb>  rsa4096/0xB9EE1FE4F0CF8F5D 2020-07-13 [A]
```

After SSH and GPG configuration we needs to be git configuration for gpg sign and verify, below I show you two possible way, 1. link from windows side when in windows configured or 2. configure localy:

1.  `$ ln -sn /mnt/c/Users/felegy/.gitconfig ~/.gitconfig`
2. local configuration with username, mail address and key id:

```console
$ git config --global user.name "felegy"

$ git config --global user.email "felegy@pm.me"

$ git config --global user.signingkey $KEY_ID
```

The last steep, with command below write `wsl-gpg.sh` entry point to shells rc file (`.bashrc`, `.zshrc` .. etc) and exit and run new session:

```console
$ echo '. ~/.dotfiles/profile.d/wsl-gpg.sh' | tee -a ~/.bashrc
. ~/.dotfiles/profile.d/wsl-gpg.sh

$ wsl
felegy@DESKTOP-IS3TA4B:/mnt/c/Users/felegy$ cd

felegy@DESKTOP-IS3TA4B:~$ ssh-add -L
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjYWNvu5RpvaL9VWUeFUWl565p5jBQXvSWHBHqEImTQjZopV5vuOYME2jwTP2fLlHF/L3zxyQAsispaoTEfZ/I5Nq1oq8HubWpxEZtwtCdjnbE04WN8a9xQkBj2udgh3vORnJYTCfiEcU08WVFXhuwR3ldrFKvzzOTLUeqlkz59JIRUNzsGKaA1VIz2K/EhBqjdur2l+Uz7XqDUFh5cgVmPAP6IeM96Zch6hxdys6UJjwqcWE7AWGdXK0e/PQBx7ITwZBAOXu8LZm/e0l/vO9Z19dsTYOKma2nPUNUQrff3BhoXpOL0qTwOhfWVBXPaKZztUcilijL7vN8j/M2E9388ovETKtJ5URv1JXWXWBitNiqii21L4hzQZYgawgecsFPerVGVSiGsa2D32PyIszgTnTeQ5k2VUKWy8ed1w+Q3AuFi+DAwmFs3nR0dd6tv/cLjIUtEgj9Wf+Gx7vcwNiYEAmZFebo4rH1VJf9wk0W3A791Ow0rt2s6l9KtFXi4xWJKxZIHw47pNChiuW58U1rcdTuBK34Gpc2lDqArN3HHigAb02skuJu9qrqA4UKfnlLRJPjJpDms8bJWpn2hytSwPHj9De/oXN5atKToqYVug7zfH/i/rFjDazn7dEfYni9kcSP/4XTxVZ3QXcB3UfvRn10TJi2z/KHPbWmCazcaQ== cardno:12_033_806
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAaL00l/uKsUSDI1BwS8OxjK6Bu7dYc78rhhSFT+8iJwy6pBLjb7IjXqr+mgej+aWQtKYkpTbqxnI2DmL6Jj4GM= cardno:12_033_806
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyTczOYVWDx58F33R/KLFRS3Qe1OwVAG+iCzafNLqy83XuFLLjv3ezgz5ZoiUnafrUsGDxmjU6omOJu1a10tI/5AJlY7o5Fg/hUqybJb/USb6AUrFmFS/x6aBlZB6iNsmcMw+A/b3QZwi5Dou+DhrcxMhi/R6cgsNaXYa4B4lPI4hz/vJyYP81rObXC/oA6tx7yQUDZ2Zt/owk2XWwL1SnG9JLKyKpM5v3jAsfKjzRJ6JK/eMTui74O0XM9B7BmPRJce7dUnTDa9vwzbKJPg8Zr0l1J6wuhI7aIdpLM25mvfF55wz0Dc8+DwJ4SY1qS+gKxsU3A1woQ12umswV66FJ SSH RSA key

felegy@DESKTOP-IS3TA4B:~$ gpg -K
/home/felegy/.gnupg/pubring.kbx
-------------------------------
sec#  rsa4096/0x45A8240C14DE6D58 2020-07-13 [SC]
      Key fingerprint = 3DEB 942F 4491 EA02 CDB1  B3D7 45A8 240C 14DE 6D58
uid                   [ultimate] Gabor FELEGYHAZI <felegy@pm.me>
uid                   [ultimate] Gabor FELEGYHAZI <felegy@hvg.hu>
uid                   [ultimate] Gabor FELEGYHAZI <felegy@gmail.com>
ssb>  rsa4096/0x76F46D098EFD31C7 2020-07-13 [E]
ssb#  rsa4096/0xACD9EACB3E9893BE 2020-07-13 [S]
ssb#  rsa4096/0x90649B93993C5D8B 2020-07-13 [A]
ssb>  rsa4096/0x20DDD592E2AD2C12 2020-07-13 [S]
ssb>  rsa4096/0xB9EE1FE4F0CF8F5D 2020-07-13 [A]

felegy@DESKTOP-IS3TA4B:~$
```

