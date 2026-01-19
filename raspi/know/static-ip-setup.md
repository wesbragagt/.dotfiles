## Problem

Need to configure static IP on Raspberry Pi Zero 2W to ensure consistent network address (192.168.68.87).

## Plan

Raspberry Pi OS uses NetworkManager with netplan. Configured static IP via nmcli instead of deprecated dhcpcd.conf.

## Solution

```sh
# Set static IP configuration
sudo nmcli connection modify 'netplan-wlan0-lanbeforetime' \
  ipv4.method manual \
  ipv4.addresses 192.168.68.87/22 \
  ipv4.gateway 192.168.68.1 \
  ipv4.dns '192.168.68.1 8.8.8.8'

# Apply changes
sudo nmcli connection down 'netplan-wlan0-lanbeforetime'
sudo nmcli connection up 'netplan-wlan0-lanbeforetime'

# Verify
nmcli connection show 'netplan-wlan0-lanbeforetime' | grep ipv4
```

### Configuration Details
- Interface: wlan0
- Static IP: 192.168.68.87/22
- Gateway: 192.168.68.1
- DNS: 192.168.68.1, 8.8.8.8
