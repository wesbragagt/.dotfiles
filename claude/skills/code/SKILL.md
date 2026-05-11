---
name: code
description: Execute tasks from a tasks.yaml by orchestrating code-writer agents
argument-hint: <path-to-tasks-yaml> [--task <task-key>]
---

Execute tasks from a tasks.yaml file by orchestrating code-writer agents. Automatically handles dependency resolution, parallel execution, and status tracking.

## Usage

```
/code <path-to-tasks-yaml> [--task <task-key>]
```

## Parameters

- `path-to-tasks-yaml`: Path to tasks.yaml file (required)
- `--task`: Execute only a specific task key, skipping dependency resolution

## Examples

```
/code prd/auth-feature/tasks.yaml
/code ./tasks.yaml --task setup-database
/code prd/search/tasks.yaml
```

## Implementation

1. **Load and validate tasks.yaml**:
   ```bash
   uv run ~/.claude/skills/tasks/tasks.py <path-to-tasks-yaml> summary
   ```
   Report task summary:
   - Total, done, in-progress, open counts

2. **If --task specified**: Jump directly to step 5 for that task.

3. **Find ready tasks** — tasks where ALL of the following are true:
   - `status == "open"`
   - All keys in `depends` have `status == "done"`

   ```bash
   uv run ~/.claude/skills/tasks/tasks.py <path> ready
   ```

4. **If no ready tasks**:
   - All done → report completion and stop
   - Circular deps or all blocked → report which tasks are blocking and stop
   - Tasks in progress → report waiting state

5. **Determine execution strategy** for ready tasks:

   **Parallelize** (max 3 concurrent agents) when tasks touch completely separate files/domains.

   **Run sequentially** when tasks:
   - May modify the same file(s)
   - Share configuration or state files
   - Have overlapping file paths
   - When in doubt → sequential

6. **For each ready task**:

   a. **Mark in progress**:
   ```bash
   uv run ~/.claude/skills/tasks/tasks.py <path> set <task-key> progress
   ```

   b. **Gather context**:
   - Read the PRD file in the same directory (`prd.md`)
   - Read the task's detail file if `details` path is set
   - Read detail files from completed dependent tasks
   - Scan codebase for relevant existing patterns

   c. **Choose agent type**:
   - Single file, simple change → `code-writer-simple`
   - Multi-file, architectural, or complex → `code-writer-complex`

   d. **Invoke agent** using the prompter skill with this structure:

   ```xml
   <delegation>
     <role>Senior software engineer specializing in {detected language/framework}</role>

     <context>
       <prd>{summary from prd.md}</prd>
       <dependencies>{list of completed dependent tasks and what they built}</dependencies>
       <codebase>{relevant existing files, patterns, conventions}</codebase>
     </context>

     <task>
       <key>{task-key}</key>
       <description>{task.description}</description>
       <details>{contents of task detail file if exists}</details>
     </task>

     <constraints>
       - Follow existing codebase conventions
       - Ensure compatibility with completed dependent tasks
       - Write production-ready code
       - No new external dependencies without explicit approval
     </constraints>

     <verification>
       1. Code compiles/runs without errors
       2. Existing tests still pass
       3. Implementation matches task details
     </verification>

     <return>
       - Files created/modified with paths
       - Summary of implementation
       - Any issues or blockers encountered
     </return>
   </delegation>
   ```

    e. **On success, mark done**:
    ```bash
    uv run ~/.claude/skills/tasks/tasks.py <path> set <task-key> done
    ```

   **For parallel tasks**: Launch all agents in a single tool call block.

7. **Loop**: After completing a batch, go back to step 3 to find the next ready tasks.

8. **Final verification** when all tasks report done:
   ```bash
   uv run ~/.claude/skills/tasks/tasks.py <path> verify
   ```

## Task Management Reference

| Operation | Command |
|-----------|---------|
| Summary | `uv run ~/.claude/skills/tasks/tasks.py <path> summary` |
| List all tasks | `uv run ~/.claude/skills/tasks/tasks.py <path> list` |
| View ready tasks | `uv run ~/.claude/skills/tasks/tasks.py <path> ready` |
| View in progress | `uv run ~/.claude/skills/tasks/tasks.py <path> list --status progress` |
| Mark in progress | `uv run ~/.claude/skills/tasks/tasks.py <path> set KEY progress` |
| Mark done | `uv run ~/.claude/skills/tasks/tasks.py <path> set KEY done` |
| Verify all done | `uv run ~/.claude/skills/tasks/tasks.py <path> verify` |

## Error Handling

- **Task fails**: Leave status as `"progress"`, report the error, allow user to retry
- **No ready tasks but not all done**: Report which tasks are blocking and why
- **Missing dependency**: Report which upstream tasks need to complete first
- **Missing detail file**: Proceed using only the task description and PRD context

## Output Format

```
✓ Loaded tasks.yaml (X tasks)
  - Done: Y
  - In Progress: Z
  - Open: W

▶ Ready: task-name-1 (no deps)
▶ Ready: task-name-2 (no deps)

[Agents executing...]

✓ task-name-1 complete
  Modified: src/foo.ts, src/bar.ts

✓ task-name-2 complete
  Created: src/baz.ts

▶ Ready: task-name-3 (depends: task-name-1, task-name-2 ✓)

[...]

✓ All tasks complete!
```
