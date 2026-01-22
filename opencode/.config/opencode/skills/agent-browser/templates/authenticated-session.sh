#!/bin/bash
set -euo pipefail

# Authenticated Session Template
# Usage: ./authenticated-session.sh <login_url> <target_url>

LOGIN_URL="${1:?Usage: $0 <login_url> <target_url>}"
TARGET_URL="${2:?Usage: $0 <login_url> <target_url>}"
AUTH_FILE="${AUTH_FILE:-auth.json}"

# Check for existing auth state
if [[ -f "$AUTH_FILE" ]]; then
    echo "Loading existing auth state..."
    agent-browser state load "$AUTH_FILE"
    agent-browser open "$TARGET_URL"
    agent-browser wait networkidle

    # Verify still authenticated (check if redirected to login)
    current_url=$(agent-browser get url --json | jq -r '.url')
    if [[ "$current_url" != *"login"* ]]; then
        echo "Auth valid, continuing..."
        agent-browser snapshot -i
        exit 0
    fi
    echo "Auth expired, re-authenticating..."
fi

# Perform login
agent-browser open "$LOGIN_URL"
agent-browser wait networkidle
agent-browser snapshot -i

# Fill credentials (customize refs based on actual form)
# agent-browser fill @e1 "$USERNAME"
# agent-browser fill @e2 "$PASSWORD"
# agent-browser click @e3

# Wait for login to complete
agent-browser wait networkidle

# Save auth state
agent-browser state save "$AUTH_FILE"
echo "Auth state saved to $AUTH_FILE"

# Navigate to target
agent-browser open "$TARGET_URL"
agent-browser wait networkidle
agent-browser snapshot -i
