# Tailscale Setup on NixOS

## Research Sources
- [Official NixOS Wiki - Tailscale](https://wiki.nixos.org/wiki/Tailscale)
- [NixOS Wiki - Tailscale](https://nixos.wiki/wiki/Tailscale)
- [MyNixOS - services.tailscale.useRoutingFeatures](https://mynixos.com/nixpkgs/option/services.tailscale.useRoutingFeatures)
- [Tailscale Support for NixOS - Martin Baillie](https://martin.baillie.id/wrote/tailscale-support-for-nixos/)
- [Using Tailscale exit nodes on NixOS](https://msfjarvis.dev/notes/using-tailscale-exit-nodes-nixos/)
- [Tailscale is magic; even more so with NixOS](https://fzakaria.com/2020/09/17/tailscale-is-magic-even-more-so-with-nixos)
- [NixOS and Tailscale - Hanckmann](https://hanckmann.com/posts/20230304-nixos-and-tailscale/)

## Basic Setup

### Configuration (configuration.nix)

```nix
services.tailscale = {
  enable = true;
  # Optional: authKeyFile = "/run/secrets/tailscale_key";
};
```

### Login

After enabling and rebuilding:

```bash
sudo tailscale up
# OR with auth key (from https://login.tailscale.com/admin/machines/new-linux)
sudo tailscale up --auth-key=tskey-xxx
```

## Firewall Configuration

### Option 1: Trust Tailscale Interface (Recommended)

```nix
networking.firewall.trustedInterfaces = [ "tailscale0" ];
```

This trusts all traffic from Tailscale network, bypassing firewall rules for `tailscale0` interface.

### Option 2: Allow Specific UDP Port

```nix
networking.firewall.allowedUDPPorts = [ 41641 ]; # default port
# OR with reference to config
networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
```

## Routing Features (Exit Nodes, Subnet Routers)

### Configuration

```nix
services.tailscale.useRoutingFeatures = "server"; # or "client" or "both"
```

Values:
- `"none"` - No routing features (default)
- `"client"` - Can use exit nodes/subnet routers
- `"server"` - Can act as exit node/subnet router
- `"both"` - Both client and server functionality

### For Exit Node Server

```nix
services.tailscale.useRoutingFeatures = "server";
```

Then run:

```bash
sudo tailscale up --advertise-exit-node
```

### For Exit Node Client

```nix
services.tailscale.useRoutingFeatures = "client";
```

Then run:

```bash
sudo tailscale up --exit-node=<exit-node-ip>
```

## Modern nftables Setup (Recommended for New Installations)

NixOS now encourages nftables over legacy iptables. This configuration forces nftables backend:

```nix
services.tailscale.enable = true;

networking.nftables.enable = true;

networking.firewall = {
  enable = true;
  # Always allow traffic from your Tailscale network
  trustedInterfaces = [ "tailscale0" ];
  # Allow the Tailscale UDP port through the firewall
  allowedUDPPorts = [ config.services.tailscale.port ];
};

# Force tailscaled to use nftables (Critical for clean nftables-only systems)
# This avoids the "iptables-compat" translation layer issues
systemd.services.tailscaled.serviceConfig.Environment = [ "TS_DEBUG_FIREWALL_MODE=nftables" ];
```

## Disable Telemetry

```nix
services.tailscale.disableUpstreamLogging = true;
```

Note: As of 2025, Tailscale collects telemetry, logs, and metadata about connectivity. Use this option to disable.

## Auto-Connect Service (Oneshot)

For automated connection with specific flags (e.g., exit node):

```nix
systemd.services.tailscale-autoconnect = {
  description = "Automatic connection to Tailscale";
  after = [ "network-pre.target" "tailscale.service" ];
  wants = [ "network-pre.target" "tailscale.service" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig.Type = "oneshot";
  script = with pkgs; ''
    # Wait for tailscaled to settle
    sleep 2
    # Otherwise authenticate with tailscale
    ${tailscale}/bin/tailscale up --advertise-exit-node
  '';
};
```

## Complete Example Configuration

```nix
{ config, pkgs, ... }: {
  # Enable Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client"; # for using exit nodes
    disableUpstreamLogging = true;
  };

  # Firewall configuration
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # Optional: Add tailscale to system packages for CLI access
  environment.systemPackages = [ pkgs.tailscale ];
}
```

## Common Commands

```bash
# Check status
tailscale status

# Show IP addresses
tailscale ip

# List devices
tailscale status --peers

# Use exit node
sudo tailscale up --exit-node=<exit-node-name>

# Disable exit node
sudo tailscale up --exit-node=

# Set as exit node
sudo tailscale up --advertise-exit-node

# Enable MagicDNS
sudo tailscale up --accept-dns=true

# Show logs
journalctl -u tailscaled -f
```

## Known Issues

### 1. Tailscale bypasses firewall for incoming traffic
Tailscale bypasses firewall for all incoming traffic on `tailscale0`. Use `trustedInterfaces` if you want this behavior.

### 2. IPv6 with NixOS-based exit node
If using exit nodes, may need to configure IPv6 properly. Check: https://nixos.wiki/wiki/Tailscale#IPv6_with_NixOS-based_exit_node

### 3. No internet when using exit node
Ensure `useRoutingFeatures = "client"` is set. May need to adjust reverse path filtering.

### 4. DNS issues
If using Tailscale DNS, you may need to configure `--accept-dns` flag.

## Testing

After configuration and rebuild:

```bash
# Check if service is running
systemctl status tailscaled

# Verify connection
tailscale status

# Test connectivity to another device
ping <tailscale-ip-of-another-device>
```

## Next Steps

1. Add Tailscale to `configuration.nix` for your host
2. Set firewall rules
3. Rebuild: `sudo nixos-rebuild switch --impure --flake .#<hostname>`
4. Login: `sudo tailscale up`
5. Test connectivity
