#!/usr/bin/env bash

set -euo pipefail

CONFIG="/etc/nixos/configuration.nix"
EXPERIMENTAL_LINE='  nix.settings.experimental-features = [ "nix-command" "flakes" ];'

echo "Adding experimental features to $CONFIG..."

if grep -q "experimental-features" "$CONFIG"; then
  echo "✓ Experimental features already configured"
  exit 0
fi

if grep -q "nix.settings" "$CONFIG"; then
  awk '/nix.settings = \{/ {print; print "  experimental-features = [ \"nix-command\" \"flakes\" ];"; next}1' "$CONFIG" > "${CONFIG}.tmp" && mv "${CONFIG}.tmp" "$CONFIG"
else
  awk '{print} /^}$/ && !added {print "  nix.settings = {\n    experimental-features = [ \"nix-command\" \"flakes\" ];\n  };"; added=1}' "$CONFIG" > "${CONFIG}.tmp" && mv "${CONFIG}.tmp" "$CONFIG"
fi

echo "✓ Experimental features added to $CONFIG"
echo "Run 'sudo nixos-rebuild switch' to apply changes"
