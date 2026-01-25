# Hyprpaper wallpaper shuffling with systemd timer

Since home-manager manages hyprpaper config as read-only symlink to Nix store, use custom config approach.

**Script** (`~/.dotfiles/utils/wallpaper-shuffler.sh`):
```bash
#!/usr/bin/env bash
WALLPAPER_DIR="$HOME/.dotfiles/wallpapers/wallpapers"
CUSTOM_CONFIG="$HOME/.config/hypr/hyprpaper-custom.conf"

cd "$WALLPAPER_DIR" || exit 1
wallpapers=(*)
random_wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
wallpaper_path="$WALLPAPER_DIR/$random_wallpaper"

cat > "$CUSTOM_CONFIG" << CONFIG
preload = $wallpaper_path
wallpaper = ,$wallpaper_path
CONFIG

pkill hyprpaper
hyprpaper -c "$CUSTOM_CONFIG" &
```

**Service** (`~/.config/systemd/user/wallpaper-shuffler.service`):
```
[Unit]
Description=Shuffle wallpapers
After=hyprpaper.service

[Service]
Type=oneshot
ExecStart=%h/.dotfiles/utils/wallpaper-shuffler.sh
```

**Timer** (`~/.config/systemd/user/wallpaper-shuffler.timer`):
```
[Unit]
Description=Timer to shuffle wallpapers every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=wallpaper-shuffler.service

[Install]
WantedBy=timers.target
```

Enable: `systemctl --user daemon-reload && systemctl --user enable --now wallpaper-shuffler.timer`

Src: https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/
