#!/bin/sh
# Notification wrapper for dunst with urgency levels

notify_info() {
    notify-send -u low -i dialog-information "$1" "$2"
}

notify_success() {
    notify-send -u normal -i dialog-ok "$1" "$2"
}

notify_warning() {
    notify-send -u normal -i dialog-warning "$1" "$2"
}

notify_error() {
    notify-send -u critical -i dialog-error "$1" "$2"
}

