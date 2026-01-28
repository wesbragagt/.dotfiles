# NixOS Bootstrap Guide

Bootstrapping a new NixOS machine with this dotfiles configuration.

## Bootstrap Steps

### 1. Enable Flakes

Add to `/etc/nixos/configuration.nix`:
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ]
```

Then apply:
```bash
sudo nixos-rebuild switch
```

### 2. Clone Dotfiles

```bash
cd ~
git clone -b feat--nixos-setup https://github.com/wesbragagt/.dotfiles.git
cd ~/.dotfiles
git lfs install
git lfs pull
```

### 3. Link Hardware Configuration

```bash
cd ~/.dotfiles/nixos
sudo ln -s /etc/nixos/hardware-configuration.nix ~/.dotfiles/nixos/hardware-configuration.nix
```

### 4. Add Agenix Private Key

Add your existing private key to the VM:
```bash
# Copy your private key to the VM
scp /path/to/your/private/key wesbragagt@192.168.71.3:~/.ssh/nixos_id

# Or if already on the VM, create it from your existing key
# Make sure the public key in secrets/secrets.nix matches this private key
```

### 5. Build System

```bash
cd ~/.dotfiles/nixos
sudo nixos-rebuild switch --impure --flake .#nixos-arm
```

## Daily Workflow

### Making Changes

**On local machine:**
```bash
# Edit config files in /Users/wesbragagt/.dotfiles/nixos/
git add .
git commit -m "feat: description"
git push
```

**On target system:**
```bash
cd ~/.dotfiles
git pull
git lfs pull  # Important for wallpapers!
cd nixos
sudo nixos-rebuild switch --impure --flake .#nixos-arm
```

## Module Structure

```
modules/
├── nvim/           # Neovim (custom build, plugins, config)
├── hypr/           # Hyprland compositor config
├── waybar/         # Waybar status bar
├── rofi/           # Application launcher
├── tmux/           # Terminal multiplexer
├── zsh/            # Shell config and aliases
├── starship/       # Prompt theme
├── web-apps.nix    # PWA desktop entries (Spotify, Slack)
├── screenshot.nix   # Screenshot tools
└── utils/          # Utility scripts
```

## Adding Packages

**Quick package (no module):**
Add to `home.packages` in `home.nix`:
```nix
home.packages = with pkgs; [
  package-name
];
```

**Feature with enable option:**
1. Create `modules/feature.nix`
2. Import in `home.nix`
3. Enable in `home.nix`:
```nix
wesbragagt.feature.enable = true;
```

## Key Commands

```bash
# Test syntax
nix flake check

# Rebuild system
sudo nixos-rebuild switch --impure --flake .#nixos-arm

# Check generations
nixos-rebuild list-generations

# Rollback
nixos-rebuild switch --rollback
```

## Troubleshooting

**LFS files not loading:**
```bash
cd ~/.dotfiles
git lfs pull
```

**Hash errors:**
- Get correct hash: `nix-prefetch-git <url>`
- Use packages from nixpkgs instead

**Build fails:**
- Always use `--impure` flag for local flakes
- Check syntax: `nix flake check`

**Neovim plugin issues:**
- All plugins managed by Nix, NOT lazy.nvim
- Check `modules/nvim/default.nix`

## Configuration Files

- `home.nix` - Main home-manager config
- `modules/nvim/kickstart-init.lua` - Neovim config
- `modules/hypr/hyprland.conf` - Hyprland settings
- `modules/waybar/config` - Waybar configuration

## Testing Changes

1. Edit config locally
2. Commit and push
3. Pull on target system
4. Run rebuild command
5. Test application/feature
6. Fix issues, repeat

## Getting Help

- NixOS Wiki: https://nixos.wiki
- Home Manager Options: https://nix-community.github.io/home-manager/options.xhtml
- Search NixOS Packages: https://search.nixos.org/packages
