---
name: tmux
description: Manage tmux sessions, windows, and panes from the CLI — list state, read pane output, send keys/commands, create or kill sessions and windows, and inspect long-running terminal work. Use this skill whenever the user mentions tmux, asks to check what's running in another terminal, wants to start a background process in a tmux session, send a command to a running pane, capture or tail output from a tmux pane, attach context from a pane, or troubleshoot a stuck tmux process — even if they don't explicitly say "tmux command."
---

# tmux

Drive tmux non-interactively via `tmux` CLI subcommands. The skill avoids attaching (which blocks). All operations either return text or mutate state and exit.

## Targets

Most commands take `-t <target>`. Targets resolve hierarchically:

- Session: `mysession` or `$1` (session id)
- Window: `mysession:0` or `mysession:winname`
- Pane: `mysession:0.1` (window 0, pane 1) or `%3` (pane id)

When unsure of the exact name, list first (see Inspecting state) and use ids — they're stable across renames.

## Where am I?

If you (the agent) are running inside tmux, you can discover your own context without guessing:

```bash
echo "$TMUX"                              # non-empty if inside tmux
tmux display-message -p '#S'              # current session name
tmux display-message -p '#W'              # current window name
tmux display-message -p '#{session_id} #{window_id} #{pane_id}'
```

From there, list sibling windows in the same session and target them directly:

```bash
SESSION=$(tmux display-message -p '#S')
tmux list-windows -t "$SESSION" -F '#{window_index}: #{window_name} (#{pane_current_command})'
tmux send-keys -t "$SESSION:1" 'echo hi' Enter      # send to window 1 of current session
tmux capture-pane -t "$SESSION:1" -p                # read window 1's pane
```

This is the right pattern when the user says things like "check the other window" or "send X to the build pane" — the agent's own session is the implicit scope.

## Inspecting state

```bash
tmux ls                                     # list sessions
tmux list-windows -t <session>              # windows in a session
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_id} #{pane_current_command} #{pane_pid}'
```

The `-F` format flag is the right tool when you need machine-parseable output. Useful fields: `pane_id`, `pane_pid`, `pane_current_command`, `pane_current_path`, `window_name`, `session_name`, `pane_active`.

## Reading pane output

```bash
tmux capture-pane -t <pane> -p              # current visible screen, printed to stdout
tmux capture-pane -t <pane> -p -S -2000     # include last 2000 lines of scrollback
tmux capture-pane -t <pane> -p -S - -E -    # entire scrollback buffer
```

`-p` prints to stdout; without it, capture goes to a paste buffer. `-S` is start line (negative = scrollback), `-E` is end. Use larger `-S` values to grab more history when diagnosing what happened earlier.

For long-running processes, capture periodically rather than attaching — attaching blocks and isn't possible from a non-interactive session anyway.

## Sending keys and commands

```bash
tmux send-keys -t <pane> 'echo hello' Enter
tmux send-keys -t <pane> C-c                # send Ctrl-C
tmux send-keys -t <pane> 'vim file.txt' Enter
```

Key names matter: `Enter` (or `C-m`) submits a command. Without it, the text just sits at the prompt. `C-c`, `C-d`, `Escape`, `Up`, `PageUp`, etc. are all valid. Multiple key arguments are sent in sequence.

Quoting: single-quote the literal text to avoid shell interpolation. If the text contains a single quote, use `"..."` and escape as needed.

After sending a command, give it a moment, then `capture-pane -p` to see the result. Don't assume it finished — check.

## Creating sessions and windows

```bash
tmux new-session -d -s <name>                       # detached new session
tmux new-session -d -s <name> -c /path/to/cwd       # with starting directory
tmux new-session -d -s <name> 'long-running-cmd'    # run a command on launch

tmux new-window -t <session>                        # new window in existing session
tmux new-window -t <session> -n <winname> -c <cwd> '<cmd>'

tmux split-window -t <pane> -h                      # split horizontally (side by side)
tmux split-window -t <pane> -v                      # split vertically (top/bottom)
```

