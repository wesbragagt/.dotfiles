# Agent Browser Skill

Automate browser interactions for web testing, form completion, screenshots, and data extraction using `agent-browser` CLI.

## Core Workflow

1. **Navigate** using `agent-browser open <url>`
2. **Snapshot** with `agent-browser snapshot -i` to get interactive elements with refs (@e1, @e2, etc.)
3. **Interact** using those refs from the snapshot
4. **Re-snapshot** after significant page changes (refs become invalid)

## Commands Reference

### Navigation

```bash
agent-browser open <url>              # Open URL in browser
agent-browser back                    # Navigate back
agent-browser forward                 # Navigate forward
agent-browser reload                  # Reload current page
agent-browser close                   # Close browser
agent-browser connect                 # Connect to existing browser
```

### Snapshots & Analysis

```bash
agent-browser snapshot                # Full page snapshot
agent-browser snapshot -i             # Interactive elements only (recommended)
agent-browser snapshot -c             # Compact output
agent-browser snapshot -d <depth>     # Limit DOM depth
agent-browser snapshot -s "<selector>" # Scope to CSS selector
```

**Important**: Refs like `@e1`, `@e2` are assigned to elements. These refs become **invalid after page changes** - always re-snapshot after navigation or dynamic updates.

### Element Interactions

```bash
agent-browser click @e1               # Click element
agent-browser dblclick @e1            # Double-click
agent-browser focus @e1               # Focus element
agent-browser fill @e1 "text"         # Clear and fill input
agent-browser type @e1 "text"         # Type without clearing
agent-browser press @e1 "Enter"       # Press key
agent-browser keydown @e1 "Shift"     # Key down
agent-browser keyup @e1 "Shift"       # Key up
agent-browser hover @e1               # Hover over element
agent-browser check @e1               # Check checkbox
agent-browser uncheck @e1             # Uncheck checkbox
agent-browser select @e1 "option"     # Select dropdown option
agent-browser scroll @e1              # Scroll element into view
agent-browser drag @e1 @e2            # Drag from e1 to e2
agent-browser upload @e1 "/path/file" # Upload file
```

### Information Retrieval

```bash
agent-browser get text @e1            # Get element text
agent-browser get html @e1            # Get element HTML
agent-browser get value @e1           # Get input value
agent-browser get attributes @e1      # Get all attributes
agent-browser get title               # Get page title
agent-browser get url                 # Get current URL
agent-browser get count "<selector>"  # Count matching elements
agent-browser get bbox @e1            # Get bounding box
agent-browser get styles @e1          # Get computed styles
```

### State Checking

```bash
agent-browser is visible @e1          # Check visibility
agent-browser is enabled @e1          # Check if enabled
agent-browser is checked @e1          # Check if checked
```

### Visual Capture

```bash
agent-browser screenshot              # Viewport screenshot
agent-browser screenshot --full       # Full page screenshot
agent-browser pdf                     # Export as PDF
```

### Video Recording

```bash
agent-browser record start            # Start recording
agent-browser record stop             # Stop and save
agent-browser record restart          # Restart recording
```

### Wait Conditions

```bash
agent-browser wait element "<selector>"       # Wait for element
agent-browser wait text "content"             # Wait for text
agent-browser wait url "pattern"              # Wait for URL match
agent-browser wait networkidle                # Wait for network idle
agent-browser wait js "expression"            # Wait for JS condition
```

### Mouse Control

```bash
agent-browser mouse move <x> <y>      # Move mouse
agent-browser mouse down              # Mouse button down
agent-browser mouse up                # Mouse button up
agent-browser mouse wheel <dx> <dy>   # Scroll wheel
```

### Semantic Locators

Find elements by semantic attributes instead of refs:

