# Swww wallpaper shuffling with systemd timer

Since home-manager manages config as read-only symlink to Nix store, use systemd timer with bash script.

**Script** (`~/.dotfiles/utils/random-wallpaper.sh`):
```bash
#!/usr/bin/bash

WALLPAPERS_DIR="$HOME/wallpapers"
WALLPAPER=$(find "$WALLPAPERS_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)
swww img "$WALLPAPER" --transition-type wipe --transition-duration 2
```

**Link wallpapers to home** (`home.nix`):
```nix
home.file = {
  "wallpapers" = {
    source = ./wallpapers/wallpapers;
    recursive = true;
  };
};
```

**Service and Timer** (`home.nix`):
```nix
systemd.user.services.wallpaper-shuffler = {
  Unit = {
    Description = "Shuffle wallpapers with swww";
  };

  Service = {
    Type = "oneshot";
    ExecStart = "%h/.dotfiles/utils/random-wallpaper.sh";
  };
};

systemd.user.timers.wallpaper-shuffler = {
  Unit = {
    Description = "Timer to shuffle wallpapers every 5 minutes";
  };

  Timer = {
    OnBootSec = "1min";
    OnUnitActiveSec = "5min";
    Unit = "wallpaper-shuffler.service";
  };

  Install = { WantedBy = [ "timers.target" ]; };
};
```

After rebuild, enable with: `systemctl --user enable --now wallpaper-shuffler.timer`

Src: https://www.codyhiar.com/blog/repeated-tasks-with-systemd-service-timers-on-nixos/
