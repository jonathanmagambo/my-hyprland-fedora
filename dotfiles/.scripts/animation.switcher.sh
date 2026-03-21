#!/usr/bin/env bash

ANIM_DIR="$HOME/.config/hypr/configs/animations"
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

CHOICE=$(ls "$ANIM_DIR" | grep ".conf" | grep -v "current_animations.conf" | sed 's/\.conf//' | rofi -dmenu -i -p "󰚔 Animations" -config "$ROFI_CONFIG")

[[ -z "$CHOICE" ]] && exit 0

ln -sf "$ANIM_DIR/$CHOICE.conf" "$ANIM_DIR/current_animations.conf"

notify-send -a "System" "Animations set to $CHOICE"
