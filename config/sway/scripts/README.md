# Sway-Dots Scripts — Drop List

Scripts from the upstream Hyprland-Dots that were intentionally **not ported** to Sway-Dots, with reasons.

## Dropped Scripts

| Script | Reason |
|---|---|
| `Animations.sh` | Sway has no animation subsystem. The Hyprland `animations {}` block and `hyprctl dispatch` animation commands have no Sway equivalent. |
| `ChangeBlur.sh` | Sway does not support blur effects. Blur is a compositor-specific Hyprland feature with no Sway equivalent. |
| `OverviewToggle.sh` | The "overview" (desktop zoom / expose) feature relies on the Hyprland `hyprexpo` plugin or AGS widget. Sway has no comparable built-in. |
| `Hypridle.sh` | Idle management on Sway is handled by `swayidle` (configured in the Startup scripts). `Nightlight.sh` covers the nightlight part. `Hypridle.sh` targeted the Hypridle daemon which does not run under Sway. |
| `Hyprsunset.sh` | Replaced by `Nightlight.sh` (using `gammastep` or `wlsunset`). Hyprsunset is Hyprland-specific and does not work under Sway. |
| `Polkit-NixOS.sh` | NixOS-specific polkit agent launcher. The standard `Polkit.sh` is used on all other distros; the NixOS path is irrelevant for Sway-Dots (non-NixOS deployment). |
| `PortalHyprland.sh` | Replaced by `PortalWlr.sh`. The `xdg-desktop-portal-hyprland` backend is Hyprland-only; Sway uses `xdg-desktop-portal-wlr`. |
| `Tak0-Autodispatch.sh` | Hyprland-specific plugin (takowm / plugin dispatch) for automatic window layout dispatch. No Sway equivalent exists; Sway uses its own layout engine via `ChangeLayout.sh`. |
| `Tak0-Per-Window-Switch.sh` | A per-window keyboard-layout hack relying on Hyprland's `keyword input:kb_layout` per-window switching. Sway handles input configuration globally via `input` blocks in the config; per-window switching is not needed. |
| `UptimeNixOS.sh` | NixOS-specific uptime / generation script. Not relevant outside NixOS and not needed for Sway-Dots. |
