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
  - Declares all plugins as nixpkgs packages
  - Uses standard home-manager `programs.neovim`

- **Lua Config**: `/Users/wesbragagt/.dotfiles/nixos/modules/nvim/kickstart-init.lua`
  - Complete kickstart.nvim configuration in single file
  - Configured to work with plugins installed via nix

- **Integration**: `/Users/wesbragagt/.dotfiles/nixos/home.nix`
  - Links `kickstart-init.lua` to `~/.config/nvim/init.lua` via `xdg.configFile`
  - Enables neovim-nixvim service

## Key Features

### Plugin Management
Plugins are installed declaratively via nixpkgs:
- **LSP**: nvim-lspconfig, mason, mason-lspconfig, mason-tool-installer
- **Fuzzy Finding**: telescope, plenary, telescope-fzf-native, telescope-ui-select
- **Git**: gitsigns
- **Completion**: blink-cmp, luasnip
- **Editing**: conform-nvim (formatting)
- **UI**: which-key, mini-nvim (statusline, surrounding, AI)
- **Syntax**: nvim-treesitter
- **Theme**: tokyonight-nvim
- **Utilities**: todo-comments, lazydev

### System Packages
- ripgrep (required for telescope)
- fd (required for telescope)

## Testing

On the NixOS ARM VM:

```bash
# Pull changes
cd ~/.dotfiles
git pull

# Rebuild configuration
cd nixos
sudo nixos-rebuild switch --impure --flake .#nixos-arm

# Test Neovim
nvim
# Should see kickstart configuration loaded with all plugins
```

## Customization

To modify configuration:

1. Edit `/Users/wesbragagt/.dotfiles/nixos/modules/nvim/kickstart-init.lua`
   - All Lua configuration is in this single file
   - Add/modify plugin configurations

2. To add new plugins:
   - Add to `plugins = [...]` list in `modules/nvim/default.nix`
   - Or add plugin configuration in `kickstart-init.lua` if using lazy.nvim

3. Rebuild on VM:
   ```bash
   cd ~/.dotfiles/nixos
   sudo nixos-rebuild switch --impure --flake .#nixos-arm
   ```

## Notes

- Configuration uses home-manager's `xdg.configFile` to link init.lua
- All plugins managed through nixpkgs ensure reproducibility
- Single init.lua file makes configuration easy to understand and modify
- Standard home-manager `programs.neovim` options used (no nixvim module required)
- Approach avoids complexity of nixvim module system while maintaining declarative plugin management

## Alternative Approaches Considered

### 1. Using nixvim directly
Complex to integrate with existing home-manager setup, requires separate module system. Deferred for simplicity.

### 2. Using kickstart.nixvim
Direct Nix implementation of kickstart, external dependency. Not chosen to maintain full control and use standard nixpkgs.

### 3. Using vim.pack
Less declarative than nixpkgs plugin management. Chose nixpkgs for reproducibility.

## References

- kickstart.nvim: https://github.com/nvim-lua/kickstart.nvim
- NixOS docs: https://nixos.org/manual/nixos/stable/options.html#opt-programs.neovim
- Home-Manager neovim: https://nix-community.github.io/home-manager/options.html#opt-programs.neovim
