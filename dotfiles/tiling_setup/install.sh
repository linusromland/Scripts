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

# --- Update system and install packages via yay ---
echo "[1/4] Updating system..."
yay -Syu --noconfirm

echo "[2/4] Installing required packages for $WM..."
# Shared packages
COMMON_PACKAGES=(
    git wget curl python jq
    jetbrains-mono-nerd feh
)

# WM-specific packages
if [ "$WM" = "sway" ]; then
    WM_PACKAGES=(
        sway waybar wofi mako grim slurp wl-clipboard swaylock
    )
else
    WM_PACKAGES=(
        i3 rofi dunst i3lock xorg-xrandr
    )
fi

# Install all packages with yay
yay -S --needed --noconfirm "${COMMON_PACKAGES[@]}" "${WM_PACKAGES[@]}"

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

# Link tiling_setup under ".config" also
ln -sf "$CONFIG_DIR/tiling_setup" ~/.config/tiling_setup

# --- Make monitor scripts executable ---
echo "[3/4] Making monitor scripts executable..."
[ -d "$CONFIG_DIR/i3/monitors" ] && find "$CONFIG_DIR/i3/monitors" -type f -name "*.sh" -exec chmod +x {} \; || true
[ -d "$CONFIG_DIR/sway/monitors" ] && find "$CONFIG_DIR/sway/monitors" -type f -name "*.conf" -exec chmod +r {} \; || true

echo "[4/4] Installation complete!"
echo "- Installed: $WM stack"
echo "- Configs linked from $CONFIG_DIR"
echo "- Monitors configured"
echo "Restart $WM to apply changes."
