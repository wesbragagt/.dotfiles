---
description: Break down a PRD into tasks following the task YAML spec
---

Break down a PRD into actionable tasks with dependencies following the task YAML spec.

## Usage

/tasks <prd-path-or-description> [--name <feature-name>]

## Parameters

- `prd-path-or-description`: Either a file path to a PRD markdown file, or a description string (required)
- `--name`: Optional feature name (auto-generated from first 4 words if not provided)

## Examples

/tasks prd/authentication/prd.md
/tasks "Build user authentication with OAuth2 and JWT"
/tasks ./features/search.md --name search-feature
/tasks "Add real-time notifications with websockets" --name realtime-notif

## Implementation

1. Parse input:
   - If input is a file path that exists: read contents as PRD
   - Otherwise: use input string as feature description

2. Generate feature name if not provided:
   - Use first 4 words, lowercase, hyphenated
   - Example: "Build user authentication system" → "build-user-auth-system"

3. Invoke the prd-planner subagent with:
   - feature_name: <name or generated>
   - description: <description from input or PRD summary>
   - context: <full PRD content if from file>

4. The prd-planner executes 3 phases:
   - **Phase 1: Research** - Research best practices and patterns
   - **Phase 2: Refine** - Create/update PRD document
   - **Phase 3: Create Tasks** - Generate tasks.yaml with dependencies

## Task YAML Spec

```yaml
tasks:
  - key: task-name          # Unique kebab-case identifier
    description: Brief description of the task
    details: ./task-name.md # Path to detail file with implementation notes
    status: open            # open, progress, or done
    depends: []             # List of task keys this depends on
```

## Output

```
✓ Tasks created: prd/{feature-name}/
  - prd.md
  - tasks.yaml (X tasks)
  - {X} detail files

Tasks:
  1. task-name-1 (no deps)
  2. task-name-2 (depends: task-name-1)
  ...
```

Use the `tasks` skill for managing tasks.yaml files (view, update status, verify completion).
