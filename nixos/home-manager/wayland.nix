{ config, pkgs, lib, ... }:

{
  # Packages for Wayland/Hyprland setup
  home.packages = with pkgs; [
    # Hyprland ecosystem
    hypridle
    hyprlock
    hyprpaper
    hyprpolkitagent
    nwg-dock-hyprland

    # Bar and notifications
    waybar
    mako

    # Wallpaper
    swww
    waypaper

    # Clipboard
    wl-clipboard
    cliphist

    # Terminal
    foot
  ];

  # Link configs from local modules (Wayland-specific)
  xdg.configFile = {
    "hypr" = {
      source = ./../modules/hypr;
      recursive = true;
      force = true;
    };
    "waybar" = {
      source = ./../modules/waybar;
      recursive = true;
      force = true;
    };
    "foot" = {
      source = ./../modules/foot;
      recursive = true;
      force = true;
    };
  };

  # Waypaper wrapper
  home.file.".local/bin/waypaper" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
        exec ${pkgs.waypaper}/bin/waypaper "$@"
      '';
  };

  # Import local modules
  imports = [
    ./../modules/nvim/default.nix
    ./../modules/rofi/default.nix
    ./../modules/screenshot.nix
    ./../modules/web-apps.nix
    ./../modules/npm.nix
    ./../modules/bitwarden.nix
  ];

  # Rofi configuration
  services.rofi-custom = {
    enable = true;
    theme = "raycast-nord";
  };

  # Enable web applications
  wesbragagt.web-apps.enable = true;

  # Enable screenshot tools
  wesbragagt.screenshot.enable = true;

  # Enable zen-browser
  programs.zen-browser.enable = true;

  # Enable npm global packages
  wesbragagt.npm = {
    enable = true;
    globalPackages = [
      "pnpm"
      "typescript"
    ];
  };

  # Enable bitwarden CLI and SSH agent
  wesbragagt.bitwarden.enable = true;

  # Wallpaper shuffler systemd service
  systemd.user.services.wallpaper-shuffler = {
    Unit = {
      Description = "Shuffle wallpapers with swww";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Requires = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash %h/.dotfiles/utils/random-wallpaper.sh";
      PassEnvironment = [ "WAYLAND_DISPLAY" "DISPLAY" ];
    };
  };

  systemd.user.timers.wallpaper-shuffler = {
    Unit = {
      Description = "Timer to shuffle wallpapers every 5 minutes";
    };

    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
      Unit = "wallpaper-shuffler.service";
    };

    Install = { WantedBy = [ "timers.target" ]; };
  };
}
