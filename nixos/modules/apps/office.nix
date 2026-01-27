{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.apps.office;
in
{
  options.wesbragagt.apps.office = {
    enable = mkEnableOption "Enable office applications";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-fresh
    ];
  };
}
