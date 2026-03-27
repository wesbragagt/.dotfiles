---
name: knowledge
description: Create, read, and update domain documentation stored under $(git rev-parse --show-toplevel)/docs/domains/. Use this skill whenever the user asks about domain concepts, business rules, terminology, ingestion, reconciliation, rate cards, or any domain-specific topic. Also use when documenting, saving, or updating knowledge. Trigger on "/knowledge", "/knowledge <topic>", "what do we know about X", "load docs for X", "document this", "save this knowledge", "update the docs for", "how does X work", or any question that likely requires domain knowledge to answer correctly. When in doubt, trigger — loading docs is cheap and always helpful.
argument-hint: [topic or query — optional]
---

# Knowledge

Manage domain documentation stored in the git repository at `$(git rev-parse --show-toplevel)/docs/domains/`.

Docs are organized as: `docs/domains/{domain}/{topic}.md`

The base path is always resolved from the repo root — run `git rev-parse --show-toplevel` to get it.

---

## Operations

### Load (default — no subcommand needed)

```
/knowledge
/knowledge rate cards
/knowledge ingestion preprocessing
```

1. Run `git rev-parse --show-toplevel` to get the repo root
2. Read `{repo_root}/docs/domains/README.md` to see what exists

**With an argument** (e.g., `/knowledge rate cards`):
3. Use Glob to list all `*.md` files under `{repo_root}/docs/domains/` (excluding README.md)
4. Fuzzy-match the argument against filenames, folder names, and README descriptions
5. Read and output the content of the best matching file(s) — return up to 3 if the query is broad

**Without an argument**:
3. Read and output the full content of every doc file under `{repo_root}/docs/domains/`

Output the loaded content directly so it is in context for answering the user's question.

---

### Create

```
/knowledge create <domain> <topic>
```

Example: `/knowledge create ingestion preprocessing-rate-cards`

1. Run `git rev-parse --show-toplevel` to get the repo root
2. Check if `{repo_root}/docs/domains/{domain}/{topic}.md` already exists
   - If it does, inform the user and offer to update instead
3. Use content from the conversation, or ask the user what to document
4. Write the file with a markdown heading derived from the topic slug
5. Update `{repo_root}/docs/domains/README.md`:
   - Add the domain section if it doesn't exist (with a one-line description of the domain)
   - Add a table row: `| [topic-slug](domain/topic-slug.md) | <one-line description> |`
   - Keep table rows sorted alphabetically by document name within each domain section
6. Confirm: `Created: docs/domains/{domain}/{topic}.md`

---

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

## Structure

```
docs/domains/
├── README.md              ← index — always keep this up to date
├── {domain}/
│   └── {topic}.md
└── ...
```

**Domain slug**: lowercase, single word (e.g. `ingestion`, `reconciliation`, `language`)
**Topic slug**: lowercase, hyphen-separated (e.g. `preprocessing-rate-cards`, `ubiquitous-language`)

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

## Known Domains

| Domain | Description |
|--------|-------------|
| `ingestion` | Email processing, file classification, pre-checks, Dropbox routing |
| `reconciliation` | Invoice matching, parcel/fulfillment reconciliation, CDM mapping |
| `classification` | GPT-based invoice/file classification logic and prompts |
| `dropbox` | Folder structure, upload conventions, brand folder resolution |
| `language` | Ubiquitous language, shared terminology, business vocabulary |
| `monday` | Ticket creation, reporter logic, TicketContext fields |
