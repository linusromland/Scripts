# Shared i3 / Sway desktop

This repository installs one keyboard-driven desktop for both **Sway (Wayland)** and **i3 (X11)**. The same bindings, dark colors, gaps, terminal, launchers, status bar, and utilities are used in both sessions. Home defaults to Sway with a two-display profile; work defaults to i3 with a three-display profile.

## Install

Run as your regular user from this repository; the installer uses `sudo` only for Ubuntu/Debian package installation:

```sh
./install-tiling.sh
```

The installer supports Arch Linux (using `yay`) and Ubuntu/Debian (using `apt`). It installs both window managers and the shared desktop tools, then links the repository's `config/` directories into `~/.config` and the launchers into `~/.local/bin`. Existing destinations are moved, not deleted, to `~/.local/state/dotfiles/backups/tiling-<timestamp>/`. Running the installer again keeps those links and does not back up or replace them again.

On Arch, `./install.sh` also runs the repository's existing development/remoting setup and invokes the tiling installer. On Ubuntu/Debian, `./install.sh` runs the tiling setup only; the older development/remoting section uses Arch-specific `yay`, `firewalld`, and service names.

After installation, log out and choose **Sway** at home or **i3** at work in the login screen's session chooser. Both are installed as separate sessions; no manual config copying is needed.

## Displays

The default profile follows the compositor: Sway selects `home` (expects two active displays), and i3 selects `work` (expects three). Sway reads active outputs from its IPC; i3 reads connected outputs from `xrandr`. Detected outputs are arranged horizontally, left to right. A count mismatch is reported, but the installer does not disable displays or assume connector names. A laptop's built-in panel counts as an output.

Set `DOTFILES_MONITOR_PROFILE=home` or `DOTFILES_MONITOR_PROFILE=work` in the session environment to override the default. The profile changes the expected-count warning and the Waybar label; the layout script still arranges every active/connected display. The monitor logic lives in `scripts/tiling-monitors`.

## Keys

`Super` is the Windows/Command key.

| Key | Action |
| --- | --- |
| `Super+Enter` | Kitty terminal |
| `Super+D` | Application launcher (Wofi on Sway, Rofi on i3) |
| `Super+Shift+B` | Launch Surf browser |
| `Super+H/J/K/L` or arrow keys | Move focus |
| `Super+Shift+H/J/K/L` or arrow keys | Move the focused window |
| `Super+1…0` | Switch workspace 1–10 |
| `Super+Shift+1…0` | Move window to workspace 1–10 |
| `Super+F` | Toggle fullscreen |
| `Super+Shift+Space` | Toggle floating |
| `Print` | Select a region, annotate, save, and copy it |
| `Shift+Print` | Capture the full screen, annotate, save, and copy it |
| `Super+Shift+V` | Clipboard history |
| `Super+Shift+E` | Lock, suspend, log out, reboot, or power off |
| `Super+Shift+R` | Reload Sway or restart i3 |

`Super+Shift+B` launches the Suckless **Surf** browser. On Sway it runs through XWayland; XWayland is installed with the desktop packages.

## Screenshots, clipboard, and screen sharing

- **Sway screenshots:** `grim` captures, `slurp` selects a region, and `swappy` opens the drawing/arrow annotation editor. Saving writes a PNG under `~/Pictures/Screenshots/` and copies that image to the Wayland clipboard.
- **i3 screenshots:** Flameshot opens its capture/annotation UI and supports both region and full-screen captures, saving to `~/Pictures/Screenshots/` and the X11 clipboard.
- **Clipboard history:** Sway records text clipboard entries with `cliphist` and `wl-clipboard`; i3 uses CopyQ. Use `Super+Shift+V` to pick an entry.
- **Sway screen sharing:** PipeWire, WirePlumber, `xdg-desktop-portal`, and `xdg-desktop-portal-wlr` provide native Wayland capture. The Sway portal preference selects the WLR ScreenCast/Screenshot backends and GTK for file dialogs. Browser/app screen capture should request the desktop portal.
- **i3 screen sharing:** applications use the X11 screen/window capture path; the GTK portal backend is installed for portal file dialogs. OBS Studio is installed for recording/streaming in either session.

The common bindings and appearance are in `config/tiling/common.conf`; compositor-specific session files are in `config/sway/` and `config/i3/`. Waybar keeps separate IPC module configs in `config/waybar/` and shares one stylesheet.
