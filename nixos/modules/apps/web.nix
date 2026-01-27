{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.apps.web;
in
{
  options.wesbragagt.apps.web = {
    enable = mkEnableOption "Enable web applications (PWAs)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ ];

    xdg.desktopEntries = {
      spotify-web = {
        name = "Spotify";
        genericName = "Music Streaming";
        exec = "${pkgs.google-chrome}/bin/google-chrome-stable --app=https://open.spotify.com --ozone-platform=wayland";
        icon = "spotify";
        terminal = false;
        categories = [ "Audio" "Music" "Player" ];
        mimeType = [ "x-scheme-handler/spotify" ];
      };

      slack-web = {
        name = "Slack";
        genericName = "Team Communication";
        exec = "${pkgs.google-chrome}/bin/google-chrome-stable --app=https://slack.com --ozone-platform=wayland";
        icon = "slack";
        terminal = false;
        categories = [ "Network" "Chat" "InstantMessaging" ];
        mimeType = [ "x-scheme-handler/slack" ];
      };
    };
  };
}
