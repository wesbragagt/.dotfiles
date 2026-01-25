# NixOS configuration

You are a NixOS expert. Research using exa mcp and document findings with sources.

## SSH

Manage the VM system via: `ssh wesbragagt@192.168.71.3 -i ~/.ssh/vm_key`

## VM Bootstrap Workflow

### Initial Setup

Clone dotfiles repo on VM:
```bash
cd ~
git clone -b feat--nixos-setup https://github.com/wesbragagt/.dotfiles.git
cd ~/.dotfiles
git lfs install
git lfs pull
cd nixos
sudo nixos-rebuild switch --impure --flake .#nixos-arm
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
sudo nixos-rebuild switch --impure --flake .#nixos-arm
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

## Rules

- Never write code without confirming documentation through exa
- Document findings with what worked and source links in `docs/`
- Always search `docs/` first for existing solutions

## Tone

Be concise. Sacrifice grammar for cohesion.

## Findings

### Home-manager with dotfiles from GitHub (with git-lfs)

Don't use `pkgs.fetchgit` with `fetchLFS = true` for dotfiles. Problems:
- Hash changes on every commit (LFS content)
- Clobber errors when updating
- Managed files conflict with git clone

Better approach: Clone repo once with `git clone`, manage with `git pull` + `git lfs pull`.

Source: https://discourse.nixos.org/t/how-to-use-git-lfs-with-fetchgit/55975

### Configuring zsh with home-manager to source dotfiles

Use `programs.zsh.enable = true` in home.nix to enable home-manager zsh management. Enable zsh system-wide in configuration.nix (`programs.zsh.enable = true`) and set user shell (`users.users.wesbragagt.shell = pkgs.zsh`). Source external dotfiles using `initContent` with ordering:

```nix
programs.zsh = {
  enable = true;
  initContent = lib.mkOrder 1000 ''
    source $HOME/.dotfiles/zsh/.zshrc
  '';
};
```

Link dotfiles to home:
```nix
home.file.".dotfiles/zsh" = {
  source = "${dotfiles}/zsh";
  recursive = true;
};
```

Source: https://nixos.wiki/wiki/Zsh, https://nix-community.github.io/home-manager/options.xhtml

### Fixing "invalid SRI hash" errors in home-manager

SRI hash format errors typically occur with `fetchFromGitHub` when the hash is incorrect. Fix by getting correct hash with `nix-prefetch-git` or use packages from nixpkgs instead of custom fetches.

Source: Home-Manager issue #3044, docs/nixos-flake-errors-fixes.md

### Pointer cursor configuration with home-manager

Configure cursors using `home.pointerCursor` for proper XCURSOR_THEME/XCURSOR_SIZE vars in Hyprland:

```nix
home.pointerCursor = {
  name = "Vanilla-DMZ";
  package = pkgs.vanilla-dmz;
  size = 24;
  gtk.enable = true;  # For GTK applications
  x11.enable = true;  # For XWayland applications
};
```

Source: docs/nixos-flake-errors-fixes.md, GitHub issue #4553

### Tuigreet package rename in nixpkgs

Package moved from `pkgs.greetd.tuigreet` to `pkgs.tuigreet` (August 2, 2025). Use `${pkgs.tuigreet}/bin/tuigreet`.

Source: GitHub commit 3d98a498, docs/nixos-flake-errors-fixes.md
