# NixOS rofi-wayland Package Merge

## Issue

The `rofi-wayland` package has been merged into the main `rofi` package and is no longer available.

## Fix

Remove `rofi-wayland` from `home.packages`. The main `rofi` package now includes Wayland support.

### Example

```nix
# Before (broken)
home.packages = with pkgs; [
  rofi
  rofi-wayland  # This package no longer exists
];

# After (working)
home.packages = with pkgs; [
  rofi  # Includes Wayland support
];
```

## Sources

- GitHub Issue #1221: https://github.com/HyDE-Project/HyDE/issues/1221
- NixOS Search: https://search.nixos.org/packages?show=rofi-wayland-unwrapped
