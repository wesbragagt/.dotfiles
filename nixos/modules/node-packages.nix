# This file can be regenerated using:
# cd modules
# nix-shell -p nodePackages.node2nix --command "node2nix -i node-packages.json -o node-packages.nix"

{ pkgs, ... }:

let
  nodePackages = import ./node-packages-generated.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    # npm packages from node-packages.json
    nodePackages.pnpm
    nodePackages.typescript
    nodePackages.tsx
    nodePackages.prettier
    nodePackages.eslint
  ];
}
