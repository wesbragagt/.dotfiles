{ config, lib, ... }:

with lib;

let
  cfg = config.wesbragagt.wifi;
in
{
  options.wesbragagt.wifi = {
    enable = mkEnableOption "Enable WiFi firmware and regulatory support";
    enableBroadcom = mkEnableOption "Enable proprietary Broadcom wl driver (for BCM4331 and similar)";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      hardware.enableAllFirmware = true;
      hardware.wirelessRegulatoryDatabase = true;
    })
    (mkIf cfg.enableBroadcom {
      nixpkgs.config.permittedInsecurePackages = [ "broadcom-sta-6.30.223.271-59-6.18.8" ];
      boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
      boot.kernelModules = [ "wl" ];
    })
  ];
}
