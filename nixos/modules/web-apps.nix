{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.web-apps;
in
{
  options.wesbragagt.web-apps = {
    enable = mkEnableOption "Enable web applications (PWAs) via Chrome";
  };

  config = mkIf cfg.enable {
    xdg.desktopEntries = {
      spotify-web = {
        name = "Spotify";
        genericName = "Music Streaming";
        exec = "${pkgs.chromium}/bin/chromium --app=https://open.spotify.com --ozone-platform=wayland";
        icon = "spotify";
        terminal = false;
        categories = [ "Audio" "Music" "Player" ];
        mimeType = [ "x-scheme-handler/spotify" ];
      };

      slack-web = {
        name = "Slack";
        genericName = "Team Communication";
        exec = "${pkgs.chromium}/bin/chromium --app=https://slack.com --ozone-platform=wayland";
        icon = "slack";
        terminal = false;
        categories = [ "Network" "Chat" "InstantMessaging" ];
        mimeType = [ "x-scheme-handler/slack" ];
      };

      telegram-web = {
        name = "Telegram";
        genericName = "Messaging";
        exec = "${pkgs.chromium}/bin/chromium --app=https://web.telegram.org --ozone-platform=wayland";
        icon = "telegram";
        terminal = false;
        categories = [ "Network" "Chat" "InstantMessaging" ];
        mimeType = [ "x-scheme-handler/tg" ];
      };
    };
  };
}
