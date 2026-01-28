# Adding a New Host

## Quick Start

```bash
# 1. Generate hardware config (on new machine)
nixos-generate-config --root /tmp/config --no-filesystems

# 2. Create host directory
mkdir -p ~/.dotfiles/nixos/hosts/<hostname>
cp /tmp/config/etc/nixos/hardware-configuration.nix ~/.dotfiles/nixos/hosts/<hostname>/

# 3. Copy or create configuration.nix
# Option A: Copy from existing host
cp ~/.dotfiles/nixos/hosts/vm-aarch64/configuration.nix ~/.dotfiles/nixos/hosts/<hostname>/

# Option B: Create minimal config
cat > ~/.dotfiles/nixos/hosts/<hostname>/configuration.nix << 'EOF'
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  # Add your system configuration
}
EOF

# 4. Add host to flake.nix
# Edit flake.nix nixosConfigurations section:
# nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
#   system = "x86_64-linux";  # or aarch64-linux
#   modules = [ ./hosts/<hostname>/configuration.nix ... ];
# };

# 5. Deploy
sudo nixos-rebuild switch --impure --flake ~/.dotfiles/nixos#<hostname>
```

## File Structure

```
nixos/
├── hosts/
│   ├── vm-aarch64/
│   │   ├── configuration.nix        # Committed: system config
│   │   └── hardware-configuration.nix # Ignored: hardware detection
│   └── <hostname>/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/                         # Shared across hosts
├── home.nix
└── flake.nix
```

## Important Notes

- **hardware-configuration.nix** is gitignored (`hosts/*/hardware-configuration.nix`)
- **configuration.nix** is committed (authored by you)
- Generate hardware config per machine during installation
- Use `--no-filesystems` flag to manage disks separately

## Updating Flake for New Host

```nix
# flake.nix
outputs = { self, nixpkgs, home-manager, zen-browser, ... }: {
  nixosConfigurations = {
    vm-aarch64 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [ ./hosts/vm-aarch64/configuration.nix ... ];
    };
    <hostname> = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/<hostname>/configuration.nix ... ];
    };
  };
};
```
