---
name: knowledge
description: Create, read, and update domain documentation stored under $(git rev-parse --show-toplevel)/docs/domains/. Use this skill when asked to document, look up, search, or update knowledge about any domain topic (ingestion, reconciliation, classification, rate cards, etc.). Trigger on phrases like "document this", "look up", "what do we know about", "update the docs for", "save this knowledge", or "/knowledge".
argument-hint: <create|read|update> [domain] [topic] [--query <fuzzy-search>]
---

# Knowledge

Manage domain documentation stored in the git repository at `$(git rev-parse --show-toplevel)/docs/domains/`.

Docs are organized as: `docs/domains/{domain}/{topic}.md`

The base path is always resolved from the repo root — run `git rev-parse --show-toplevel` to get it.

---

## Operations

### Read (fuzzy search)

```
/knowledge read <query>
/knowledge read "rate card"
/knowledge read "ingestion preprocessing"
```

1. Run `git rev-parse --show-toplevel` to get the repo root
2. Read `{repo_root}/docs/domains/README.md` for a quick overview of what exists
3. Use Glob to find all `*.md` files under `{repo_root}/docs/domains/` (excluding README.md)
4. Use Grep to search file contents and filenames for the query terms
5. Rank results: exact filename match > path match > content match
6. Read and return the top matching file(s)
7. If multiple matches, list them and ask the user which to open — or return all if <= 3

### Create

```
/knowledge create <domain> <topic>
```

Example: `/knowledge create ingestion preprocessing-rate-cards`

1. Run `git rev-parse --show-toplevel` to get the repo root
2. Check if `{repo_root}/docs/domains/{domain}/{topic}.md` already exists with Glob
   - If it exists, inform the user and offer to update instead
3. Use the content already present in conversation, or ask the user for it
4. Write the file with a markdown heading derived from the topic slug
5. Update `{repo_root}/docs/domains/README.md`:
   - Add the domain section if it doesn't exist (with a one-line description of the domain)
   - Add a table row: `| [topic-slug](domain/topic-slug.md) | <one-line description> |`
   - Keep the table sorted alphabetically by document name within each domain section
6. Confirm: `Created: docs/domains/{domain}/{topic}.md`

### Update

```
/knowledge update <domain> <topic>
```

Example: `/knowledge update ingestion preprocessing-rate-cards`

1. Run `git rev-parse --show-toplevel` to get the repo root
2. Read the existing file first
3. Apply the user's changes (new sections, corrections, additions)
4. Write the updated file
5. If the document's purpose changed significantly, update its description row in `docs/domains/README.md`
6. Confirm: `Updated: docs/domains/{domain}/{topic}.md`

---

## README.md Format

`docs/domains/README.md` is the index. Keep it structured as:

```markdown
# Domain Knowledge Index

Brief intro line.

---

## {domain}

One-line description of the domain.

| Document | Description |
|----------|-------------|
| [topic-slug](domain/topic-slug.md) | One-line description |
```

- One `##` section per domain, alphabetically sorted
- Table rows sorted alphabetically by document name within each domain
- Descriptions are one line — enough to know whether to open the file

---

## File Format

All docs use plain markdown. No required frontmatter.
Topic slug: lowercase, hyphen-separated (e.g. `preprocessing-rate-cards`, `classify-invoice-files`).
Domain slug: lowercase, single word (e.g. `ingestion`, `reconciliation`, `classification`).

---

## Known Domains

| Domain | Description |
|--------|-------------|
| `ingestion` | Email processing, file classification, pre-checks, Dropbox routing |
| `reconciliation` | Invoice matching, parcel/fulfillment reconciliation, CDM mapping |
| `classification` | GPT-based invoice/file classification logic and prompts |
| `dropbox` | Folder structure, upload conventions, brand folder resolution |
| `monday` | Ticket creation, reporter logic, TicketContext fields |

---

## Examples

```
/knowledge read "rate card freight fulfillment"
-> Reads README.md, finds ingestion/preprocessing-rate-cards.md, returns it

/knowledge create dropbox folder-structure
-> Creates docs/domains/dropbox/folder-structure.md
-> Adds dropbox section + row to README.md

/knowledge update ingestion preprocessing-rate-cards
-> Reads existing file, applies edits, rewrites
-> Updates README.md row if description changed
```
