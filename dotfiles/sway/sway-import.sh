#!/bin/bash

SWAY_DIR="$(pwd)"
CONFIG_DIR="$HOME/.config/sway"
WAYBAR_DIR="$HOME/.config/waybar"
WOFI_DIR="$HOME/.config/wofi"
MAKO_DIR="$HOME/.config/mako"
ASK_FILES=( "monitors" )

if [ "$EUID" -eq 0 ]; then
    echo "Do not run this script as root. Exiting."
    exit 1
fi

mkdir -p "$CONFIG_DIR" "$WAYBAR_DIR" "$WOFI_DIR" "$MAKO_DIR"

for file in "$SWAY_DIR"/*; do
    if [[ -f "$file" ]]; then
        filename=$(basename "$file")

        if [[ " ${ASK_FILES[@]} " =~ " $filename " ]] && [[ -f "$CONFIG_DIR/$filename" ]]; then
            read -p "Import $filename from system before overwriting? (y/n) " choice
            if [[ "$choice" == "y" ]]; then
                cp "$CONFIG_DIR/$filename" "$SWAY_DIR/$filename.imported"
                echo "$filename imported as $filename.imported"
            fi
        fi

        if [[ "$filename" != "sway-import.sh" ]]; then
            cp "$file" "$CONFIG_DIR/$filename"
            echo "$filename copied to $CONFIG_DIR"
        fi
    fi
done

if [[ -d "$SWAY_DIR/waybar" ]]; then
    cp -r "$SWAY_DIR/waybar/." "$WAYBAR_DIR/"
    echo "waybar config copied to $WAYBAR_DIR"
fi

if [[ -d "$SWAY_DIR/wofi" ]]; then
    cp -r "$SWAY_DIR/wofi/." "$WOFI_DIR/"
    echo "wofi config copied to $WOFI_DIR"
fi

if [[ -d "$SWAY_DIR/mako" ]]; then
    cp -r "$SWAY_DIR/mako/." "$MAKO_DIR/"
    echo "mako config copied to $MAKO_DIR"
fi


echo "Sway configuration updated."

read -p "Do you want to reload Sway? (y/n) " reload_choice
if [[ "$reload_choice" == "y" ]]; then
    swaymsg reload
    echo "Sway reloaded."
fi
