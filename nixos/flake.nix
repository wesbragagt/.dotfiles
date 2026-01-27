{
  description = "NixOS configuration with home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:LunaCOLON3/zen-browser-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, agenix, ... }: {
    nixosConfigurations.nixos-arm = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit agenix; };
      modules = [
        ./configuration.nix
        {
          nixpkgs.overlays = [ zen-browser.overlay ];
          nixpkgs.config.allowUnsupportedSystem = true;
        }
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        {
          nix.settings = {
            extra-substituters = [
              "https://walker.cachix.org"
              "https://walker-git.cachix.org"
            ];
            extra-trusted-public-keys = [
              "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
              "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
            ];
          };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.wesbragagt = { config, pkgs, lib, ... }: {
            imports = [
              ./home.nix
              zen-browser.homeManagerModules.zen-browser
            ];
          };
        }
      ];
    };
  };
}
