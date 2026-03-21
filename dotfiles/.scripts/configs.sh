#!/usr/bin/env bash
# Opens a rofi menu to quickly edit Hyprland, Waybar, or Animation configs.
# Uses 'xdg-open' so it works with whatever text editor you have set as default.

HYPR_DIR="$HOME/.config/hypr/configs"
ANIM_DIR="$HOME/.config/hypr/configs/animations"
WAYBAR_DIR="$HOME/.config/waybar"
ROFI_CONF="$HOME/.config/rofi/config.rasi"

MAIN_OPTIONS="1. Hyprland\n2. Waybar\n3. Animations"

CHOICE=$(echo -e "$MAIN_OPTIONS" | rofi -dmenu -i -p "󱊟 " -config "$ROFI_CONF")

case "$CHOICE" in
    *Hyprland)
        FILE=$(ls "$HYPR_DIR" | grep ".conf" | rofi -dmenu -i -p "󰧨 Hyprland Configs" -config "$ROFI_CONF")
        [[ -n "$FILE" ]] && xdg-open "$HYPR_DIR/$FILE"
        ;;

    *Waybar)
        PRESET=$(ls -d "$WAYBAR_DIR"/*/ | xargs -n1 basename | rofi -dmenu -i -p "󱗼 Select Waybar Layout" -config "$ROFI_CONF")
        
        if [[ -n "$PRESET" ]]; then
            ln -sf "$WAYBAR_DIR/$PRESET/config.jsonc" "$WAYBAR_DIR/config.jsonc"
            ln -sf "$WAYBAR_DIR/$PRESET/style.css" "$WAYBAR_DIR/style.css"
            
            killall waybar && waybar &
            notify-send -a "System" "Waybar layout changed to $PRESET"
        fi
        ;;

    *Animations)
        ANIM=$(ls "$ANIM_DIR" | grep ".conf" | grep -v "current" | rofi -dmenu -i -p "󰚔 Select Animation" -config "$ROFI_CONF")
        
        if [[ -n "$ANIM" ]]; then
            ln -sf "$ANIM_DIR/$ANIM" "$ANIM_DIR/current_animations.conf"
            ln -sf "$ANIM_DIR/$ANIM" "$HYPR_DIR/animations.conf"
            
            notify-send -a "System" "Animations updated to $ANIM"
            hyprctl reload
        fi
        ;;
esac
