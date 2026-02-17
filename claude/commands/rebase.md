---
description: Rebase current branch onto target with conflict resolution
argument-hint: [target]
allowed-tools: Bash(git fetch:*), Bash(git rebase:*), Bash(git log:*), Bash(git add:*), Bash(git status:*), Read, Edit
---

Rebase the current branch.

Arguments: $ARGUMENTS

## Behavior

- No arguments: fetch origin, update local default branch, rebase onto it
- "origin": fetch origin, update local default branch, rebase onto it
- "origin/branch": fetch origin, update local branch, rebase onto it
- "branch": fetch origin, update local branch, rebase onto it

## Steps

1. Determine the default branch by running: `git remote show origin | awk '/HEAD branch/ {print $NF}'`
2. Parse arguments:
   - No args → target branch is <default-branch>
   - Contains "/" (e.g., "origin/develop") → extract branch name after "/"
   - Just "origin" → target branch is <default-branch>
   - Anything else → target branch is the argument
3. Run: `git fetch origin`
4. Run: `git rebase <branch>` (using local branch, not origin/branch)
5. If conflicts occur, handle them carefully (see below)
6. Continue until rebase is complete

## Handling conflicts

- BEFORE resolving any conflict, understand what changes were made to each conflicting file in the target branch
- For each conflicting file, run `git log -p -n 3 <target> -- <file>` to see recent changes to that file in the target branch
- The goal is to preserve BOTH the changes from the target branch AND our branch's changes
- After resolving each conflict, stage the file and continue with `git rebase --continue`
- If a conflict is too complex or unclear, ask for guidance before proceeding

## Output

IMPORTANT: Be silent during execution. Do not narrate your actions or explain what you're doing.

When complete, output ONLY a compact summary in this exact format:
```
Rebased N commits onto <target>
[If conflicts:]
  - <file>: <one line describing resolution>
  - <file>: <one line describing resolution>
```

Nothing else. No explanations, no status updates, no tool output.
