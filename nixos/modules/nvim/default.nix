{ config, lib, pkgs, ... }:

let
  # Custom Neovim v0.12.0-dev build
  neovim-dev = pkgs.neovim-unwrapped.overrideAttrs (oldAttrs: {
    version = "v0.12.0-dev";
    src = pkgs.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "c39d18ee93";
      sha256 = "sha256-KOVSBncEUsn5ZqbkaDo5GhXWCoKqdZGij/KnLH5CoVI=";
    };
  });

  # Get all required plugins from nixpkgs
  inherit (pkgs.vimPlugins)
    telescope-nvim
    telescope-fzf-native-nvim
    telescope-ui-select-nvim
    nvim-lspconfig
    fidget-nvim
    gitsigns-nvim
    which-key-nvim
    conform-nvim
    kanagawa-nvim
    todo-comments-nvim
    nvim-treesitter
    plenary-nvim
    lazydev-nvim
    blink-cmp
    luasnip
    mini-nvim;
in
{
  config = {
    home.packages = [ neovim-dev ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      package = neovim-dev;
      plugins = with pkgs.vimPlugins; [
        gitsigns-nvim
        which-key-nvim
        telescope-nvim
        plenary-nvim
        telescope-fzf-native-nvim
        telescope-ui-select-nvim
        lazydev-nvim
        nvim-lspconfig
        fidget-nvim
        blink-cmp
        luasnip
        conform-nvim
        kanagawa-nvim
        todo-comments-nvim
        mini-nvim
        (nvim-treesitter.withPlugins (
          p: [ p.bash p.c p.diff p.html p.lua p.luadoc p.markdown p.markdown_inline p.query p.vim p.vimdoc ]
        ))
      ];

      extraPackages = with pkgs; [
        ripgrep
        fd
        lua-language-server
        nodePackages.typescript-language-server
        nodePackages.pyright
      ];

      initLua = lib.strings.fileContents ./kickstart-init.lua;
    };
  };
}
