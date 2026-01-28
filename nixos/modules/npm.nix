{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.npm;
in
{
  options.wesbragagt.npm = {
    enable = mkEnableOption "Enable npm global packages";
    
    globalPackages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of npm global packages to install from nixpkgs";
    };
  };

  config = mkIf cfg.enable {
    home.packages = map (pkg: 
      if hasAttr pkg pkgs.nodePackages then
        pkgs.nodePackages.${pkg}
      else
        throw "npm package '${pkg}' not found in nixpkgs nodePackages"
    ) cfg.globalPackages;
  };
}
