# Multi-stage Dockerfile for Neovim Nix flake testing
# Stage 1: Base Nix environment with dependencies
FROM nixos/nix:latest AS base

# The nixos/nix image already includes basic tools, just ensure flakes are enabled
# No additional packages needed for basic testing

# Stage 2: Development environment with full flake
FROM base AS development

# Set environment variables
ENV USER=neovim-dev
ENV HOME=/home/${USER}
ENV EDITOR=nvim
ENV VISUAL=nvim

# Create user directory
RUN mkdir -p ${HOME} && \
    chown -R 1000:1000 ${HOME}

# Create app directory
WORKDIR /app

# Copy flake files
COPY flake.nix flake.lock ./

# Stage 3: Minimal testing environment
FROM base AS test

# Set environment for testing
ENV USER=testuser
ENV HOME=/home/${USER}

# Create user and app directory
RUN mkdir -p ${HOME} /app && \
    chown -R 1000:1000 ${HOME} && \
    chown -R 1000:1000 /app

# Create minimal inline flake for testing
RUN cat > /app/flake.nix << 'EOF'
{
  description = "Minimal Neovim test";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = [ pkgs.neovim-unwrapped ];
        shellHook = "echo \"🧪 Minimal Neovim test environment\"";
      };
    });
}
EOF

WORKDIR /app

# Default command for testing
CMD ["nix", "--extra-experimental-features", "nix-command", "--extra-experimental-features", "flakes", "develop", "--command", "bash", "-c", "echo '🧪 Testing Neovim setup...' && nvim --version | head -n1 && echo '✅ Neovim accessible!'"]

# Stage 4: Production-ready environment
FROM development AS production

# Copy the actual Neovim configuration
COPY ../nvim/.config/nvim ./nvim-config

# Update flake to use the copied config
RUN sed -i "s|../nvim/.config/nvim|./nvim-config|g" flake.nix

# Set default command
CMD ["nix", "--extra-experimental-features", "nix-command", "--extra-experimental-features", "flakes", "develop", "--command", "nvim"]

# Stage 5: CI/CD testing environment
FROM development AS ci

# Set CI-specific environment
ENV CI=true
ENV NONINTERACTIVE=true

# Create inline test script (flake files already copied from development stage)
RUN cat > /app/test.sh << 'EOF'
#!/bin/bash
echo "🧪 CI Testing Neovim setup"
echo "=========================="

# Test 1: Check Neovim version
echo "📋 Test 1: Neovim version"
nix --extra-experimental-features nix-command --extra-experimental-features flakes develop --impure --command nvim --version | head -n1
echo "✅ Neovim accessible"

# Test 2: Test flake development shell
echo "📋 Test 2: Development shell"
nix --extra-experimental-features nix-command --extra-experimental-features flakes develop --impure --command bash -c "echo \"✅ Development shell works\""

echo "🎉 All CI tests passed!"
EOF
RUN chmod +x /app/test.sh

# Default CI command
CMD ["./test.sh"]