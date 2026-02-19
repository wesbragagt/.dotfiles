{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.arm;

  # Host-side udev trigger script for disc insertion.
  # Docker runs as root so this is straightforward — no namespace workarounds needed.
  armTriggerScript = pkgs.writeShellScript "arm-trigger.sh" ''
    DEVNAME="$1"
    CONTAINER="automatic-ripping-machine"
    LOG="/var/log/arm-trigger.log"
    DATE="${pkgs.coreutils}/bin/date"
    DOCKER="${pkgs.docker}/bin/docker"
    UDEVADM="${pkgs.systemd}/bin/udevadm"

    echo "$($DATE) [ARM] Disc event on $DEVNAME" >> $LOG

    if ! $DOCKER exec "$CONTAINER" true 2>/dev/null; then
      echo "$($DATE) [ARM] Container not running, skipping" >> $LOG
      exit 0
    fi

    # Pass host udev disc type env vars into the container
    UDEV_ENVS=""
    for var in $($UDEVADM info --query=env "/dev/$DEVNAME" 2>/dev/null | ${pkgs.gnugrep}/bin/grep '^ID_CDROM\|^ID_FS_TYPE'); do
      UDEV_ENVS="$UDEV_ENVS -e $var"
    done

    echo "$($DATE) [ARM] Triggering rip for $DEVNAME" >> $LOG
    $DOCKER exec $UDEV_ENVS "$CONTAINER" /opt/arm/scripts/docker/docker_arm_wrapper.sh "$DEVNAME" &
  '';

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

    # Host-side udev rule to trigger ARM when a disc is inserted
    services.udev.extraRules = ''
      KERNEL=="sr[0-9]*", ACTION=="change", SUBSYSTEM=="block", ENV{ID_CDROM_MEDIA_STATE}!="blank", RUN+="${armTriggerScript} %k"
    '';

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
