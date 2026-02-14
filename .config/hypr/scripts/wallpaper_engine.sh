#!/bin/bash
# Log path
LOG_FILE="/tmp/wallpaper_engine.log"

# Record logs with date and time
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Resets the log file on every execution
echo "--- New Omarchy Session ---" > "$LOG_FILE"
log_msg "Starting environment check..."

# Wait for the environment to load completely
sleep 3

# Kill Omarchy's static wallpaper manager
killall swaybg 2>/dev/null && log_msg "swaybg conflict removed."
# Kill previous mpvpaper instances
killall mpvpaper 2>/dev/null && log_msg "Old mpvpaper instances cleared."

# Monitors and paths definition
MON1="HDMI-A-1"
VID1="$HOME/Videos/Wallpapers Animateds/apocalyptic-cyberpunk-moewalls-com.mp4"

MON2="DP-2"
VID2="$HOME/Videos/Wallpapers Animateds/cyberpunk-girl-sleeping-moewalls-com.mp4"

# Load the wallpaper with verification
load_wallpaper() {
    local monitor=$1
    local video=$2

    if [ -f "$video" ]; then
        log_msg "Loading $video on monitor $monitor..."
        mpvpaper -f -o "no-audio --loop-file=inf --hwdec=nvdec" "$monitor" "$video" >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            log_msg "Success: $monitor active."
        else
            log_msg "ERROR: Failed to start mpvpaper on $monitor."
        fi
    else
        log_msg "CRITICAL ERROR: File not found at $video"
    fi
}

# Execution
load_wallpaper "$MON1" "$VID1"
sleep 0.5
load_wallpaper "$MON2" "$VID2"

log_msg "Startup script completed."