```bash
agent-browser find role "button"      # By ARIA role
agent-browser find text "Click me"    # By text content
agent-browser find label "Email"      # By label
agent-browser find placeholder "..."  # By placeholder
agent-browser find alt "logo"         # By alt text
agent-browser find title "..."        # By title attribute
agent-browser find testid "submit"    # By data-testid
agent-browser find first "<selector>" # First matching
agent-browser find last "<selector>"  # Last matching
agent-browser find nth "<selector>" 2 # Nth matching (0-indexed)
```

### Browser Configuration

```bash
agent-browser viewport <width> <height>       # Set viewport size
agent-browser device "iPhone 12"              # Emulate device
agent-browser geolocation <lat> <lon>         # Set geolocation
agent-browser offline true|false              # Toggle offline mode
agent-browser headers '{"X-Custom":"value"}'  # Set HTTP headers
agent-browser credentials "user" "pass"       # HTTP auth
agent-browser colorscheme dark|light          # Color scheme preference
```

### Storage Management

```bash
agent-browser cookies get                     # Get all cookies
agent-browser cookies get "name"              # Get specific cookie
agent-browser cookies set "name" "value"      # Set cookie
agent-browser cookies clear                   # Clear all cookies
agent-browser storage get "key"               # Get localStorage item
agent-browser storage set "key" "value"       # Set localStorage item
agent-browser storage clear                   # Clear localStorage
```

### Session State

```bash
agent-browser state save auth.json            # Save browser state
agent-browser state load auth.json            # Load browser state
```

### Network Control

```bash
agent-browser route "<pattern>" block         # Block requests
agent-browser route "<pattern>" mock <json>   # Mock response
agent-browser requests                        # List tracked requests
agent-browser requests clear                  # Clear request log
```

### Advanced Features

```bash
agent-browser tabs                            # List open tabs
agent-browser tab new                         # Open new tab
agent-browser tab switch <index>              # Switch to tab
agent-browser tab close                       # Close current tab
agent-browser iframe <selector>               # Switch to iframe
agent-browser iframe main                     # Switch to main frame
agent-browser dialog accept                   # Accept dialog
agent-browser dialog dismiss                  # Dismiss dialog
agent-browser eval "js expression"            # Execute JavaScript
```

## Global Options

| Option | Description |
|--------|-------------|
| `--session <name>` | Use isolated browser session |
| `--json` | Output in JSON format |
| `--headed` | Show browser window (visible mode) |
| `--proxy <url>` | Use proxy server |
| `--extension <path>` | Load browser extension |
| `--executable-path <path>` | Use custom browser binary |

## Common Patterns

### Authentication Flow

```bash
# Login and save state
agent-browser open "https://example.com/login"
agent-browser snapshot -i
agent-browser fill @e1 "username"
agent-browser fill @e2 "password"
agent-browser click @e3
agent-browser wait networkidle
agent-browser state save auth.json

# Later: restore authenticated session
agent-browser state load auth.json
agent-browser open "https://example.com/dashboard"
```

### Form Automation

```bash
agent-browser open "https://example.com/form"
agent-browser wait networkidle
agent-browser snapshot -i

# Fill form fields using refs
agent-browser fill @e1 "John Doe"
agent-browser fill @e2 "john@example.com"
agent-browser select @e3 "Option A"
agent-browser check @e4
agent-browser click @e5  # Submit button

agent-browser wait url "success"
agent-browser screenshot
```

### Data Extraction

```bash
agent-browser open "https://example.com/data"
agent-browser wait element ".results"
agent-browser snapshot -i -s ".results"

# Extract data
agent-browser get text @e1
agent-browser get html @e2
agent-browser eval "JSON.stringify([...document.querySelectorAll('.item')].map(e => e.textContent))"
```

## Best Practices

1. **Always snapshot before interacting** - Get fresh refs before clicking/filling
2. **Re-snapshot after navigation** - Refs become invalid after page changes
3. **Use regional snapshots** - Scope with `-s` for complex pages
4. **Wait appropriately** - Use `wait networkidle` after navigation
5. **Save auth state** - Don't re-login for every session
6. **Use --headed for debugging** - See what the browser is doing
