---
description: Execute tasks from a PRD by orchestrating code-writer agents
---

Execute tasks from tasks.yaml by orchestrating code-writer agents. Automatically handles task dependencies and status updates.

## Usage

```
/code <path-to-tasks-yaml> [--task <task-key>]
```

## Parameters

- `path-to-tasks-yaml`: Path to tasks.yaml file (required)
- `--task`: Optional specific task key to execute (skips dependency resolution)

## Examples

```
/code prd/auth-feature/tasks.yaml
/code ./tasks.yaml --task setup-database
/code prd/search/tasks.yaml
```

## Implementation

1. **Load tasks.yaml** and validate it follows the task spec

2. **If --task specified**: Execute only that task (skip to step 5)

3. **Find ready tasks**: Tasks where:
   - status is "open"
   - All dependencies have status "done"
   - No blockers remain

4. **If no ready tasks**:
   - Check if all tasks are done → Report completion
   - Check for circular dependencies or blocked state → Report issue
   - Otherwise → Report waiting on in-progress tasks

5. **Determine execution strategy**:

   Analyze ready tasks for conflicts before parallelizing:

   **Parallelization limit**: Maximum 3 agents concurrently.

   **Safe to parallelize** (run concurrently):
   - Tasks that modify completely separate files/directories
   - Tasks with no shared mutable state
   - Tasks in different modules/domains
   - Example: `setup-database` + `create-ui-components`

   **Must run sequentially**:
   - Tasks that may modify the same file(s)
   - Tasks with overlapping file paths
   - Tasks that share configuration or state files
   - Tasks where one's output affects another's implementation
   - Example: `create-api-routes` + `update-api-types` (both touch api/)

   When in doubt, run sequentially to avoid merge conflicts.

6. **For each ready task** (or specified task):

   a. **Mark as progress**:
   ```bash
   yq '.tasks |= (.[] | select(.key == "<task-key>") | .status) = "progress"' -i <tasks-yaml>
   ```

   b. **Gather context**:
   - Read the PRD (same directory, prd.md)
   - Read task details file if exists
   - Read completed task details for context
   - Scan codebase for relevant existing code

   c. **Determine agent type**:
   - Single file, simple change → `code-writer-simple`
   - Multi-file, architectural, complex → `code-writer-complex`

   d. **Invoke code-writer agent** with:
   - Task key and description
   - Full task details
   - PRD context
   - Relevant codebase context
   - Dependency context (what was built in dependent tasks)

   e. **On completion, mark task done**:
   ```bash
   yq '.tasks |= (.[] | select(.key == "<task-key>") | .status) = "done"' -i <tasks-yaml>
   ```

   **For parallel execution**: Launch multiple agents in a single tool call block, each with isolated scope.

7. **Loop**: After completing tasks, find next ready tasks and continue

8. **Final verification**: When all tasks done, verify with:
   ```bash
   yq '[.tasks[].status == "done"] | all' tasks.yaml | grep -q true
   ```

## Agent Prompt Template

When invoking code-writer agent, use this structure:

```
Task: {task-key}
Description: {task-description}

Context:
- PRD: {prd-summary}
- Dependencies completed: {list-of-completed-dependent-tasks}
- Codebase context: {relevant-files-and-patterns}

Details:
{task-details-content}

Requirements:
1. Implement according to the task details
2. Follow existing codebase conventions
3. Ensure compatibility with completed dependent tasks
4. Write production-ready code

After completion, report what was implemented.
```

## Output

```
✓ Loaded tasks.yaml (X tasks)
  - Done: Y
  - In Progress: Z
  - Open: W

▶ Ready to execute: task-name-1
  Depends on: (all complete)

[Agent executes task...]

✓ Task complete: task-name-1
  - Files created/modified: ...

▶ Ready to execute: task-name-2
...

✓ All tasks complete!
```

## Error Handling

- **No ready tasks but not done**: Report which tasks are blocking
- **Task fails**: Keep status as "progress", report error, allow retry
- **Missing dependencies**: Report which dependent tasks need completion first