`-d` keeps it detached — critical for non-interactive use. Without `-d`, tmux tries to attach and hangs.

If the session already exists, `new-session -A -s <name>` attaches-or-creates idempotently (use `-d -A` for detached idempotent create).

## Killing things

**Never run `tmux kill-server`.** It destroys every session on the machine — including in-progress work the user cares about. There is no legitimate "cleanup" or "fresh slate" reason to use it. If you think you need it, you don't.

Only kill scopes the user explicitly asked you to kill, or sessions you yourself created in this conversation:

```bash
tmux kill-pane -t <pane>
tmux kill-window -t <window>
tmux kill-session -t <session-you-created>
```

If a test or sandbox seems to require a clean global tmux state, stop and ask — use uniquely-named sessions for your own work instead.

## Common patterns

**Start a long build in the background and check on it:**

```bash
tmux new-session -d -s build -c /repo 'npm run build 2>&1'
# ... do other work ...
tmux capture-pane -t build -p -S -200
```

**Send a command to an existing dev server pane:**

```bash
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}'
# pick the right target, then:
tmux send-keys -t dev:0.0 'rs' Enter         # e.g., nodemon restart
```

**Capture state for debugging a stuck process:**

```bash
tmux list-panes -a -F '#{pane_id} #{pane_pid} #{pane_current_command}'
tmux capture-pane -t %4 -p -S -5000 > /tmp/pane-history.txt
```

## Driving another Claude Code (or other TUI) in a sibling window

A common case: the agent is running in one tmux window and wants to send a prompt to another Claude Code instance running in a different window of the same session.

```bash
SESSION=$(tmux display-message -p '#S')
TARGET="$SESSION:2"            # window index of the other Claude

# Short prompts: send-keys works directly. Use -l so words like "Enter" or
# "C-c" inside the prompt are treated as literal text, not key names.
tmux send-keys -t "$TARGET" -l 'summarize the README in 3 bullets'
tmux send-keys -t "$TARGET" Enter      # submit

# Long or multi-line prompts: avoid shell-escaping headaches by going through
# a paste buffer.
tmux load-buffer -b cc-prompt /tmp/prompt.txt   # or: echo "..." | tmux load-buffer -b cc-prompt -
tmux paste-buffer -t "$TARGET" -b cc-prompt -d  # -d deletes the buffer after paste
tmux send-keys -t "$TARGET" Enter

# Wait for the response, then read it.
sleep 5
tmux capture-pane -t "$TARGET" -p -S -200
```

Notes:
- Claude Code's response streams in over time. Don't capture immediately — sleep, then capture, and re-capture if needed until you see the prompt symbol return.
- `send-keys -l` (literal mode) is the safe default for user-supplied text. Without `-l`, tokens like `Enter`, `Space`, `C-c` get interpreted as keys.
- Sending `Enter` is a separate call after the text — Claude Code submits on Enter at the prompt.

## Gotchas

- **Don't attach.** `tmux attach` blocks the calling shell. Use `capture-pane` to read state instead.
- **`Enter` is required** to actually run a sent command. Forgetting it is the #1 mistake.
- **Wait before reading output.** A command sent via `send-keys` runs asynchronously — capture too soon and you'll see a blank prompt. For commands you expect to take time, sleep briefly or poll.
- **Pane indices renumber** when panes are killed unless `renumber-windows` is off. Pane ids (`%N`) and session ids (`$N`) are stable — prefer them for scripts.
- **Server may not be running.** `tmux ls` exits non-zero with "no server running" if there are no sessions. Treat that as "zero sessions," not an error.
- **Panes die when the command finishes.** A session created with `tmux new-session -d -s build 'npm run build'` will close as soon as `npm run build` exits, taking your output with it before you can capture it. Two ways around this:
  - Append a hold: `'npm run build; exec bash'` (or `; sleep 60`) keeps the pane alive after the command exits.
  - Set remain-on-exit: `tmux set-option -t <session> remain-on-exit on` before the command runs — the pane stays in a "dead" state and `capture-pane` still works.
  - For short commands you only need the final output of, `capture-pane` *during* the run (before it exits) also works.
