---
name: w-prd
description: Plan a feature using the prd-planner subagent
argument-hint: <feature-name> --description "<description>" [--context "<context>"] [--quick]
---

Plan a feature using the prd-planner subagent.

## Usage

```
/w-prd <feature-name> --description "<description>" [--context "<context>"] [--quick]
```

## Parameters

- `feature-name`: The name of the feature to plan (required)
- `--description`: Brief description of what needs to be done (required)
- `--context`: Optional additional context or requirements
- `--quick`: Skip research phase for straightforward features

## Examples

```
/w-prd metronome --description "Implement metronome feature with BPM control"
/w-prd track-splitting --description "Add ability to split audio tracks at markers" --context "Use Web Audio API"
/w-prd fix-typo --description "Fix typo in header component" --quick
/w-prd keyboard-shortcuts --description "Global keyboard shortcuts for common actions"
```

## Implementation

1. Parse arguments from user input
2. Use the prompter skill to delegate to prd-planner:

```xml
<delegation>
  <role>Product planner and task breakdown specialist</role>

  <context>
    Feature: $ARGUMENTS
  </context>

  <task>
    Create a comprehensive PRD and task breakdown for: $ARGUMENTS
  </task>

  <constraints>
    - Use status: open (not done: false)
    - Follow tasks.yaml schema
    - Keep scope minimal and focused
  </constraints>

  <output_format>
    - prd/{feature}/prd.md
    - prd/{feature}/tasks.yaml
    - prd/{feature}/*.md (detail files)
  </output_format>

  <verification>
    - tasks.yaml has valid schema
    - All tasks have status: open
    - Dependencies reference existing task keys
  </verification>

  <return>
    Summary with file paths and dependency graph
  </return>
</delegation>
```

3. The prd-planner executes:
   - **Phase 1: Research** (skip if --quick) - Research best practices
   - **Phase 2: Refine** - Create comprehensive PRD
   - **Phase 3: Create Tasks** - Break down into actionable tasks
   - **Phase 4: Validate** - Ensure schema compliance

4. Display summary with dependency graph

## Task Management

Use the `w-tasks` skill for task operations:

| Command | Description |
|---------|-------------|
| `/w-tasks pending prd/{feature}/tasks.yaml` | List pending tasks |
| `/w-tasks ready prd/{feature}/tasks.yaml` | List ready tasks (no blockers) |
| `/w-tasks progress prd/{feature}/tasks.yaml` | List in-progress tasks |

Or use yq directly:
```bash
yq '.tasks[] | select(.status != "done")' prd/{feature}/tasks.yaml
yq '.tasks[] | select(.status == "open" and (.depends | length == 0))' prd/{feature}/tasks.yaml
```

## Output Format

```
✓ PRD created: prd/{feature-name}/
  - prd.md
  - tasks.yaml (X tasks)
  - {X} detail files

Dependency Graph:
create-store
└── create-hooks
    ├── build-ui
    └── write-tests

Next: /code prd/{feature-name}/tasks.yaml
```

## Schema Validation

After creation, verify:
```bash
yq '.tasks[] | .status' prd/{feature}/tasks.yaml | sort | uniq -c
```

Should show only `open` values.
