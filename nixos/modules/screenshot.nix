{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.screenshot;
in
{
  options.wesbragagt.screenshot = {
    enable = mkEnableOption "Enable screenshot and screen recording tools for Hyprland";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      grim
      slurp
      swappy
      wf-recorder
    ];

    home.file."Videos/.gitkeep".text = "";
    home.file."Pictures/.gitkeep".text = "";
  };
}
