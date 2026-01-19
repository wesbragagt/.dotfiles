## Problem

Need reliable remote access to Raspberry Pi. Local mDNS (.local) not working due to router blocking multicast between WiFi and wired segments.

## Plan

Install Tailscale for secure mesh networking with MagicDNS hostname resolution.

## Solution

```sh
# Fix corrupted apt cache (if needed)
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Authenticate and set hostname
sudo tailscale up --hostname=raspi

# Or change hostname later
sudo tailscale set --hostname=raspi
```

### Access
```sh
ssh raspi
# or
ssh raspi.tail585d38.ts.net
```

### Notes
- If hostname shows as `raspi-1`, remove old device from [Tailscale admin](https://login.tailscale.com/admin/machines)
- Tailscale IP: 100.112.64.22
