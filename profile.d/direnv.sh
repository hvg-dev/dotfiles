if [ -n "$ZSH_VERSION" ]; then
    eval "$(direnv hook zsh)"
elif [ -n "$BASH_VERSION" ]; then
    eval "$(direnv hook bash)"
else
    :
fi
