---
name: tmux-job-runner
description: Dispatch Claude Code tasks in detached tmux windows with automatic logging. Use when the user wants to run parallel tasks, background jobs, long-running operations, or mentions tmux, detached sessions, or job orchestration.
---

# tmux Job Runner

Run Claude Code tasks in detached tmux windows with automatic logging and structured workspaces.

## Core Pattern

```bash
JOB="task-name"
WS=".claude-local/jobs/$JOB"
mkdir -p "$WS"
tmux new-window -n "$JOB" "
  claude 'Your task. Document progress in $WS/notes.md' 2>&1 | tee \"$WS/log.txt\";
  exec bash
"
```

## Workspace Structure

Each job gets an isolated workspace:

```
.claude-local/jobs/<job-name>/
├── log.txt       # Full execution output (auto-captured via tee)
├── notes.md      # Progress, decisions, questions, results
└── artifacts/    # Generated files and outputs
```

## Dispatcher Script

Use the dispatcher script at `~/.claude/skills/tmux/dispatch.sh`

## Common Commands

```bash
# Dispatch a new job
~/.claude/skills/tmux/dispatch.sh "api-server" "Build REST API with auth"

# Monitor job output (live)
tail -f .claude-local/jobs/api-server/log.txt

# Attach to job window (for interaction)
tmux select-window -t api-server

# Check progress
cat .claude-local/jobs/api-server/notes.md

# List all jobs
ls -1 .claude-local/jobs/

# View job artifacts
ls -lh .claude-local/jobs/api-server/artifacts/

# List active tmux windows
tmux list-windows
```

## Multi-Job Coordination

Jobs can reference each other's documentation for coordinated work:

```bash
# Job 1: Backend API
stack/.claude/skills/tmux/dispatch.sh "backend-api" "
Build REST API with endpoints for users and posts.
Document all endpoints, request/response formats in notes.md.
"

# Job 2: Frontend (reads backend docs)
stack/.claude/skills/tmux/dispatch.sh "frontend-ui" "
Build React frontend consuming the API.
Read API specification from: .claude-local/jobs/backend-api/notes.md
Document component structure in your notes.md.
"

# Job 3: Tests (reads both)
stack/.claude/skills/tmux/dispatch.sh "integration-tests" "
Write integration tests.
Read specs from:
- .claude-local/jobs/backend-api/notes.md
- .claude-local/jobs/frontend-ui/notes.md
"
```

## Best Practices

**Output Style**: Regarding output be extremely concise. Sacrifice grammar for the sake of concision.

**Job Naming**: Use descriptive, slug-style names (`user-auth`, `data-migration`, `test-suite`)

**Task Instructions**: Be specific about:
- What to build/accomplish
- Where to document progress
- What questions need human input
- Success criteria

**Monitoring Strategy**:
- Use `tail -f` for real-time logs
- Check `notes.md` for high-level progress
- Attach to window only when interaction needed

**Handling Paused Jobs**: If a job needs input and pauses:
```bash
tmux select-window -t <job-name>
# Respond to Claude's question
# Detach with Ctrl-b d
```

## Workflow Examples

### Parallel Development Tasks
```bash
stack/.claude/skills/tmux/dispatch.sh "database" "Design and implement user schema"
stack/.claude/skills/tmux/dispatch.sh "api-layer" "Build API routes (check database job notes)"
stack/.claude/skills/tmux/dispatch.sh "frontend" "Build UI (check api-layer job notes)"
```

### Long-Running Analysis
```bash
stack/.claude/skills/tmux/dispatch.sh "log-analysis" "
Analyze all logs in ./logs/ directory.
Generate report in artifacts/report.md.
Process may take 20+ minutes - work independently.
"
# Detach immediately, check back later
tail -f .claude-local/jobs/log-analysis/notes.md
```

### Iterative Refinement
```bash
stack/.claude/skills/tmux/dispatch.sh "prototype-v1" "Build initial prototype"
# Wait for completion
cat .claude-local/jobs/prototype-v1/notes.md
# Review and start v2
stack/.claude/skills/tmux/dispatch.sh "prototype-v2" "
Refine prototype based on v1 feedback.
Read v1 notes: .claude-local/jobs/prototype-v1/notes.md
"
```

## Technical Notes

- `exec bash` keeps window open after Claude exits (useful for reviewing output)
- `tee` captures stdout/stderr to log.txt while displaying in real-time
- Detach anytime with `Ctrl-b d` (standard tmux keybinding)
- Jobs requiring input will pause - attach to the window to respond
- Exit codes are captured and displayed at job completion
- All jobs are independent processes - can run truly parallel work

## Troubleshooting

**Job not appearing**: Check `tmux list-windows` to verify window was created

**Can't find job workspace**: Ensure you're in the project root where `.claude-local/` exists

**Job exited immediately**: Check log.txt for errors, may be task instruction issue

**Lost track of jobs**: Run `ls .claude-local/jobs/` and check each notes.md
