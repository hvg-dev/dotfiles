#!/usr/bin/env bash

DOTFILES_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p "$HOME/.antigen"

curl -LsS git.io/antigen > "$HOME/.antigen/antigen.zsh"

curl -sS https://starship.rs/install.sh | sh -s -- -y

ln -sn "$DOTFILES_DIR/antigenrc" "$HOME/.antigenrc"

if [ -f "$HOME/.tmux.conf" ] ; then
    rm "$HOME/.tmux.conf"
fi
ln -sn "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.config"

ln -sn "$DOTFILES_DIR/starship.toml" "$HOME/.config/"

tee -a "$HOME/.zshrc" <<'EOF'

# Load Antigen
source "$HOME/.antigen/antigen.zsh"

# Load Antigen configurations
antigen init ~/.antigenrc

eval "$(starship init zsh)"
EOF
