
#!/bin/sh
# toggle-mpd-rmpc.sh
# Starts/stops MPD and spawns rmpc in Alacritty with concise notifications

# Check if MPD is running
if pgrep -x mpd > /dev/null; then
    # Stop MPD and rmpc
    pkill -x rmpc
    systemctl --user stop mpd
    notify-send "MPD Stopped" "MPD & rmpc stopped"
else
    # Start MPD
    systemctl --user start mpd
    sleep 1  # wait for MPD to initialize

    # Launch rmpc inside Alacritty
    st -e rmpc &

    notify-send "MPD Started" "MPD & rmpc running"
fi
