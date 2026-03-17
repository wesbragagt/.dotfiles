#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "psycopg2-binary",
# ]
# ///
"""
PostgreSQL read-only query tool.

Mirrors the guardrails of mcp-server-postgres-multi-schema:
  - All queries run inside a READ ONLY transaction
  - Schema isolation via restricted search_path
  - Only SELECT / WITH (CTE) queries allowed
  - Forbidden write/DDL keywords are rejected

Usage:
    uv run query_postgres.py "SELECT ..." [--url URL] [--schemas s1,s2] [--limit N]
    uv run query_postgres.py --describe schema.table [--url URL]

Connection:
    Pass connection string via --url or set $DB_URL environment variable.
    Format: postgresql://user:password@localhost:5432/dbname

Options:
    --url URL           PostgreSQL connection string (overrides $DB_URL)
    --schemas s1,s2     Comma-separated schemas to expose via search_path
                        (default: public,client,cdm,analytics,reconciliation)
    --limit N           Max rows to return (default: 50, ignored if query has LIMIT)
    --describe s.t      Describe columns of schema.table instead of running a query

Examples:
    uv run query_postgres.py "SELECT slug, name FROM client.brand LIMIT 5"
    uv run query_postgres.py "SELECT * FROM cdm.reconciliation_run" --limit 20
    uv run query_postgres.py --describe client.invoice
"""

import os
import re
import sys
from typing import Optional

import psycopg2
import psycopg2.extensions
import psycopg2.extras


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

DEFAULT_LIMIT = 50
DEFAULT_SCHEMAS = "public,client,cdm,analytics,reconciliation"

FORBIDDEN_KEYWORDS = [
    "INSERT",
    "UPDATE",
    "DELETE",
    "DROP",
    "TRUNCATE",
    "ALTER",
    "CREATE",
    "GRANT",
    "REVOKE",
    "MERGE",
    "CALL",
    "EXECUTE",
    "COPY",
    "VACUUM",
    "ANALYZE",
    "REINDEX",
    "CLUSTER",
    "LOCK",
    "LISTEN",
    "NOTIFY",
    "UNLISTEN",
]


# ---------------------------------------------------------------------------
# Connection
# ---------------------------------------------------------------------------


def get_connection(url: Optional[str], schemas: list[str]) -> psycopg2.extensions.connection:
    """Open a PostgreSQL connection and configure search_path."""
    dsn = url or os.environ.get("DB_URL")
    if not dsn:
        raise ValueError(
            "No connection string provided. Pass --url or set $DB_URL.\n"
            "Example: postgresql://user:password@localhost:5432/app"
        )

    conn = psycopg2.connect(dsn)
    conn.set_session(readonly=True, autocommit=False)

    with conn.cursor() as cur:
        # Restrict to allowed schemas only (mirrors MCP server search_path isolation)
        schema_list = ", ".join(f'"{s.strip()}"' for s in schemas)
        cur.execute(f"SET search_path TO {schema_list}")

    return conn


# ---------------------------------------------------------------------------
# Query guardrails
# ---------------------------------------------------------------------------


def validate_query(sql: str) -> None:
    """Reject anything that isn't a read-only SELECT or CTE."""
    normalized = sql.strip().upper()

    if not (normalized.startswith("SELECT") or normalized.startswith("WITH")):
        raise ValueError(
            "Only SELECT queries are allowed. Query must start with SELECT or WITH."
        )

    for keyword in FORBIDDEN_KEYWORDS:
        if re.search(rf"\b{keyword}\b", normalized):
            raise ValueError(f"Query contains forbidden keyword: {keyword}")


def apply_limit(sql: str, limit: int) -> str:
    """Append LIMIT if the query doesn't already have one."""
    if re.search(r"\bLIMIT\s+\d+", sql.strip().upper()):
        return sql
    return sql.rstrip().rstrip(";") + f" LIMIT {limit}"


# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------


def format_table(columns: list[str], rows: list[tuple]) -> str:
    """Render results as a plain ASCII table."""
    if not rows:
        return "(0 rows)"

    widths = [len(c) for c in columns]
    for row in rows:
        for i, val in enumerate(row):
            widths[i] = max(widths[i], min(len(str(val) if val is not None else "NULL"), 60))

    header = "  ".join(c.ljust(w) for c, w in zip(columns, widths))
    separator = "  ".join("-" * w for w in widths)
    lines = [header, separator]

    for row in rows:
        cells = []
        for val, w in zip(row, widths):
            s = str(val) if val is not None else "NULL"
            if len(s) > w:
                s = s[: w - 3] + "..."
            cells.append(s.ljust(w))
        lines.append("  ".join(cells))

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Query mode
# ---------------------------------------------------------------------------


