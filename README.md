# Sway-Dots — KooL-style Sway rice (translated from JaKooLit/Hyprland-Dots)

A community Sway port of the popular [KooL Hyprland Dots](https://github.com/JaKooLit/Hyprland-Dots) by JaKooLit.
This project is **not affiliated with JaKooLit** — it is an independent translation of the config set for the Sway window manager.

---

## Screenshot

> _(screenshot placeholder — replace with your own)_

---

## What's Included

| Component | Notes |
|---|---|
| `sway` | Main WM config, keybinds, outputs, workspaces |
| `waybar` | Status bar with wallust theming |
| `swaync` | Notification center |
| `rofi` | App launcher, power menu, clipboard |
| `wlogout` | Logout / power screen |
| `swaylock` | Lock screen |
| `swayidle` | Idle inhibit / DPMS |
| `swww` | Wallpaper daemon (via wallpaper scripts) |
| `wallust` | Automatic color theming from wallpaper |
| `nwg-displays` | Monitor layout GUI |
| `btop`, `cava`, `fastfetch` | System / audio / info tools |
| `ghostty`, `kitty`, `wezterm` | Terminal emulators |
| `Kvantum`, `qt5ct`, `qt6ct` | Qt theming |
| `swappy` | Screenshot annotation |

---

## Manual Install

> Most users get Sway-Dots automatically via the Fedora-Sway installer script.
> Use the steps below only if you want to install the dotfiles directly.

```bash
git clone https://github.com/seyboo/Sway-Dots.git
cd Sway-Dots
chmod +x copy.sh
./copy.sh
```

The installer will:
- Back up any existing configs before overwriting.
- Prompt you for resolution, clock format, and whether to download the full wallpaper bank.
- Set scripts executable and initialize wallust.

---

## Dropped Features (Sway Limitations)

The following features exist in JaKooLit's Hyprland-Dots but are **not available in Sway** and have been removed from this port:

| Feature | Reason |
|---|---|
| Window animations | Hyprland-exclusive (`animation = ...`) |
| Blur / frosted glass | Requires Hyprland compositor |
| Rounded corners | Hyprland-exclusive (`rounding = ...`) |
| Desktop overview (ags / quickshell) | Not ported; Sway has no equivalent hook |
| Cursor zoom | Hyprland-exclusive (`cursor:zoom_factor`) |
| Per-window keyboard layout hack | Hyprland IPC only |

---

## Default Keybinds

> `SUPER` = the Windows / Meta key (mod4 in Sway).

| Keybind | Action |
|---|---|
| `SUPER + Return` | Open terminal |
| `SUPER + D` | Rofi app launcher |
| `SUPER + E` | File manager |
| `SUPER + Q` | Close focused window |
| `SUPER + W` | Wallpaper picker / set wallpaper |
| `SUPER + T` | Theme switcher |
| `CTRL + ALT + L` | Lock screen (swaylock) |
| `CTRL + ALT + P` | Power menu (wlogout) |
| `SUPER + Shift + S` | Screenshot area (swappy) |
| `SUPER + [1-0]` | Switch to workspace 1–10 |

---

## Attribution / Credits

This project is a **community Sway translation** of the excellent work done by **JaKooLit**.

- Original Hyprland dotfiles: <https://github.com/JaKooLit/Hyprland-Dots>
- Fedora Hyprland installer: <https://github.com/JaKooLit/Fedora-Hyprland>

All credit for the original design, theming approach, scripts, and configuration structure goes to JaKooLit and contributors.
This Sway port is not affiliated with, endorsed by, or supported by JaKooLit.

Licensed under the [GNU General Public License v3.0](./LICENSE.md).
