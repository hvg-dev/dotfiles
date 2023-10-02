case $(uname) in
    Darwin) export HOMEBREW_PREFIX=${HOMEBREW_PREFIX-/usr/local};;
    *)      export HOMEBREW_PREFIX=${HOMEBREW_PREFIX-/home/linuxbrew/.linuxbrew};;
esac
eval $(${HOMEBREW_PREFIX}/bin/brew shellenv)
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS=--require-sha

if [ -n "$ZSH_VERSION" ]; then
    # autocomplete zsh setup
    FPATH="${HOMEBREW_PREFIX}/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit
elif [ -n "$BASH_VERSION" ]; then
    # autocomplete bash setup
    if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
    then
        source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    else
        for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
        do
        [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
        done
    fi
else
    :
fi
