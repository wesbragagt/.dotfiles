{ config, pkgs, lib, ... }:

let
  dotfiles = pkgs.fetchgit {
    url = "https://github.com/wesbragagt/.dotfiles.git";
    rev = "503bb07";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    fetchLFS = true;
  };

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

    # App launcher
    walker

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

    # Neovim dependencies (neovim provided by custom module)
    ripgrep
    fd
    bat
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
    "foot" = {
      source = "${dotfiles}/foot/.config/foot";
      recursive = true;
    };
    "mako" = {
      source = "${dotfiles}/mako/.config/mako";
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

  # Link utils scripts to ~/.dotfiles/utils
  home.file.".dotfiles/utils" = {
    source = "${dotfiles}/utils";
    recursive = true;
  };

  # Link wallpapers from dotfiles root wallpapers folder
  home.file.".dotfiles/wallpapers" = {
    source = "${dotfiles}/wallpapers";
    recursive = true;
  };

  # Link zsh config from local module
  programs.zsh = {
    enable = true;
    initContent = lib.mkOrder 1000 ''
      source ${./modules/zsh/.zshrc}
    '';
  };

  programs.starship.enable = true;
}
