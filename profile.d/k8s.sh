if [ -n "$ZSH_VERSION" ] && [ $(which kubectl) ]; then
    # autocomplete zsh setup
    . <(kubectl completion zsh)
elif [ -n "$BASH_VERSION" ] && [ $(which kubectl) ]; then
    # autocomplete bash setup
    . <(kubectl completion bash)
else
    :
fi

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
touch $HOME/.kube/all
export KUBECONFIG=$(echo $HOME/.kube/all $HOME/.kube/*.yaml | sed "s/ /:/g")
