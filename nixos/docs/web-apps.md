# Web Apps with Chrome/Chromium

Create PWAs using Google Chrome or Chromium with `--app` flag and Home Manager's `xdg.desktopEntries`.

## Configuration Example

### Spotify Web App

```nix
# modules/apps/media.nix
xdg.desktopEntries.spotify-web = {
  name = "Spotify";
  genericName = "Music Streaming";
  exec = "${pkgs.google-chrome}/bin/google-chrome-stable --app=https://open.spotify.com --ozone-platform=wayland";
  icon = "spotify";
  terminal = false;
  categories = [ "Audio" "Music" "Player" ];
  mimeType = [ "x-scheme-handler/spotify" ];
};
```

### Slack Web App

```nix
# modules/apps/communication.nix
xdg.desktopEntries.slack-web = {
  name = "Slack";
  genericName = "Team Communication";
  exec = "${pkgs.google-chrome}/bin/google-chrome-stable --app=https://slack.com --ozone-platform=wayland";
  icon = "slack";
  terminal = false;
  categories = [ "Network" "Chat" "InstantMessaging" ];
  mimeType = [ "x-scheme-handler/slack" ];
};
```

## How It Works

1. **`--app=URL`**: Launches Chrome in app mode (minimal chrome, no tabs)
2. **`--ozone-platform=wayland`**: Wayland support for Hyprland
3. **`xdg.desktopEntries`**: Creates `.desktop` file at `~/.local/share/applications/`
4. **Icon**: Uses system icon theme or custom icon

## Custom Icons

Place custom icons in:

```nix
home.file.".local/share/icons/spotify.png".source = ./icons/spotify.png;
```

Then reference in `desktopEntries.icon = "spotify"`.

## Running Apps

- **Rofi**: Appears in application launcher
- **Hyprland**: `bind = $mod, S, exec, spotify-web`
- **Terminal**: `spotify-web` or `slack-web` (command becomes available after rebuild)

## Benefits Over Browser Tab

- Separate window (no tab bar, no omnibox)
- Appears in window switcher as app
- Custom categories for launcher
- Dedicated workspace for specific tasks
- Isolated cookies/session

## Sources

- https://mynixos.com/home-manager/option/xdg.desktopEntries
- https://nix-community.github.io/home-manager/options.xhtml
- Chrome app mode documentation
