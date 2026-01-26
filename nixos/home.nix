{ config, pkgs, lib, ... }:

let
  neovim-dev = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
    version = "v0.12.0-dev";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "c39d18ee93";
      sha256 = "sha256-KOVSBncEUsn5ZqbkaDo5GhXWCoKqdZGij/KnLH5CoVI=";
    };
  });
in
{
  home.username = "wesbragagt";
  home.homeDirectory = "/home/wesbragagt";
  home.stateVersion = "24.11";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Cursor theme
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Packages for hyprland setup
  home.packages = with pkgs; [
    # Fonts
    nerd-fonts.jetbrains-mono

    # Hyprland ecosystem
    hypridle
    hyprlock
    hyprpaper
    hyprpolkitagent

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
    tmux

    # Neovim (built from v0.12.0-dev)
    neovim-dev

    # Screenshot/recording
    grim
    slurp
    swappy
    wf-recorder

    # Utilities
    brightnessctl
    playerctl
    pamixer
    pavucontrol
    networkmanagerapplet
    fzf
    git-lfs

    # File manager
    thunar
    xfce.thunar-plugins
    file-roller

    # Neovim dependencies (neovim provided by custom module)
    ripgrep
    fd
    bat
    eza
  ];

  # Link configs from local modules
  xdg.configFile = {
    "hypr" = {
      source = ./modules/hypr;
      recursive = true;
    };
    "waybar" = {
      source = ./modules/waybar;
      recursive = true;
    };
    "tmux" = {
      source = ./modules/tmux;
      recursive = true;
    };
    "starship" = {
      source = ./modules/starship;
      recursive = true;
    };
  };

  # Import local modules
  imports = [
    ./modules/nvim/default.nix
    ./modules/rofi/default.nix
  ];

  # Rofi configuration
  services.rofi-custom = {
    enable = true;
    theme = "rounded-nord-dark";
  };

  # Link zsh config from local module
  programs.zsh = {
    enable = true;
    initContent = lib.mkOrder 1000 ''
      source ${./modules/zsh/.zshrc}
    '';
  };

  # Link dotfiles and utils to home
  home.file = {
    ".aliases" = {
      source = ./modules/zsh/.aliases;
    };
    ".dotfiles/utils" = {
      source = ./modules/utils;
      recursive = true;
    };
    "wallpapers" = {
      source = ../wallpapers/wallpapers;
      recursive = true;
    };
  };

  programs.starship.enable = true;

  programs.zen-browser.enable = true;

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
