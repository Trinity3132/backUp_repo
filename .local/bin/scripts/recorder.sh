
#!/usr/bin/sh

# ------------------------------
# Interactive Terminal Screen Recorder
# ------------------------------

DEFAULTDIR="$HOME/multiMediaLibraries/Videos/screenRecord"
mkdir -p "$DEFAULTDIR"

# Full paths to binaries
FFMPEG="/usr/bin/ffmpeg"
NOTIFY="/usr/bin/notify-send"
FZF="/usr/bin/fzf"
PKILL="/usr/bin/pkill"
AMIXER="/usr/bin/amixer"

# Video & Audio defaults
VID_CODEC="libx264"
VID_PRESET="fast"
VID_CRF="18"
VID_FRAMERATE="30"
AUDIO_CODEC="aac"
AUDIO_CHANNELS="2"           # stereo
AUDIO_BITRATE="192k"

# ------------------------------
# DisplayPort-0 geometry
# ------------------------------
WIDTH=1920
HEIGHT=1080
X_OFFSET=1440
Y_OFFSET=0

# ------------------------------
# Start recording
# ------------------------------
record() {
    # Toggle mic
    "$AMIXER" set Capture toggle

    # fzf save location
    SAVEDIR=$("$FZF" --prompt="Save recording in: " --height=40% < <(find "$HOME" -type d 2>/dev/null))
    [ -z "$SAVEDIR" ] && SAVEDIR="$DEFAULTDIR"
    mkdir -p "$SAVEDIR"

    # fzf recording type
    MODE=$("$FZF" --prompt="Choose recording mode: " --height=20% < <(printf "Video+Audio (merged)\nVideo only\nAudio only\nVideo+Separate Audio"))
    [ -z "$MODE" ] && MODE="Video+Audio (merged)"

    TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
    FILEVIDEO="$SAVEDIR/recording_$TIMESTAMP.mp4"
    FILEAUDIO="$SAVEDIR/audio_$TIMESTAMP.wav"

    # Update dwmblocks icon
    echo "| 󰑋" > /tmp/recordingicon
    "$PKILL" -RTMIN+3 dwmblocks

    # Notify start (brief, auto-dismiss)
    "$NOTIFY" -t 2000 "Screen recording started"

    # Handle Ctrl+C to stop recording safely
    trap 'end' SIGINT SIGTERM

    case "$MODE" in
        "Video+Audio (merged)")
            echo "Recording Video+Audio to $FILEVIDEO..."
            "$FFMPEG" -f x11grab -video_size ${WIDTH}x${HEIGHT} -i :0.0+${X_OFFSET},${Y_OFFSET} \
                -f pulse -i default -ac "$AUDIO_CHANNELS" -c:a "$AUDIO_CODEC" -b:a "$AUDIO_BITRATE" \
                -c:v "$VID_CODEC" -crf "$VID_CRF" -preset "$VID_PRESET" -pix_fmt yuv420p \
                "$FILEVIDEO" -stats
            ;;
        "Video only")
            echo "Recording Video only to $FILEVIDEO..."
            "$FFMPEG" -f x11grab -video_size ${WIDTH}x${HEIGHT} -i :0.0+${X_OFFSET},${Y_OFFSET} \
                -c:v "$VID_CODEC" -crf "$VID_CRF" -preset "$VID_PRESET" -pix_fmt yuv420p \
                "$FILEVIDEO" -stats
            ;;
        "Audio only")
            echo "Recording Audio only to $FILEAUDIO..."
            "$FFMPEG" -f pulse -i default -ac "$AUDIO_CHANNELS" -c:a "$AUDIO_CODEC" -b:a "$AUDIO_BITRATE" \
                "$FILEAUDIO" -stats
            ;;
        "Video+Separate Audio")
            echo "Recording Video to $FILEVIDEO and Audio to $FILEAUDIO..."
            "$FFMPEG" -f x11grab -video_size ${WIDTH}x${HEIGHT} -i :0.0+${X_OFFSET},${Y_OFFSET} \
                -c:v "$VID_CODEC" -crf "$VID_CRF" -preset "$VID_PRESET" -pix_fmt yuv420p \
                "$FILEVIDEO" -stats &
            VIDPID=$!
            "$FFMPEG" -f pulse -i default -ac "$AUDIO_CHANNELS" -c:a "$AUDIO_CODEC" -b:a "$AUDIO_BITRATE" \
                "$FILEAUDIO" -stats &
            AUDPID=$!
            wait $VIDPID $AUDPID
            ;;
    esac
}

# ------------------------------
# Stop recording
# ------------------------------
end() {
    # Kill any running ffmpeg processes started by this script
    pkill -P $$ ffmpeg 2>/dev/null
    # Reset mic
    "$AMIXER" set Capture toggle
    # Clear icon
    echo "" > /tmp/recordingicon
    "$PKILL" -RTMIN+3 dwmblocks
    # Notify stop with manual dismissal and directory info
    SAVE_DIR_DISPLAY=$(dirname "$FILEVIDEO")
    "$NOTIFY" -t 0 "Recording stopped" "Saved to: $SAVE_DIR_DISPLAY"
    exit 0
}

# ------------------------------
# Toggle logic
# ------------------------------
if [ -f /tmp/recpid ] || [ -f /tmp/audpid ]; then
    end
else
    record
fi
