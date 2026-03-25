---
name: pr
description: Create a GitHub pull request for the current branch. Invokes /commit first to stage and commit any uncommitted changes, then uses the GitHub CLI (gh) to open a PR with a generated title and body. Use this skill whenever the user wants to open a PR, submit their work for review, push a branch and create a pull request, or says anything like "open a PR", "create a pull request", "submit for review", "push and PR", or "ship this".
argument-hint: "[optional PR title or description context]"
---

# pr

Create a GitHub pull request from the current branch. Always commit first, then push, then open the PR.

## Step 1: Commit any uncommitted changes

Invoke the `/commit` skill to stage and commit any pending changes before creating the PR. If there is nothing to commit (clean working tree), skip this step and proceed.

## Step 2: Check for an existing PR

```bash
gh pr view --json number,title,body,baseRefName 2>/dev/null
```

If a PR already exists for this branch:
- Commit any new changes (Step 1 above still applies)
- Push the branch
- Regenerate the PR body based on the full current diff against the base (not just new commits)
- Update the existing PR description:
  ```bash
  gh pr edit --body "<updated body>"
  ```
- Output the PR URL and note that the description was updated, not a new PR created.
- **Skip Steps 3–5 below.**

Only proceed to Step 3 if no PR exists yet.

## Step 3: Identify branch and base

```bash
git branch --show-current
```

Determine the base branch to PR against. Check in this order:
1. If the user specified a base branch, use it.
2. Check if a `main` or `master` branch exists — prefer `main`.
3. Fall back to whatever the repo's default remote HEAD points to: `git remote show origin | grep 'HEAD branch'`

If the current branch IS the base branch (e.g., the user is on `main`), stop and tell the user — they need to be on a feature branch to open a PR.

## Step 4: Push the branch

```bash
git push -u origin HEAD
```

If the push fails due to a rejected update (non-fast-forward), do NOT force-push. Tell the user and ask how they'd like to proceed.

## Step 5: Generate the PR title and body

Look at the commits on this branch relative to the base:

```bash
git log origin/<base>..HEAD --oneline
```

Also read a brief diff summary:

```bash
git diff origin/<base>..HEAD --stat
```

**Title**: Derive a clear, concise title (under 72 chars) from the branch name and commits. Use sentence case, no trailing period. If the user provided context in their prompt, incorporate it.

**Body**: Write a PR description using this template:

```
## Summary

<1-2 paragraphs explaining the goal of this PR, what problem it solves, or what feature value it adds>

## Changes

- <bullet list of notable changes derived from commit messages and diff stat>

## Technical Details

<implementation notes, architecture decisions, or anything reviewers should understand about the approach — omit if there's nothing non-obvious to say>
```

Keep it factual. Do not pad with filler. If the user provided a description, incorporate it into the Summary section rather than replacing the template entirely.

## Step 6: Create the PR

```bash
gh pr create \
  --base <base-branch> \
  --title "<title>" \
  --body "<body>"
```

After creation, output the PR URL so the user can open it directly.

## What NOT to do

- Do not force-push to fix a rejected push — ask the user.
- Do not open a PR from the default branch (main/master) to itself.
- Do not skip the commit step if there are uncommitted changes — always run `/commit` first.
- Do not add a `--draft` flag unless the user explicitly asked for a draft PR.
- Do not mark the PR as ready for review or request reviewers unless the user asked.
