#!/bin/bash

#=============================
# Environment variables
#=============================
export FONTCONFIG_PATH=/etc/fonts
export EDITOR=nvim
export VISUAL=nvim

#=============================
# Keyboard and input setup
#=============================
setxkbmap -option
numlockx on


# Run remaps with delay to ensure X is ready
(sleep 2 && "$HOME/.local/bin/scripts/remaps") &

# Background services 
    ~/.local/bin/scripts/volumewatch &
    ~/.screenlayout/output.sh &
    dwmblocks &

feh --no-fehbg --bg-fill \
    "$HOME/.local/share/wallpapers/dwm_1.jpg" \
    "$HOME/.local/share/wallpapers/dwm_3.jpg" \
    "$HOME/.local/share/wallpapers/dwm_3.jpg" &

# Notification daemon
dunst &

#=============================
# Start window manager
#=============================
exec dwm
