---
name: agent-browser
description: This skill should be used when the user needs to automate browser interactions, test UI workflows, verify page elements, take screenshots, upload files to forms, or interact with web applications during development and debugging. Use this skill for testing PDF upload dialogs, form interactions, dropdown selections, and visual verification of web pages.
version: 1.0.0
---

# Agent Browser Skill

Automate browser interactions for UI testing, debugging, and development iteration using Claude Code's agent-browser automation tool.

## Overview

This skill enables interactive browser automation directly from Claude Code, allowing you to:
- Launch browsers and navigate to URLs
- Inspect and interact with page elements
- Verify UI state and extract information
- Test workflows like form submissions and file uploads
- Take screenshots for visual verification

## When This Skill Applies

This skill activates when you need to:
- **Test UI components** - Verify buttons, forms, dropdowns work correctly
- **Inspect page structure** - Examine DOM elements and their properties
- **Automate workflows** - Click, fill, and submit forms programmatically
- **Upload files** - Test file inputs and upload flows
- **Verify visual state** - Take screenshots at different stages
- **Debug page issues** - Check element visibility, attributes, content

## Agent-Browser CLI Reference

```
agent-browser - fast browser automation CLI for AI agents

Usage: agent-browser <command> [args] [options]

Core Commands:
  open <url>                 Navigate to URL
  click <sel>                Click element (or @ref)
  dblclick <sel>             Double-click element
  type <sel> <text>          Type into element
  fill <sel> <text>          Clear and fill
  press <key>                Press key (Enter, Tab, Control+a)
  hover <sel>                Hover element
  focus <sel>                Focus element
  check <sel>                Check checkbox
  uncheck <sel>              Uncheck checkbox
  select <sel> <val...>      Select dropdown option
  drag <src> <dst>           Drag and drop
  upload <sel> <files...>    Upload files
  scroll <dir> [px]          Scroll (up/down/left/right)
  scrollintoview <sel>       Scroll element into view
  wait <sel|ms>              Wait for element or time
  screenshot [path]          Take screenshot
  pdf <path>                 Save as PDF
  snapshot                   Accessibility tree with refs (for AI)
  eval <js>                  Run JavaScript
  connect <port>             Connect to browser via CDP
  close                      Close browser

Navigation:
  back                       Go back
  forward                    Go forward
  reload                     Reload page

Get Info:  agent-browser get <what> [selector]
  text, html, value, attr <name>, title, url, count, box, styles

Check State:  agent-browser is <what> <selector>
  visible, enabled, checked

Find Elements:  agent-browser find <locator> <value> <action> [text]
  role, text, label, placeholder, alt, title, testid, first, last, nth

Mouse:  agent-browser mouse <action> [args]
  move <x> <y>, down [btn], up [btn], wheel <dy> [dx]

Browser Settings:  agent-browser set <setting> [value]
  viewport <w> <h>, device <name>, geo <lat> <lng>
  offline [on|off], headers <json>, credentials <user> <pass>
  media [dark|light] [reduced-motion]

Network:  agent-browser network <action>
  route <url> [--abort|--body <json>]
  unroute [url]
  requests [--clear] [--filter <pattern>]

Storage:
  cookies [get|set|clear]    Manage cookies
  storage <local|session>    Manage web storage

Tabs:
  tab [new|list|close|<n>]   Manage tabs

Debug:
  trace start|stop [path]    Record trace
  record start <path> [url]  Start video recording
  record stop                Stop and save video
  console [--clear]          View console logs
  errors [--clear]           View page errors
  highlight <sel>            Highlight element

Sessions:
  session                    Show current session name
  session list               List active sessions

Snapshot Options:
  -i, --interactive          Only interactive elements
  -c, --compact              Remove empty structural elements
  -d, --depth <n>            Limit tree depth
  -s, --selector <sel>       Scope to CSS selector

Options:
  --session <name>           Isolated session
  --headers <json>           HTTP headers for auth
  --executable-path <path>   Custom browser executable
  --json                     JSON output
  --full, -f                 Full page screenshot
  --headed                   Show browser window
  --debug                    Debug output

Examples:
  agent-browser open example.com
  agent-browser snapshot -i              # Interactive elements
  agent-browser click @e2                # Click by ref
  agent-browser fill @e3 "test@example.com"
  agent-browser screenshot --full
```

