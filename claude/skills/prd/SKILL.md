---
name: prd
description: Plan a feature using the prd-planner subagent
argument-hint: <feature-name> --description "<description>" [--context "<context>"] [--quick]
---

Plan a feature using the prd-planner subagent.

## Usage

```
/prd <feature-name> --description "<description>" [--context "<context>"] [--quick]
```

## Parameters

- `feature-name`: The name of the feature to plan (required)
- `--description`: Brief description of what needs to be done (required)
- `--context`: Optional additional context or requirements
- `--quick`: Skip research phase for straightforward features

## Examples

```
/prd metronome --description "Implement metronome feature with BPM control"
/prd track-splitting --description "Add ability to split audio tracks at markers" --context "Use Web Audio API"
/prd fix-typo --description "Fix typo in header component" --quick
/prd keyboard-shortcuts --description "Global keyboard shortcuts for common actions"
```

## Implementation

1. Parse arguments from user input
2. Use the prompter skill to delegate to prd-planner (PRD only — no tasks):

```xml
<delegation>
  <role>Product manager writing a requirements document — not a technical designer</role>

  <context>
    Feature: $ARGUMENTS
  </context>

  <task>
    Create a PRD for: $ARGUMENTS
  </task>

  <constraints>
    ## PRD content (prd.md)
    - Write at the product requirements level: WHAT and WHY, never HOW
    - No code examples, class names, file paths, or implementation patterns in the PRD
    - Acceptance criteria describe user-observable outcomes ("users can do X"), not implementation steps
    - If a technical approach section is needed, keep it to 2-3 sentences of high-level direction only
    - Implementation specifics (patterns, file structure, migration steps) belong in task detail files, not in the PRD

    ## PRD structure — use this skeleton:
    1. Problem Statement — what is broken or missing, and the user/business impact
    2. Goals — outcomes we want, written as capabilities or properties
    3. Non-Goals — explicit scope boundaries
    4. Acceptance Criteria — functional, user-observable requirements (no code)
    5. Out of Scope — what this PRD deliberately excludes
  </constraints>

  <output_format>
    - ./prds/{feature}/prd.md — product requirements only (problem, goals, acceptance criteria)
  </output_format>

  <verification>
    - prd.md contains no code blocks or file paths
  </verification>

  <return>
    Path to the created prd.md file
  </return>
</delegation>
```

3. The prd-planner executes:
   - **Phase 1: Research** (skip if --quick) - Research best practices
   - **Phase 2: Refine** - Create PRD following the product requirements skeleton
   - **Phase 3: Validate** - Ensure no implementation details in prd.md

4. After prd.md is written, dispatch an Agent using the `tasks` skill to break it down:
   - Invoke `/tasks ./prds/{feature}/prd.md --name {feature}` as a subagent
   - The w-tasks agent creates `tasks.yaml` and per-task detail files in `./prds/{feature}/`

5. Display summary with dependency graph

## Task Management

```bash
uv run ~/.claude/skills/tasks/tasks.py ./prds/{feature}/tasks.yaml summary
uv run ~/.claude/skills/tasks/tasks.py ./prds/{feature}/tasks.yaml list --status open
uv run ~/.claude/skills/tasks/tasks.py ./prds/{feature}/tasks.yaml ready
uv run ~/.claude/skills/tasks/tasks.py ./prds/{feature}/tasks.yaml set <key> done
```

## Output Format

```
✓ PRD created: ./prds/{feature-name}/prd.md
  Dispatching task breakdown...

✓ Tasks created: ./prds/{feature-name}/
  - tasks.yaml (X tasks)
  - {X} detail files

Dependency Graph:
create-store
└── create-hooks
    ├── build-ui
    └── write-tests

Next: /code ./prds/{feature-name}/tasks.yaml
```

## Schema Validation

After creation, verify:
```bash
uv run ~/.claude/skills/tasks/tasks.py ./prds/{feature}/tasks.yaml summary
```

Should show all tasks as `open`.
