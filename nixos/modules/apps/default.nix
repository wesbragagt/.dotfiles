{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./browsers.nix
    ./communication.nix
    ./media.nix
    ./office.nix
  ];
}
