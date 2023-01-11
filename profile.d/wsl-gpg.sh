if uname -a | grep -q microsoft; then
  # WSL 2 needs help from socat/sorelay
  ${HOME}/.local/bin/win-gpg-agent-relay start
  export SSH_AUTH_SOCK=${HOME}/.gnupg/S.gpg-agent.ssh
fi