# macpro-nixos

Mac Pro running NixOS. Headless media server with Hyprland desktop.

- Host: `macpro-nixos`
- Branch: `feat--nixos-setup`
- Rebuild: `sudo nixos-rebuild switch --flake .#macpro-nixos`
- SSH: `ssh wesbragagt@macpro-nixos` (or use Tailscale hostname / local IP)

## Automatic Ripping Machine (ARM)

Docker-based DVD/Blu-ray ripping pipeline. Detects disc insertion via udev, rips with MakeMKV, transcodes with HandBrake.

### Architecture

```
disc insert → container udev (51-docker-arm.rules) → docker_arm_wrapper.sh → ARM
  → MakeMKV rip (raw/) → HandBrake transcode (transcode/) → completed output (completed/)
```

The container runs privileged with its own udev daemon. Do NOT add host-side udev triggers — the container handles disc detection internally. Adding host triggers causes duplicate ARM processes that race for the drive.

### NixOS Module

File: `arm.nix`
Option namespace: `wesbragagt.arm`

```nix
wesbragagt.arm.enable = true;  # in configuration.nix
```

Options:
- `dataDir` — host path for volumes (default: `/home/wesbragagt/arm-compose`)
- `port` — web UI port (default: 8080)
- `uid` / `gid` — container user IDs (default: 1000/100)

Requires `virtualisation.docker.enable = true` in configuration.nix.

### Host Paths

All under `~/arm-compose/`:

```
arm-home/       → /home/arm          (ARM app data, db, MakeMKV settings)
arm-media/      → /home/arm/media    (rip pipeline)
  raw/          → MakeMKV output (temporary)
  transcode/    → HandBrake working dir (temporary)
  completed/    → final output (movies/, unidentified/)
arm-logs/       → /home/arm/logs     (ARM logs + progress files)
arm-music/      → /home/arm/music    (CD rips)
arm-config/     → /etc/arm/config    (arm.yaml config file)
```

### ARM Config

Persistent config lives at `~/arm-compose/arm-config/arm.yaml` (volume-mounted).

Key settings:
- `DEST_EXT` — output format (`mp4` or `mkv`)
- `RIPMETHOD` — MakeMKV method (`mkv`, `backup`, `backup_dvd`)
- `HB_PRESET_DVD` / `HB_PRESET_BD` — HandBrake presets
- `SKIP_TRANSCODE` — keep raw MakeMKV output without HandBrake
- `OMDB_API_KEY` — for movie title lookup (key: `dfa420d7`)

Edit inside container or directly on host:
```bash
# via container
docker exec -it automatic-ripping-machine nano /etc/arm/config/arm.yaml

# via host
nano ~/arm-compose/arm-config/arm.yaml
```

### Device Requirements

- `/dev/sr0` — optical drive (block device)
- `/dev/sg0`, `/dev/sg1` — SCSI generic devices (required by MakeMKV)
- `sg` kernel module must be loaded (`boot.kernelModules = [ "sg" ]` — handled by arm.nix)

### Known Issues

**`{err:s}` Python format string bug** — exists in all published ARM Docker images (up to 2.22.1). Fixed only in unreleased `3.0_devel` branch. The compose entrypoint patches this on startup via `sed`.

**Eject error after rip** — `eject: /dev/sr0: not found mountpoint` appears in logs. Non-fatal, disc still ejects in most cases.

**Duplicate completed directories** — if ARM triggers multiple times for the same disc, you get directories with timestamp suffixes. Safe to delete empty ones.

### Web UI

Access at `http://<host>:8080`. Shows active jobs, history, and settings. Settings changed in the UI write to `arm.yaml`.

### Common Operations

```bash
# Check container status
docker ps | grep arm

# View live logs
docker logs -f automatic-ripping-machine

# Check rip progress
ls -lh ~/arm-compose/arm-media/raw/

# Kill a running rip
docker exec automatic-ripping-machine ps aux | grep makemkv
docker exec automatic-ripping-machine kill <PID>

# Restart container
docker-compose -f ~/arm-compose/docker-compose.yml restart

# Rebuild after config changes in dotfiles
cd ~/.dotfiles && git pull && cd nixos && sudo nixos-rebuild switch --flake .#macpro-nixos
```
