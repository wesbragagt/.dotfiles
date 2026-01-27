{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.apps.browsers;
in
{
  options.wesbragagt.apps.browsers = {
    enable = mkEnableOption "Enable browser applications";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      google-chrome
    ];
  };
}
