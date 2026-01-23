#!/bin/bash

set -e

ln -sf ~/.dotfiles/claude/skills ~/.claude/skills
ln -sf ~/.dotfiles/claude/agents ~/.claude/agents
ln -sf ~/.dotfiles/claude/commands ~/.claude/commands

# Add must-have MCP servers (user scope - available across all projects)
# Only add if not already present
if ! claude mcp get exa &>/dev/null; then
  claude mcp add --scope user --transport stdio exa -- npx -y mcp-remote https://mcp.exa.ai/mcp
fi
