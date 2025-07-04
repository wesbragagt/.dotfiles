{
  description = "NixOS configuration with home-manager and Hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, neovim-nightly-overlay, flake-utils }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            hyprland.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.user = import ./home.nix;
            }
          ];
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ neovim-nightly-overlay.overlays.default ];
        };
        
        # Define packages once
        myPackages = [
          neovim-nightly-overlay.packages.${system}.default
          pkgs.gcc
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
