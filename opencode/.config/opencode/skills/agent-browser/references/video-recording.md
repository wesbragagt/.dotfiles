# Video Recording

## Overview

agent-browser can record browser sessions as video for debugging, documentation, or evidence collection.

## Basic Recording

```bash
# Start recording
agent-browser record start

# Perform actions
agent-browser open "https://example.com"
agent-browser snapshot -i
agent-browser click @e1
# ... more actions ...

# Stop and save recording
agent-browser record stop
```

## Recording Options

### Output Path

```bash
agent-browser record start --output recording.webm
agent-browser record stop
```

### Video Quality

```bash
# Higher quality (larger file)
agent-browser record start --quality high

# Lower quality (smaller file, faster)
agent-browser record start --quality low
```

## Recording Workflow

### Start Recording

```bash
agent-browser record start [--output <path>] [--quality <level>]
```

Recording begins immediately. All subsequent browser activity is captured.

### Stop Recording

```bash
agent-browser record stop
```

Saves the video file and returns the path.

### Restart Recording

```bash
agent-browser record restart
```

Stops current recording, saves it, and starts a new one. Useful for separating test scenarios.

## Use Cases

### Test Documentation

Record test execution for review:

```bash
agent-browser record start --output "test-login-flow.webm"

agent-browser open "https://example.com/login"
agent-browser wait networkidle
agent-browser snapshot -i
agent-browser fill @e1 "testuser"
agent-browser fill @e2 "password"
agent-browser click @e3
agent-browser wait url "dashboard"
agent-browser screenshot

agent-browser record stop
```

### Debugging Failures

Capture what happened during a failed test:

```bash
agent-browser record start --output "debug-$(date +%s).webm"

# Run test steps
if ! run_test_scenario; then
    echo "Test failed - video saved for review"
fi

agent-browser record stop
```

### Multiple Scenarios

Separate recordings for different test cases:

```bash
# Scenario 1
agent-browser record start --output "scenario-1.webm"
# ... test steps ...
agent-browser record stop

# Scenario 2
agent-browser record start --output "scenario-2.webm"
# ... test steps ...
agent-browser record stop
```

Or use restart:

```bash
agent-browser record start --output "tests.webm"

# Scenario 1
# ... test steps ...
agent-browser record restart  # Saves "tests.webm", starts "tests-1.webm"

# Scenario 2
# ... test steps ...
agent-browser record stop  # Saves "tests-1.webm"
```

## Integration with CI/CD

### GitHub Actions

```yaml
- name: Run browser tests
  run: |
    agent-browser record start --output "test-recording.webm"
    npm run e2e-tests
    agent-browser record stop

- name: Upload recording on failure
  if: failure()
  uses: actions/upload-artifact@v3
  with:
    name: test-recording
    path: test-recording.webm
```

### GitLab CI

```yaml
test:
  script:
    - agent-browser record start --output recording.webm
    - npm run e2e-tests
    - agent-browser record stop
  artifacts:
    when: on_failure
    paths:
      - recording.webm
```

## Performance Considerations

1. **Recording adds overhead** - Tests run slightly slower
2. **Disk space** - Videos can be large for long sessions
3. **CI storage limits** - Compress or limit recording length
4. **Headed mode recommended** - Better visual quality

## Combining with Screenshots

Use both for different purposes:

```bash
agent-browser record start

# Video captures entire flow
agent-browser open "https://example.com"
agent-browser snapshot -i
agent-browser fill @e1 "data"

# Screenshot captures specific state
agent-browser screenshot --output "form-filled.png"

agent-browser click @e2
agent-browser wait networkidle

# Another screenshot
agent-browser screenshot --output "result.png"

agent-browser record stop
```

## Troubleshooting

### Recording not starting
- Ensure browser is open first
- Check disk space
- Verify output path is writable

### Poor video quality
- Use `--headed` mode
- Increase `--quality` setting
- Set appropriate viewport size

### Large file sizes
- Use lower quality setting
- Record shorter segments
- Compress after recording