## Quick Examples

**Open a page and take screenshot:**
```bash
agent-browser open http://localhost:3000/instructions
agent-browser screenshot
```

**Click an element:**
```bash
agent-browser click "button[data-testid='submit']"
```

**Fill an input field:**
```bash
agent-browser fill "input[name='email']" "user@example.com"
```

**Select from dropdown:**
```bash
agent-browser select "select[name='biller']" "XPO Logistics"
```

**Take a snapshot (for AI):**
```bash
agent-browser snapshot --interactive
```

**Wait for element:**
```bash
agent-browser wait "div.success-message"
```

**Upload a file:**
```bash
agent-browser upload "input[type='file']" "~/Downloads/invoice.pdf"
```

## Real Use Cases from Development

### 1. **Testing 3PL Selector in PDF Upload Dialog**
When developing the 3PL instructions feature for PDF invoice extraction, agent-browser verified that:
- The dropdown selector appears with correct label: "3PL / Biller (Optional)"
- All billers from instruction sets populate in dropdown options
- Selection state persists when uploading files
- Selected biller name is passed to the extraction API

**Why it mattered:** Confirmed frontend integration with backend instructions data without manual browser testing.

### 2. **Verifying Page Navigation and Loading**
Used to test that specific routes load correctly:
- http://localhost:3000/instructions - Instructions management page
- http://localhost:3000/summary-charges/add-charges?brand=TCT - PDF upload dialog

**Why it mattered:** Quick verification that pages are accessible and rendering, catching routing errors early.

### 3. **Capturing Screenshots for Documentation**
Took snapshots at each test phase to document:
- Initial page state before interactions
- Dialog open with selector visible
- Form filled with test data
- Success states after submission

**Why it mattered:** Visual evidence that UI changes work as expected, useful for PRs and bug reports.

### 4. **Inspecting Element Structure**
Used `snapshot` command to:
- Verify SearchableSelect component rendered with correct props
- Check HTML hierarchy of dialogs and form elements
- Understand page layout before interacting

**Why it mattered:** Understanding page structure before writing selectors for clicks/fills.

### 5. **Testing Form Workflows**
Tested complete user journeys:
- Click "Import from PDF" button
- Select instruction set from dropdown
- Upload PDF file through file input
- Trigger extraction
- Wait for success toast

**Why it mattered:** Caught form submission issues, timing problems, and missing UI elements.

## Common Workflows

### Testing a PDF Upload Dialog

```bash
# 1. Navigate to the page
/browser open http://localhost:3000/summary-charges/add-charges?brand=TCT

# 2. Click "Import from PDF" button
/browser click "button:has-text('Import from PDF')"

# 3. Select instruction set from dropdown
/browser select "select.instruction-select" "Standard Warehouse Format"

# 4. Upload PDF file
/browser upload "input[type='file']" "~/Downloads/misen.pdf"

# 5. Click extract button
/browser click "button:has-text('Extract Charges')"

# 6. Wait for completion and verify
/browser wait ".success-toast" --timeout 30000
/browser screenshot
/browser inspect "table[data-testid='extracted-charges']"
```

### Testing Instructions Management

```bash
# Navigate to instructions page
/browser open http://localhost:3000/instructions

# Click "New Instruction Set"
/browser click "button:has-text('New Instruction Set')"

# Fill form fields
/browser fill "input[name='name']" "Test Warehouse Format"
/browser fill "textarea[name='instructions']" "## Invoice Structure\n- Invoice number: Top-right"

# Add biller tag
/browser click "button:has-text('Add Biller')"
/browser fill ".tag-input" "XPO Logistics"
/browser click "button:has-text('Add Tag')"

# Submit form
/browser click "button[type='submit']"

# Verify success
/browser wait ".success-toast"
/browser screenshot
```

