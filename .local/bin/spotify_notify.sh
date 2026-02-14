#!/bin/bash

# Path to the icon you found (If using a custom icon pack)
ICON="$HOME/.local/share/icons/WhiteSur-dark/apps/symbolic/com.spotify.Client-symbolic.svg"

playerctl --player=spotify metadata --format '{{title}} - {{artist}}' --follow | while read -r line; do
    # Sends the notification with the correct icon
    notify-send -a "Spotify" -i "$ICON" "Now Playing" "$line"
done
