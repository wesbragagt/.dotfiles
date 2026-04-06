---
name: obsidian
description: Interact with an Obsidian vault via the Obsidian CLI. Use when the user wants to create, read, search, organize, or manage notes, tasks, tags, properties, bookmarks, daily notes, or anything in their Obsidian vault. Trigger on phrases like "add a note", "search my vault", "create a daily note", "find notes tagged", "obsidian", "vault", "my notes".
argument-hint: <action and details, e.g. "create a note called Project Ideas" or "search for meetings">
---

# Obsidian

Interact with the user's Obsidian vault using the `obsidian` CLI.

## Prerequisites

The Obsidian desktop app must be running (the CLI communicates with the running app). Verify with:

```bash
obsidian version
```

If this fails, ask the user to open Obsidian first.

## Vault targeting

If the user has multiple vaults, add `vault=<name>` to any command. To discover vaults:

```bash
obsidian vaults verbose
```

When the user hasn't specified a vault and the command fails, list vaults and ask which one to use.

## Command reference

### Notes — CRUD

```bash
# Create
obsidian create name="Note Title" content="Body text"
obsidian create name="Note Title" template="Template Name"
obsidian create path="folder/note.md" content="Body" open  # open after creating

# Read
obsidian read file="Note Title"
obsidian read path="folder/note.md"

# Append / Prepend
obsidian append file="Note Title" content="New paragraph"
obsidian prepend file="Note Title" content="Top content"

# Open
obsidian open file="Note Title"
obsidian open path="folder/note.md" newtab

# Move / Rename
obsidian move file="Old Name" to="new-folder/"
obsidian rename file="Old Name" name="New Name"

# Delete
obsidian delete file="Note Title"           # moves to trash
obsidian delete file="Note Title" permanent  # permanent delete — confirm with user first
```

### Search

```bash
obsidian search query="search terms"
obsidian search query="search terms" path="folder" limit=10
obsidian search:context query="search terms"              # includes matching lines
obsidian search query="search terms" format=json total     # count + structured output
```

### Daily notes

```bash
obsidian daily                                    # open today's daily note
obsidian daily:read                               # read daily note contents
obsidian daily:append content="- Meeting at 3pm"  # append to daily note
obsidian daily:prepend content="# Top priority"   # prepend to daily note
obsidian daily:path                               # get daily note file path
```

### Tasks

```bash
obsidian tasks                          # list all incomplete tasks
obsidian tasks done                     # list completed tasks
obsidian tasks file="Project"           # tasks in a specific file
obsidian tasks daily                    # tasks from daily note
obsidian tasks verbose                  # group by file with line numbers
obsidian task file="Project" line=15 toggle  # toggle task status
obsidian task file="Project" line=15 done    # mark done
```

### Tags

```bash
obsidian tags                           # list all tags
obsidian tags counts sort=count         # tags sorted by frequency
obsidian tags file="Note Title"         # tags in a specific file
obsidian tag name="project" verbose     # files with a specific tag
```

### Properties (frontmatter)

```bash
obsidian properties                                  # list all properties in vault
obsidian properties file="Note Title"                # properties for a file
obsidian property:read name="status" file="Note"     # read a property value
obsidian property:set name="status" value="done" file="Note"
obsidian property:set name="due" value="2026-04-15" type=date file="Note"
obsidian property:remove name="draft" file="Note"
```

### Bookmarks

```bash
obsidian bookmarks                          # list bookmarks
obsidian bookmark file="important.md"       # bookmark a file
obsidian bookmark search="TODO" title="My TODOs"  # bookmark a search
```

### Links and graph

```bash
obsidian links file="Note Title"        # outgoing links
obsidian backlinks file="Note Title"    # incoming links
obsidian orphans                        # files with no incoming links
obsidian deadends                       # files with no outgoing links
obsidian unresolved                     # broken/unresolved links
```

### Files and folders

```bash
obsidian files                          # list all files
obsidian files folder="Projects" ext=md # filter by folder and extension
obsidian files total                    # file count
obsidian folders                        # list all folders
obsidian file file="Note Title"         # file metadata
obsidian vault                          # vault info (name, path, size)
```

### Templates

```bash
obsidian templates                              # list available templates
obsidian template:read name="Meeting Notes"     # read template content
obsidian create name="Standup" template="Meeting Notes" open
```

### Outline and word count

```bash
obsidian outline file="Note Title"              # heading tree
obsidian outline file="Note Title" format=md    # as markdown
obsidian wordcount file="Note Title"            # words and characters
```

### Plugins

```bash
obsidian plugins                                # list installed plugins
obsidian plugins:enabled                        # list enabled plugins
obsidian plugin:enable id="plugin-id"
obsidian plugin:disable id="plugin-id"
obsidian plugin:install id="plugin-id" enable   # install and enable
```

### Sync

```bash
obsidian sync:status                    # check sync status
obsidian sync on                        # resume sync
obsidian sync off                       # pause sync
obsidian sync:history file="Note"       # sync version history
```

### Commands

```bash
obsidian commands                       # list all available commands
obsidian commands filter="editor"       # filter by prefix
obsidian command id="command-id"        # execute a command
```

## Workflow patterns

### Quick capture to daily note

When the user wants to quickly jot something down:
```bash
obsidian daily:append content="- $(date +%H:%M) User's note here"
```

### Batch operations

For operations across multiple files, combine `obsidian files` or `obsidian search` output with a loop. Always confirm with the user before batch modifications.

### Creating structured notes

When creating notes with rich content, use `\n` for newlines:
```bash
obsidian create name="Meeting Notes" content="# Meeting\n\n## Attendees\n\n## Agenda\n\n## Action Items"
```

Or create with a template if one exists:
```bash
obsidian templates  # check available templates first
obsidian create name="Meeting Notes" template="Meeting" open
```

## Guardrails

- **Never delete permanently without explicit user confirmation.** Default to trash.
- **Never batch-modify files without confirming the scope with the user first.**
- **Quote values with spaces**: `name="My Note Title"`
- **Use `\n` for newlines** in content values, not literal newlines.
- When a command fails, check that Obsidian is running and the vault name is correct before retrying.
- Prefer `file=` (wiki-link style name resolution) over `path=` unless the user specifies an exact path.
