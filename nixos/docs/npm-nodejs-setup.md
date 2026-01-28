# Node.js, npm, and Package Managers Setup

## Overview

This document describes how npm, fnm, uv, and bun are configured in the NixOS setup.

## Packages Installed

The following packages are available in `home.packages`:

- **nodejs**: Node.js runtime
- **fnm**: Fast Node.js version manager
- **bun**: Fast JavaScript runtime and package manager
- **uv**: Python package manager (configured via `programs.uv`)

## NPM Global Packages Setup

NPM is configured to install global packages in `~/.npm_global` instead of system directories. This avoids permission issues and keeps packages isolated.

### Declarative Packages (via Nix)

Use the npm module to install packages from nixpkgs declaratively:

```nix
# In home.nix
wesbragagt.npm = {
  enable = true;
  globalPackages = [
    "pnpm"
    "typescript"
  ];
};
```

### Configuration Location

The npm module is in `modules/npm.nix`:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.npm;
in
{
  options.wesbragagt.npm = {
    enable = mkEnableOption "Enable npm global packages";
    
    globalPackages = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of npm global packages to install from nixpkgs";
    };
  };

  config = mkIf cfg.enable {
    home.packages = map (pkg: 
      if hasAttr pkg pkgs.nodePackages then
        pkgs.nodePackages.${pkg}
      else
        throw "npm package '${pkg}' not found in nixpkgs nodePackages"
    ) cfg.globalPackages;
  };
}
```

### Imperative Packages (via npm)

For packages not in nixpkgs, you can still use npm directly:

```nix
programs.zsh = {
  enable = true;
  initContent = lib.mkOrder 1000 ''
    # Setup npm global packages
    mkdir -p ~/.npm_global
    npm config set prefix ~/.npm_global
    export PATH="$HOME/.npm_global/bin:$PATH"

    # Source dotfiles
    source ${./modules/zsh/.zshrc}
  '';
};
```

### Usage

After switching to the new configuration, you can use:

```bash
# Install a global npm package
npm install -g <package>

# Use the installed package
<package>
```

The `~/.npm_global/bin` directory is added to PATH, so installed packages are immediately available.

## FNM Usage

FNM is installed for managing Node.js versions:

```bash
# Install a Node.js version
fnm install 20

# Use a specific version
fnm use 20

# Set default version
fnm default 20

# List installed versions
fnm list
```

## Bun Usage

Bun is installed as an alternative JavaScript runtime:

```bash
# Install dependencies
bun install

# Run a script
bun run <script>

# Install a global package
bun install -g <package>
```

## UV Usage

UV is configured via Home Manager and writes to `~/.config/uv/uv.toml`:

```nix
programs.uv = {
  enable = true;
};
```

Basic usage:

```bash
# Create a virtual environment
uv venv

# Install a package
uv pip install <package>

# Install from requirements.txt
uv pip install -r requirements.txt
```

## Testing

To verify the setup:

```bash
# Check npm prefix
npm config get prefix
# Should output: /home/wesbragagt/.npm_global

# Install a test package
npm install -g pnpm

# Verify it's available
pnpm --version

# Check fnm
fnm --version

# Check bun
bun --version

# Check uv
uv --version
```

## Source

Based on research from:
- [NixOS Wiki - Node](https://nixos.wiki/wiki/Node)
- [Home Manager Manual - UV](https://home-manager.dev/manual/25.05/)
- [NPM Global Packages without Sudo](https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally)
