{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.podman;
in
{
  options.wesbragagt.podman = {
    enable = mkEnableOption "Enable Podman container runtime";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      podman
      podman-compose
    ];

    # Podman configuration
    home.file.".config/containers/registries.conf".text = ''
      [registries.search]
      registries = ['docker.io']

      [registries.block]
      registries = []
    '';

    home.file.".config/containers/policy.json".text = ''
      {
        "default": [
          {
            "type": "insecureAcceptAnything"
          }
        ],
        "transports": {
          "docker-daemon": {
            "": [{"type":"insecureAcceptAnything"}]
          }
        }
      }
    '';
  };
}
