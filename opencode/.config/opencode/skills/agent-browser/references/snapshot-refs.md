# Snapshot Refs System

## Overview

The snapshot refs system is designed to minimize token usage when AI agents interact with web pages. Instead of sending full DOM content (3,000-5,000 tokens per action), agent-browser generates compact snapshots with unique reference identifiers requiring only 200-400 tokens per interaction.

## How It Works

```
Traditional approach:  Full HTML → Parse → Find element → Interact
agent-browser:         Compact snapshot → @refs assigned → Direct ref interaction
```

### Generating Refs

```bash
agent-browser snapshot -i
```

Output example:
```
@e1 button "Submit"
@e2 input[type=email] placeholder="Enter email"
@e3 input[type=password] placeholder="Password"
@e4 a "Forgot password?"
@e5 checkbox "Remember me"
```

### Using Refs

Refs can be used directly in commands:

```bash
agent-browser click @e1
agent-browser fill @e2 "user@example.com"
agent-browser fill @e3 "secretpassword"
agent-browser check @e5
```

## Ref Invalidation

**Critical**: Refs become invalid when page content changes.

Invalid after:
- Page navigation (`open`, `back`, `forward`)
- Form submissions
- AJAX/dynamic content updates
- Tab switches
- Iframe switches

**Always re-snapshot after page changes:**

```bash
agent-browser click @e1  # Submit form
agent-browser wait networkidle
agent-browser snapshot -i  # Get new refs!
# Now use new refs @e1, @e2, etc.
```

## Snapshot Options

| Option | Description | Use Case |
|--------|-------------|----------|
| `-i` | Interactive elements only | Most common - buttons, inputs, links |
| `-c` | Compact output | Reduce token usage further |
| `-d <n>` | Limit DOM depth | Deep nested structures |
| `-s "<selector>"` | Scope to CSS selector | Focus on specific region |

### Regional Snapshots

For complex pages, scope to specific areas:

```bash
# Only snapshot the form
agent-browser snapshot -i -s "form#login"

# Only snapshot results section
agent-browser snapshot -i -s ".search-results"

# Only snapshot navigation
agent-browser snapshot -i -s "nav"
```

## Best Practices

1. **Snapshot before first interaction** on any page
2. **Re-snapshot after any navigation** or dynamic update
3. **Use `-i` flag** to focus on interactive elements
4. **Scope with `-s`** on complex pages to reduce noise
5. **Verify visibility** before interacting: `agent-browser is visible @e1`

## Troubleshooting

### "Element not found" errors
- Ref is stale - re-snapshot the page
- Element not visible - check with `is visible`
- Element in iframe - switch with `iframe <selector>`

### Too many elements in snapshot
- Use `-s` to scope to specific region
- Use `-d` to limit depth
- Target specific container elements
