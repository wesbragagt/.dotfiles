{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./arm.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = "macpro-nixos";
  networking.networkmanager.enable = true;

  # WiFi - generic firmware + Broadcom proprietary driver
  wesbragagt.wifi.enable = true;
  wesbragagt.wifi.enableBroadcom = true;

  # Time zone
  time.timeZone = "America/Chicago";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # User
  users.users.wesbragagt = {
    isNormalUser = true;
    description = "wesbragagt";
    extraGroups = [ "networkmanager" "wheel" "video" "podman" ];
    shell = pkgs.zsh;
  };

  # Zsh
  programs.zsh.enable = true;

  # Hyprland (Wayland)
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Greetd for autologin (replaces getty on tty1)
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "uwsm start hyprland-uwsm.desktop";
        user = "wesbragagt";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --asterisks --remember --remember-user-session --time --cmd 'uwsm start hyprland-uwsm.desktop'";
        user = "greeter";
      };
    };
  };

  # Disable getty on tty1 (greetd takes over)
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Laptop power management - don't suspend on lid close
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";

  # Tailscale VPN
  wesbragagt.tailscale.enable = true;

  # Automatic Ripping Machine
  wesbragagt.arm.enable = true;

  # Podman container runtime
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Keyd - Caps Lock: hold = Ctrl, tap = Esc
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = { 
            capslock = "overload(control, esc)";
          };
        };
      };
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    git-lfs
  ];

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
