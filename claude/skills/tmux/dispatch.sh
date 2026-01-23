#!/bin/bash
# Usage: ./dispatch.sh <job-name> <task-description> [model]
# model: optional - haiku, sonnet, opus (default: sonnet)

JOB="$1"
TASK="$2"
MODEL="${3:-sonnet}"
WS=".claude-local/jobs/$JOB"

# Minimal tools for autonomous agents
TOOLS="Bash,Read,Edit,Write,Glob,Grep"

if [ -z "$JOB" ] || [ -z "$TASK" ]; then
  echo "Usage: $0 <job-name> <task-description> [model]"
  echo "  model: haiku, sonnet, opus (default: sonnet)"
  exit 1
fi

mkdir -p "$WS/artifacts"

# Write prompt to file to avoid shell quoting issues
# Use printf to safely write task content without shell interpretation
{
  printf 'Task: %s\n\n' "$TASK"
  cat << 'PROMPT_TEMPLATE'
Documentation Requirements:
- Maintain notes.md in your job directory with:
  * Current status and progress
  * Key decisions and rationale
  * Questions needing input (prefix with ⚠️)
  * Final results and outcomes

Work independently. Document thoroughly.

Output Style: Be extremely concise. Sacrifice grammar for concision.
PROMPT_TEMPLATE
} > "$WS/prompt.txt"

# Create runner script - all paths are hardcoded after variable expansion
cat > "$WS/run.sh" << 'RUNNER_END'
#!/bin/bash
RUNNER_END

# Append with variable expansion for paths
cat >> "$WS/run.sh" << RUNNER_VARS
WORKDIR="$(pwd)"
JOBDIR="$WS"
MODEL="$MODEL"
JOBNAME="$JOB"
TOOLS="$TOOLS"
RUNNER_VARS

# Append the rest without expansion (uses single-quoted heredoc marker)
cat >> "$WS/run.sh" << 'RUNNER_BODY'
cd "$WORKDIR" || exit 1
echo '═══════════════════════════════════════════════════'
echo "Job: $JOBNAME (model: $MODEL)"
echo "Tools: $TOOLS"
echo 'Detach: Ctrl-b d | Stop: Ctrl-c'
echo '═══════════════════════════════════════════════════'
echo ''
# Export vars so they're available inside script -c subshell
export CLAUDE_PROMPT="$(cat "$JOBDIR/prompt.txt")"
export MODEL
export TOOLS
script -q -c 'FORCE_COLOR=1 claude --model "$MODEL" --permission-mode bypassPermissions --tools "$TOOLS" --verbose "$CLAUDE_PROMPT"' "$JOBDIR/log.txt"
EXIT_CODE=$?
echo ''
echo '═══════════════════════════════════════════════════'
echo "Job completed with exit code: $EXIT_CODE"
echo 'Press Enter to close or wait...'
read -t 30
RUNNER_BODY

chmod +x "$WS/run.sh"
tmux new-window -n "$JOB" "$WS/run.sh"

echo "✓ Dispatched: $JOB (tools: $TOOLS)"
echo "  Attach:  tmux select-window -t $JOB"
echo "  Monitor: tail -f $WS/log.txt"
echo "  Notes:   cat $WS/notes.md"
