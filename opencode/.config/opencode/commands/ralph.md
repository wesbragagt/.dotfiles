---
description: Execute Ralph Wiggum loop - autonomous PRD creation and task execution in worktree
---

Orchestrate autonomous PRD creation and task execution loop until all tasks complete in a dedicated worktree.

## Input
- First argument: Either a file path to read or a prompt string
- File path will be read and used as the prompt

## Steps

1. Parse input:
   - If file path exists: read contents as prompt
   - Otherwise: use input string as prompt

2. Generate feature name from prompt (first 4 words, lowercase, hyphenated)
   - Example: "Build user authentication system" → "build-user-auth"

3. Load the ralph skill

4. Use the ralph skill to execute the loop:
   - The skill will:
     - Create a git worktree with branch: `ralph--{feature_name}`
     - Switch to the worktree for all work (one worktree per `/ralph` command)
     - Check for existing PRD/tasks.yaml from previous runs
     - If no PRD exists: call prd-planner to create it
     - Execute tasks from the PRD
     - If tasks remain (blocked or incomplete): continue looping with same prompt
     - Repeat until all tasks are done

5. The loop continues autonomously in the worktree:
   - Creates PRD from prompt (first time or if new tasks needed)
   - Executes ready tasks in parallel batches
   - Commits changes each iteration
   - Re-evaluates remaining tasks
   - Continues until all tasks are done

## Output

```
Ralph loop started
Prompt: {prompt}
Worktree: ralph--{feature_name}

Executing...
  Iteration 1: 5 tasks ready
  Iteration 2: 3 tasks ready
  ...

Complete! All tasks finished.
Worktree path: /path/to/worktree
To merge: git checkout main && git merge ralph--{feature_name}
```
Ralph loop started
Prompt: {prompt}

Executing...
  Iteration 1: 5 tasks ready
  Iteration 2: 3 tasks ready
  ...

Complete! All tasks finished.
```
