# Sway UserScripts

Translated from Hyprland-Dots UserScripts for use with Sway.

## Intentionally Dropped Scripts

The following scripts from the upstream Hyprland-Dots were **not** translated because they depend on
Hyprland-specific features with no equivalent in Sway:

- **RainbowBorders.bak.sh** — Animated border color cycling via `hyprctl` keyword animations.
  Hyprland exposes a per-client border-color animation API; Sway has no equivalent animated border
  concept.

- **Tak0-Autodispatch.sh** — Per-window keyboard layout switching using Hyprland's
  `hyprctl switchxkblayout` per-device/window hook. Sway's `swaymsg input` keyboard switching is
  global only; per-window layout tracking requires a different approach (e.g., a separate daemon).
