# Neovim 0.12 (Nightly) + Home Manager Test

This flake builds Neovim 0.12 development version from source and uses Home Manager to symlink your LazyVim configuration.

## Features

- ✅ Neovim 0.12 built from source
- ✅ Home Manager declarative config symlinking
- ✅ LazyVim manages plugins and LSPs
- ✅ Docker-ready for testing
- ✅ Cross-platform support

## Quick Start

### Development Shell (Recommended for testing)
```bash
cd nix/
nix develop
```

### Install via Home Manager
```bash
cd nix/
nix run .#homeConfigurations.test.activationPackage
```

### Run Neovim directly
```bash
cd nix/
nix run .# nvim
```

## Docker Testing

Create a Dockerfile to test this setup:

```dockerfile
FROM nixos/nix:latest

# Install dependencies
RUN nix --version

# Copy the flake
COPY . /app
WORKDIR /app

# Enter development environment
RUN nix develop --echo

# Test the setup
CMD ["nix", "develop", "--run", "nvim --version"]
```

Build and run:
```bash
docker build -t neovim-test .
docker run -it neovim-test
```

## Directory Structure

```
nix/
├── flake.nix          # Main flake configuration
├── README.md          # This file
└── ../nvim/           # Your LazyVim config
    └── .config/
        └── nvim/
            ├── init.lua
            ├── lazy.json
            └── lua/
```

## Configuration Details

### Neovim Build
- Version: 0.12.0-dev (nightly)
- Built from source with optimizations
- JIT compilation enabled
- Proper library linking

### Home Manager Integration
- Uses `xdg.configFile` for symlinking
- Atomic updates with rollback support
- Conflict detection
- Environment variable setup

### LazyVim Integration
- Config symlinked to `$HOME/.config/nvim`
- LazyVim handles plugin installation
- LSPs installed automatically by LazyVim
- No Nix-managed plugins or LSPs

## Verification

Once in the development shell:

```bash
# Check Neovim version
nvim --version

# Verify config symlink
ls -la ~/.config/nvim

# Test LazyVim installation
nvim --headless -c "Lazy sync" -c "qa"

# Check installed plugins
nvim --headless -c "Lazy" -c "qa"
```

## Troubleshooting

### Build Issues
- Check if all dependencies are available
- Verify hash matches the source
- Try updating the hash with `nix run nixpkgs#nix-prefetch-github -- neovim neovim v0.12.0`

### Symlink Issues
- Ensure source config exists at `../nvim/.config/nvim`
- Check permissions
- Verify Home Manager activation

### LazyVim Issues
- Run `nvim` and let LazyVim install
- Check `~/.local/share/nvim/lazy` for plugins
- Verify `lazy.json` configuration

## Next Steps

1. Test in Docker container
2. Verify LazyVim plugin installation
3. Test LSP auto-installation
4. Validate cross-platform compatibility
5. Integrate with your main dotfiles setup