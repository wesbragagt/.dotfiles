## Macpro NixOS

This is a home server running NixOS on a Mac Pro 2012, primarily used for Immich (photo management) and media ripping.

### Hardware

- **CPU:** Intel Core i5-3210M (2 cores / 4 threads) @ 2.50GHz, VT-x enabled
- **RAM:** 12 GiB (no swap)
- **Disk:** 232.9 GiB SSD (`/dev/sda`)
  - `/dev/sda1` → 1G `/boot` (vfat, systemd-boot)
  - `/dev/sda2` → 228G `/` (ext4, ~28% used)
- **NICs:** `enp1s0f0` (ethernet), `wlp2s0` (WiFi - Broadcom 4331)

### Network

| Interface | IP | Purpose |
|-----------|----|---------|
| `enp1s0f0` | `192.168.68.88/22` | LAN |
| `tailscale0` | `100.79.196.52/32` | Tailscale VPN |
| `docker0` | `172.17.0.0/16` | Docker default bridge |

SSH access: `ssh wesbragagt@macpro-nixos` (resolves via Tailscale MagicDNS or LAN IP).

### OS & Config

- **OS:** NixOS 26.05 (Yarara), kernel 6.18.8 (latest)
- **Config location:** `/etc/nixos/configuration.nix` (traditional, not flakes-based for system config)
- **State version:** `25.11`
- **Bootloader:** systemd-boot (UEFI)
- **Desktop:** XFCE with LightDM + auto-login (user: `wesbragagt`)
- **Nix features:** experimental-features = `nix-command flakes`
- **User:** `wesbragagt` (groups: `networkmanager`, `wheel`, `docker`; sudo without password)

### Applying config changes

```bash
# Edit config
sudo vim /etc/nixos/configuration.nix

# Test build (no activation)
sudo nixos-rebuild build

# Apply changes
sudo nixos-rebuild switch

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

### Running Services

| Service | Notes |
|---------|-------|
| `docker.service` | Docker Engine |
| `sshd.service` | Remote SSH access |
| `tailscaled.service` | Tailscale mesh VPN |
| `greetd.service` | Display manager |
| `keyd.service` | Keyboard remapping daemon |
| `NetworkManager.service` | Network management |
| `pipewire` | Audio (via PulseAudio compatibility) |

### Docker Containers

All compose files live under `/home/wesbragagt/dev/<name>/`.

| Container | Image | Compose dir | Notes |
|-----------|-------|-------------|-------|
| `immich_server` | `ghcr.io/immich-app/immich-server:v2` | `~/dev/immich-compose/` | Photo management, exposed via Tailscale serve (HTTPS) |
| `immich_machine_learning` | `ghcr.io/immich-app/immich-machine-learning:v2` | `~/dev/immich-compose/` | ML face/object detection |
| `immich_postgres` | `ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0` | `~/dev/immich-compose/` | Database, data at `./immich-data/database` |
| `immich_redis` | `valkey/valkey:9` | `~/dev/immich-compose/` | Cache |
| `tailscale-immich` | `tailscale/tailscale:latest` | `~/dev/immich-compose/` | Tailscale sidecar with serve config |
| `caddy` | `caddy:latest` | `~/dev/immich-compose/` | Reverse proxy, config at `./caddy/Caddyfile` |
| `automatic-ripping-machine` | `automaticrippingmachine/automatic-ripping-machine:latest` | `~/dev/arm-compose/` | Disc ripper, port 8080 |

#### Immich specifics

- Immich data (uploads): `~/dev/immich-compose/immich-data/upload`
- Immich is networked via `network_mode: service:tailscale` (shares Tailscale sidecar network)
- Tailscale serve config exposes Immich at `https://immich.<tailnet>.ts.net:443`
- Env file: `~/dev/immich-compose/.env`

#### Managing Docker services

```bash
# Restart all Immich containers
docker compose -f ~/dev/immich-compose/compose.yaml restart

# Pull and recreate (after image updates)
docker compose -f ~/dev/immich-compose/compose.yaml pull
docker compose -f ~/dev/immich-compose/compose.yaml up -d

# View logs
docker logs -f immich_server
```

### Adding an NFS mount (e.g., NAS photos for Immich)

Add to `/etc/nixos/configuration.nix`:

```nix
{
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  fileSystems."/mnt/nas-photos" = {
    device = "NAS_IP:/path/to/photos";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "noatime"
    ];
  };
}
```

Then apply: `sudo nixos-rebuild switch`.

To use with Immich, update `UPLOAD_LOCATION` in `~/dev/immich-compose/.env`:

```
UPLOAD_LOCATION=/mnt/nas-photos
```

And restart Immich: `docker compose -f ~/dev/immich-compose/compose.yaml up -d`.
