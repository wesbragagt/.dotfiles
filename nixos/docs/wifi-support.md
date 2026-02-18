# WiFi Support for Laptops on NixOS

## Overview

NixOS supports WiFi through multiple approaches depending on your use case and hardware.

## Approaches

### 1. NetworkManager (Recommended for Desktop/Laptops)

**Best for**: Users who want GUI integration, easy network switching, and desktop environment integration

```nix
# Enable NetworkManager
networking.networkmanager.enable = true;

# Optional: Set WiFi backend (default: wpa_supplicant)
networking.networkmanager.wifi.backend = "wpa_supplicant";  # or "iwd"

# Power saving for laptops
networking.networkmanager.wifi.powersave = true;

# User needs to be in networkmanager group
users.users.<username>.extraGroups = [ "networkmanager" ];
```

**Usage**:
- `nmcli device wifi connect <SSID> password <PASS>`
- `nmtui` (terminal UI)
- Desktop environment network applets (GNOME, KDE, etc.)

**Backend Options**:
- `wpa_supplicant` (default) - Most compatible, mature
- `iwd` - Faster connection times, better for some chipsets

### 2. wpa_supplicant (Standalone)

**Best for**: Headless servers, minimal installations, or when you want declarative config

```nix
networking.wireless.enable = true;

# Declarative network configuration
networking.wireless.networks = {
  "mySSID" = {
    psk = "myPassword";  # Stored in plaintext in nix store
    priority = 10;
  };
  "hidden-network" = {
    hidden = true;
    psk = "myPassword";
  };
  "public-wifi" = {};
};

# User control for wpa_gui
networking.wireless.userControlled.enable = true;

# User must be in wheel group
users.users.<username>.extraGroups = [ "wheel" ];
```

**Better security** (pskRaw instead of plaintext):
```bash
# Generate PSK hash
wpa_passphrase ESSID PSK
```

```nix
networking.wireless.networks."mySSID".pskRaw = "dca6d6ed41f4ab5a984c9f55f6f66d4efdc720ebf66959810f4329bb391c5435";
```

**Usage**:
- `wpa_cli` (command line)
- `wpa_gui` (graphical, requires userControlled.enable)

**Important** (NixOS 25.11+): Cannot use `networking.wireless.networks` with NetworkManager unless you mark interfaces as `unmanaged`.

### 3. iwd (iNet Wireless Daemon)

**Best for**: Modern systems, faster connections, standalone without NetworkManager

```nix
networking.wireless.iwd.enable = true;

# Configure iwd settings
networking.wireless.iwd.settings = {
  Network = {
    EnableIPv6 = true;
  };
  Settings = {
    AutoConnect = true;
  };
};
```

**Usage**:
- `iwctl` (interactive command line)

**Enterprise networks** (eduroam, WPA2-Enterprise):
Create `/var/lib/iwd/eduroam.8021x`:
```ini
[Security]
EAP-Method=PEAP
EAP-Identity=user@domain.edu
EAP-PEAP-CACert=/var/lib/iwd/ca.pem
EAP-PEAP-ServerDomainMask=*.domain.edu
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=username
EAP-PEAP-Phase2-Password=password

[Settings]
AutoConnect=true
```

## Hardware Requirements

### Kernel Modules

Add to `boot.kernelModules`:

```nix
# Intel wireless cards
boot.kernelModules = [ "iwlwifi" ];

# Atheros cards
boot.kernelModules = [ "ath9k" ];

# Broadcom cards (may need proprietary drivers)
boot.kernelModules = [ "b43" ];
```

### Firmware

**Essential for Intel wireless cards**:

```nix
# Enable redistributable firmware (includes linux-firmware)
hardware.enableRedistributableFirmware = true;

# OR enable all firmware (includes some unfree)
hardware.enableAllFirmware = true;
nixpkgs.config.allowUnfree = true;  # Required for enableAllFirmware

# Enable wireless regulatory database
hardware.wirelessRegulatoryDatabase = true;
```

**Common firmware packages** (automatically included by `enableRedistributableFirmware`):
- `linux-firmware` - Intel iwlwifi, Realtek, Atheros, etc.
- `intel2200BGFirmware` - Older Intel cards
- `rtl8192su-firmware` - Realtek USB adapters

### Intel Wireless Cards

Supported Intel cards (requires iwlwifi + firmware):
- Intel Wireless 7260, 7265
- Intel Wireless 8260, 8265, 9260
- Intel Wi-Fi 6 AX200, AX201, AX210
- Intel Wi-Fi 6E AX211, AX210

Common issues:
- Firmware not found → Enable `hardware.enableRedistributableFirmware = true`
- Connection drops → Try switching backend to iwd
- Interface not showing up → Check dmesg for firmware errors

## Troubleshooting

### Check if WiFi is detected

