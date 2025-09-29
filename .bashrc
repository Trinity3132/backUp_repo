#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Add scripts to PATH
export PATH="$HOME/.local/bin/scripts:$PATH"

# Aliases
alias lf='lfub'
alias vim='nvim'
alias c='clear && exec bash && refresh-dwmblocks'
alias cdwm='vim ~/dwm/config.h'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias mdwm='cd ~/dwm; sudo make clean install; cd -'

# Prompt
PS1='[\u@\h \W]\$ '

# lfcd function
lfcd() {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && cd "$dir"
    fi
}

# Keybinding: Ctrl+O to open lfcd
bind '"\C-o":"lfcd\n"'

fastfetch
