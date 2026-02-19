{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.arm;

  composeFile = pkgs.writeText "docker-compose.yml" ''
    version: '3.8'

    services:
      arm:
        container_name: automatic-ripping-machine
        image: automaticrippingmachine/automatic-ripping-machine:latest
        restart: unless-stopped
        privileged: true
        group_add:
          - cdrom
        devices:
          - '/dev/sr0:/dev/sr0'
        ports:
          - "${toString cfg.port}:8080"
        volumes:
          - ${cfg.dataDir}/arm-home:/home/arm
          - ${cfg.dataDir}/arm-media:/home/arm/media
          - ${cfg.dataDir}/arm-logs:/home/arm/logs
          - ${cfg.dataDir}/arm-music:/home/arm/music
          - ${cfg.dataDir}/arm-config:/etc/arm/config
        environment:
          - ARM_UID=${toString cfg.uid}
          - ARM_GID=${toString cfg.gid}
          - TZ=${config.time.timeZone}
  '';
in
{
  options.wesbragagt.arm = {
    enable = mkEnableOption "Enable Automatic Ripping Machine (ARM)";

    dataDir = mkOption {
      type = types.path;
      default = "/home/wesbragagt/arm-compose";
      description = "Directory for ARM data and compose file";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Host port for ARM web UI";
    };

    uid = mkOption {
      type = types.int;
      default = 1000;
      description = "UID for the arm user inside the container";
    };

    gid = mkOption {
      type = types.int;
      default = 100;
      description = "GID for the arm user inside the container";
    };
  };

  config = mkIf cfg.enable {
    # ARM requires Docker with privileged access for optical drive ioctl

    # Open the ARM web UI port
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # Systemd service to set up directories and run docker compose
    systemd.services.arm = {
      description = "Automatic Ripping Machine (ARM)";
      after = [ "network-online.target" "docker.service" ];
      wants = [ "network-online.target" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.docker pkgs.docker-compose pkgs.coreutils ];

      preStart = ''
        # Create data directories if they don't exist
        mkdir -p ${cfg.dataDir}/{arm-home,arm-media,arm-logs,arm-music,arm-config}
        mkdir -p ${cfg.dataDir}/arm-home/{db,logs,media,music,.MakeMKV}
        mkdir -p ${cfg.dataDir}/arm-media/{completed,movies,raw,transcode}
        mkdir -p ${cfg.dataDir}/arm-logs/progress

        # Copy compose file
        cp ${composeFile} ${cfg.dataDir}/docker-compose.yml

        # Fix ownership — no namespace remapping with Docker
        chown -R ${toString cfg.uid}:${toString cfg.gid} ${cfg.dataDir}/arm-home ${cfg.dataDir}/arm-media ${cfg.dataDir}/arm-logs ${cfg.dataDir}/arm-music ${cfg.dataDir}/arm-config
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${cfg.dataDir}/docker-compose.yml up -d";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f ${cfg.dataDir}/docker-compose.yml down";
      };
    };
  };
}