def run_query(sql: str, conn: psycopg2.extensions.connection, limit: int) -> str:
    validate_query(sql)
    sql = apply_limit(sql, limit)

    with conn.cursor() as cur:
        cur.execute(sql)
        columns = [desc[0] for desc in cur.description]
        rows = cur.fetchall()

    output = [f"Rows: {len(rows)}", ""]
    output.append(format_table(columns, rows))
    return "\n".join(output)


# ---------------------------------------------------------------------------
# Describe mode
# ---------------------------------------------------------------------------


def run_describe(schema: str, table: str, conn: psycopg2.extensions.connection) -> str:
    with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cur:
        cur.execute(
            """
            SELECT
                c.column_name,
                c.data_type,
                c.is_nullable,
                c.column_default,
                CASE WHEN pk.column_name IS NOT NULL THEN 'YES' ELSE 'NO' END AS primary_key
            FROM information_schema.columns c
            LEFT JOIN (
                SELECT kcu.column_name
                FROM information_schema.table_constraints tc
                JOIN information_schema.key_column_usage kcu
                  ON tc.constraint_name = kcu.constraint_name
                 AND tc.table_schema    = kcu.table_schema
                 AND tc.table_name      = kcu.table_name
                WHERE tc.constraint_type = 'PRIMARY KEY'
                  AND tc.table_schema = %s
                  AND tc.table_name   = %s
            ) pk ON pk.column_name = c.column_name
            WHERE c.table_schema = %s
              AND c.table_name   = %s
            ORDER BY c.ordinal_position
            """,
            (schema, table, schema, table),
        )
        rows = cur.fetchall()

    if not rows:
        return f"No table found: {schema}.{table}"

    col_names = ["column_name", "data_type", "is_nullable", "column_default", "primary_key"]
    headers   = ["COLUMN",      "TYPE",       "NULLABLE",    "DEFAULT",         "PK"]
    data = [[str(r[c] or "") for c in col_names] for r in rows]

    widths = [len(h) for h in headers]
    for row in data:
        for i, val in enumerate(row):
            widths[i] = max(widths[i], min(len(val), 50))

    header_line = "  ".join(h.ljust(w) for h, w in zip(headers, widths))
    separator   = "  ".join("-" * w for w in widths)
    lines = [f"TABLE: {schema}.{table}", "", header_line, separator]
    for row in data:
        cells = []
        for val, w in zip(row, widths):
            if len(val) > w:
                val = val[: w - 3] + "..."
            cells.append(val.ljust(w))
        lines.append("  ".join(cells))

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def parse_args(argv: list[str]) -> dict:
    args = {
        "url": None,
        "schemas": DEFAULT_SCHEMAS,
        "limit": DEFAULT_LIMIT,
        "describe": None,
        "sql": None,
    }

    i = 1
    while i < len(argv):
        a = argv[i]
        if a in ("--url",) and i + 1 < len(argv):
            args["url"] = argv[i + 1]; i += 2
        elif a in ("--schemas",) and i + 1 < len(argv):
            args["schemas"] = argv[i + 1]; i += 2
        elif a in ("--limit",) and i + 1 < len(argv):
            try:
                args["limit"] = int(argv[i + 1])
            except ValueError:
                print(f"Error: --limit must be an integer", file=sys.stderr)
                sys.exit(1)
            i += 2
        elif a in ("--describe",) and i + 1 < len(argv):
            args["describe"] = argv[i + 1]; i += 2
        elif not a.startswith("--") and args["sql"] is None:
            args["sql"] = a; i += 1
        else:
            i += 1

    return args


def main() -> None:
    if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help"):
        print(__doc__)
        sys.exit(0)

    args = parse_args(sys.argv)
    schemas = [s.strip() for s in args["schemas"].split(",") if s.strip()]

    try:
        conn = get_connection(args["url"], schemas)
        try:
            if args["describe"]:
                if "." not in args["describe"]:
                    print(
                        f"Error: --describe expects schema.table, got '{args['describe']}'",
                        file=sys.stderr,
                    )
                    sys.exit(1)
                schema, table = args["describe"].split(".", 1)
                print(run_describe(schema, table, conn))

            elif args["sql"]:
                print(run_query(args["sql"], conn, args["limit"]))

            else:
                print(__doc__)
                sys.exit(1)

        finally:
            conn.close()

    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except psycopg2.Error as e:
        print(f"Database error: {e.pgerror or str(e)}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
