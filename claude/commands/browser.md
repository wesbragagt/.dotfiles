# Browser QA Dispatch

Dispatch the qa-agent to perform browser-based QA testing via tmux.

## Usage

```
/browser <task-description>
```

## Arguments

- `$ARGUMENTS` - The QA task to perform (URL to test, feature to verify, workflow to check)

## Dispatch Command

Run this to dispatch the qa-agent:

```bash
~/.claude/skills/tmux/dispatch.sh "browser-qa" "You are performing browser-based QA testing.

## Task
$ARGUMENTS

## Browser Testing Instructions

Use agent-browser CLI for all browser interactions:

### Standard Flow
1. Open URL: \`agent-browser open <url>\`
2. Wait for load: \`agent-browser wait networkidle\`
3. Get element refs: \`agent-browser snapshot -i\`
4. Interact using refs: \`agent-browser click @e1\`, \`agent-browser fill @e2 \"text\"\`
5. Re-snapshot after page changes (refs invalidate)
6. Verify with: \`agent-browser get text @ref\`, \`agent-browser screenshot\`

### Key Commands
| Action | Command |
|--------|---------|
| Open URL | \`agent-browser open <url>\` |
| Snapshot | \`agent-browser snapshot -i\` |
| Click | \`agent-browser click @ref\` |
| Fill | \`agent-browser fill @ref \"text\"\` |
| Select | \`agent-browser select @ref \"option\"\` |
| Upload | \`agent-browser upload @ref \"path/to/file\"\` |
| Screenshot | \`agent-browser screenshot\` |
| Get text | \`agent-browser get text @ref\` |
| Get URL | \`agent-browser get url\` |
| Wait | \`agent-browser wait <selector|ms|networkidle>\` |

### Critical Rules
- ALWAYS re-snapshot after navigation or dynamic updates
- Use --headed flag to show browser window if debugging visually
- Take screenshots at each verification step

## Output Format

Report results as:
\`\`\`
[PASS] <what was verified>
  - Steps taken
  - Evidence: screenshot path or actual value

[FAIL] <what failed>
  - Expected: <expected behavior>
  - Actual: <what happened>
  - Screenshot: <path>
\`\`\`

## Final Summary

End with:
\`\`\`
Results: X/Y PASS
[PASS] item 1
[FAIL] item 2 - <brief reason>
\`\`\`
" sonnet
```

## What This Does

1. Creates a tmux window named `browser-qa`
2. Runs the qa-agent with browser-testing context
3. Agent uses `agent-browser` CLI to interact with pages
4. Results logged to `.claude-local/jobs/browser-qa/`

## Monitoring

```bash
# Watch the job
tmux select-window -t browser-qa

# Check logs
tail -f .claude-local/jobs/browser-qa/log.txt

# Read notes
cat .claude-local/jobs/browser-qa/notes.md
```

## Examples

```bash
# Test a login flow
/browser "Test login at http://localhost:3000/login with user@test.com / password123"

# Verify a form works
/browser "Verify the contact form at http://localhost:3000/contact submits successfully"

# Check page elements
/browser "Verify the dashboard at http://localhost:3000/dashboard shows user stats"

# Test file upload
/browser "Test PDF upload at http://localhost:3000/upload with ~/test.pdf"
```
