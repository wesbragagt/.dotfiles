{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.apps.media;
in
{
  options.wesbragagt.apps.media = {
    enable = mkEnableOption "Enable media applications";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # spotify - Not available on aarch64-linux
      # Use Chromium web wrapper: chromium --app="https://open.spotify.com"
    ];
  };
}
