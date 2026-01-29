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
  
  # Monitor through btm
  programs.bottom.enable = true;

  # Cursor theme
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # GTK theme and icons
  gtk = {
    enable = true;

    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir";
    };
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

    # Utilities
    brightnessctl
    playerctl
    pamixer
    pavucontrol
    networkmanagerapplet
    fzf
    git-lfs
    glow

    # File manager
    thunar
    file-roller

    # Browsers
    firefox

    # Browsers

    # Neovim dependencies (neovim provided by custom module)
    ripgrep
    fd
    bat
    eza
    zoxide

    # Node.js and package managers
    nodejs
    fnm
    bun

    # AI tools
    opencode

    # Secrets tools
    age
    age-plugin-yubikey
    sops

    # Data tools
    duckdb
    harlequin
  ];

  # UV package manager
  programs.uv = {
    enable = true;
  };

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
    "foot" = {
      source = ./modules/foot;
      recursive = true;
    };
  };

  # Link dotfiles and wallpapers directory
  home.file = {
    ".aliases" = {
      source = ./modules/zsh/.aliases;
    };
    ".dotfiles/utils" = {
      source = ./modules/utils;
      recursive = true;
    };
    "wallpapers" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/wesbragagt/.dotfiles/wallpapers/wallpapers";
      force = true;
    };
    ".local/bin/waypaper" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        exec ${pkgs.waypaper}/bin/waypaper "$@"
      '';
    };
    "Pictures/Screenshots/.gitkeep".text = "";
    "Pictures/.gitkeep".text = "";
    "Videos/.gitkeep".text = "";
    "Documents/.gitkeep".text = "";
  };

  # Import local modules
  imports = [
    ./modules/nvim/default.nix
    ./modules/rofi/default.nix
    ./modules/screenshot.nix
    ./modules/web-apps.nix
    ./modules/npm.nix
  ];

  # Rofi configuration
  services.rofi-custom = {
    enable = true;
    theme = "rounded-nord-dark";
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

  # Link zsh config from local module
  programs.zsh = {
    enable = true;
    initContent = lib.mkOrder 1000 ''
      # Setup npm global packages
      mkdir -p ~/.npm_global
      npm config set prefix ~/.npm_global
      export PATH="$HOME/.npm_global/bin:$PATH"

      # Source dotfiles
      source ${./modules/zsh/.zshrc}
    '';
  };

  programs.starship.enable = true;

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
