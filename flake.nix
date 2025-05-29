{
  description = "Basic user packages with neovim nightly";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, neovim-nightly-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ neovim-nightly-overlay.overlays.default ];
      };
      
      # Define packages once
      myPackages = [
        neovim-nightly-overlay.packages.${system}.default
        pkgs.gopls
        pkgs.pyright
        pkgs.lua-language-server
        pkgs.vscode-langservers-extracted
        pkgs.yaml-language-server
        pkgs.ansible-language-server
        pkgs.emmet-ls
        pkgs.typescript-language-server
        pkgs.terraform-ls
        pkgs.gcc
        pkgs.python3
        pkgs.luarocks
        pkgs.gnused

        pkgs.stow # Manage symlinks
        pkgs.zsh
        pkgs.zsh-autosuggestions
        pkgs.starship # Prompt for shell
        pkgs.git
        pkgs.ripgrep # Grep in Rust
        pkgs.fd # Fast file finder
        pkgs.fzf # Fuzzy finder
        pkgs.tmux # Terminal multiplexer
        pkgs.nodejs_24
        pkgs.fnm # Node.js version manager
        pkgs.unzip
        pkgs.curl
        pkgs.wget 
        pkgs.jq # JSON processor
        pkgs.zoxide # smart directory navigation
        pkgs.delta # syntax highlighting pager for git
        pkgs.gh # GitHub CLI
      ];
    in {
      packages.default = pkgs.buildEnv {
        name = "user-packages-${system}";
        paths = myPackages;
      };

      devShells.default = pkgs.mkShell {
        packages = myPackages;
      };
    }
    );
}
