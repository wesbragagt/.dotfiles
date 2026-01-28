# Hardware Configuration Management

## Problem

`hardware-configuration.nix` is system installation specific and contains:
- Kernel modules for detected hardware
- Filesystem configuration
- Boot configuration
- Network interfaces

Committing it to a shared dotfiles repo causes issues when deploying to different machines.

## Research Findings

### Best Practice: Per-Host `hosts/` Directory

Store machine-specific configurations in a `hosts/` directory:

```
nixos/
├── hosts/
│   ├── nixos-arm/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix  (machine-specific)
│   ├── laptop/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── desktop/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/           (shared modules)
├── flake.nix
└── .gitignore
```

**Sources:**
- [BhasherBEL/dotfiles-nix](https://github.com/bhasherbel/dotfiles-nix)
- [not-matthias/dotfiles-nix](https://github.com/not-matthias/dotfiles-nix)
- [8bitbuddhist/nix-configuration](https://codeberg.org/8bitbuddhist/nix-configuration)
- [Adyxax blog](https://www.adyxax.org/blog/2023/11/28/managing-multiple-nixos-hosts-remotely/)

### .gitignore Patterns

Ignore all hardware configurations:

```gitignore
hosts/*/hardware-configuration.nix
```

Or ignore generically:

```gitignore
hardware-configuration.nix
```

**Source:** [Discourse - Github strategies for configuration.nix?](https://discourse.nixos.org/t/github-strategies-for-configuration-nix/1983)

### On New Machine

Generate hardware configuration and copy to appropriate host directory:

```bash
# Generate without filesystems (for disk management)
nixos-generate-config --root /tmp/config --no-filesystems

# Copy to host directory
sudo cp /tmp/config/etc/nixos/hardware-configuration.nix \
  ~/.dotfiles/nixos/hosts/$(hostname)/hardware-configuration.nix

# Deploy
sudo nixos-rebuild switch --impure --flake ~/.dotfiles/nixos#$(hostname)
```

**Source:** [BhasherBEL/dotfiles-nix README](https://github.com/bhasherbel/dotfiles-nix)

### Flake Configuration

Update `flake.nix` to support multiple hosts:

```nix
outputs = { self, nixpkgs, home-manager, zen-browser, ... }: {
  nixosConfigurations = {
    nixos-arm = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./hosts/nixos-arm/configuration.nix
        ./modules/shared.nix
        # ...
      ];
    };
    laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/laptop/configuration.nix
        ./modules/shared.nix
        # ...
      ];
    };
  };
};
```

**Source:** [Creating a Multi-System Modular NixOS Configuration](https://certifikate.io/blog/posts/2024/12/creating-a-multi-system-modular-nixos-configuration-with-flakes/)

## Current Setup Issues

### Symlink Approach (Not Recommended)

Current approach uses symlink from `/etc/nixos/hardware-configuration.nix` to dotfiles:

**Problems:**
- Requires manual symlink setup on each machine
- Creates inconsistency between local and remote
- Confusing for contributors
- Breaks if file doesn't exist locally

**Source:** [Discourse - How to manage my dotfiles](https://discourse.nixos.org/t/how-to-manage-my-dotfiles/16608)

### Keep in /etc/nixos Only

Alternative: Never commit hardware-configuration.nix, keep only in `/etc/nixos`:

```nix
# In configuration.nix
imports = [
  ./modules/shared.nix
  # hardware-configuration.nix imported from /etc/nixos only
];
```

**Source:** [Discourse - How to manage my dotfiles](https://discourse.nixos.org/t/how-to-manage-my-dotfiles/16608)

## Recommendation

Use **per-host `hosts/` directory** approach:

1. Move machine-specific configs to `hosts/<hostname>/`
2. Add `hosts/*/hardware-configuration.nix` to .gitignore
3. Update flake.nix to support multiple nixosConfigurations
4. Generate hardware-configuration.nix per machine during installation
5. Deploy with `sudo nixos-rebuild switch --flake ~/.dotfiles/nixos#<hostname>`

**Benefits:**
- Clear separation of shared vs machine-specific configs
- Easy to manage multiple machines
- Follows community best practices
- Scalable for future machines
