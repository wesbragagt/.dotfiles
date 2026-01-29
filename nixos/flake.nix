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
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, ... }: {
    nixosConfigurations.vm-aarch64 = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.hostPlatform = "aarch64-linux";
          nixpkgs.config = {
            allowUnsupportedSystem = true;
            allowUnfree = true;
          };
          nixpkgs.overlays = [ zen-browser.overlay ];
        }
        ./hosts/vm-aarch64/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.wesbragagt = { config, pkgs, lib, ... }: {
              imports = [
                ./home.nix
                zen-browser.homeManagerModules.zen-browser
              ];
            };
          };
        }
      ];
    };
  };
}
