# Neovim with vim.pack (Native Plugin Manager)

## Problem
Neovim 0.12+ includes a native plugin manager called `vim.pack`. Need to build Neovim from source and use it instead of external plugin managers.

## Solution
Build Neovim from a specific commit that includes vim.pack support. Use `vim.pack.add()` to install plugins directly from GitHub URLs.

## Implementation

### Module: `modules/nvim/default.nix`

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.neovim-custom;

  neovim-custom = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
    version = "v0.12.0-dev";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "c39d18ee93";
      sha256 = "sha256-KOVSBncEUsn5ZqbkaDo5GhXWCoKqdZGij/KnLH5CoVI=";
    };
  });

  simple-init = pkgs.writeText "init.lua" ''
    -- Basic Neovim settings
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
    vim.opt.termguicolors = true

    -- Add plugins using native vim.pack
    vim.pack.add({
      "https://github.com/nvim-lua/plenary.nvim",
      "https://github.com/ibhagwan/fzf-lua",
      "https://github.com/lewis6991/gitsigns.nvim",
      "https://github.com/nvim-lualine/lualine.nvim",
    })

    -- Configure plugins with safe pcall
    pcall(function()
      require("fzf-lua").setup({})
    end)

    pcall(function()
      require("gitsigns").setup({})
    end)

    pcall(function()
      require("lualine").setup({})
    end)

    -- Test vim.pack availability
    print("vim.pack is available: " .. tostring(vim.pack ~= nil))
    local v = vim.version()
    print("Neovim version: " .. v.major .. "." .. v.minor .. "." .. v.patch)
  '';
in
{
  options.services.neovim-custom = {
    enable = lib.mkEnableOption "Enable custom Neovim build with vim.pack";
    version = lib.mkOption {
      type = lib.types.str;
      default = "v0.12.0-dev";
      description = "Neovim git tag or commit to build from source";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ neovim-custom ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      package = neovim-custom;  # Important: use custom build
    };

    xdg.configFile."nvim/init.lua".text = simple-init;
  };
}
```

### Config: `init.lua` with vim.pack

```lua
-- Add plugins using native vim.pack
vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
})

-- Configure plugins with safe pcall
pcall(function()
  require("fzf-lua").setup({})
end)
```

## Key Features
- Plugins installed from GitHub URLs directly
- Simple API: `vim.pack.add()`, `vim.pack.update()`, `vim.pack.del()`
- Plugins stored in `~/.local/share/nvim/site/pack/core/opt/` by default
- Use `:packadd` to load opt plugins, or move to `start/` for auto-loading
- Configuration: `:help vim.pack`

## Implementation Notes

### Important: `programs.neovim.package`
When using `programs.neovim`, you MUST set `package = neovim-custom` to use your custom build. Without this, Home Manager uses the default `pkgs.neovim` from nixpkgs.

### Plugin Loading
- vim.pack installs plugins to `opt/` directory by default (lazy loading)
- For auto-loading, move plugins to `start/` or use `:packadd`
- Plugins requiring build steps (like nvim-treesitter) need manual compilation

### SRI Hash Format
Nix uses SRI (Subresource Integrity) hash format. Convert with:
```bash
nix-prefetch-url --type sha256 "https://github.com/neovim/neovim/archive/<COMMIT>.tar.gz"
# Convert base64 to SRI if needed:
nix hash to-sri --type sha256 <base64-hash>
```

### Tested Version
- Commit: `c39d18ee93` (v0.12.0-dev)
- SHA256: `sha256-KOVSBncEUsn5ZqbkaDo5GhXWCoKqdZGij/KnLH5CoVI=`
- Working plugins: plenary.nvim, fzf-lua, gitsigns.nvim, lualine.nvim

## Sources
- https://neovim.io/doc/user/pack.html#_plugin-manager
- https://github.com/neovim/neovim/pull/34009 (vim.pack PR)
- https://www.jiholland.net/2026/01/14/neovim-with-native-plugin-manager/
- https://blog.rakshithnettar.com/the-new-native-package-manager-in-neovim
- https://github.com/neovim/packspec/issues/23 (post-install hooks discussion)
