{
  description = "My first flake";

  # Every input to the system
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    home-manager.url = "github:nix-community/home-manager/release-23.05";

    # Make sure the versions between home-manager and nixpkgs are the same
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Tells the actual system that is to be built
  outputs = {self, nixpkgs, ...}: 
  let 
    lib = nixpkgs.lib; 
      in {
        nixosConfigurations = {
          nixos-tutorial = lib.nixosSystem {
            system = "x86_64-linux";
            modules = ["./configuration.nix"];
          };
    };
  };
}
