#!/bin/bash
set -euo pipefail

MAX_ITERATIONS=10
VERIFY_CMD=""
AGENT_CMD=""
PROMPT_FILES=()
PROMPT_TEXT=""
TASKS_FILE=""

usage() {
  cat <<EOF
Usage: ralph -c 'command' [options] [-p 'prompt' | -f FILE | < prompt.txt]

Run an agentic CLI in a Ralph Loop (iterates until objective success).

Options:
  -c 'cmd'     Agent command to run (e.g., 'opencode run', 'claude code')
  -p 'text'    Prompt text (can be combined with -f files)
  -v 'cmd'     Verification command to check success (default: exit code 0)
  -t [GLOB]    Verify via tasks.yaml glob (default: prd/**/tasks.yaml, auto-enabled)
  -v 'cmd'     Verification command (overrides tasks.yaml check)
  -l N         Max iterations/loops (default: 10)
  -f FILE      Read prompt from file (can be used multiple times)

Examples:
  ralph -c 'opencode run' -p "Fix the bug in auth.ts"
  ralph -c 'claude code' -v 'npm test' -f prompt.md
  ralph -c 'opencode run' -f context.md -f task.md -f rules.md
  ralph -c 'opencode run' -p "Focus on tests" -f context.md -f task.md
  ralph -c 'opencode run' -t tasks.yaml -f task.md
  cat task.md | ralph -c 'opencode run' -v 'cargo test' -l 5

The loop runs the agent, then verifies with -v command (if provided).
Success = verification exits 0, or agent exits 0 if no -v given.
EOF
  exit "${1:-0}"
}

for arg in "$@"; do
  case "$arg" in
    --help) usage 0 ;;
  esac
done

while getopts "c:p:v:t:l:f:h" opt; do
  case "$opt" in
    c) AGENT_CMD="$OPTARG" ;;
    p) PROMPT_TEXT="$OPTARG" ;;
    v) VERIFY_CMD="$OPTARG" ;;
    t) TASKS_FILE="${OPTARG:-prd/**/tasks.yaml}" ;;
    v) VERIFY_CMD="$OPTARG"; TASKS_FILE="" ;;
    l) MAX_ITERATIONS="$OPTARG" ;;
    f) PROMPT_FILES+=("$OPTARG") ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
done
shift $((OPTIND - 1))

[[ -z "$AGENT_CMD" ]] && { echo "Error: -c command required" >&2; usage 1; }

if [[ -z "$TASKS_FILE" && -z "$VERIFY_CMD" ]]; then
  TASKS_FILE="prd/**/tasks.yaml"
fi

if [[ -n "$TASKS_FILE" ]]; then
  VERIFY_CMD="[[ \$(yq ea '[.tasks[].status] | flatten | unique | . == [\"done\"]' $TASKS_FILE) == 'true' ]]"
fi

PROMPT=""

if [[ -n "$PROMPT_TEXT" ]]; then
  PROMPT+="$PROMPT_TEXT"$'\n'
fi

if [[ ${#PROMPT_FILES[@]} -gt 0 ]]; then
  for f in "${PROMPT_FILES[@]}"; do
    PROMPT+="$(cat "$f")"$'\n'
  done
fi

if [[ -z "$PROMPT" ]]; then
  PROMPT=$(cat)
fi

[[ -z "$PROMPT" ]] && { echo "Error: No prompt provided via -p, -f, or stdin" >&2; exit 1; }

WORKDIR=$(mktemp -d)
PROMPT_PATH="$WORKDIR/prompt.md"
PROGRESS_PATH="$WORKDIR/progress.md"
ITERATION_LOG="$WORKDIR/iterations.log"

echo "$PROMPT" > "$PROMPT_PATH"
echo "# Progress Log" > "$PROGRESS_PATH"

cleanup() {
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

echo "Starting Ralph Loop (max $MAX_ITERATIONS iterations)"
echo "Agent: $AGENT_CMD"
if [[ -n "$TASKS_FILE" ]]; then
  echo "Verify: tasks.yaml ($TASKS_FILE)"
elif [[ -n "$VERIFY_CMD" ]]; then
  echo "Verify: $VERIFY_CMD"
fi
echo ""

iteration=1
while [[ $iteration -le $MAX_ITERATIONS ]]; do
  echo "=== Iteration $iteration/$MAX_ITERATIONS ==="
  echo "[$(date -Iseconds)] Starting iteration $iteration" >> "$ITERATION_LOG"

  ITERATION_PROMPT="$WORKDIR/iter_prompt.md"
  cat "$PROMPT_PATH" > "$ITERATION_PROMPT"
  
  if [[ $iteration -gt 1 ]]; then
    cat >> "$ITERATION_PROMPT" <<EOF

---
## Previous Attempt Context

This is iteration $iteration. Previous attempts did not pass verification.
Review what was tried and try a different approach.

EOF
    cat "$PROGRESS_PATH" >> "$ITERATION_PROMPT"
  fi

  if echo "$AGENT_CMD" | grep -qE 'opencode|claude'; then
    $AGENT_CMD < "$ITERATION_PROMPT" 2>&1 | tee -a "$ITERATION_LOG" || true
  else
    $AGENT_CMD < "$ITERATION_PROMPT" 2>&1 | tee -a "$ITERATION_LOG" || true
  fi

  echo ""
  
  if [[ -n "$VERIFY_CMD" ]]; then
    echo "Running verification: $VERIFY_CMD"
    if eval "$VERIFY_CMD" 2>&1 | tee -a "$ITERATION_LOG"; then
      echo ""
      echo "✓ Verification passed after $iteration iteration(s)"
      echo "[$(date -Iseconds)] SUCCESS on iteration $iteration" >> "$ITERATION_LOG"
      exit 0
    else
      echo "✗ Verification failed"
      echo "[$(date -Iseconds)] FAILED iteration $iteration" >> "$ITERATION_LOG"
    fi
  else
    echo "No verification command - checking agent exit status"
    echo "✓ Agent completed (iteration $iteration)"
    exit 0
  fi

  echo "" >> "$PROGRESS_PATH"
  echo "## Iteration $iteration - Failed" >> "$PROGRESS_PATH"
  echo "Timestamp: $(date -Iseconds)" >> "$PROGRESS_PATH"
  
  ((iteration++))
  echo ""
done

echo ""
echo "✗ Max iterations ($MAX_ITERATIONS) reached without success"
echo "Progress log saved to: $PROGRESS_PATH"
exit 1
