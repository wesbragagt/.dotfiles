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
2. Use the prompter skill to delegate to prd-planner:

```xml
<delegation>
  <role>Product manager writing a requirements document — not a technical designer</role>

  <context>
    Feature: $ARGUMENTS
  </context>

  <task>
    Create a PRD and task breakdown for: $ARGUMENTS
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

    ## Tasks
    - Use status: open (not done: false)
    - Follow tasks.yaml schema
    - Keep scope minimal and focused
    - Task descriptions are action-oriented ("Implement X", "Add Y") — details go in detail files
  </constraints>

  <output_format>
    - ${SHARED_NOTES_FOLDER:-.}/prd/<project>/{feature}/prd.md — product requirements only (problem, goals, acceptance criteria)
    - ${SHARED_NOTES_FOLDER:-.}/prd/<project>/{feature}/tasks.yaml — task list with dependencies
    - ${SHARED_NOTES_FOLDER:-.}/prd/<project>/{feature}/*.md — one detail file per task; this is where implementation specifics live
  </output_format>

  <verification>
    - prd.md contains no code blocks or file paths
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
   - **Phase 2: Refine** - Create PRD following the product requirements skeleton
   - **Phase 3: Create Tasks** - Break down into actionable tasks
   - **Phase 4: Validate** - Ensure schema compliance and no implementation details in prd.md

4. Display summary with dependency graph

## Task Management

```bash
uv run ~/.claude/skills/w-tasks/tasks.py ${SHARED_NOTES_FOLDER:-.}/prd/<project>/{feature}/tasks.yaml summary
uv run ~/.claude/skills/w-tasks/tasks.py ${SHARED_NOTES_FOLDER:-.}/prd/<project>/{feature}/tasks.yaml list --status open
uv run ~/.claude/skills/w-tasks/tasks.py ${SHARED_NOTES_FOLDER:-.}/prd/<project>/{feature}/tasks.yaml ready
uv run ~/.claude/skills/w-tasks/tasks.py ${SHARED_NOTES_FOLDER:-.}/prd/<project>/{feature}/tasks.yaml set <key> done
```

## Output Format

```
✓ PRD created: ${SHARED_NOTES_FOLDER:-.}/prd/<project>/{feature-name}/
  - prd.md
  - tasks.yaml (X tasks)
  - {X} detail files

Dependency Graph:
create-store
└── create-hooks
    ├── build-ui
    └── write-tests

Next: /code <prd-dir>/tasks.yaml

(where <prd-dir> = ${SHARED_NOTES_FOLDER:-.}/prd/<project>/<feature-name>, project = git toplevel basename)
```

## Schema Validation

After creation, verify:
```bash
uv run ~/.claude/skills/w-tasks/tasks.py ${SHARED_NOTES_FOLDER:-.}/prd/<project>/{feature}/tasks.yaml summary
```

Should show all tasks as `open`.
