
#!/usr/bin/sh
# Screenshot script with notifications and optional area selection
set -euo pipefail
export DISPLAY="${DISPLAY:-:0}"

# Default directory
DEFAULT_OUTDIR="${HOME}/multiMediaLibraries/Images/Screenshots/"
mkdir -p "$DEFAULT_OUTDIR"

# Let user pick directory with fzf (ESC = default)
OUTDIR=$(find "$HOME" -type d 2>/dev/null | fzf --prompt="Select save directory (ESC = default): " --height 40% --reverse)
OUTDIR="${OUTDIR:-$DEFAULT_OUTDIR}"
mkdir -p "$OUTDIR"

# Timestamped filename
current="$(date +%Y%m%d_%H%M%S).png"
filepath="${OUTDIR}/${current}"

# Determine screenshot tool
tool_path="$(command -v import 2>/dev/null || command -v scrot 2>/dev/null)" || {
    notify-send -u critical "Screenshot Tool Missing" "Install 'scrot' or 'import'."
    exit 1
}
TOOL="$(basename "$tool_path")"

# Flags for tool: area select
flags=()
if [[ "${1:-}" == "-s" ]]; then
    if [[ "$TOOL" == "scrot" ]]; then
        flags=(--select)
    elif [[ "$TOOL" == "import" ]]; then
        flags=()   # import defaults to area selection if no -window argument
    fi
else
    if [[ "$TOOL" == "import" ]]; then
        flags=(-window root)
    fi
fi

# Take screenshot
if "$TOOL" "${flags[@]}" "$filepath"; then
    notify-send -u normal "Screenshot Taken" "Saved as $current in $OUTDIR"
else
    notify-send -u critical "Screenshot Failed" "Could not save screenshot to $filepath"
fi
