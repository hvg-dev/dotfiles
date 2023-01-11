case $(uname) in
    Darwin) export HOMEBREW_PREFIX=${HOMEBREW_PREFIX-/usr/local};;
    *)      export HOMEBREW_PREFIX=${HOMEBREW_PREFIX-/home/linuxbrew/.linuxbrew};;
esac
eval $(${HOMEBREW_PREFIX}/bin/brew shellenv)
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS=--require-sha
