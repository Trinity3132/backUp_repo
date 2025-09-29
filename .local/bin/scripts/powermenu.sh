#!/bin/bash

# Power menu options
options="󰗽  Shutdown\n󰜉  Reboot\n󰍃  Lock\n󰤄  Suspend\n󰗼  Logout"
choice=$(printf "$options" | rofi -dmenu -i -p "Power Menu")

# Confirmation prompt
confirm() {
  echo -e "No\nYes" | rofi -dmenu -i -p "$1?"
}

# Unmount and spin down external HDDs
cleanup_hdds() {
  for disk in /dev/sd?; do
    # Skip root disk
    rootdev=$(df / | tail -1 | awk '{print $1}')
    if [[ "$disk" == "${rootdev%[0-9]*}" ]]; then
      continue
    fi

    # Unmount mounted partitions
    mountpoints=$(lsblk -nr -o MOUNTPOINT "$disk" | grep -v '^$')
    if [ -n "$mountpoints" ]; then
      for mnt in $mountpoints; do
        umount "$mnt" &>/dev/null
      done
    fi

    # Spin down the drive
    if command -v udisksctl &>/dev/null; then
      udisksctl power-off -b "$disk" &>/dev/null
    elif command -v hdparm &>/dev/null; then
      hdparm -y "$disk" &>/dev/null
    fi
  done
}

# Handle power menu selection
case "$choice" in
  "󰗽  Shutdown")
    [[ $(confirm "Shutdown") == "Yes" ]] && {
      cleanup_hdds
      systemctl poweroff
    }
    ;;
  "󰜉  Reboot")
    [[ $(confirm "Reboot") == "Yes" ]] && {
      cleanup_hdds
      systemctl reboot
    }
    ;;
  "󰍃  Lock")
    if command -v slock &>/dev/null; then
      slock
    elif command -v i3lock &>/dev/null; then
      i3lock
    elif command -v betterlockscreen &>/dev/null; then
      betterlockscreen -l
    else
      notify-send "No lock utility found."
    fi
    ;;
  "󰤄  Suspend")
    [[ $(confirm "Suspend") == "Yes" ]] && {
      if command -v slock &>/dev/null; then
        slock &         # lock in background
        sleep 1         # give slock time to activate
      fi
      systemctl suspend
    }
    ;;
  "󰗼  Logout")
    [[ $(confirm "Logout") == "Yes" ]] && {
      cleanup_hdds
      if command -v loginctl &>/dev/null; then
        loginctl terminate-user "$USER"
      else
        pkill -KILL -u "$USER"
      fi
    }
    ;;
esac

