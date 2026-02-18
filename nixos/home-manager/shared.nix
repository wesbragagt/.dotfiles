{ config, pkgs, lib, ... }:

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

  home.packages = with pkgs; [
    # Fonts
    nerd-fonts.jetbrains-mono

    # System monitor
    btop

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
    chromium

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

  # Link dotfiles and wallpapers directory
  home.file = {
    ".aliases" = {
      source = ./../modules/zsh/.aliases;
      force = true;
    };
    ".dotfiles/utils" = {
      source = ./../modules/utils;
      recursive = true;
      force = true;
    };
    "wallpapers" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/wesbragagt/.dotfiles/wallpapers/wallpapers";
      force = true;
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

  # Link zsh config from local module
  programs.zsh = {
    enable = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#888";
    };
    initContent = lib.mkOrder 1000 ''
      # Setup npm global packages
      mkdir -p ~/.npm_global
      npm config set prefix ~/.npm_global
      export PATH="$HOME/.npm_global/bin:$PATH"

      # Source dotfiles
      source ${./../modules/zsh/.zshrc}
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
}
