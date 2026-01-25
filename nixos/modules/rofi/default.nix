{ config, lib, pkgs, ... }:

let
  cfg = config.programs.rofi-custom;

in
{
  options.programs.rofi-custom = {
    enable = lib.mkEnableOption "Enable custom Rofi configuration with themes and icons";
    theme = lib.mkOption {
      type = lib.types.enum [ "default" "dracula" "nord" "gruvbox-dark" "catppuccin" "fresh" ];
      default = "nord";
      description = "Rofi theme to use";
    };
    iconTheme = lib.mkOption {
      type = lib.types.enum [ "hicolor" "papirus" "adwaita" ];
      default = "papirus";
      description = "GTK icon theme for rofi";
    };
  };

  config = lib.mkIf cfg.enable {
    # GTK icon theme
    gtk.iconTheme = {
      name = if cfg.iconTheme == "papirus" then "Papirus"
             else if cfg.iconTheme == "adwaita" then "Adwaita"
             else "Hicolor";
      package = if cfg.iconTheme == "papirus" then pkgs.papirus-icon-theme
                else if cfg.iconTheme == "adwaita" then pkgs.adwaita-icon-theme
                else pkgs.hicolor-icon-theme;
    };

    # Generate rofi config based on theme selection
    xdg.configFile."rofi/config.rasi".text = ''
      configuration {
        show-icons: true;
        icon-theme: "${cfg.iconTheme}";
      }

      * {
        font: "JetBrainsMono Nerd Font 14";
      }
    '' + (if cfg.theme == "dracula" then ''
      /* Dracula Theme Colors */
      * {
        bg-color: #282a36;
        fg-color: #f8f8f2;
        selected-bg: #bd93f9;
        selected-fg: #282a36;
        separator-color: #44475a;
        urgent-bg: #ff5555;
        urgent-fg: #f8f8f2;
      }

      window {
        background-color: #282a36;
        border-color: #bd93f9;
        border: 2;
        border-radius: 8;
        padding: 15;
        width: 50;
        height: 30;
      }

      element {
        padding: 10;
        border: 0;
        border-radius: 5;
      }

      element.selected {
        background-color: #bd93f9;
        text-color: #282a36;
      }

      element.normal.normal {
        background-color: #282a36;
        text-color: #f8f8f2;
      }

      separator {
        border-color: #44475a;
      }
    '' else if cfg.theme == "nord" then ''
      /* Nord Theme Colors */
      * {
        bg-color: #2e3440;
        fg-color: #d8dee9;
        selected-bg: #88c0d0;
        selected-fg: #2e3440;
        separator-color: #4c566a;
        urgent-bg: #bf616a;
        urgent-fg: #eceff4;
      }

      window {
        background-color: #2e3440;
        border-color: #88c0d0;
        border: 2;
        border-radius: 8;
        padding: 15;
        width: 50;
        height: 30;
      }

      element.selected {
        background-color: #88c0d0;
        text-color: #2e3440;
      }

      element.normal.normal {
        background-color: #2e3440;
        text-color: #d8dee9;
      }

      separator {
        border-color: #4c566a;
      }
    '' else if cfg.theme == "gruvbox-dark" then ''
      /* Gruvbox Dark Theme Colors */
      * {
        bg-color: #282828;
        fg-color: #ebdbb2;
        selected-bg: #458588;
        selected-fg: #282828;
        separator-color: #504945;
        urgent-bg: #cc241d;
        urgent-fg: #ebdbb2;
      }

      window {
        background-color: #282828;
        border-color: #458588;
        border: 2;
        border-radius: 8;
        padding: 15;
        width: 50;
        height: 30;
      }

      element.selected {
        background-color: #458588;
        text-color: #282828;
      }

      element.normal.normal {
        background-color: #282828;
        text-color: #ebdbb2;
      }

      separator {
        border-color: #504945;
      }
    '' else if cfg.theme == "catppuccin" then ''
      /* Catppuccin Theme Colors (Mocha) */
      * {
        bg-color: #1e1e2e;
        fg-color: #cdd6f4;
        selected-bg: #f5c2e7;
        selected-fg: #1e1e2e;
        separator-color: #45475a;
        urgent-bg: #eba0ac;
        urgent-fg: #cdd6f4;
      }

      window {
        background-color: #1e1e2e;
        border-color: #f5c2e7;
        border: 2;
        border-radius: 8;
        padding: 15;
        width: 50;
        height: 30;
      }

      element.selected {
        background-color: #f5c2e7;
        text-color: #1e1e2e;
      }

      element.normal.normal {
        background-color: #1e1e2e;
        text-color: #cdd6f4;
      }

      separator {
        border-color: #45475a;
      }
    '' else if cfg.theme == "fresh" then ''
      /* Fresh Theme Colors */
      * {
        bg-color: #1a1b26;
        fg-color: #a6accd;
        selected-bg: #3ddbd9;
        selected-fg: #1a1b26;
        separator-color: #465c70;
        urgent-bg: #e78a4e;
        urgent-fg: #1a1b26;
      }

      window {
        background-color: #1a1b26;
        border-color: #3ddbd9;
        border: 2;
        border-radius: 8;
        padding: 15;
        width: 50;
        height: 30;
      }

      element.selected {
        background-color: #3ddbd9;
        text-color: #1a1b26;
      }

      element.normal.normal {
        background-color: #1a1b26;
        text-color: #a6accd;
      }

      separator {
        border-color: #465c70;
      }
    '' else ''
      /* Default Theme Colors */
      * {
        bg-color: #1a1b26;
        fg-color: #c0caf5;
        selected-bg: #7aa2f7;
        selected-fg: #1a1b26;
        separator-color: #44475a;
        urgent-bg: #f7768e;
        urgent-fg: #1a1b26;
      }

      window {
        background-color: #1a1b26;
        border-color: #7aa2f7;
        border: 2;
        border-radius: 8;
        padding: 15;
        width: 50;
        height: 30;
      }

      element.selected {
        background-color: #7aa2f7;
        text-color: #1a1b26;
      }

      element.normal.normal {
        background-color: #1a1b26;
        text-color: #c0caf5;
      }

      separator {
        border-color: #44475a;
      }
    '');

    # Themes directory
    xdg.configFile."rofi/themes" = {
      source = ./themes;
      recursive = true;
    };

    home.packages = home.packages ++ [
      (pkgs.writeShellScriptBin {
        name = "rofi-theme-selector";
        text = builtins.readFile ./theme-selector.sh;
      })
    ];
  };
}
