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
    elephant = {
      url = "github:abenz1267/elephant";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, elephant, ... }: {
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
            extraSpecialArgs = { inherit elephant; };
            users.wesbragagt = { config, pkgs, lib, elephant, ... }: {
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
