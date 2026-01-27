{ config, lib, pkgs, ... }:

let
  cfg = config.services.neovim-nixvim;
in
{
  options.services.neovim-nixvim = {
    enable = lib.mkEnableOption "Enable Nixvim-based Neovim with kickstart.nvim configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ripgrep
      fd
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        gitsigns-nvim
        which-key-nvim
        telescope-nvim
        plenary-nvim
        telescope-fzf-native-nvim
        telescope-ui-select-nvim
        lazydev-nvim
        nvim-lspconfig
        mason-nvim
        mason-lspconfig-nvim
        mason-tool-installer-nvim
        fidget-nvim
        blink-cmp
        luasnip
        conform-nvim
        tokyonight-nvim
        todo-comments-nvim
        mini-nvim
        (nvim-treesitter.withPlugins (
          p: [ p.bash p.c p.diff p.html p.lua p.luadoc p.markdown p.markdown_inline p.query p.vim p.vimdoc ]
        ))
      ];

      extraPackages = with pkgs; [
        ripgrep
        fd
      ];
    };
  };
}
