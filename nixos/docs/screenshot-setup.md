# Screenshot & Screen Recording Setup

## Overview

Hyprland screenshot configuration using Wayland-native tools for capturing and editing screenshots, plus screen recording capabilities.

## Dependencies

| Package | Description |
|----------|-------------|
| `grim` | Screenshot utility for Wayland compositors |
| `slurp` | Select a region in a Wayland compositor |
| `swappy` | Wayland native snapshot editing tool |
| `wf-recorder` | Screen recording utility for Wayland |

## Keybindings (from `modules/hypr/hyprland.conf`)

- `Super + Shift + P`: Screenshot selected region (opens in swappy editor)
- `Super + Shift + R`: Toggle screen recording (saves to `~/Videos/`)

## Usage

### Screenshot

The keybinding `Super + Shift + P` runs:
```bash
grim -g "$(slurp -d)" $HOME/Pictures/screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png && swappy -f $HOME/Pictures/screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png
```

This:
1. Opens `slurp` to select a region
2. Captures selected area with `grim` to `~/Pictures/screenshots/screenshot_<timestamp>.png`
3. Opens `swappy` for editing
4. Saves edited screenshot to same location

### Screen Recording

The keybinding `Super + Shift + R` runs `~/.dotfiles/utils/wf-recorder.sh`, which:
- Starts/stops `wf-recorder` toggle
- Shows 3-2-1 countdown notifications
- Saves recordings to `$HOME/Videos/<timestamp>.mp4`

## Configuration

Module: `modules/screenshot.nix`

```nix
{ config, lib, pkgs, ... }:
{
  options.wesbragagt.screenshot = {
    enable = mkEnableOption "Enable screenshot and screen recording tools for Hyprland";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      grim
      slurp
      swappy
      wf-recorder
    ];

    home.file."Videos/.gitkeep".text = "";
    home.file."Pictures/.gitkeep".text = "";
  };
}
```

Enabled in `home.nix`:
```nix
wesbragagt.screenshot.enable = true;
```

## Sources

- Grim: https://sr.ht/~emersion/grim/
- Slurp: https://github.com/emersion/slurp
- Swappy: https://github.com/jtheoof/swappy
- wf-recorder: https://github.com/ammen99/wf-recorder
- Hyprland wiki: https://wiki.hypr.land/Configuring/Binds/
