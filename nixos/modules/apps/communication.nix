{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.apps.communication;
in
{
  options.wesbragagt.apps.communication = {
    enable = mkEnableOption "Enable communication applications";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # slack - Not available on aarch64-linux
      signal-desktop
    ];
  };
}
