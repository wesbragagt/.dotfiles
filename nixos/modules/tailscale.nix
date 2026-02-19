{ config, lib, ... }:

with lib;

let
  cfg = config.wesbragagt.tailscale;
in
{
  options.wesbragagt.tailscale = {
    enable = mkEnableOption "Enable Tailscale VPN";
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
    networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
