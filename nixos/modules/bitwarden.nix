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
      bitwarden-cli
    ];

    home.sessionVariables = {
      SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
    };
  };
}
