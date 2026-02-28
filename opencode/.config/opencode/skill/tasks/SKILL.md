---
name: tasks
description: Manage task YAML files with status tracking and dependencies. Use this skill to verify, query, and update task status in tasks.yaml files.
---

This skill provides operations for managing task YAML files following the task spec.

## Task YAML Spec

```yaml
tasks:
  - key: task-name          # Unique kebab-case identifier
    description: Brief description of the task
    details: ./task-name.md # Path to detail file with implementation notes
    status: open            # open, progress, or done
    depends: []             # List of task keys this depends on
```

## Operations

All operations use `yq` on a tasks.yaml file.

### Verify All Tasks Complete

Returns exit code 0 if all tasks are done, 1 otherwise.

```bash
yq '[.tasks[].status == "done"] | all' tasks.yaml | grep -q true
```

### View Pending Tasks (not done)

```bash
yq '.tasks[] | select(.status != "done")' tasks.yaml
```

### View Ready Tasks (open with no blockers)

```bash
yq '.tasks[] | select(.status == "open" and (.depends | length == 0))' tasks.yaml
```

### View Tasks In Progress

```bash
yq '.tasks[] | select(.status == "progress")' tasks.yaml
```

### View Completed Tasks

```bash
yq '.tasks[] | select(.status == "done")' tasks.yaml
```

### Mark Task In Progress

```bash
yq '.tasks |= (.[] | select(.key == "task-name") | .status) = "progress"' -i tasks.yaml
```

### Mark Task Done

```bash
yq '.tasks |= (.[] | select(.key == "task-name") | .status) = "done"' -i tasks.yaml
```

### Mark Task Open

```bash
yq '.tasks |= (.[] | select(.key == "task-name") | .status) = "open"' -i tasks.yaml
```

### View Blocked Tasks (have uncompleted dependencies)

```bash
yq '.tasks[] | select(.status != "done" and (.depends | length > 0))' tasks.yaml
```

### Get Task by Key

```bash
yq '.tasks[] | select(.key == "task-name")' tasks.yaml
```

### List All Task Keys

```bash
yq '.tasks[].key' tasks.yaml
```

### Count Tasks by Status

```bash
yq '[.tasks[].status] | group_by(.) | map({status: .[0], count: length})' tasks.yaml
```
