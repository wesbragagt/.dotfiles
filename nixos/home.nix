{ config, pkgs, ... }:

let
  dotfiles = pkgs.fetchgit {
    url = "https://github.com/wesbragagt/.dotfiles.git";
    rev = "3741786d1cc0f4799cf0faa7482237110bf613cd";
    sha256 = "sha256-PsYTGrXV/OwtMgU6Kdt0F2fbN421kcQQzPggE6c9w4s=";
    fetchLFS = true;
  };
in
{
  home.username = "wesbragagt";
  home.homeDirectory = "/home/wesbragagt";
  home.stateVersion = "24.11";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Cursor theme (traditional/default style)
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 24;
    gtk.enable = true;
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
  ];

  # Link configs from fetched dotfiles repo
  xdg.configFile = {
    "hypr" = {
      source = "${dotfiles}/hypr/.config/hypr";
      recursive = true;
    };
    "waybar" = {
      source = "${dotfiles}/waybar/.config/waybar";
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
      source = "${dotfiles}/tmux/.config/tmux";
      recursive = true;
    };
  };

  # Link utils scripts to ~/.dotfiles/utils
  home.file.".dotfiles/utils" = {
    source = "${dotfiles}/utils";
    recursive = true;
  };

  # Link wallpapers
  home.file.".dotfiles/wallpapers" = {
    source = "${dotfiles}/wallpapers";
    recursive = true;
  };
}
