---
name: review
description: Review a pull request, branch diff, or local changes with a proven step-by-step workflow focused on architecture and design fit, refactor opportunities, potential bugs, and missing test coverage. Use when asked to review code, review a PR, look for bugs, suggest refactors, or assess test gaps.
---

# Review

Use this skill to run a structured code review that prioritizes code health over nitpicks.

## Principles

1. Review for design and correctness before style.
2. Read every changed line and open surrounding context when needed.
3. Focus human attention on architecture, behavior, edge cases, and tests.
4. Suggest simplification when complexity increases without clear value.
5. Do not block on perfection; prefer changes that improve code health.
6. Avoid flagging issues that are out of scope, speculative, or likely caught by CI.

## Scope

Start by identifying the review target:
- Pull request URL or PR number
- Current branch diff
- Staged or unstaged local changes
- Specific files called out by the user

If the review target is unclear, ask once and proceed.

## Step-by-step workflow

### 1. Triage the review

Establish the review surface before reading code.

Check:
- PR title, description, linked issue, and requested feedback focus
- changed files and rough diff size
- whether the change is small and focused or mixed and sprawling
- whether tests changed alongside behavior changes

If the review is very large, recommend splitting it or reviewing in chunks. Review quality drops on very large diffs.

### 2. Read intent first

Before judging implementation details, understand what the change is trying to do.

Read in this order:
1. PR or task description
2. changed file list
3. tests
4. implementation

If the author provided a suggested review order, follow it.

### 3. Review tests early

Use tests to understand intended behavior.

Check:
- are tests present when behavior changed?
- do tests cover happy path, failure path, and edge cases?
- would the tests fail if the implementation were broken?
- are assertions meaningful instead of vague snapshot noise?
- are integration boundaries exercised where unit tests are insufficient?

### 4. Architecture and design pass

This is the highest-priority review pass.

Ask:
- does this change belong in this module, layer, or service?
- does it respect existing architectural boundaries?
- do responsibilities sit in the right place?
- do the interactions between changed parts make sense?
- is the design the simplest thing that solves the problem now?
- is unrelated work mixed into the same change?
- does the change improve or reduce long-term maintainability?

Flag architecture issues before local code nits.

### 5. Correctness and bug pass

Inspect the changed lines and surrounding context for defects.

Look for:
- logic that does not match the apparent intent
- missing validation or error handling
- null, empty, timeout, retry, and partial-failure cases
- race conditions, ordering issues, or shared-state hazards
- security or privacy issues, including unsafe logging
- hidden side effects or unexpected state changes
- obvious performance regressions such as unnecessary network or database calls

Open the full file when the diff alone is not enough.

### 6. Refactor and simplification pass

After correctness, look for better ways to express the same behavior.

Look for:
- duplication
- deeply nested control flow
- large functions or classes doing multiple things
- weak names that hide intent
- over-engineering or premature generalization
- comments compensating for code that should be simpler

Prefer concrete refactor suggestions over vague opinions.

### 7. Coverage gap pass

Explicitly identify what is not tested.

Common gaps:
- failure path not covered
- edge-case input not covered
- concurrency-sensitive behavior not covered
- regression case missing for the bug being fixed
- architecture-sensitive behavior only tested indirectly
- tests added, but they only mirror implementation details instead of behavior

If the change is trivial and non-behavioral, say so instead of forcing test feedback.

### 8. Synthesize findings

Return findings grouped by category:
- Architecture
- Potential bugs
- Coverage gaps
- Refactor suggestions
- Optional nits

For each finding include:
- severity: `must-fix`, `should-fix`, or `optional`
- confidence: `high`, `medium`, or `low`
- brief evidence tied to the code
- concrete recommendation

Prefer a short list of high-signal findings over a long list of weak guesses.

## What not to flag

Avoid these false positives:
- pure formatting or lint issues likely handled by tooling
- speculative future abstractions
- unrelated pre-existing tech debt unless this change worsens it
- out-of-scope adjacent cleanup as a blocker
- vague “this could be cleaner” feedback without an actionable suggestion
- requests for tests on trivial non-behavioral changes
- opinions based only on personal preference when multiple designs are valid

If feedback is educational but not required, label it clearly as optional.

## Output artifact

You must write the review to a Markdown file under a `reviews/` folder in the current working directory.

Filename format:
- `reviews/review-YYYYMMDD-HHMMSS.md`

Create the directory if it does not exist:

```bash
mkdir -p reviews
```

Generate the timestamp at runtime in local time, for example with:

```bash
date +%Y%m%d-%H%M%S
```

The review response should mention the file path clearly after writing it.

## Output template

Use this structure unless the user asked for a different one:

```markdown
## Review summary

### Architecture
- [must-fix][high] ...

### Potential bugs
- [should-fix][high] ...

### Coverage gaps
- [should-fix][high] ...

### Refactor suggestions
- [optional][medium] ...

### Strengths
- ...
```

If no meaningful issues are found, say so directly and summarize the strengths.

## Review heuristics

- Design first, then correctness, then simplification, then style.
- Read every changed line.
- Open surrounding code when the diff is misleading.
- Keep the review within scope.
- Favor continuous improvement over perfection.
- Escalate only issues that materially affect maintainability, correctness, or confidence.

## References

See [references/proven-practices.md](references/proven-practices.md) for the research basis and source URLs.
