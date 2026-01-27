# NixOS Neovim with kickstart.nvim Configuration

## Overview

Successfully integrated kickstart.nvim into NixOS using home-manager with a single init.lua file. This setup provides:
- All kickstart.nvim plugins (telescope, LSP, treesitter, etc.)
- Single-file Lua configuration (`kickstart-init.lua`)
- Declarative plugin management through nixpkgs
- Easy customization and maintenance

## Configuration Files

- **Module**: `/Users/wesbragagt/.dotfiles/nixos/modules/nvim/default.nix`
  - Home-manager module for Neovim configuration
  - Builds custom neovim v0.12.0-dev from source
  - Declares all plugins as nixpkgs packages
  - Uses `programs.neovim` with custom `package` option

- **Lua Config**: `/Users/wesbragagt/.dotfiles/nixos/modules/nvim/kickstart-init.lua`
  - Complete kickstart.nvim configuration in single file
  - Configured to work with plugins installed via nix

- **Integration**: `/Users/wesbragagt/.dotfiles/nixos/home.nix`
  - Links `kickstart-init.lua` to `~/.config/nvim/init.lua` via `xdg.configFile`
  - Forces config creation with `force = true`

## Key Features

### Plugin Management

**IMPORTANT**: This setup does NOT use lazy.nvim or any external plugin manager. All plugins are managed exclusively via Nix through `programs.neovim.plugins`.

Plugins are installed declaratively via nixpkgs:
- **LSP**: nvim-lspconfig, mason, mason-lspconfig, mason-tool-installer
- **Fuzzy Finding**: telescope, plenary, telescope-fzf-native, telescope-ui-select
- **Git**: gitsigns
- **Completion**: blink-cmp, luasnip
- **Editing**: conform-nvim (formatting)
- **UI**: which-key, mini-nvim (statusline, surrounding, AI)
- **Syntax**: nvim-treesitter
- **Theme**: kanagawa-nvim
- **Utilities**: todo-comments, lazydev

All plugins are loaded automatically from `~/.local/share/nvim/site/pack/hm/start/` which is managed by home-manager.

### System Packages
- ripgrep (required for telescope)
- fd (required for telescope)
- Custom neovim v0.12.0-dev build from source

## Testing

On NixOS ARM VM:

```bash
# Pull changes
cd ~/.dotfiles
git pull

# Rebuild configuration
cd nixos
sudo nixos-rebuild switch --impure --flake .#nixos-arm

# Test Neovim
nvim --version
# Should show NVIM v0.11.5-dev
nvim -c 'print(vim.version())' -c 'qa'
```

## Customization

To modify configuration:

1. Edit `/Users/wesbragagt/.dotfiles/nixos/modules/nvim/kickstart-init.lua`
   - All Lua configuration is in this single file
   - Add/modify plugin configurations as needed

2. To add new plugins:
   - Add to `plugins = [...]` list in `modules/nvim/default.nix`
   - Plugin must be available in nixpkgs under `vimPlugins`
   - DO NOT use lazy.nvim setup - plugins are loaded automatically from `~/.local/share/nvim/site/pack/hm/start/`

3. Rebuild on VM:
   ```bash
   cd ~/.dotfiles/nixos
   sudo nixos-rebuild switch --impure --flake .#nixos-arm
   ```

4. Force config recreation:
   - If neovim config doesn't update, remove `nvim` config and rebuild:
   ```bash
   ssh vm 'rm -rf ~/.config/nvim'
   cd ~/.dotfiles/nixos && sudo nixos-rebuild switch --impure --flake .#nixos-arm
   ```

## Notes

- **NO lazy.nvim**: This setup does NOT use lazy.nvim or any external plugin manager. All plugins are managed exclusively by Nix.
- Configuration uses home-manager's `initLua` option to load the single kickstart-init.lua file
- All plugins managed through nixpkgs ensure reproducibility
- Plugins are automatically loaded from `~/.local/share/nvim/site/pack/hm/start/` directory
- Single init.lua file makes configuration easy to understand and modify
- Custom neovim v0.12.0-dev built from GitHub source
- Do NOT attempt to install plugins using vim.pack or lazy.nvim - use only nixpkgs declarations

## Troubleshooting

### Neovim not updating after rebuild

If neovim configuration doesn't update after making changes to `kickstart-init.lua`:

1. Check if config file exists on VM:
   ```bash
   ssh vm 'ls -la ~/.config/nvim/'
   ```

2. If it exists but changes aren't applied:
   ```bash
   ssh vm 'rm -rf ~/.config/nvim'
   ssh vm 'cd ~/.dotfiles/nixos && git pull'
   ssh vm 'cd ~/.dotfiles/nixos && sudo nixos-rebuild switch --impure --flake .#nixos-arm'
   ```

3. Verify neovim is using custom build:
   ```bash
   nvim --version
   # Should show: NVIM v0.11.5-dev
   # (Not system neovim which might be older)
   ```

4. Check home-manager logs:
   ```bash
   journalctl --user -u home-manager-wesbragagt -n 20 --no-pager
   ```

## Alternative Approaches Considered

### 1. Using nixvim module directly
Complex to integrate with existing home-manager setup. Deferred for simplicity.

### 2. Using kickstart.nixvim
Direct Nix implementation, external dependency. Not chosen to maintain full control and use standard nixpkgs.

### 3. Using lazy.nvim plugin manager
Did NOT choose this approach. While commonly used in Neovim setups, it's not reproducible in NixOS and requires lazy.nvim setup code. Chose native Nix plugin loading through `programs.neovim.plugins` for full reproducibility.

### 4. Using vim.pack (native Neovim plugin manager)
Less declarative than nixpkgs plugin management. Chose nixpkgs for reproducibility and easier integration with home-manager.

## References

- kickstart.nvim: https://github.com/nvim-lua/kickstart.nvim
- NixOS docs: https://nixos.org/manual/nixos/stable/options.html#opt-programs.neovim
- Home-Manager neovim: https://nix-community.github.io/home-manager/options.html#opt-programs.neovim
