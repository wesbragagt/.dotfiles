# Authentication Guide

## Overview

Managing authentication state is crucial for browser automation. agent-browser provides state persistence to avoid re-authenticating on every session.

## Basic Authentication Flow

```bash
# 1. Open login page
agent-browser open "https://example.com/login"
agent-browser wait networkidle

# 2. Get form elements
agent-browser snapshot -i

# 3. Fill credentials
agent-browser fill @e1 "username"
agent-browser fill @e2 "password"

# 4. Submit
agent-browser click @e3  # Login button
agent-browser wait networkidle

# 5. Verify login succeeded
agent-browser get url  # Should be dashboard/home
agent-browser snapshot -i  # Should show logged-in state
```

## Saving Authentication State

After successful login, save the browser state:

```bash
agent-browser state save auth.json
```

This saves:
- Cookies (session tokens, auth cookies)
- localStorage
- sessionStorage

## Restoring Authentication

Load saved state before navigating:

```bash
agent-browser state load auth.json
agent-browser open "https://example.com/dashboard"
```

## HTTP Basic Authentication

For sites using HTTP Basic Auth:

```bash
agent-browser credentials "username" "password"
agent-browser open "https://protected.example.com"
```

## Session Management

### Named Sessions

Isolate different accounts/contexts:

```bash
# Admin session
agent-browser --session admin open "https://example.com/login"
# ... login as admin ...
agent-browser --session admin state save admin-auth.json

# User session
agent-browser --session user open "https://example.com/login"
# ... login as regular user ...
agent-browser --session user state save user-auth.json

# Use specific session
agent-browser --session admin open "https://example.com/admin"
agent-browser --session user open "https://example.com/profile"
```

### Session Lifecycle

```bash
# Sessions persist until explicitly closed
agent-browser --session myapp close

# Or until browser exits
agent-browser close  # Closes all sessions
```

## Handling Auth Expiration

Authentication can expire. Handle gracefully:

```bash
# Try to access protected resource
agent-browser state load auth.json
agent-browser open "https://example.com/dashboard"
agent-browser wait networkidle

# Check if redirected to login
current_url=$(agent-browser get url --json | jq -r '.url')
if [[ "$current_url" == *"login"* ]]; then
    # Re-authenticate
    agent-browser snapshot -i
    agent-browser fill @e1 "username"
    agent-browser fill @e2 "password"
    agent-browser click @e3
    agent-browser wait networkidle
    agent-browser state save auth.json  # Update saved state
fi
```

## OAuth/SSO Flows

For OAuth flows, use headed mode to handle redirects:

```bash
agent-browser --headed open "https://example.com/login"
agent-browser snapshot -i
agent-browser click @e1  # "Login with Google" button

# Wait for OAuth redirect
agent-browser wait url "accounts.google.com"
agent-browser snapshot -i

# Complete OAuth flow
agent-browser fill @e1 "email@gmail.com"
agent-browser click @e2  # Next
agent-browser wait networkidle
agent-browser fill @e3 "password"
agent-browser click @e4  # Sign in

# Wait for redirect back
agent-browser wait url "example.com"
agent-browser state save oauth-auth.json
```

## Multi-Factor Authentication

For MFA, use headed mode and wait for user input:

```bash
agent-browser --headed open "https://example.com/login"
# ... fill credentials ...
agent-browser click @e3  # Login

# Wait for MFA page
agent-browser wait element "input[name=otp]"
agent-browser snapshot -i

# Option 1: Automated TOTP
otp_code=$(generate-totp "SECRETKEY")  # External tool
agent-browser fill @e1 "$otp_code"
agent-browser click @e2

# Option 2: Manual entry (headed mode)
# User enters code manually in visible browser
agent-browser wait url "dashboard"  # Wait for success
```

## Security Considerations

1. **Never commit auth.json** - Add to .gitignore
2. **Use environment variables** for credentials
3. **Rotate saved states** periodically
4. **Use separate sessions** for different environments
5. **Clear state after testing** - `agent-browser cookies clear`
