{ config, pkgs, agenix, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";

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
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.zsh;
  };

  # Zsh
  programs.zsh.enable = true;

  # Hyprland
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

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    git-lfs
    agenix.packages.${pkgs.system}.default
  ];

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };

  # Agenix secrets
  age.identityPaths = [
    "/home/wesbragagt/.ssh/nixos_id_ed25519"
  ];

  age.secrets.test-secret = {
    file = ./secrets/test-secret.age;
    mode = "600";
    owner = "root";
    group = "root";
  };

  # Example: systemd service that reads secret at startup
  systemd.services.test-secret-reader = {
    description = "Read test secret on startup";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo \"Secret content: $(cat ${config.age.secrets.test-secret.path})\"'";
    };
  };



  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "24.11";
}
