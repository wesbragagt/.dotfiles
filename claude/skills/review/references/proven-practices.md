# Proven review practices

This skill is based on a small set of consistent themes across established code review guidance.

## Core practices

### 1. Review design first
Google states that the most important thing in review is the overall design of the change: whether the interactions make sense, whether the code belongs where it was added, and whether the change fits the system well.

### 2. Read every changed line and inspect context
Google and Microsoft both emphasize reading every changed line, then opening the whole file or broader context when the diff alone is insufficient.

### 3. Spend human review effort on architecture, correctness, and tests
Microsoft explicitly recommends leaving automated concerns to linters and similar tools so human reviewers can focus on architecture, business logic, maintainability, and correctness of tests.

### 4. Look for complexity and over-engineering
Google warns against changes that are more complex than necessary or that solve speculative future problems. Microsoft similarly recommends checking readability, single responsibility, and function complexity.

### 5. Treat tests as part of the change
Google and Microsoft both recommend that tests usually ship in the same change as production code and that reviewers confirm the tests are sensible, useful, and cover edge cases.

### 6. Do not block on perfection
Google's review standard is continuous improvement in code health, not perfect code. A change that clearly improves the system should not be delayed over minor issues.

### 7. Keep reviews small and focused
GitHub recommends small, focused pull requests with clear context. SmartBear reports review effectiveness drops on large diffs and long review sessions.

## Suggested thresholds from SmartBear

These are heuristics, not hard rules:
- Best review chunk: about 200 to 400 LOC
- Review speed: under 500 LOC per hour
- Session length: under 60 minutes before taking a break

## Source URLs

- Google Eng Practices — What to look for in a code review  
  https://google.github.io/eng-practices/review/reviewer/looking-for.html

- Google Eng Practices — The Standard of Code Review  
  https://google.github.io/eng-practices/review/reviewer/standard.html

- Microsoft Engineering Playbook — Reviewer Guidance  
  https://microsoft.github.io/code-with-engineering-playbook/code-reviews/process-guidance/reviewer-guidance

- GitHub Docs — Helping others review your changes  
  https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/getting-started/helping-others-review-your-changes

- SmartBear — Best Practices for Peer Code Review  
  https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/
