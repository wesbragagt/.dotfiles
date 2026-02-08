{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.bitwarden;
in
{
  options.wesbragagt.bitwarden = {
    enable = mkEnableOption "Enable Bitwarden desktop application and SSH agent integration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bitwarden-desktop
    ];

    home.sessionVariables = {
      SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    systemd.user.services.bitwarden-desktop = {
      Unit = {
        Description = "Bitwarden Desktop Application";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Requires = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.bitwarden-desktop}/bin/bitwarden-desktop --ozone-platform=wayland --enable-features=UseOzonePlatform";
        Restart = "on-failure";
        PassEnvironment = [ "WAYLAND_DISPLAY" "DISPLAY" "NIXOS_OZONE_WL" "ELECTRON_OZONE_PLATFORM_HINT" ];
        Environment = [
          "NIXOS_OZONE_WL=1"
          "ELECTRON_OZONE_PLATFORM_HINT=auto"
        ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
