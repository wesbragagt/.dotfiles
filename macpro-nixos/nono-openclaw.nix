{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.nono-openclaw;

  nonoVersion = "0.29.1";
  nonoSrc = pkgs.fetchurl {
    url = "https://github.com/always-further/nono/releases/download/v${nonoVersion}/nono-v${nonoVersion}-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "0ryk5p9zgxb7cgg4xfwpb42xlvjw1hk64cv6c8rc7ywwz85xsa4c";
  };

  nonoBin = pkgs.stdenv.mkDerivation {
    name = "nono-${nonoVersion}";
    src = nonoSrc;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      tar xzf $src -C $out/bin --strip-components=1
      chmod +x $out/bin/nono
    '';
  };

  nonoProfile = pkgs.writeText "openclaw-server.json" (builtins.toJSON {
    meta = {
      name = "openclaw-server";
      version = "1.0.0";
      description = "OpenClaw server manager with nono sandbox and proxy-injected secrets";
    };
    workdir = { access = "readwrite"; };
    filesystem = {
      allow = [
        cfg.stateDir
        "$HOME/.config/openclaw"
        "$HOME/.local"
        "$TMPDIR/openclaw-$UID"
        "$WORKDIR"
        "/etc"
        "/var"
        "/run"
        "/tmp"
        "/nix"
        "/usr"
        "/bin"
        "/sbin"
      ];
      read = [
        "$HOME/.ssh"
        "$HOME/.gitconfig"
      ];
    };
    network = {
      block = false;
      credentials = [ "openrouter" "telegram" ];
      custom_credentials = {
        openrouter = {
          upstream = "https://openrouter.ai/api/v1";
          credential_key = "openrouter_api_key";
          inject_header = "Authorization";
          credential_format = "Bearer {}";
        };
        telegram = {
          upstream = "https://api.telegram.org";
          credential_key = "telegram_bot_token";
          inject_mode = "url_path";
          path_pattern = "/bot{}/";
          path_replacement = "/bot{}/";
        };
      };
    };
  });

  sopsBridgeScript = pkgs.writeShellScriptBin "nono-sops-bridge" ''
    set -euo pipefail

    export SOPS_AGE_KEY_FILE=${cfg.ageKeyFile}

    if ! SECRETS=$(${pkgs.sops}/bin/sops --config ${cfg.sopsConfigFile} -d ${cfg.secretsFile} 2>/dev/null); then
      echo "nono-sops-bridge: failed to decrypt ${cfg.secretsFile}" >&2
      exit 1
    fi

    openrouter_key=$(echo "$SECRETS" | ${pkgs.yq-go}/bin/yq -e '.openrouter_api_key')
    telegram_token=$(echo "$SECRETS" | ${pkgs.yq-go}/bin/yq -e '.telegram_bot_token')

    echo -n "$openrouter_key" | ${pkgs.libsecret}/bin/secret-tool store \
      --label="nono: openrouter_api_key" \
      service nono username openrouter_api_key target default

    echo -n "$telegram_token" | ${pkgs.libsecret}/bin/secret-tool store \
      --label="nono: telegram_bot_token" \
      service nono username telegram_bot_token target default

    echo "nono-sops-bridge: secrets loaded into keyring"
  '';

  openclawSandboxed = pkgs.writeShellScriptBin "openclaw-sandboxed" ''
    set -euo pipefail

    ${sopsBridgeScript}/bin/nono-sops-bridge

    exec ${nonoBin}/bin/nono run \
      --profile ${nonoProfile} \
      --listen-port ${toString cfg.gatewayPort} \
      --allow-cwd \
      --credential openrouter \
      --credential telegram \
      -- "$@"
  '';
in
{
  options.wesbragagt.nono-openclaw = {
    enable = mkEnableOption "nono sandbox with OpenClaw, sops secret proxy injection, and server management";

    secretsFile = mkOption {
      type = types.path;
      default = "/home/wesbragagt/.config/nono/secrets/secrets.yaml";
      description = "Path to sops-encrypted secrets file";
    };

    sopsConfigFile = mkOption {
      type = types.path;
      default = "/home/wesbragagt/.config/nono/secrets/.sops.yaml";
      description = "Path to .sops.yaml config";
    };

    ageKeyFile = mkOption {
      type = types.path;
      default = "/home/wesbragagt/age.txt";
      description = "Path to age private key for sops decryption";
    };

    stateDir = mkOption {
      type = types.str;
      default = "~/.openclaw";
      description = "OpenClaw state directory";
    };

    gatewayPort = mkOption {
      type = types.int;
      default = 18789;
      description = "Port for OpenClaw gateway WebSocket";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.openclaw or (pkgs.callPackage ./packages/openclaw.nix { });
      defaultText = "pkgs.openclaw";
      description = "OpenClaw package to use";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      nonoBin
      openclawSandboxed
      sopsBridgeScript
      cfg.package
      pkgs.age
      pkgs.sops
      pkgs.yq-go
      pkgs.libsecret
      pkgs.gnome-keyring
    ];

    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = cfg.ageKeyFile;
    };

    xdg.configFile = {
      "nono/profiles/openclaw-server.json".source = nonoProfile;
    };

    systemd.user.services.openclaw-gateway = {
      Unit = {
        Description = "OpenClaw Gateway (nono sandboxed)";
        After = [ "network.target" "dbus.service" ];
      };

      Service = {
        Type = "simple";
        ExecStartPre = "${sopsBridgeScript}/bin/nono-sops-bridge";
        ExecStart = "${nonoBin}/bin/nono run --profile ${nonoProfile} --listen-port ${toString cfg.gatewayPort} --allow-cwd --credential openrouter --credential telegram -- ${cfg.package}/bin/openclaw gateway start --foreground";
        Restart = "always";
        RestartSec = 10;

        Environment = [
          "SOPS_AGE_KEY_FILE=${cfg.ageKeyFile}"
          "PATH=/run/wrappers/bin:/run/current-system/sw/bin:%h/.nix-profile/bin:/usr/bin:/bin"
        ];
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
