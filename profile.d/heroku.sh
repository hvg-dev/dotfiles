if [ -n "$ZSH_VERSION" ]; then
    # heroku autocomplete zsh setup
    export HEROKU_AC_ZSH_SETUP_PATH="${HOME}/.cache/heroku/autocomplete/zsh_setup" && test -f $HEROKU_AC_ZSH_SETUP_PATH && source $HEROKU_AC_ZSH_SETUP_PATH;
elif [ -n "$BASH_VERSION" ]; then
    # heroku autocomplete bash setup
    export HEROKU_AC_BASH_SETUP_PATH="${HOME}/.cache/heroku/autocomplete/bash_setup" && test -f $HEROKU_AC_BASH_SETUP_PATH && source $HEROKU_AC_BASH_SETUP_PATH;
else
    :
fi
