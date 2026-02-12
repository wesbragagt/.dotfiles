{ config, lib, pkgs, ... }:

let
  cfg = config.services.rofi-custom;

  # Theme definitions
  themes = import ./themes { inherit pkgs lib; };

  # Get selected theme content
  themeContent = if builtins.hasAttr cfg.theme themes
    then themes.${cfg.theme}.content
    else themes.raycast-nord.content;

  # Rofi configuration
  rofiConfig = pkgs.writeText "config.rasi" ''
    configuration {
      modi: "drun,window,ssh";
      font: "${cfg.font}";
      icon-theme: "${cfg.iconTheme.name}";
      show-icons: true;
      terminal: "foot";
      drun-display-format: "{name}";
      disable-history: false;
      hide-scrollbar: true;
      sidebar-mode: false;
    }

    /* Theme: ${cfg.theme} */
    ${themeContent}
  '';

  # Theme selector script
  themeSelector = pkgs.writeShellScriptBin "rofi-theme-selector" ''
    #!/usr/bin/env bash
    set -e

    THEME_DIR="$HOME/.config/rofi/themes"
    mkdir -p "$THEME_DIR"

    echo "Available themes:"
    echo ""
    echo "  default - Simple Nord theme"
    echo "  rounded-nord-dark - Rounded corners Nord theme"
    echo "  dracula - Dracula colors"
    echo "  gruvbox - Gruvbox Dark"
    echo "  catppuccin - Catppuccin Mocha"
    echo "  fresh - Clean blue theme"
    echo ""
    read -p "Enter theme name: " THEME_NAME

    # Validate theme exists
    case "$THEME_NAME" in
      default|dracula|gruvbox|catppuccin|fresh|rounded-nord-dark)
        echo "Setting theme to: $THEME_NAME"
        # Theme is set via Nix configuration
        echo "To permanently set this theme, add to home.nix:"
        echo "  services.rofi-custom.theme = \"$THEME_NAME\";"
        ;;
      *)
        echo "Error: Unknown theme '$THEME_NAME'"
        exit 1
        ;;
    esac
  '';
in
{
  options.services.rofi-custom = {
    enable = lib.mkEnableOption "Enable custom Rofi configuration";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "raycast-nord";
      description = "Theme to use: default, dracula, gruvbox, catppuccin, fresh, rounded-nord-dark, raycast-nord";
    };

    font = lib.mkOption {
      type = lib.types.str;
      default = "Roboto 12";
      description = "Font for Rofi";
    };

    iconTheme = lib.mkOption {
      type = lib.types.attrs;
      default = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
      description = "Icon theme for Rofi";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install packages
    home.packages = with pkgs; [
      rofi
      cfg.iconTheme.package
      themeSelector
    ];

    # Generate rofi configuration
    xdg.configFile."rofi/config.rasi".source = rofiConfig;

    # Ensure theme files are available
    xdg.configFile."rofi/themes/default.rasi".text = themes.default.content;
    xdg.configFile."rofi/themes/rounded-nord-dark.rasi".text = themes.rounded-nord-dark.content;
    xdg.configFile."rofi/themes/dracula.rasi".text = themes.dracula.content;
    xdg.configFile."rofi/themes/gruvbox.rasi".text = themes.gruvbox.content;
    xdg.configFile."rofi/themes/catppuccin.rasi".text = themes.catppuccin.content;
    xdg.configFile."rofi/themes/fresh.rasi".text = themes.fresh.content;
    xdg.configFile."rofi/themes/raycast-nord.rasi".text = themes.raycast-nord.content;
  };
}
