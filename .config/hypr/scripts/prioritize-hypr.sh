#!/bin/bash
sleep 2 # Wait for Hyprland to stabilize
renice -n -20 $(pidof Hyprland)