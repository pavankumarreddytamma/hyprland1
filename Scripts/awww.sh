#!/bin/bash

# Directory containing your wallpapers
WALLPAPER_DIR="/home/pavan/Wallpapers"

# Transition settings
TRANSITION_TYPE="wipe"
TRANSITION_STEP=10
TRANSITION_FPS=60
TRANSITION_ANGLE=45

# File to remember the last wallpaper index
STATE_FILE="/tmp/awww_wallpaper_index"

# Ensure awww daemon is running
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 1
fi

# Check wallpaper directory
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Wallpaper directory $WALLPAPER_DIR does not exist."
    exit 1
fi

# Get wallpapers in alphabetical order
mapfile -t WALLPAPERS < <(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" \
        -o -iname "*.png" -o -iname "*.webp" \) |
        sort
)

TOTAL=${#WALLPAPERS[@]}

if [ "$TOTAL" -eq 0 ]; then
    echo "No images found in $WALLPAPER_DIR"
    exit 1
fi

# Read last index and select the next wallpaper
LAST_INDEX=$(cat "$STATE_FILE" 2>/dev/null || echo "-1")
NEXT_INDEX=$(( (LAST_INDEX + 1) % TOTAL ))

NEXT_WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"

# Apply wallpaper with transition
awww img "$NEXT_WALLPAPER" \
    --transition-type "$TRANSITION_TYPE" \
    --transition-step "$TRANSITION_STEP" \
    --transition-fps "$TRANSITION_FPS"

# Save current index
echo "$NEXT_INDEX" > "$STATE_FILE"

echo "Wallpaper $((NEXT_INDEX + 1))/$TOTAL: $NEXT_WALLPAPER"
