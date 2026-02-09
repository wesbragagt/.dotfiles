{ config, pkgs, lib, elephant, ... }:

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

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir";
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";
    GTK_APPLICATION_PREFER_DARK_THEME = "1";
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

    # Launcher
    walker
    elephant.packages.${pkgs.system}.default

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

    # GTK themes
    gnome-themes-extra
    adwaita-icon-theme
    networkmanagerapplet
    fzf
    git-lfs
    glow

    # File manager
    thunar
    file-roller

    # Video player
    mpv

    # Image viewer
    swayimg

    # Browsers
    firefox
    google-chrome

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
      force = true;
    };
    "waybar" = {
      source = ./modules/waybar;
      recursive = true;
      force = true;
    };
    "tmux" = {
      source = ./modules/tmux;
      recursive = true;
      force = true;
    };
    "starship" = {
      source = ./modules/starship;
      recursive = true;
      force = true;
    };
    "foot" = {
      source = ./modules/foot;
      recursive = true;
      force = true;
    };
  };

  # Link dotfiles and wallpapers directory
  home.file = {
    ".aliases" = {
      source = ./modules/zsh/.aliases;
      force = true;
    };
    ".dotfiles/utils" = {
      source = ./modules/utils;
      recursive = true;
      force = true;
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

  # Default applications
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "video/mp4" = "mpv.desktop";
    "video/webm" = "mpv.desktop";
    "video/quicktime" = "mpv.desktop";
    "video/x-matroska" = "mpv.desktop";
    "video/*" = "mpv.desktop";
    "image/jpeg" = "swayimg.desktop";
    "image/png" = "swayimg.desktop";
    "image/gif" = "swayimg.desktop";
    "image/webp" = "swayimg.desktop";
    "image/svg+xml" = "swayimg.desktop";
    "image/*" = "swayimg.desktop";
  };
  xdg.mimeApps.associations.added = {
    "video/*" = ["mpv.desktop"];
    "image/*" = ["swayimg.desktop"];
  };
  xdg.configFile."mimeapps.list".force = true;

  # Import local modules
  imports = [
    ./modules/nvim/default.nix
    ./modules/rofi/default.nix
    ./modules/screenshot.nix
    ./modules/web-apps.nix
    ./modules/npm.nix
    ./modules/bitwarden.nix
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

  # Enable bitwarden CLI and SSH agent
  wesbragagt.bitwarden.enable = true;

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

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        HostName github.com
        User git
        IdentityAgent ~/.bitwarden-ssh-agent.sock
        IdentityFile ~/.ssh/github_key.pub
        IdentitiesOnly yes
    '';
  };

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

  systemd.user.services.elephant = {
    Unit = {
      Description = "Elephant backend service for Walker";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Requires = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${elephant.packages.${pkgs.system}.default}/bin/elephant";
      Restart = "on-failure";
      PassEnvironment = [ "WAYLAND_DISPLAY" "DISPLAY" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}
