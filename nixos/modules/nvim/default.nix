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
      package = neovim-custom;
    };

    xdg.configFile."nvim/init.lua".text = simple-init.text;
  };
}
