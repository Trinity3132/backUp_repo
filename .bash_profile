#
# ~/.bash_profile
#

export PATH="$HOME/.local/bin/scripts:$PATH"
export EDITOR=nvim
export VISUAL=nvim

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec startx
fi

