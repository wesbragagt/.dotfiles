# Docker Compose workflows for Neovim Nix flake development

## Quick Start

```bash
# Build and run development environment
docker-compose up neovim-dev

# Run minimal test
docker-compose up neovim-test

# Run full test suite
docker-compose --profile ci up neovim-ci

# Enter interactive shell
docker-compose --profile commands run neovim-cmd
```

## Services

### neovim-dev
- **Target**: Development environment with full Neovim setup
- **Use**: Interactive development and testing
- **Features**: Volume mounts for config, persistent data

### neovim-test  
- **Target**: Minimal testing environment
- **Use**: Quick validation of basic functionality
- **Features**: Lightweight, fast startup

### neovim-prod
- **Target**: Production-ready environment
- **Profile**: `production`
- **Use**: Production deployment testing

### neovim-ci
- **Target**: CI/CD testing environment
- **Profile**: `ci`
- **Use**: Automated testing in CI pipelines

### neovim-cmd
- **Target**: Command execution environment
- **Profile**: `commands`
- **Use**: Running specific commands or scripts

## Development Workflows

### Interactive Development
```bash
# Start development container
docker-compose up neovim-dev

# Attach to running container
docker-compose exec neovim-dev bash

# Run Neovim directly
docker-compose exec neovim-dev nix develop --command nvim
```

### Testing
```bash
# Quick test
docker-compose up neovim-test

# Full test suite
docker-compose --profile ci up neovim-ci

# Test specific commands
docker-compose --profile commands run neovim-cmd "nvim --version"
```

### Production Testing
```bash
# Build production image
docker-compose --profile ci build neovim-prod

# Test production setup
docker-compose --profile production up neovim-prod
```

## Multi-stage Build Targets

The Dockerfile includes multiple stages:

1. **base** - Core Nix environment
2. **development** - Full development setup
3. **test** - Minimal testing environment  
4. **production** - Production-ready setup
5. **ci** - CI/CD optimized environment

## Volume Management

- `neovim-data` - Plugin installations and runtime files
- `neovim-cache` - Compilation cache and temporary files
- Separate volumes for production isolation

## Environment Variables

- `USER` - Container user name
- `HOME` - User home directory
- `EDITOR`/`VISUAL` - Default editor (nvim)
- `CI` - CI mode flag
- `NONINTERACTIVE` - Non-interactive mode flag