---
description: Plan a feature using the prd-planner subagent
---

Plan a feature using the prd-planner subagent.

## Usage

/prd <feature-name> --description "<description>" [--context "<context>"]

## Parameters

- `feature-name`: The name of the feature to plan (required)
- `--description`: Brief description of what needs to be done (required)
- `--context`: Optional additional context or requirements

## Examples

/prd metronome --description "Implement metronome feature with BPM control"
/prd track-splitting --description "Add ability to split audio tracks at markers" --context "Use Web Audio API"
/prd keyboard-shortcuts --description "Global keyboard shortcuts for common actions"

## Implementation

1. Parse the feature-name, description, and optional context from user input
2. Use the prd-planner subagent with:
   - feature_name: <feature-name>
   - description: <description>
   - context: <context> (if provided)
3. The prd-planner subagent will execute 3 phases:
   - **Phase 1: Research** - Use exa tools to research best practices, patterns, and examples
   - **Phase 2: Refine** - Synthesize findings into comprehensive PRD
   - **Phase 3: Create Tasks** - Break down into actionable tasks with dependencies
4. Display a summary showing:
   - Research findings file
   - PRD file
   - Task breakdown
   - Detail files created
   - Next steps (using yq to query tasks)

## yq Commands for Task Management

```bash
# List all pending tasks
yq '.tasks[] | select(.done == false)' prd/*/tasks.yaml

# Show tasks for a specific feature
yq '.tasks[]' prd/{feature}/tasks.yaml

# List ready tasks (no dependencies or all deps done)
yq '.tasks[] | select(.done == false and (.depends | length == 0))' prd/*/tasks.yaml

# Mark task as done
yq '.tasks[] |= select(.key == "task-name") | .done = true' -i prd/{feature}/tasks.yaml
```

## Output Format

```
✓ PRD created: prd/{feature-name}/
  - prd.md
  - tasks.yaml (X tasks)
  - {X} detail files

Next steps:
  yq '.tasks[] | select(.done == false)' prd/{feature-name}/tasks.yaml
```
