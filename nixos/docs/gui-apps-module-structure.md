# NixOS GUI Applications Module Structure

## Overview

This guide explains how to set up a modular structure for managing GUI applications (Spotify, Slack, Signal, LibreOffice, Chrome, etc.) in NixOS using home-manager.

## Module Pattern

Home-manager uses the standard NixOS module pattern:
- `options`: Declare configuration options (like enable/disable toggles)
- `config`: Apply configuration when options are set
- `imports`: Include other modules

### Module Template

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.apps.<category>;
in
{
  options.apps.<category>.enable = lib.mkEnableOption "Enable <category> applications";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Application packages
    ];
  };
}
```

## Directory Structure

```
modules/
├── apps/
│   ├── default.nix           # Central app module (imports all categories)
│   ├── browsers.nix          # Web browsers
│   ├── communication.nix      # Chat/messaging apps
│   ├── office.nix            # Productivity/office apps
│   └── media.nix            # Music/video apps
```

## Example: Browsers Module

`modules/apps/browsers.nix`:
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.apps.browsers;
in
{
  options.apps.browsers.enable = lib.mkEnableOption "Enable browser applications";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      google-chrome
      firefox-wayland
    ];
  };
}
```

## Example: Communication Module

`modules/apps/communication.nix`:
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.apps.communication;
in
{
  options.apps.communication.enable = lib.mkEnableOption "Enable communication applications";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      slack
      signal-desktop
      discord
      element-desktop
    ];
  };
}
```

## Example: Office Module

`modules/apps/office.nix`:
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.apps.office;
in
{
  options.apps.office.enable = lib.mkEnableOption "Enable office applications";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-fresh
      onlyoffice-desktopeditors
      xournalpp
    ];
  };
}
```

## Example: Media Module

`modules/apps/media.nix`:
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.apps.media;
in
{
  options.apps.media.enable = lib.mkEnableOption "Enable media applications";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      spotify
      vlc
      mpv
      obs-studio
    ];
  };
}
```

## Central Aggregator Module

`modules/apps/default.nix`:
```nix
{ ... }:
{
  imports = [
    ./browsers.nix
    ./communication.nix
    ./office.nix
    ./media.nix
  ];
}
```

## Integration with home.nix

Add to your home-manager imports and enable categories:

```nix
{ config, ... }:

{
  imports = [
    ./modules/apps
    # ... other imports
  ];

  config = {
    # Enable application categories
    apps.browsers.enable = true;
    apps.communication.enable = true;
    apps.office.enable = true;
    apps.media.enable = true;
  };
}
```

## Alternative: Single File Approach

For simpler setups, group categories in a single file:

`modules/apps.nix`:
```nix
{ config, lib, pkgs, ... }:

{
  options = {
    apps.browsers.enable = lib.mkEnableOption "Enable browsers";
    apps.communication.enable = lib.mkEnableOption "Enable communication apps";
    apps.office.enable = lib.mkEnableOption "Enable office apps";
    apps.media.enable = lib.mkEnableOption "Enable media apps";
  };

  config = {
    home.packages = lib.mkMerge [
      (lib.mkIf config.apps.browsers.enable (with pkgs; [ google-chrome firefox-wayland ]))
      (lib.mkIf config.apps.communication.enable (with pkgs; [ slack signal-desktop discord ]))
      (lib.mkIf config.apps.office.enable (with pkgs; [ libreoffice-fresh onlyoffice-desktopeditors ]))
      (lib.mkIf config.apps.media.enable (with pkgs; [ spotify vlc mpv ]))
    ];
  };
}
```

## Best Practices

1. **Use `lib.mkEnableOption`**: Creates standard boolean options for enabling/disabling categories
2. **Use `lib.mkIf`**: Conditionally apply config based on option state
3. **Use `home.packages`**: User-scoped packages (vs `environment.systemPackages` for system-wide)
4. **Organize by category**: Group similar applications (browsers, communication, office, media)
5. **Keep modules focused**: Each module should handle one category or functionality
6. **Use `with pkgs`**: Simplifies package references (use sparingly for clarity)

## When to Use System vs Home Packages

- **`environment.systemPackages`** (in `configuration.nix`): System-wide packages, available to all users
- **`home.packages`** (in `home.nix`): User-specific packages, better for GUI apps and user tools

## Sources

- [Home Manager module writing documentation](https://nix-community.github.io/home-manager/)
- [Modular NixOS with Flakes guide](https://github.com/ryan4yin/nixos-and-flakes-book)
- [Cross-platform home-manager config structure](https://github.com/ryan4yin/nix-config)
