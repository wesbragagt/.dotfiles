# NixOS configuration

You are a NixOS expert. You must rely on researching using exa mcp and documenting findings and their references here as you find solutions that worked.

## SSH

The system runs in a vm and you must ssh using `ssh wesbragagt@192.168.71.3 -i ~/.ssh/vm_key` to manage it.

## Problem Solving

When tasked with a feature perform a 3 step process:
1. Research with exa
2. Think about the findings
3. Put together a list of todos to implement
4. Task an agent with sonnet to do those tasks, keeping it 1-5 todos, explaining the problem clearly and presenting examples of the proposed solution when possible.


## Rules

* You must not write any code until you've confirmed documentation or answers through exa regarding a problem or request.
* You must document in a few sentences your findings, what worked and a link to the source.

## Tone

Be concise and sacrifice grammar for the sake of cohision.

## Findings

### Home-manager with dotfiles from GitHub (with git-lfs)

Use `pkgs.fetchgit` with `fetchLFS = true` instead of `fetchFromGitHub` - the latter doesn't support LFS. Must use commit hash not branch name for `rev` parameter.

```nix
dotfiles = pkgs.fetchgit {
  url = "https://github.com/user/repo.git";
  rev = "commit-hash";
  sha256 = "...";
  fetchLFS = true;
};
```

Source: https://discourse.nixos.org/t/how-to-use-git-lfs-with-fetchgit/55975

### Hyprland gestures syntax change (0.51+)

Old `gestures { workspace_swipe { } }` syntax deprecated. New format: `gesture = fingers, direction, action`. Source: https://wiki.hypr.land/Configuring/Gestures/

### Auto-start Hyprland with greetd (recommended over getty)

Getty autologin causes glitchy behavior. Use greetd with `initial_session` for clean autologin:

```nix
services.greetd = {
  enable = true;
  settings = {
    initial_session = {
      command = "uwsm start hyprland-uwsm.desktop";
      user = "username";
    };
    default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --asterisks --remember --remember-user-session --time --cmd 'uwsm start hyprland-uwsm.desktop'";
      user = "greeter";
    };
  };
};
```

`initial_session` auto-logs in on boot. `default_session` shows tuigreet after logout.

Source: https://discourse.nixos.org/t/autologin-hyprland/38159

### Hyprpaper wallpaper shuffling with systemd timer

Since home-manager manages hyprpaper config as read-only symlink to Nix store, use custom config approach:

1. Script (`~/.dotfiles/utils/wallpaper-shuffler.sh`):
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

2. Service (`~/.config/systemd/user/wallpaper-shuffler.service`):
```
[Unit]
Description=Shuffle wallpapers
After=hyprpaper.service

[Service]
Type=oneshot
ExecStart=%h/.dotfiles/utils/wallpaper-shuffler.sh
```

3. Timer (`~/.config/systemd/user/wallpaper-shuffler.timer`):
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

Enable with: `systemctl --user daemon-reload && systemctl --user enable --now wallpaper-shuffler.timer`

Source: https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/
