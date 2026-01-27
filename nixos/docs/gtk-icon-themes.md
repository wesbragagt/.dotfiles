# GTK Icon Theme Configuration for Thunar

## Problem
Thunar icons looked ugly/unclear without proper icon theme configuration.

## Solution
Configure GTK icon theme in home-manager using the `gtk.iconTheme` option:

```nix
gtk = {
  enable = true;

  iconTheme = {
    package = pkgs.qogir-icon-theme;
    name = "Qogir";
  };
};
```

## Icon Theme Options
Available icon themes in nixpkgs:
- `pkgs.qogir-icon-theme` - "Qogir" (flat colorful design, recommended)
- `pkgs.adwaita-icon-theme` - "Adwaita" (default GNOME theme)
- `pkgs.papirus-icon-theme` - "Papirus" (popular Material Design theme)
- `pkgs.tela-icon-theme` - "Tela" (colorful flat design)
- `pkgs.whitesur-icon-theme` - "WhiteSur" (macOS-inspired)

## Implementation
Added to `home.nix` after cursor theme configuration. The Qogir icon theme provides clean, colorful icons that work well with Thunar and other GTK applications.

## Source
- [Home Manager GTK documentation](https://nix-community.github.io/home-manager/options.xhtml)
- [NixOS GTK configuration guide](https://hyprwm.github.io/hyprland-wiki/Nix/Hyprland-on-Home-Manager)
- [Qogir Icon Theme](https://github.com/vinceliuice/Qogir-icon-theme)
