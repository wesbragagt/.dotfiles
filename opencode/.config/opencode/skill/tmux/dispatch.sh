#!/bin/bash
# Usage: ./dispatch.sh <job-name> <task-description> [model]
# model: optional - haiku, sonnet, opus (default: sonnet)

JOB="$1"
TASK="$2"
MODEL="${3:-sonnet}"
WS=".claude-local/jobs/$JOB"

if [ -z "$JOB" ] || [ -z "$TASK" ]; then
  echo "Usage: $0 <job-name> <task-description> [model]"
  echo "  model: haiku, sonnet, opus (default: sonnet)"
  exit 1
fi

mkdir -p "$WS/artifacts"

tmux new-window -n "$JOB" "
  echo '═══════════════════════════════════════════════════';
  echo 'Job: $JOB (model: $MODEL)';
  echo 'Detach: Ctrl-b d | Stop: Ctrl-c';
  echo '═══════════════════════════════════════════════════';
  echo '';
  script -q -c \"FORCE_COLOR=1 claude --model $MODEL --dangerously-skip-permissions --verbose '\
Task: $TASK

Documentation Requirements:
- Maintain $WS/notes.md with:
  * Current status and progress
  * Key decisions and rationale
  * Questions needing input (prefix with ⚠️)
  * Final results and outcomes

File Locations:
- Save all generated files to: $WS/artifacts/
- Your output is being logged to: $WS/log.txt

Work independently. Document thoroughly.

Output Style: Be extremely concise. Sacrifice grammar for concision.
  '\" \"$WS/log.txt\";
  EXIT_CODE=\$?;
  echo '';
  echo '═══════════════════════════════════════════════════';
  echo \"Job completed with exit code: \$EXIT_CODE\";
  echo 'Press Enter to close or wait...';
  read -t 30
"

echo "✓ Dispatched: $JOB"
echo "  Attach:  tmux select-window -t $JOB"
echo "  Monitor: tail -f $WS/log.txt"
echo "  Notes:   cat $WS/notes.md"