```bash
# List network interfaces
ip link

# List wireless interfaces
ls /sys/class/net | grep -E '^wl'
ls /sys/class/ieee80211

# Check if wireless kernel module is loaded
lsmod | grep -E 'wifi|iwl|brcm|ath'

# Check PCI/USB devices for wireless hardware
lspci | grep -i network  # For PCI cards
lsusb | grep -i wireless # For USB adapters
```

### Check firmware status

```bash
# Check kernel logs for firmware errors
sudo dmesg | grep -i firmware

# Check if driver found hardware
sudo dmesg | grep -i iwlwifi
```

### Check rfkill (hardware switch)

```bash
rfkill list

# Unblock if needed
sudo rfkill unblock wifi
```

### NetworkManager issues

```bash
# Check NetworkManager status
systemctl status NetworkManager

# List devices
nmcli device status

# Scan for networks
nmcli device wifi list
```

### Common Issues

**1. WiFi interface not appearing**
- Check firmware is installed: `hardware.enableRedistributableFirmware = true`
- Rebuild and reboot
- Check dmesg for firmware load errors

**2. Can see networks but can't connect**
- Try switching WiFi backend: `networking.networkmanager.wifi.backend = "iwd"`
- Check RF kill isn't blocking: `rfkill list`
- Verify password/credentials

**3. Connection drops frequently**
- Try different backend (wpa_supplicant vs iwd)
- Check power saving settings
- Update kernel: `boot.kernelPackages = pkgs.linuxPackages_latest`

**4. Broadcom cards**
- May need proprietary driver: `boot.kernelModules = [ "wl" ]`
- Enable `hardware.enableAllFirmware = true`
- May need to blacklist conflicting modules: `boot.blacklistedKernelModules = [ "brcmfmac" ]`

## Configuration Examples

### Minimal Laptop WiFi (NetworkManager)

```nix
# hardware-configuration.nix
{
  boot.kernelModules = [ "iwlwifi" ];
  hardware.enableRedistributableFirmware = true;
  hardware.wirelessRegulatoryDatabase = true;
}

# configuration.nix
{
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;
  users.users.wesbragagt.extraGroups = [ "networkmanager" ];
}
```

### Minimal Laptop WiFi (iwd + NetworkManager)

```nix
{
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # iwd configuration
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
    Settings = {
      AutoConnect = true;
    };
  };
}
```

### Headless/Server (wpa_supplicant)

```nix
{
  networking.wireless.enable = true;
  networking.wireless.networks = {
    "HomeNetwork" = {
      pskRaw = "dca6d6ed41f4ab5a984c9f55f6f66d4efdc720ebf66959810f4329bb391c5435";
      priority = 20;
    };
    "GuestNetwork" = {};
  };
}
```

### MacBook Pro 2012 (Broadcom 4331)

**Issue**: Broadcom 4331 detected but firmware missing:

```
b43-phy0: Broadcom 4331 WLAN found (core revision 29)
b43-phy0 ERROR: Firmware file "b43/ucode29_mimo.fw" not found
```

**Solution**: Add to configuration:

```nix
# hardware-configuration.nix
{
  boot.kernelModules = [ "b43" "b43legacy" ];
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;  # Required for Broadcom firmware
  hardware.wirelessRegulatoryDatabase = true;
}

# configuration.nix
{
  networking.networkmanager.enable = true;
  users.users.<username>.extraGroups = [ "networkmanager" ];
}
```

**If b43 driver doesn't work**, try the proprietary wl driver:

```nix
{
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.blacklistedKernelModules = [ "b43" "b43legacy" "ssb" "bcma" ];

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
}
```

**Verification**:
```bash
# Check if interface appears
ip link | grep -E 'wl|wlan'
ls /sys/class/net | grep wl

# Check for firmware errors
sudo dmesg | grep -i b43
```

## Sources

- [NixOS Wiki - NetworkManager](https://wiki.nixos.org/wiki/NetworkManager)
- [NixOS Wiki - wpa_supplicant](https://nixos.wiki/wiki/Wpa_supplicant)
- [NixOS Wiki - iwd](https://wiki.nixos.org/wiki/Iwd)
- [NixOS Manual - Wireless Networks](https://nlewo.github.io/nixos-manual-sphinx/configuration/wireless.xml.html)
- [NixOS as a Daily Driver - Enabling Wi-Fi](https://jakegoldsborough.com/blog/2025/nixos-daily-driver-9/)
- [Reddit - WiFi: Network manager vs wpa_supplicant](https://www.reddit.com/r/NixOS/comments/ikjpyb/wifi_network_manager_vs_wpa_supplicant/)
- [Kernel Documentation - b43 firmware](https://wireless.docs.kernel.org/en/latest/en/users/drivers/b43/developers.html)
- [b43 firmware download instructions](https://wireless.docs.kernel.org/en/latest/en/users/drivers/b43/developers.html)
