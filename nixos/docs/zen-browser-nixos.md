# Zen Browser on NixOS

## Setup

Add Zen Browser to NixOS using LunaCOLON3/zen-browser-nix flake:

```nix
# flake.nix
{
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
    nixosConfigurations.nixos-arm = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        { nixpkgs.overlays = [ zen-browser.overlay ]; }
        home-manager.nixosModules.home-manager
        {
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
```

```nix
# home.nix
{
  programs.zen-browser.enable = true;
}
```

## Verification

```bash
which zen
zen --version
```

## Tested Version

- Mozilla Zen 1.17.4b (aarch64-linux)

## Notes

- Requires `nixpkgs.overlays = [ zen-browser.overlay ];` to make package available
- Requires importing `zen-browser.homeManagerModules.zen-browser` in user home-manager config
- Warning: `nixpkgs.config` or `nixpkgs.overlays` with `home-manager.useGlobalPkgs` will soon be deprecated

## Source

- LunaCOLON3/zen-browser-nix: https://github.com/LunaCOLON3/zen-browser-nix
- Based on youwen5/zen-browser-flake: https://github.com/youwen5/zen-browser-flake
