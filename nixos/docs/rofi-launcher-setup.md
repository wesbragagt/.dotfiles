# Rofi Launcher Setup

## Summary

Rofi is a window switcher, application launcher and dmenu replacement. As of version 2.0.0 (released September 1, 2025), rofi has native Wayland support, built from merging lbonn/rofi-wayland fork into mainline repository.

## Key Findings

### Rofi Does NOT Require a Service

Unlike walker (which needs `elephant` + `walker --gapplication-service` running in the background), rofi is a simple on-demand launcher:
- **Launched on-demand** via keybinds
- **No background process** needed - it opens, shows, and closes when you select or escape
- **Just needs to be installed** in PATH

### NixOS Configuration with Home Manager

Use the built-in `programs.rofi` module from home-manager:

```nix
programs.rofi-custom = {
  enable = true;
  theme = "nord";  # default | dracula | nord | gruvbox-dark | catppuccin
  iconTheme = "papirus";  # papirus | hicolor | adwaita
};
```

**DO NOT** use `services.rofi` - rofi is not a service!

### Icons Configuration

Rofi shows icons by using the GTK icon theme. Options:
- `hicolor-icon-theme` - Default fallback (minimal icons)
- `papirus-icon-theme` - More comprehensive icon set (recommended)
- `adwaita-icon-theme` - GNOME default theme

Enable via GTK icon theme setting:
```nix
gtk.iconTheme = {
  name = "Papirus";
  package = pkgs.papirus-icon-theme;
};
```

### Available Themes

Built-in themes in the module:
- `default` - Dark blue/cyan theme
- `dracula` - Dracula color scheme
- `nord` - Nord color scheme
- `gruvbox-dark` - Gruvbox dark theme
- `catppuccin` - Catppuccin (Mocha flavor)

### Configuration

The module generates `~/.config/rofi/config.rasi` with:
- Icon theme enabled (`show-icons: true`)
- Selected theme colors
- JetBrainsMono Nerd Font at 14px

### Hyprland Keybinding

```nix
# Set rofi as menu launcher
$menu = rofi -show drun

# Use rofi as dmenu replacement for clipboard
bind = $mainMod, V, exec, cliphist list | rofi -dmenu -p "Clipboard" | cliphist decode | wl-copy
```

### Generate Default Config

```bash
mkdir -p ~/.config/rofi
rofi -dump-config > ~/.config/rofi/config.rasi
```

## Sources

- Rofi GitHub: https://github.com/davatorium/rofi
- Rofi 2.0.0 Release: https://github.com/davatorium/rofi/releases/tag/2.0.0
- Rofi Wayland Wiki: https://github.com/davatorium/rofi/wiki/Wayland
- Catppuccin Nix Module: https://github.com/catppuccin/nix
- Dracula Theme: https://draculatheme.com/rofi

## Keybinds

Default rofi keybinds:
- `Ctrl+Tab`: Switch between enabled modes
- `Alt+1-9`: Jump to specific mode
- `Return`: Select item
- `Shift+Return`: Select item with additional options
- `Escape`: Close rofi

## Modes

- `drun`: Desktop application launcher (uses .desktop files)
- `run`: Application launcher from $PATH
- `window`: Window switcher
- `ssh`: SSH launcher
- `filebrowser`: File browser
- `combi`: Combine multiple modes
- `keys`: List internal keybindings

## Wayland Notes

Rofi automatically detects the backend (X11 or Wayland) and uses the appropriate one. No special flags needed for Wayland - it works out of the box with Hyprland.

To force X11 backend (if both are available):
```bash
rofi -x11 -show drun
```

### Configuration

Configure rofi in Hyprland:

```nix
# Set rofi as menu launcher
$menu = rofi -show drun

# Use rofi as dmenu replacement for clipboard
bind = $mainMod, V, exec, cliphist list | rofi -dmenu -p "Clipboard" | cliphist decode | wl-copy
```

### Generate Default Config

```bash
mkdir -p ~/.config/rofi
rofi -dump-config > ~/.config/rofi/config.rasi
```

## Sources

- Rofi GitHub: https://github.com/davatorium/rofi
- Rofi 2.0.0 Release: https://github.com/davatorium/rofi/releases/tag/2.0.0
- Rofi Wayland Wiki: https://github.com/davatorium/rofi/wiki/Wayland

## Keybinds

Default rofi keybinds:
- `Ctrl+Tab`: Switch between enabled modes
- `Alt+1-9`: Jump to specific mode
- `Return`: Select item
- `Shift+Return`: Select item with additional options
- `Escape`: Close rofi

## Modes

- `drun`: Desktop application launcher
- `run`: Application launcher from $PATH
- `window`: Window switcher
- `ssh`: SSH launcher
- `filebrowser`: File browser
- `combi`: Combine multiple modes
- `keys`: List internal keybindings

## Wayland Notes

Rofi automatically detects the backend (X11 or Wayland) and uses the appropriate one. No special flags needed for Wayland - it works out of the box with Hyprland.

To force X11 backend (if both are available):
```bash
rofi -x11 -show drun
```
