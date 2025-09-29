# #!/bin/bash
#
# # Usage: toggle_hdd.sh [mount|unmount] <label>
#
# ACTION="$1"
# LABEL="$2"
#
# if [ -z "$ACTION" ] || [ -z "$LABEL" ]; then
#     echo "Usage: $0 [mount|unmount] <label>"
#     exit 1
# fi
#
# case "$LABEL" in
#     backup)
#         DEVICE="/dev/sda1"
#         ;;
#     movies1)
#         DEVICE="/dev/sdb1"
#         ;;
#     movies2)
#         DEVICE="/dev/sdc1"
#         ;;
#     *)
#         echo "Unknown label: $LABEL"
#         exit 1
#         ;;
# esac
#
# if [ "$ACTION" = "mount" ]; then
#     udisksctl mount -b "$DEVICE"
# elif [ "$ACTION" = "unmount" ]; then
#     udisksctl unmount -b "$DEVICE"
# else
#     echo "Invalid action: $ACTION"
#     exit 1
# fi


#!/bin/bash

. ~/.local/bin/scripts/notify.sh   # load notification functions

# Usage: toggle_hdd.sh [mount|unmount] <label>
ACTION="$1"
LABEL="$2"

if [ -z "$ACTION" ] || [ -z "$LABEL" ]; then
    notify_warning "HDD" "Usage: $0 [mount|unmount] <label>"
    exit 1
fi

# Map labels to devices
case "$LABEL" in
    backup) DEVICE="/dev/sda1" ;;
    movies1) DEVICE="/dev/sdb1" ;;
    movies2) DEVICE="/dev/sdc1" ;;
    *)
        notify_error "HDD" "Unknown label: $LABEL"
        exit 1
        ;;
esac

if [ "$ACTION" = "mount" ]; then
    if udisksctl mount -b "$DEVICE" >/dev/null 2>&1; then
        notify_success "HDD" "$LABEL mounted"
    else
        notify_error "HDD" "$LABEL mount failed"
    fi

elif [ "$ACTION" = "unmount" ]; then
    # Unmount first
    if udisksctl unmount -b "$DEVICE" >/dev/null 2>&1; then
        notify_success "HDD" "$LABEL unmounted"
    else
        notify_error "HDD" "$LABEL unmount failed"
    fi

    # Then try to power off, but ignore exit status
    udisksctl power-off -b "$DEVICE" >/dev/null 2>&1

else
    notify_error "HDD" "Invalid action: $ACTION"
    exit 1
fi
