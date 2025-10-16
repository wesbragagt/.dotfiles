#!/bin/bash

# Test script for Neovim 0.12 + Home Manager setup

set -e

echo "🧪 Testing Neovim 0.12 + Home Manager setup"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "flake.nix" ]; then
    echo "❌ Error: flake.nix not found. Run this from the nix/ directory."
    exit 1
fi

# Check if nvim config exists
if [ ! -d "../nvim/.config/nvim" ]; then
    echo "❌ Error: Neovim config not found at ../nvim/.config/nvim"
    exit 1
fi

echo "✅ Directory structure looks good"

# Test 1: Enter development shell
echo ""
echo "📋 Test 1: Development shell"
echo "----------------------------"
nix develop --command bash -c "echo '✅ Development shell accessible' && nvim --version | head -n1"

# Test 2: Build Neovim package
echo ""
echo "📋 Test 2: Build Neovim package"
echo "-------------------------------"
nix build .#packages.x86_64-linux.neovim-custom
echo "✅ Neovim package built successfully"

# Test 3: Test symlink creation
echo ""
echo "📋 Test 3: Config symlink test"
echo "-----------------------------"
TEMP_HOME=$(mktemp -d)
export HOME=$TEMP_HOME
export USER=testuser

mkdir -p "$HOME/.config"
ln -sfn "$(pwd)/../nvim/.config/nvim" "$HOME/.config/nvim"

if [ -L "$HOME/.config/nvim" ]; then
    echo "✅ Config symlink created successfully"
    echo "📁 Symlink points to: $(readlink $HOME/.config/nvim)"
else
    echo "❌ Config symlink creation failed"
    rm -rf $TEMP_HOME
    exit 1
fi

# Test 4: Run Neovim with config
echo ""
echo "📋 Test 4: Neovim with LazyVim config"
echo "-------------------------------------"
nix develop --command bash -c "nvim --headless -c 'echo \"Neovim started successfully\" | q'"

# Cleanup
rm -rf $TEMP_HOME

echo ""
echo "🎉 All tests passed!"
echo ""
echo "🚀 To use this setup:"
echo "   cd nix/"
echo "   nix develop"
echo "   nvim"
echo ""
echo "📝 LazyVim will install plugins on first run"