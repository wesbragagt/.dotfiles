# NixOS configuration

You are a NixOS expert. Research using exa mcp and document findings with sources.

### Adding New Host

Generate hardware configuration for new host:
```bash
# Generate without filesystems (for disk management)
nixos-generate-config --root /tmp/config --no-filesystems

# Create host directory
mkdir -p ~/.dotfiles/nixos/hosts/<hostname>
cp /tmp/config/etc/nixos/hardware-configuration.nix ~/.dotfiles/nixos/hosts/<hostname>/

# Copy or create configuration.nix for the host
# Add host to flake.nix nixosConfigurations
```

### Updating Configuration

On local machine:
```bash
# Make changes in /Users/wesbragagt/.dotfiles/nixos/
git add .
git commit -m "description"
git push
```

On VM:
```bash
cd ~/.dotfiles
git pull
git lfs pull
cd nixos
sudo nixos-rebuild switch --impure --flake .#vm-aarch64
```

### File Locations

- Config: `~/.dotfiles/nixos/`
- Wallpapers: `~/.dotfiles/wallpapers/wallpapers/`
- Local edit: `/Users/wesbragagt/.dotfiles/nixos/`

### Key Points

- Use HTTPS clone on VM (SSH requires key setup)
- Always run `git lfs pull` after git pull for LFS files (wallpapers, etc.)
- Rebuild requires `--impure` flag for local flakes
- Changes pushed to `feat--nixos-setup` branch

### Removing fetchgit Approach

Don't use `pkgs.fetchgit` with `fetchLFS = true` for dotfiles. Issues:
- Hash changes on every commit (LFS content)
- Clobber errors when updating
- Managed files conflict with git clone

Better: Clone repo once, manage with git + git-lfs.

## Problem Solving

When tasked with a feature:
1. Research with exa
2. Think about the findings
3. Create 1-5 todos to implement
4. Task an agent with sonnet, explaining the problem and solution examples

## Host Organization

Host-specific configurations live in `hosts/<hostname>/`:
- `configuration.nix` - System configuration for the host
- `hardware-configuration.nix` - Machine-specific hardware (gitignored)

Shared modules live in `modules/`:
- `nvim/` - Neovim configuration (custom build, plugins, kickstart-init.lua)
- `rofi/` - Rofi launcher configuration
- `web-apps.nix` - PWA desktop entries (Spotify, Slack via Chrome)
- `screenshot.nix` - Screenshot tools (swappy, slurp, grim)
- `hypr/` - Hyprland config
- `waybar/` - Waybar config
- `tmux/` - Tmux config
- `starship/` - Starship prompt config
- `zsh/` - Zsh config and aliases
- `utils/` - Utility scripts

**Module pattern:**
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.feature-name;
in
{
  options.wesbragagt.feature-name = {
    enable = mkEnableOption "Enable feature-name";
  };

  config = mkIf cfg.enable {
    # Configuration here
  };
}
```

Import in `home.nix`:
```nix
imports = [
  ./modules/feature-name.nix
];
```

Enable in `home.nix`:
```nix
wesbragagt.feature-name.enable = true;
```

## Adding Packages

**Direct packages (no module needed):**
Add to `home.packages` in `home.nix`:
```nix
home.packages = with pkgs; [
  package-name
];
```

**Feature packages (with enable option):**
Create module in `modules/feature.nix`:
```nix
config = mkIf cfg.enable {
  home.packages = with pkgs; [
    package-name
  ];
};
```

**LSP servers (for Neovim):**
Add to `extraPackages` in `modules/nvim/default.nix`:
```nix
extraPackages = with pkgs; [
  lua-language-server
  nodePackages.typescript-language-server
  pyright
];
```

Then configure in `kickstart-init.lua` using `vim.lsp.enable()`.

## Configuration Patterns

**XDG config files (Hyprland, Waybar, etc.):**
```nix
xdg.configFile."app-name" = {
  source = ./modules/app-name;
  recursive = true;
};
```

**Home files (dotfiles, scripts):**
```nix
home.file.".config/app-name/config.conf" = {
  source = ./modules/app-name/config.conf;
};
```

**Desktop entries:**
```nix
xdg.desktopEntries.app-name = {
  name = "App Name";
  exec = "${pkgs.package}/bin/command";
  icon = "app-icon";
  terminal = false;
  categories = [ "Category" ];
};
```

**Systemd user services:**
```nix
systemd.user.services.service-name = {
  Unit = {
    Description = "Description";
    After = [ "graphical-session.target" ];
  };
  Service = {
    ExecStart = "${pkgs.package}/bin/command";
  };
};
```

## Testing Workflow

**1. Test syntax:**
```bash
nix flake check
```

**2. Test on VM:**
```bash
# Local machine
cd /Users/wesbragagt/.dotfiles/nixos
git add .
git commit -m "feat: description"
git push

# VM
ssh wesbragagt@192.168.71.3 -i ~/.ssh/vm_key
cd ~/.dotfiles
git pull
git lfs pull
cd nixos
sudo nixos-rebuild switch --impure --flake .#vm-aarch64
```

**3. Test functionality:**
- Launch the application
- Verify configuration loaded
- Check for errors in logs

## Common Issues

**"SRI hash" errors:**
- Get correct hash: `nix-prefetch-git <url>`
- Or use packages from nixpkgs

**LFS files not loading:**
- Run `git lfs pull` after `git pull`

**Rebuild fails with "impure" flag:**
- Always use `--impure` for local flakes

**Plugin not found in Neovim:**
- Check plugin name in `modules/nvim/default.nix`
- Ensure it exists in nixpkgs

**LSP not working:**
- Check LSP server in `extraPackages` in `modules/nvim/default.nix`
- Check server name in `kickstart-init.lua`
- Use new `vim.lsp.enable()` API, not `lspconfig`

## Rules

- Never write code without confirming documentation through exa
- Document findings with what worked and source links in `docs/`
- Always search `docs/` first for existing solutions
- Use Nix packages, NOT lazy.nvim for Neovim plugins
- Keep module structure consistent with existing patterns
- Test on VM before considering changes complete

## Tone

Be concise. Sacrifice grammar for cohesion.
