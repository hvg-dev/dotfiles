if uname -a | grep -q microsoft; then
  # WSL 2 needs help from socat/sorelay
  ${HOME}/.dotfiles/win-gpg-agent-relay start
  export SSH_AUTH_SOCK="$(gpgconf --list-dir agent-ssh-socket)"
fi