# Background tmux session eval

## Steps
1. Created detached session: `tmux new-session -d -s claude-eval-bg-without "sleep 3 && echo BUILD_DONE_WITHOUT; sleep 30"` (added trailing sleep so pane stays alive long enough to capture; first attempt without it lost the pane immediately on command completion).
2. Waited 4s, captured pane: `tmux capture-pane -t claude-eval-bg-without -p`.
3. Killed only my own session: `tmux kill-session -t claude-eval-bg-without`.

## Captured pane output
```
BUILD_DONE_WITHOUT
```

Confirmed: `BUILD_DONE_WITHOUT` appears in the pane output.
