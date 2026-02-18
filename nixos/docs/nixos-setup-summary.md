# NixOS Setup: Podman and Waybar Battery Module

## Changes Made

### 1. Podman Container Runtime

**Files Created:**
- `modules/podman.nix` - Home Manager module for Podman
- `docs/podman-setup.md` - Podman setup documentation

**Files Modified:**
- `home.nix` - Import and enable Podman module
- `hosts/macpro-nixos/configuration.nix` - System-level Podman configuration

**Features:**
- Podman 5.7.0 with rootless container support
- podman-compose for Docker Compose compatibility
- User added to `podman` group
- SubUID/SubGID ranges configured for rootless mode
- Container registries configured (Docker Hub)
- System-level Podman daemon enabled with Docker compatibility

**Testing Results:**
✓ Podman installed (v5.7.0)
✓ User in podman group
✓ SubUID ranges configured
✓ Rootless container execution successful: `podman run --rm alpine echo 'Rootless Podman works!'`

### 2. Waybar Battery Module

**Files Modified:**
- `modules/waybar/config.jsonc` - Added battery module
- `docs/waybar-battery.md` - Battery module documentation

**Configuration:**
- Battery device: BAT0
- Polling interval: 60 seconds
- Warning state: 30%
- Critical state: 15%
- Custom formats for charging/plugged states
- Battery level icons (0-100%)

**Testing Results:**
✓ Battery module added to Waybar config
✓ Module positioned in right bar (before pulseaudio)
✓ Configuration includes proper states and formats

## Documentation

Updated documentation index with:
- Podman setup guide
- Waybar battery module guide

## Next Steps

To complete the setup:
1. **Log out and log back in** to activate Home Manager changes (Podman CLI and configs)
2. **Restart Waybar** to see the battery module: `pkill waybar` (auto-restart via systemd)
3. **Optional:** Add CSS styling for battery states in `modules/waybar/style.css`

## Usage Examples

### Podman
```bash
# Pull and run container
podman pull nginx
podman run -d -p 80:80 nginx

# List containers
podman ps -a

# Remove containers
podman rm <container_id>
```

### Verify Battery Module
The battery module will appear in Waybar showing current capacity and charging status.

## Sources
- [NixOS Wiki - Podman](https://wiki.nixos.org/wiki/Podman)
- [Waybar Wiki - Battery Module](https://github.com/Alexays/Waybar/wiki/Module:-Battery)
- [NixOS Discourse - Rootless Podman](https://discourse.nixos.org/t/rootless-podman-setup-with-home-manager/57905)
