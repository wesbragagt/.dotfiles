# Eval 0: Background process (with skill)

## Steps

1. Read the tmux skill at `/home/wesbragagt/.claude/skills/tmux/SKILL.md`.
2. Created a detached tmux session named `claude-eval-bg-with` running `sleep 3 && echo BUILD_DONE_WITH; exec bash` (the trailing `exec bash` keeps the pane alive after the command finishes so output remains capturable — the first attempt without it caused the session to exit before capture).
   - `tmux new-session -d -s claude-eval-bg-with 'sleep 3 && echo BUILD_DONE_WITH; exec bash'`
3. Waited ~4 seconds, then captured the pane:
   - `tmux capture-pane -t claude-eval-bg-with -p -S -100`
4. Killed only the session created here: `tmux kill-session -t claude-eval-bg-with`.

## Captured output (proof)

```
BUILD_DONE_WITH
[wesbragagt@icebox .claude]$
```

`BUILD_DONE_WITH` is present — process completed successfully.
