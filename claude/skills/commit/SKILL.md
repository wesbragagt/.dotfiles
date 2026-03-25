---
name: commit
description: Commit only the changes relevant to the current task or context. Never uses `git add -A` or `git add .` — always stages files selectively. Use when the user wants to commit work, save progress, or record changes to git.
argument-hint: "[optional commit message or context]"
---

# commit

Commit only the files relevant to the current context. Never stage everything blindly.

## Step 1: Understand what changed

Run `git status` to see all modified, added, and deleted files. Then run `git diff --stat` to get a quick sense of what changed in each file.

Do NOT proceed to staging until you have read the status output.

## Step 2: Identify relevant files

From the status output, determine which files are part of the current task or context:

- If the user described what they were working on, match files to that description
- If files are clearly unrelated to the current task (e.g. config drift, unrelated feature work, auto-generated files from other tasks), exclude them
- When in doubt about a file, check its diff with `git diff <file>` before deciding

**Never use `git add -A`, `git add .`, or any wildcard that stages everything.**

## Step 3: Stage selectively

Add only the relevant files by name:

```
git add <file1> <file2> ...
```

If only specific hunks within a file are relevant, use `git add -p <file>` to stage interactively.

After staging, run `git diff --cached --stat` to confirm exactly what will be committed.

Then run `git status` again and check for any remaining unstaged files. If any exist, explicitly list them to the user — they may represent unfinished work, unrelated changes, or files accidentally omitted. Do not silently proceed without surfacing this.

## Step 4: Write the commit message

If the user provided a message, use it (cleaned up if needed).

Otherwise, write a concise conventional commit message:

```
<type>(<optional scope>): <short imperative summary>
```

Types: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`, `style`, `perf`

Rules:
- Lowercase, no trailing period
- Under 72 characters
- Imperative mood ("add", "fix", "remove" — not "added", "fixes")
- No vague messages like "updates" or "changes"

## Step 5: Commit

```
git commit -m "<message>"
```

Then confirm success by showing the commit with `git log --oneline -1`.

## What NOT to do

- Do not run `git add -A`, `git add .`, or `git add *`
- Do not commit unrelated files to keep the history clean
- Do not amend or force-push unless explicitly asked
- Do not create empty commits
- Do not attribute commits to Claude. Before committing, verify the git author is set to the user (not `claude` or `no-reply@anthropic.com`). If the author is wrong, do not override it silently — inform the user and ask them to fix their git config (`git config user.name` / `git config user.email`) before proceeding.