### Debugging Page State

```bash
# Open page with issues
/browser open http://localhost:3000/summary-charges

# Inspect critical elements
/browser inspect "dialog"
/browser inspect "select"
/browser inspect "button[type='submit']"

# Take screenshots
/browser screenshot

# Verify form state
/browser inspect "form[data-testid='pdf-upload-form']"
```

## Element Selectors

The skill supports multiple selector formats:

- **CSS selectors**: `button.primary`, `input[data-testid='email']`
- **Text matching**: `button:has-text('Submit')`, `div:has-text('Error')`
- **Data attributes**: `[data-testid='submit']`, `[data-id='123']`
- **XPath** (when needed): Complex element queries

## Command Details

### navigate
Move to a new URL in the current session
```bash
/browser navigate http://localhost:3000/new-page
```

### click
Click an element and capture the result
```bash
/browser click ".submit-button"
```

### fill
Enter text into an input field
```bash
/browser fill "input[name='username']" "testuser"
/browser fill ".search-box" "query text"
```

### select
Choose an option from a dropdown
```bash
/browser select "select[name='option']" "Option Value"
```

### wait
Poll for element appearance with optional timeout (default 5000ms)
```bash
/browser wait ".modal-content" --timeout 10000
```

### inspect
Extract element structure and content information
```bash
/browser inspect ".data-table"
```

### upload
Submit a file through a file input
```bash
/browser upload "input[type='file']" "~/path/to/file.pdf"
```

## Tips & Best Practices

1. **Always start with `open`** - Initialize the browser session before other commands
2. **Use specific selectors** - Prefer `data-testid` attributes over generic selectors
3. **Check screenshots between steps** - Verify page state after interactions
4. **Increase timeout for slow operations** - PDF extraction may need 30-60 seconds
5. **Use inspect to understand page structure** - Before clicking/filling, inspect the element
6. **Handle async operations** - Use `wait` for dynamically loaded content
7. **Use text matching for buttons** - `button:has-text('Submit')` is often more reliable

## Example: Complete Feature Test

```bash
# Phase 1: Setup
/browser open http://localhost:3000/summary-charges/add-charges?brand=TCT

# Phase 2: Verify UI loaded
/browser inspect ".dialog-header"
/browser screenshot

# Phase 3: Test 3PL selector
/browser click "button:has-text('Import from PDF')"
/browser screenshot

# Phase 4: Select instruction set
/browser select ".instruction-select" "XPO Warehouse"
/browser screenshot

# Phase 5: Upload PDF
/browser upload "input[type='file']" "~/Downloads/test.pdf"
/browser screenshot

# Phase 6: Trigger extraction
/browser click "button:has-text('Extract Charges')"

# Phase 7: Wait and verify
/browser wait ".extracted-charges-table" --timeout 30000
/browser screenshot
/browser inspect "table"
```

## Troubleshooting

**Element not found:**
- Check the selector syntax
- Use `inspect` to understand the page structure
- Try text matching instead of specific selectors

**Click/fill not working:**
- Ensure element is visible and clickable
- Check if element requires scrolling into view
- Verify element is not disabled or hidden

**Timeout waiting for element:**
- Increase the timeout value
- Check console for JavaScript errors
- Use `screenshot` to see current page state

**File upload fails:**
- Verify file path exists (use absolute or ~/ paths)
- Check file input accepts the file type
- Ensure upload input is visible and accessible

## Integration with Development

This skill works best when:
- You have a dev server running (e.g., `pnpm run dev`)
- You know the URLs to test (localhost ports documented in project)
- You have test files available (PDFs, images, etc.)
- You're iterating on UI features and need quick verification

Use this skill in Claude Code workflows to:
1. Verify UI changes work as expected
2. Debug form interactions
3. Test file upload functionality
4. Screenshot progress for documentation
5. Validate workflow sequences
