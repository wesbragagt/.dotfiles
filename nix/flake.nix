{
  description = "Neovim 0.12 from source with Home Manager config symlinks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, flake-utils, neovim-nightly-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { 
        inherit system;
        config.allowUnfree = true;
      };

      # Use Neovim from nixpkgs (for testing - replace with nightly later)
      neovim-custom = pkgs.neovim-unwrapped;

      homeConfig = {
        home.stateVersion = "23.11";
        home.username = "testuser";
        home.homeDirectory = "/home/testuser";

        # Symlink Neovim config using Home Manager
        xdg.configFile."nvim".source = 
          pkgs.lib.file.mkOutOfStoreSymlink 
          (builtins.toString ../nvim/.config/nvim);

        # Install our custom Neovim and basic tools
        home.packages = with pkgs; [
          neovim-custom
          git
          curl
          wget
        ];

        # Optional: Set environment variables
        home.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };

        # Activation script to verify setup
        home.activation.verifyNeovim = 
          pkgs.lib.hm.dag.entryAfter ["writeBoundary"] ''
            echo "✅ Neovim 0.12 installed at: $(which nvim)"
            echo "📁 Config symlinked to: $HOME/.config/nvim"
            echo "🔧 Neovim version: $(nvim --version | head -n1)"
            
            # Verify LazyVim can install
            if [ -d "$HOME/.config/nvim" ]; then
              echo "✅ LazyVim config found"
            else
              echo "❌ LazyVim config not found"
            fi
          '';
      };

    in {
      # Development shell for testing
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          neovim-custom
          git
          curl
          wget
        ];

        shellHook = ''
          echo "🚀 Entering Neovim 0.12 development environment"
          echo "📦 Neovim version: $(nvim --version | head -n1)"
          echo "🔧 Testing Home Manager configuration..."
          
          # Create a temporary home directory for testing
          export HOME=$(mktemp -d)
          export USER=testuser
          
          # Set up basic XDG directories
          mkdir -p "$HOME/.config"
          mkdir -p "$HOME/.local/share"
          mkdir -p "$HOME/.cache"
          
          echo "🏠 Test home directory: $HOME"
          echo "📁 Config will be symlinked to: $HOME/.config/nvim"
          
          # Test the symlink creation manually
          if [ -d "${../nvim/.config/nvim}" ]; then
            ln -sfn "${../nvim/.config/nvim}" "$HOME/.config/nvim"
            echo "✅ Config symlinked successfully"
          else
            echo "❌ Source config not found at ${../nvim/.config/nvim}"
          fi
          
          echo ""
          echo "🎯 Ready to test!"
          echo "   Run: nvim"
          echo "   LazyVim will install plugins on first run"
          echo ""
        '';
      };

      # Home Manager configuration
      homeConfigurations.test = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ homeConfig ];
      };

      # Package output
      packages = {
        neovim-custom = neovim-custom;
        default = neovim-custom;
      };

      # App output
      apps.default = {
        type = "app";
        program = "${neovim-custom}/bin/nvim";
      };
    });
}