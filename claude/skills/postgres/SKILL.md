---
name: postgres
description: Query a PostgreSQL database via a local tunnel. Use when asked to run queries, explore tables, or inspect schema state against a live database connected through db-tunnel or db-tunnel-ro.
---

# PostgreSQL Query Skill

Uses `query_postgres.py` — a read-only query tool that mirrors the guardrails of `mcp-server-postgres-multi-schema`:
- All queries run inside a **READ ONLY** transaction
- Schema isolation via restricted `search_path`
- Only `SELECT` / `WITH` (CTE) queries allowed
- Forbidden write/DDL keywords are rejected

The tunnel must already be running (`db-tunnel` or `db-tunnel-ro`). No MCP server required.

## Connection

Pass the connection string via `--url` or set `$DB_URL`. The `db-tunnel` scripts print it on startup:
```
Connection: postgresql://username:password@localhost:51555/app
```

If `$DB_URL` is set in the shell, you can omit `--url`.

## Running the script

`python3` has `psycopg2` available when in this project's nix devshell (via `flake.nix`). The script also has PEP 723 inline metadata, so `uv run` works as a fallback outside the devshell.

Use whichever works in your environment:

```bash
# In nix devshell (preferred)
python3 ~/.claude/skills/postgres/query_postgres.py "SELECT slug, name FROM client.brand" --url "postgresql://..."

# Outside devshell (uv auto-installs psycopg2)
uv run ~/.claude/skills/postgres/query_postgres.py "SELECT slug, name FROM client.brand" --url "postgresql://..."
```

## Run a query

```bash
python3 ~/.claude/skills/postgres/query_postgres.py "SELECT slug, name FROM client.brand" --url "postgresql://..."
```

```bash
DB_URL="postgresql://..." python3 ~/.claude/skills/postgres/query_postgres.py "SELECT * FROM cdm.reconciliation_run WHERE brand_id = '...'" --limit 20
```

Default schemas exposed via `search_path`: `public, client, cdm, analytics, reconciliation`

Override with `--schemas`:
```bash
python3 ~/.claude/skills/postgres/query_postgres.py "SELECT ..." --schemas "public,client" --url "postgresql://..."
```

## Describe a table

```bash
python3 ~/.claude/skills/postgres/query_postgres.py --describe client.invoice --url "postgresql://..."
```

## Discover tables

```bash
python3 ~/.claude/skills/postgres/query_postgres.py \
  "SELECT table_schema, table_name FROM information_schema.tables WHERE table_type = 'BASE TABLE' AND table_schema NOT IN ('pg_catalog','information_schema') ORDER BY table_schema, table_name" \
  --url "postgresql://..."
```

## Limit guardrails

**Always pass `--limit` explicitly.** Never let the script use its default of 50 unless the user has confirmed that is acceptable.

| Situation | Max limit |
|-----------|-----------|
| Exploring an unknown table | 10 |
| Debugging a specific record | 1–5 |
| Fetching results for analysis | 100 |
| User explicitly requests more | up to 500 |

- **Never exceed 500 rows** in a single call — large result sets flood context and are rarely useful as-is.
- If you need aggregate information (counts, sums, distributions), write a `GROUP BY` or aggregation query instead of fetching raw rows.
- If the user asks for "all" rows of a large table, ask them to confirm intent and suggest an aggregation or filtered query instead.

## Workflow

1. **Ask for the connection string** if not provided and `$DB_URL` is unset. Remind the user to run `db-tunnel-ro` or `db-tunnel` first.
2. **Describe tables first** with `--describe` before writing business queries against unfamiliar schemas.
3. **Always specify `--limit`** — pick the appropriate tier from the table above.
4. **Never run writes** — the script enforces read-only at the transaction level and will reject forbidden keywords.
