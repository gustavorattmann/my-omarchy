#!/bin/bash
# List of apps that should NOT pause the wallpaper (separate with |)
EXCEPTIONS="discord|chrome-discord.com__channels_@me-Default|spotify|com.obsproject.Studio|Anydesk|TeamViewer|org.telegram.desktop"

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    # When a window enters fullscreen
    if echo "$line" | grep -q "fullscreen>>1"; then
        # Get the active window class
        WINDOW_ACTIVE=$(hyprctl activewindow -j | jq -r ".class")
        
        # Check if the window is in the exceptions list
        if echo "$WINDOW_ACTIVE" | grep -Ei -q "$EXCEPTIONS"; then
            echo "$(date) - Exception detected ($WINDOW_ACTIVE). Keeping wallpaper active." >> /tmp/wallpaper_engine.log
        else
            pkill -STOP mpvpaper
        fi
        
    # When exiting fullscreen
    elif echo "$line" | grep -q "fullscreen>>0"; then
        pkill -CONT mpvpaper
    fi
done