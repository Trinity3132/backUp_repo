#!/bin/zsh
# ~/.zprofile

# Environment variables
export PATH="$HOME/.local/bin/scripts:$PATH"
export EDITOR=nvim
export VISUAL=nvim

# Source interactive config if present
[[ -f ~/.zshrc ]] && source ~/.zshrc

# Autostart X on tty1
if [[ -z "$DISPLAY" && "$XDG_VTNR" == 1 ]]; then
  exec startx
fi
