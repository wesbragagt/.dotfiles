# Pull Request Feedback

Review and address all open comments on the current pull request.

## Steps

1. **Fetch PR context** — run `gh pr view` to get the PR number and description, then `gh pr comments` and `gh api repos/{owner}/{repo}/pulls/{pr}/reviews` to collect all reviewer comments and inline code comments.

2. **Triage each comment** — for every comment, determine:
   - Is it a bug or correctness issue? → implement immediately
   - Is it a style/naming suggestion? → implement if low-risk
   - Is it a question or discussion? → reply via `gh api` without code changes
   - Is it already resolved or stale? → reply explaining why no action is needed

3. **Implement changes** — make code edits for actionable feedback. Read the relevant files before modifying them. Keep changes scoped to what the comment asks.

4. **Resolve each comment** — after addressing or deciding not to act, post a reply using the gh CLI:
   ```
   gh api repos/{owner}/{repo}/pulls/comments/{comment_id}/replies -f body="<response>"
   ```

5. **Summarize** — report back what was changed, what was replied to without changes, and anything that needs the user's input before proceeding.

## Notes

- Do not resolve unrelated issues encountered while reviewing feedback — create a separate task instead.
- Confirm with the user before making changes that significantly alter behavior or public interfaces.
