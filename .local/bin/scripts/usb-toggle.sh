 #!/bin/bash
#
# ACTION="$1"
#
# # Collect all USB partitions safely
# usb_parts=()
# while IFS= read -r part; do
#     parent=$(lsblk -no PKNAME "$part" 2>/dev/null)
#     tran=$(lsblk -dn -o TRAN "/dev/$parent" 2>/dev/null)
#     if [ "$tran" = "usb" ]; then
#         usb_parts+=("$part")
#     fi
# done < <(lsblk -rpno NAME,TYPE | awk '$2 == "part" {print $1}')
#
# if [ "${#usb_parts[@]}" -eq 0 ]; then
#     echo "No USB partition found."
#     pkill -RTMIN+7 dwmblocks
#     exit 1
# fi
#
# case "$ACTION" in
#     mount)
#         for part in "${usb_parts[@]}"; do
#             mountpoint=$(lsblk -nrpo MOUNTPOINT "$part" | tr -d '[:space:]')
#             if [ -z "$mountpoint" ]; then
#                 udisksctl mount -b "$part" >/dev/null
#             fi
#         done
#         ;;
#     unmount)
#         for part in "${usb_parts[@]}"; do
#             mountpoint=$(lsblk -nrpo MOUNTPOINT "$part" | tr -d '[:space:]')
#             if [ -n "$mountpoint" ]; then
#                 udisksctl unmount -b "$part" >/dev/null
#                 udisksctl power-off -b "$part" >/dev/null
#             fi
#         done
#         ;;
#     *)
#         echo "Usage: $0 [mount|unmount]"
#         exit 1
#         ;;
# esac
#
# # Refresh dwmblocks USB icon
# pkill -RTMIN+7 dwmblocks


#!/bin/bash

. ~/.local/bin/scripts/notify.sh   # load notification functions

ACTION="$1"

# Collect all USB partitions safely
usb_parts=()
while IFS= read -r part; do
    parent=$(lsblk -no PKNAME "$part" 2>/dev/null)
    tran=$(lsblk -dn -o TRAN "/dev/$parent" 2>/dev/null)
    if [ "$tran" = "usb" ]; then
        usb_parts+=("$part")
    fi
done < <(lsblk -rpno NAME,TYPE | awk '$2 == "part" {print $1}')

if [ "${#usb_parts[@]}" -eq 0 ]; then
    notify_error "USB" "No devices found"
    pkill -RTMIN+7 dwmblocks
    exit 1
fi

case "$ACTION" in
    mount)
        for part in "${usb_parts[@]}"; do
            name=$(basename "$part")
            mountpoint=$(lsblk -nrpo MOUNTPOINT "$part" | tr -d '[:space:]')
            if [ -z "$mountpoint" ]; then
                if udisksctl mount -b "$part" >/dev/null 2>&1; then
                    notify_success "USB" "$name mounted"
                else
                    notify_error "USB" "$name mount failed"
                fi
            else
                notify_info "USB" "$name already mounted"
            fi
        done
        ;;
    unmount)
        for part in "${usb_parts[@]}"; do
            name=$(basename "$part")
            mountpoint=$(lsblk -nrpo MOUNTPOINT "$part" | tr -d '[:space:]')
            if [ -n "$mountpoint" ]; then
                if udisksctl unmount -b "$part" >/dev/null 2>&1 && \
                   udisksctl power-off -b "$part" >/dev/null 2>&1; then
                    notify_success "USB" "$name unmounted"
                else
                    notify_error "USB" "$name unmount failed"
                fi
            else
                notify_info "USB" "$name already unmounted"
            fi
        done
        ;;
    *)
        notify_warning "USB" "Usage: $0 [mount|unmount]"
        exit 1
        ;;
esac

# Refresh dwmblocks USB icon
pkill -RTMIN+7 dwmblocks
