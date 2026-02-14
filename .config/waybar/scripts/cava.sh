#!/bin/bash
CONF="/tmp/cava_config_$$"
cleanup() { pkill -P $$; rm -f "$CONF"; exit 0; }
trap cleanup EXIT

echo "[general]
framerate = 60
bars = 24
gravity = 1.0
integral = 80
sensitivity = 100
[input]
method = pipewire
source = auto
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7" > "$CONF"

dict="s/;//g;s/0/ /g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g"

# Execution with dynamic background and original colors preserved
cava -p "$CONF" | stdbuf -oL sed -u "$dict" | stdbuf -oL awk '{
    if ($0 ~ /[▂▃▄▅▆▇█]/) {
        split($0, chars, "")
        content = ""
        for (i=1; i<=length($0); i++) {
            if (i <= 4) color = "#cba6f7"
            else if (i <= 8) color = "#89b4fa"
            else if (i <= 12) color = "#a6e3a1"
            else if (i <= 16) color = "#f9e2af"
            else if (i <= 20) color = "#fab387"
            else color = "#f38ba8"
            content = content "<span color=\"" color "\">" chars[i] "</span>"
        }
        # Send the bars with spaces at the ends to give width to the box
        print content
    } else {
        # Absolute void: makes the widget and CSS shrink to zero
        print ""
    }
    fflush()
}'