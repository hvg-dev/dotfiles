source "${HOMEBREW_PREFIX}/opt/kube-ps1/share/kube-ps1.sh"

alias k='kubectl'
alias h='helm'

if [ -n "$ZSH_VERSION" ]; then
    # kube autocomplete zsh setup
    . <(kubectl completion zsh)
    . <(helm completion zsh)
elif [ -n "$BASH_VERSION" ]; then
    # kube autocomplete bash setup
    . <(kubectl completion bash)
    complete -F __start_kubectl k
    . <(helm completion bash)
    complete -F __start_helm h
else
    :
fi
