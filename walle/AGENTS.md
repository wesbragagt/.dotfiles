## Walle

Walle is my Synology NAS instance (hostname: `Wall-e`).

### Hardware

- **Model**: Synology DS224+ (Gemini Lake platform)
- **CPU**: Intel Celeron J4125 @ 2.00GHz, 4 cores, 4 threads (4MB cache)
- **RAM**: 1.7 GB DDR4 (soldered, non-upgradeable — 2GB stock, ~300MB reserved for GPU)
- **Storage**: 2x 4TB HDD in RAID 1 (mdadm), single storage pool on `/volume1`
- **Networking**: 2x Realtek RTL8111 (1 GbE); primary: `eth0` at `192.168.68.70/22`

### Disk Layout

| Device | Size | RAID | Mount |
|---|---|---|---|
| `/dev/md0` | 8 GB | RAID 1 | `/` (system) |
| `/dev/md1` | 2 GB | RAID 1 | swap |
| `/dev/md2` (via LVM `vg1/volume_1`) | 3.5 TB | RAID 1 | `/volume1` (data) |

### OS

- **DSM**: 7.2.1 (build 69057, update 11)
- **Kernel**: Linux 4.4.302+ (x86_64, patched by Synology)
- **Init**: systemd
- **Boot**: Synology boot loader on SPI flash (`synoboot`)

### Installed Packages

- Container Manager (Docker engine)
- File Station
- Synology Photos
- Audio Station
- Synology Finder (Elasticsearch)
- Active Insight (monitoring)
- Support Service
- Synology Storage Console (SCSI target)
- Samba (SMB/NMB/WS-Discovery)

### Docker

- **Binary**: `/volume1/@appstore/ContainerManager/usr/bin/docker` (not on default `PATH`)
- **Version**: Docker 20.10.23 (Container Manager package v1437)

| Container | Image | Port(s) |
|---|---|---|
| syncthing | linuxserver/syncthing | — |
| n8n | n8nio/n8n:1.123.1 | 5678-5679 |
| jellyfin | jellyfin/jellyfin | 8096 |
| cloudflared-tunnel | cloudflare/cloudflared | — |
| home_assistant | homeassistant/home-assistant | — |

### DSM-Specific Commands

Synology tools live in `/usr/syno/bin/` and `/usr/syno/sbin/` — **not on the default PATH**. Use full paths or prefix with the directory.

**Package management** (`/usr/syno/bin/synopkg`):
- `synopkg status <package>` — check package status
- `synopkg version <package>` — get installed version
- `synopkg start <package>` / `synopkg stop <package>` — start/stop a package
- `synopkg restart <package>` — restart a package
- `synopkg install <spk>` — install from local .spk file
- `synopkg uninstall <package>` — uninstall a package
- `synopkg install_from_server <package>` — install from Synology repo

**Service management** (`/usr/syno/sbin/synopkgctl`):
- `synopkgctl start <package>` / `synopkgctl stop <package>` — start/stop package services

**Systemd wrapper** (`/usr/syno/bin/synosystemctl`):
- Drop-in replacement for `systemctl` on DSM. Same flags (`start`, `stop`, `restart`, `enable`, `disable`, `status`, etc.)

**Disk & storage** (`/usr/syno/bin/synodisk`):
- `synodisk --enum -t internal` — list internal disks
- `synodisk --info <device>` — query disk info (requires root)
- `synodisk --isssd <device>` — check if disk is SSD
- `synodisk --read_temp <device>` — read disk temperature
- `synodisk --standby <device>` — set disk to standby

**Users & shares** (`/usr/syno/sbin/`):
- `synouser` — manage DSM users (requires root)
- `synogroup` — manage DSM groups (requires root)
- `synoshare` — manage shared folders (requires root)

**Power control** (`/usr/syno/sbin/`):
- `synopoweroff` — shut down the NAS
- `synoshutdown` — shut down or restart

**Upgrade** (`/usr/syno/sbin/synoupgrade`):
- `synoupgrade --check` — check for DSM updates
- `synoupgrade --download` — download updates

### Key Services

- `sshd` — remote access
- `nginx` — web UI (DSM)
- `pgsql` — PostgreSQL for package metadata
- `pkg-ContainerManager-dockerd` — Docker engine
- `synosamba-*` — SMB file sharing
- `snmpd` — SNMP monitoring
- `chronyd` — NTP time sync

### Known Constraints

- **Memory is tight** (~1.0 GB used of 1.7 GB with heavy swap). Avoid running too many containers simultaneously.
- **Docker not on PATH** — use full path `/volume1/@appstore/ContainerManager/usr/bin/docker` or add to PATH.
- **No `sudo` for disk SMART** — requires root for `smartctl`.
- **Post-quantum SSH** not yet supported on this DSM version.
- **Kernel is old** (4.4) — some modern tools/binaries may not work.

## Projects

In the Synology NAS instance we store projects in the `~/dev/` folder.

<rules>
* When connecting to it you must use `ssh walle "command"`
* You must never delete any files
* You must ask permission to install something
</rules>
