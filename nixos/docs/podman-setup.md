# Podman Setup

## Overview

This module configures Podman for container management with support for rootless containers.

## Configuration

The Podman module is enabled in `home.nix`:
```nix
wesbragagt.podman.enable = true;
```

## Features

- **Podman CLI**: Main container runtime
- **podman-compose**: Docker Compose compatibility
- **Container registries**: Configured to use Docker Hub
- **Rootless mode**: Containers run as non-root user

## Usage

### Basic Commands
```bash
# Pull an image
podman pull alpine

# Run a container
podman run -it alpine /bin/sh

# List containers
podman ps -a

# Remove containers
podman rm <container_id>

# Using podman-compose
podman-compose up -d
```

### Docker Compatibility
The module includes `dockerCompat` which provides command aliases:
```bash
# Use docker commands with podman
alias docker=podman
docker pull nginx
docker run -d -p 80:80 nginx
```

### Rootless Containers

Podman runs in rootless mode by default for better security. No additional configuration needed for Home Manager setup.

## System-Level Configuration

For NixOS system-level Podman configuration (not managed by this module), add to your host's `configuration.nix`:

```nix
virtualisation = {
  containers.enable = true;
  podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
};

# Add user to podman group
users.users.<USERNAME>.extraGroups = [ "podman" ];
```

**Sources:**
- [NixOS Wiki - Podman](https://wiki.nixos.org/wiki/Podman)
- [NixOS Discourse - Rootless Podman](https://discourse.nixos.org/t/rootless-podman-setup-with-home-manager/57905)
