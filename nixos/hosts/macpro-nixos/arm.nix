{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.arm;

  # Script that runs on the host when a disc is inserted, triggers ARM inside the container.
  # udev runs as root, but podman rootless containers belong to wesbragagt,
  # so we use runuser to exec into the container as the correct user.
  armTriggerScript = pkgs.writeShellScript "arm-trigger.sh" ''
    DEVNAME="$1"
    CONTAINER="automatic-ripping-machine"
    LOG="/var/log/arm-trigger.log"

    echo "$(date) [ARM] Disc event on $DEVNAME" >> $LOG

    # Run podman exec as wesbragagt since the container is rootless
    if ! ${pkgs.util-linux}/bin/runuser -u wesbragagt -- ${pkgs.podman}/bin/podman exec "$CONTAINER" true 2>/dev/null; then
      echo "$(date) [ARM] Container not running, skipping" >> $LOG
      exit 0
    fi

    echo "$(date) [ARM] Triggering rip for $DEVNAME" >> $LOG
    ${pkgs.util-linux}/bin/runuser -u wesbragagt -- ${pkgs.podman}/bin/podman exec "$CONTAINER" /opt/arm/scripts/docker/docker_arm_wrapper.sh "$DEVNAME" &
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
    # Open the ARM web UI port
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # Host-side udev rule to trigger ARM when a disc is inserted
    # Podman rootless doesn't forward kernel uevents into the container,
    # so we need the host to notify the container via podman exec.
    services.udev.extraRules = ''
      KERNEL=="sr[0-9]*", ACTION=="change", SUBSYSTEM=="block", ENV{ID_CDROM_MEDIA_STATE}!="blank", RUN+="${armTriggerScript} %k"
    '';

    # Systemd service to set up ARM directories (runs as root for chown)
    systemd.services.arm-setup = {
      description = "Automatic Ripping Machine (ARM) - Directory Setup";
      wantedBy = [ "multi-user.target" ];
      before = [ "arm.service" ];

      path = [ pkgs.coreutils pkgs.podman ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        # Create data directories if they don't exist
        mkdir -p ${cfg.dataDir}/{arm-home,arm-media,arm-logs,arm-music,arm-config}
        mkdir -p ${cfg.dataDir}/arm-home/{db,logs,media,music,.MakeMKV}
        mkdir -p ${cfg.dataDir}/arm-media/{completed,movies,raw,transcode}
        mkdir -p ${cfg.dataDir}/arm-logs/progress

        # Copy compose file
        cp ${composeFile} ${cfg.dataDir}/docker-compose.yml

        # First ensure host user owns everything so podman unshare can operate
        chown -R ${toString cfg.uid}:${toString cfg.gid} ${cfg.dataDir}

        # Then remap ownership for podman rootless user namespace.
        # podman unshare runs in the user namespace where host UID 1000 = container UID 0.
        # We chown to 1000:100 inside the namespace so container sees files as 1000:100.
        ${pkgs.util-linux}/bin/runuser -u wesbragagt -- ${pkgs.podman}/bin/podman unshare chown -R ${toString cfg.uid}:${toString cfg.gid} ${cfg.dataDir}/arm-home ${cfg.dataDir}/arm-media ${cfg.dataDir}/arm-logs ${cfg.dataDir}/arm-music ${cfg.dataDir}/arm-config
      '';
    };

    # Systemd service to run podman compose (runs as wesbragagt)
    systemd.services.arm = {
      description = "Automatic Ripping Machine (ARM)";
      after = [ "network-online.target" "podman.service" "arm-setup.service" ];
      wants = [ "network-online.target" "podman.service" ];
      requires = [ "arm-setup.service" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.podman pkgs.podman-compose ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "wesbragagt";
        Group = "users";
        ExecStart = "${pkgs.podman-compose}/bin/podman-compose -f ${cfg.dataDir}/docker-compose.yml up -d";
        ExecStop = "${pkgs.podman-compose}/bin/podman-compose -f ${cfg.dataDir}/docker-compose.yml down";
      };
    };
  };
}
