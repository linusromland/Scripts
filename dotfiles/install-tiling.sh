#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONFIG_DIR="$SCRIPT_DIR/config"
USER_BIN="$HOME/.local/bin"
USER_CONFIG="$HOME/.config"
BACKUP_DIR="$HOME/.local/state/dotfiles/backups/tiling-$(date '+%Y%m%d-%H%M%S')"
BACKUPS_CREATED=0

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
fi

install_arch_packages() {
  command -v yay >/dev/null 2>&1 || {
    printf 'Arch Linux setup requires yay. Install yay, then rerun this script.\n' >&2
    exit 1
  }
  yay -S --needed --noconfirm \
    sway i3-wm waybar rofi-wayland wofi \
    swaybg swayidle swaylock i3lock kitty picom dunst mako \
    grim slurp swappy flameshot wl-clipboard cliphist copyq xclip \
    xorg-xrandr xorg-xsetroot xorg-xwayland \
    pipewire pipewire-audio pipewire-pulse wireplumber \
    xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    obs-studio procps-ng jq brightnessctl playerctl pavucontrol pamixer \
    networkmanager network-manager-applet polkit-gnome thunar firefox surf \
    papirus-icon-theme ttf-jetbrains-mono ttf-inter noto-fonts-emoji
}

install_debian_packages() {
  local -a apt=(apt-get)
  if ((EUID != 0)); then
    command -v sudo >/dev/null 2>&1 || {
      printf 'Ubuntu/Debian setup needs root or sudo.\n' >&2
      exit 1
    }
    apt=(sudo apt-get)
  fi

  "${apt[@]}" update
  "${apt[@]}" install --yes \
    sway i3-wm waybar rofi wofi \
    swaybg swayidle swaylock i3lock kitty picom dunst mako-notifier \
    grim slurp swappy flameshot wl-clipboard cliphist copyq xclip \
    x11-xserver-utils xwayland \
    pipewire pipewire-audio pipewire-pulse wireplumber \
    xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    obs-studio procps jq brightnessctl playerctl pavucontrol pamixer \
    network-manager network-manager-gnome policykit-1-gnome thunar firefox surf \
    papirus-icon-theme fonts-jetbrains-mono fonts-inter fonts-noto-color-emoji
}

case "${ID:-}" in
  arch|manjaro|endeavouros) install_arch_packages ;;
  ubuntu|debian) install_debian_packages ;;
  *)
    if [[ " ${ID_LIKE:-} " == *' debian '* ]] && command -v apt-get >/dev/null 2>&1; then
      install_debian_packages
    else
      printf 'Unsupported distribution: %s. Supported: Arch Linux and Ubuntu/Debian.\n' "${ID:-unknown}" >&2
      exit 1
    fi
    ;;
esac

mkdir -p "$USER_CONFIG" "$USER_BIN"

link_item() {
  local source=$1 destination=$2
  if [[ -L "$destination" && $(readlink -- "$destination") == "$source" ]]; then
    printf 'Already linked: %s\n' "$destination"
    return
  fi
  if [[ -e "$destination" || -L "$destination" ]]; then
    if ((BACKUPS_CREATED == 0)); then
      mkdir -p "$BACKUP_DIR"
      BACKUPS_CREATED=1
    fi
    mv -- "$destination" "$BACKUP_DIR/$(basename -- "$destination")"
    printf 'Backed up existing path to %s\n' "$BACKUP_DIR/$(basename -- "$destination")"
  fi
  ln -s -- "$source" "$destination"
  printf 'Linked %s -> %s\n' "$destination" "$source"
}

for name in i3 sway tiling waybar wofi rofi kitty picom swappy mako xdg-desktop-portal; do
  link_item "$CONFIG_DIR/$name" "$USER_CONFIG/$name"
done

for script in "$SCRIPT_DIR"/scripts/tiling-*; do
  link_item "$script" "$USER_BIN/$(basename -- "$script")"
done

if command -v systemctl >/dev/null 2>&1 && systemctl --user show-environment >/dev/null 2>&1; then
  systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service || \
    printf 'PipeWire services will be started when the compositor session starts.\n' >&2
else
  printf 'PipeWire is installed; its user services start when i3 or sway starts.\n'
fi

printf '\nTiling setup installed. Log out, then choose i3 or sway at the login screen.\n'
