#!/bin/bash

STATUS=$(hyprctl getoption decoration:blur:enabled -j | jq -r '.int')

if [ "$STATUS" -eq 1 ]; then
    NEW_STATUS=0
    notify-send "Hyprland" "Blur Disabled" -i dialog-information -t 1000
else
    NEW_STATUS=1
    notify-send "Hyprland" "Blur Enabled" -i dialog-information -t 1000
fi

hyprctl keyword decoration:blur:enabled $NEW_STATUS
