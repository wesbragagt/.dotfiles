{
  description = "Basic user packages with neovim nightly";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, neovim-nightly-overlay }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
      };
      
      # Define packages once
      myPackages = [
        neovim-nightly-overlay.packages.${system}.default
        pkgs.stow
        pkgs.zsh
        pkgs.zsh-autosuggestions
        pkgs.starship
        pkgs.git
        pkgs.ripgrep
        pkgs.fd
        pkgs.fzf
        pkgs.tmux
        pkgs.nodejs_24
      ];
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "user-packages";
        paths = myPackages;
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = myPackages;
      };
    };
}
