# Claude Code and OpenCode Setup on NixOS

## Overview

This document describes how to install Claude Code (Anthropic's AI coding assistant) and OpenCode (open-source AI coding agent) using Nix.

## Claude Code

### Installation Options

#### Option 1: Use nixpkgs (Recommended)

Claude Code is available in nixpkgs unstable:

```nix
# In home.nix
home.packages = with pkgs; [
  claude-code
];
```

#### Option 2: Use Third-Party Flake (Hourly Updates)

For always-up-to-date version with hourly updates, use sadjow/claude-code-nix flake:

```nix
# In flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, claude-code, ... }: {
    homeConfigurations."username" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "aarch64-linux"; };
      modules = [
        {
          nixpkgs.overlays = [ claude-code.overlays.default ];
          home.packages = [ pkgs.claude-code ];
        }
      ];
    };
  };
}
```

**Runtime Options:**
- `pkgs.claude-code` - Native binary (default, ~180MB)
- `pkgs.claude-code-node` - Node.js 22 LTS runtime
- `pkgs.claude-code-bun` - Bun runtime

#### Quick Start (No Installation)

Try Claude Code without installing:

```bash
nix run github:sadjow/claude-code-nix
```

#### Home Manager Configuration

```nix
# Configure Claude Code settings
programs.claude-code = {
  enable = true;
  settings = {
    model = "claude-3-5-sonnet-20241022";
    theme = "dark";
    permissions = {
      allow = [ "Edit" "Bash(git diff:*)" ];
      deny = [ "WebFetch" "Read(./.env)" ];
    };
    hooks = {
      PostToolUse = [{
        matcher = "Edit|MultiEdit|Write";
        hooks = [{
          command = "nix fmt $(jq -r '.tool_input.file_path' <<< '$CLAUDE_TOOL_INPUT')";
          type = "command";
        }];
      }];
    };
  };
};
```

### MCP Integration

Configure MCP servers for Claude Code:

```nix
programs.claude-code.settings.mcpServers = {
  github = {
    command = "docker";
    args = [ "run" "-i" "--rm" "-e" "GITHUB_PERSONAL_ACCESS_TOKEN" "ghcr.io/github/github-mcp-server" ];
  };
  filesystem = {
    command = "uvx";
    args = [ "mcp-filesystem" ];
  };
};
```

### Source

- [nixpkgs - claude-code](https://search.nixos.org/packages?query=claude-code)
- [sadjow/claude-code-nix](https://github.com/sadjow/claude-code-nix)
- [MyNixOS - programs.claude-code.settings](https://mynixos.com/home-manager/option/programs.claude-code.settings)

## OpenCode

### Installation

OpenCode is available in nixpkgs:

```nix
# In home.nix
home.packages = with pkgs; [
  opencode
];
```

### Quick Start

```bash
# Run without installing
nix run nixpkgs#opencode
```

### Installation Methods

According to opencode documentation, multiple installation methods are supported:

1. **x-cmd**: `xinstallopencode`
2. **Nix**: `nixrunnixpkgs#opencode`
3. **npm**: `npmi-gopencode-ai@latest`
4. **Homebrew**: `brewinstallopencode`

### Source

- [nixpkgs - opencode](https://mynixos.com/nixpkgs/package/opencode)
- [OpenCode GitHub](https://github.com/anomalyco/opencode)
- [X-CMD Installation](https://www.x-cmd.com/install/opencode/)

## Comparison

| Feature | Claude Code | OpenCode |
|----------|-------------|-----------|
| Source | Proprietary (Anthropic) | Open Source |
| Installation | nixpkgs or flake | nixpkgs |
| Updates | Hourly (flake) or nixpkgs cycle | nixpkgs cycle |
| Nixpkgs Available | ✅ Yes | ✅ Yes |
| Runtime Options | Native, Node.js, Bun | TypeScript/JavaScript + Go TUI |
| MCP Support | ✅ Yes | ✅ Yes |
| License | Proprietary | MIT |

## Module Structure

Create an AI tools module for both tools:

```nix
# modules/ai-tools.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wesbragagt.ai-tools;
in
{
  options.wesbragagt.ai-tools = {
    enable = mkEnableOption "Enable AI coding tools";
    
    claude-code = {
      enable = mkEnableOption "Enable Claude Code";
      runtime = mkOption {
        type = types.enum [ "native" "node" "bun" ];
        default = "native";
        description = "Runtime to use for Claude Code";
      };
    };
    
    opencode = {
      enable = mkEnableOption "Enable OpenCode";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      (if cfg.claude-code.enable then [ claude-code ] else []) ++
      (if cfg.opencode.enable then [ opencode ] else []);
  };
}
```

Usage in home.nix:

```nix
wesbragagt.ai-tools = {
  enable = true;
  claude-code = {
    enable = true;
    runtime = "native";
  };
  opencode = {
    enable = true;
  };
};
```

## Testing

After installation:

```bash
# Test Claude Code
claude --version

# Test OpenCode
opencode --version

# Run Claude Code interactively
claude

# Run OpenCode interactively
opencode
```

## Notes

- Both tools are available in nixpkgs unstable
- Claude Code provides more frequent updates via third-party flakes
- OpenCode is open source and may offer more customization
- MCP (Model Context Protocol) allows extending both tools with custom servers
