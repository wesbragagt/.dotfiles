# Session Management

## Overview

Sessions provide isolated browser contexts for managing multiple accounts, environments, or parallel automation tasks.

## Named Sessions

Create isolated browser instances with `--session`:

```bash
# Each session has its own cookies, storage, and state
agent-browser --session dev open "https://dev.example.com"
agent-browser --session staging open "https://staging.example.com"
agent-browser --session prod open "https://example.com"
```

## Session Persistence

Sessions persist across commands until explicitly closed:

```bash
# Start session
agent-browser --session myapp open "https://example.com"

# Later commands use same session
agent-browser --session myapp snapshot -i
agent-browser --session myapp click @e1

# Session maintains state between commands
agent-browser --session myapp get url  # Still on same page
```

## Session Lifecycle

### Creating Sessions

Sessions are created implicitly on first use:

```bash
agent-browser --session newsession open "https://example.com"
```

### Listing Sessions

```bash
agent-browser sessions  # List active sessions
```

### Closing Sessions

```bash
# Close specific session
agent-browser --session myapp close

# Close all sessions
agent-browser close
```

## Use Cases

### Multiple Accounts

Test interactions between different user roles:

```bash
# Admin creates content
agent-browser --session admin state load admin-auth.json
agent-browser --session admin open "https://example.com/admin/posts/new"
agent-browser --session admin snapshot -i
agent-browser --session admin fill @e1 "New Post Title"
agent-browser --session admin click @e2  # Publish

# User views content
agent-browser --session user state load user-auth.json
agent-browser --session user open "https://example.com/posts"
agent-browser --session user snapshot -i
# Verify post appears
```

### Environment Testing

Compare behavior across environments:

```bash
# Test same flow in dev and staging
for env in dev staging; do
    agent-browser --session $env open "https://$env.example.com/feature"
    agent-browser --session $env wait networkidle
    agent-browser --session $env screenshot
done
```

### Parallel Automation

Run multiple automations simultaneously:

```bash
# Background jobs
agent-browser --session job1 open "https://site1.com" &
agent-browser --session job2 open "https://site2.com" &
agent-browser --session job3 open "https://site3.com" &
wait

# Each has independent state
agent-browser --session job1 screenshot
agent-browser --session job2 screenshot
agent-browser --session job3 screenshot
```

## Session State

### Saving State

```bash
agent-browser --session myapp state save myapp-state.json
```

### Loading State

```bash
agent-browser --session myapp state load myapp-state.json
```

### What's Saved

- Cookies
- localStorage
- sessionStorage
- Origin permissions

### What's NOT Saved

- Open tabs/pages (use `open` after load)
- Browser history
- Downloads
- Extension state

## Session Configuration

Sessions inherit global options:

```bash
# Configure session with proxy
agent-browser --session corp --proxy "http://proxy:8080" open "https://internal.corp"

# Configure session with extensions
agent-browser --session extended --extension "/path/to/ext" open "https://example.com"
```

## Best Practices

1. **Use descriptive session names** - `admin`, `user`, `dev`, `staging`
2. **Close sessions when done** - Free up resources
3. **Save state for reuse** - Avoid re-authentication
4. **Isolate test scenarios** - Each test gets fresh session
5. **Clean up in CI/CD** - Ensure sessions close on pipeline exit
