#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"

echo "Using config directory: $CONFIG_DIR"

# --- Detect environment: Wayland (Sway) or X11 (i3) ---
if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    WM="sway"
elif [ -n "${DISPLAY:-}" ]; then
    WM="i3"
else
    echo "No DISPLAY/WAYLAND_DISPLAY detected, defaulting to sway..."
    WM="sway"
fi

echo "Detected WM: $WM"

# --- Install packages ---
echo "[1/4] Updating package database..."
sudo pacman -Syu --noconfirm

echo "[2/4] Installing required packages for $WM..."
# Shared packages
sudo pacman -S --needed --noconfirm \
    git wget curl python jq \
    jetbrains-mono-nerd feh

if [ "$WM" = "sway" ]; then
    sudo pacman -S --needed --noconfirm \
        sway waybar wofi mako grim slurp wl-clipboard swaylock
else
    sudo pacman -S --needed --noconfirm \
        i3 rofi dunst i3lock xorg-xrandr
fi

# --- Create required directories ---
echo "[3/4] Creating directories..."
mkdir -p ~/.config/{sway,i3,waybar,wofi,mako}

# --- Link configs dynamically ---
echo "[3/4] Linking configs..."
if [ "$WM" = "sway" ]; then
    ln -sf "$CONFIG_DIR/sway/config" ~/.config/sway/config
    ln -sf "$CONFIG_DIR/sway/waybar/config" ~/.config/waybar/config
    ln -sf "$CONFIG_DIR/sway/waybar/style.css" ~/.config/waybar/style.css
    ln -sf "$CONFIG_DIR/sway/wofi/style.css" ~/.config/wofi/style.css
    ln -sf "$CONFIG_DIR/sway/mako/config" ~/.config/mako/config
else
    ln -sf "$CONFIG_DIR/i3/config" ~/.config/i3/config
fi

# --- Make monitor scripts executable ---
echo "[3/4] Making monitor scripts executable..."
find "$CONFIG_DIR/i3/monitors" -type f -name "*.sh" -exec chmod +x {} \; || true
find "$CONFIG_DIR/sway/monitors" -type f -name "*.conf" -exec chmod +r {} \; || true

echo "[4/4] Installation complete!"
echo "- Installed: $WM stack"
echo "- Configs linked from $CONFIG_DIR"
echo "- Monitors configured"
echo "Restart $WM to apply changes."
