#!/bin/bash
# Nerd Fonts icons
ICON_EMPTY="󰂜"          # nf-md-bell_outline (Empty/Read)
ICON_HISTORY="󰂚"        # nf-md-bell (Have history)
ICON_NEW="󱅫"            # nf-md-bell_badge (New)

# Count notifications active in display
WAITING=$(dunstctl count waiting)
# Count notifications in history
HISTORY=$(dunstctl count history)

if [ "$WAITING" -ne 0 ]; then
    echo "{\"text\": \"$ICON_NEW\", \"class\": \"active\"}"
elif [ "$HISTORY" -ne 0 ]; then
    echo "{\"text\": \"$ICON_HISTORY\", \"class\": \"unread\"}"
else
    echo "{\"text\": \"$ICON_EMPTY\", \"class\": \"empty\"}"
fi