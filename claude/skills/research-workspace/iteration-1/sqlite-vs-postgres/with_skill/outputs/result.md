# Research: SQLite vs PostgreSQL for a Side Project That Might Grow

---

## SQLite: Architecture, Strengths, and Ideal Use Cases

SQLite is an embedded, serverless database library — not a separate server process. The entire engine links directly into the application and writes to a single portable file. This architectural decision carries profound downstream consequences.

**Core characteristics:**
- Zero configuration, no server process, no daemon management
- ACID-compliant with full transaction support
- Database stored as a single file (supports up to ~281 TB theoretically)
- Deployed in trillions of devices: iOS, Android, Chrome, Firefox, Windows, the Mars rovers

**Where SQLite genuinely excels:**
- Prototypes, MVPs, and side projects with low to moderate traffic
- Read-heavy workloads (SQLite allows unlimited concurrent readers)
- Single-server deployments where one app process touches the database
- Local-first and embedded applications (desktop apps, mobile, IoT)
- Websites under roughly 100K hits/day with typical read/write ratios
- Testing, CI environments, and developer laptops (zero-setup advantage)
- Edge computing (Cloudflare D1, Turso/LibSQL distribute SQLite globally)

**The WAL-mode upgrade:** SQLite in default journal mode serializes both reads and writes. Enabling WAL (Write-Ahead Logging) mode allows concurrent readers alongside a single writer, significantly improving throughput for typical web applications. Rails 8 ships with WAL mode on by default, and the "one-person framework" community has demonstrated SQLite handling substantial workloads on a single well-tuned server.

**The modern SQLite ecosystem (2025–2026):** Tools like Litestream (continuous S3 replication), LiteFS (distributed replication via Fly.io), and Turso/LibSQL (edge-deployed SQLite with a network layer) now address what were previously hard blockers. Turso also launched a "concurrent writes" technology preview in late 2025, claiming up to 4x write throughput improvement over raw SQLite — though this remains in beta.

---

## PostgreSQL: Architecture, Strengths, and Ideal Use Cases

PostgreSQL is a full client-server relational database system. A separate process listens for network connections, parses queries, manages a shared buffer pool, and handles multi-process concurrency through MVCC (Multi-Version Concurrency Control).

**Core characteristics:**
- ACID-compliant with full transaction isolation levels
- MVCC enables hundreds to thousands of concurrent readers and writers without blocking
- Rich type system: JSONB, arrays, geometric types, full-text search, UUID, ranges
- Extensible: PostGIS (geospatial), pgvector (AI/ML vector search), pg_cron, foreign data wrappers
- Row-level security, generated columns, materialized views, logical replication
- Second most popular database in the world as of 2025

**Where PostgreSQL excels:**
- Multi-user SaaS applications with concurrent write patterns from day one
- Applications requiring advanced query features (window functions, CTEs, lateral joins)
- Deployments across multiple app servers or containers
- Data integrity requirements (strict typing, foreign key enforcement, constraints)
- Terabyte-scale datasets
- Applications needing fine-grained access control (row-level security)
- Anything requiring a mature operational story: backups, replication, monitoring, connection pooling

**Managed hosting options (2025):** Supabase, Neon, Railway, Render, and PlanetScale (via compatibility) all offer managed PostgreSQL with reasonable free tiers, lowering the operational burden significantly for solo developers.

---

## Scalability, Concurrency, and Migration Tradeoffs

### The core scaling constraint: writes

SQLite's single-writer model is its primary architectural limit. Only one write transaction can proceed at a time. Additional writers queue and wait. Under concurrent write pressure:
- `SQLITE_BUSY` errors appear
- SQLite's default timeout is 5 seconds before a transaction fails
- Maximum sustained throughput is approximately 150K rows/second, with no parallelism benefit from additional threads

A real-world example: DeployStack ran a multi-database architecture (SQLite + Turso + PostgreSQL) before migrating entirely to PostgreSQL. Their satellite infrastructure generated 50–200 writes/second from heartbeats and audit logs across 100 active satellites — a load that exposed SQLite's serialization ceiling and produced regular `SQLITE_BUSY` errors. They migrated to PostgreSQL for its "true multi-writer parallelism without serialization."

PostgreSQL's MVCC handles this class of problem natively. PostgreSQL comfortably sustains thousands of writes per second and scales to 100+ simultaneous connections without blocking reads against writes.

### When SQLite's limits don't matter

For a typical read-heavy side project — a blog, a personal tool, a content site, a SaaS with light write volume — SQLite's single-writer model is not a practical constraint. Most web applications are 80–95% reads. With WAL mode enabled and proper tuning for modern SSD hardware, SQLite handles significant production loads on a single server.

The practical SQLite ceiling for a web application is roughly: one server, moderate write concurrency, database under 10GB, and no need for horizontal scaling. Cross that line and the friction compounds.

### Migration: the real cost

Migrating from SQLite to PostgreSQL is technically feasible but introduces meaningful friction:

1. **Type system mismatches**: SQLite is loosely typed (stores strings in integer columns). PostgreSQL enforces strict typing. Data cleanup is often required.
2. **Boolean and date columns**: SQLite stores booleans as `0/1` and dates as text. PostgreSQL uses native `BOOLEAN` and `TIMESTAMP` types.
3. **Foreign key enforcement**: SQLite historically allowed orphaned foreign keys. PostgreSQL enforces referential integrity by default.
4. **Schema translation**: Tools like `pgloader` automate most of this, but edge cases require manual resolution.
5. **Network overhead**: Local SQLite file reads have sub-millisecond latency. PostgreSQL connections over a network introduce 50–100ms for cold queries, requiring connection pooling (PgBouncer) to amortize.

For a database under 10GB, a migration typically requires a 1–4 hour maintenance window. The migration is achievable but has a non-zero cost — especially if the codebase accumulated SQLite-specific idioms or relied on its permissive typing.

---

## Selection Criteria for Side Projects That May Grow

The answer depends on three variables: **anticipated write concurrency**, **operational willingness**, and **deployment architecture**.

### Choose SQLite if:
- The project is a prototype or MVP where shipping speed matters more than future-proofing
- Write patterns are predominantly single-user or low-concurrent (personal tools, small-team internal apps)
- Deployment is a single server or container
- You want zero DevOps overhead (no connection pooling, no separate database service to manage, no backups beyond file copies or Litestream)
- The edge/embedded ecosystem is relevant (Cloudflare D1, Turso, Fly.io with LiteFS)
- You are comfortable with a migration later if the project genuinely needs it

### Choose PostgreSQL if:
- The project is SaaS or multi-user from day one, with concurrent writes baked into the design
- You are planning multiple app instances (containers, horizontal scaling) from the start
- The feature set requires JSONB, full-text search, row-level security, PostGIS, or pgvector
- Operational complexity is acceptable (or you're using a managed provider like Supabase or Neon)
- You want to avoid a migration entirely if growth materializes

### The "might grow" dimension

The SQLite documentation itself frames the choice starkly: "SQLite competes with fopen(), not with PostgreSQL." The fundamental question is not "which is better" but "what architecture does the application actually need?"

For a side project that might grow:
- If "might grow" means more users with read-heavy usage, SQLite scales well and a migration is deferred.
- If "might grow" means many concurrent writers (e.g., a real-time app, a job queue, a multi-tenant SaaS with bursty writes), PostgreSQL from the start avoids a forced migration at the worst possible moment.
- If "might grow" means horizontal scaling across multiple servers, SQLite does not support this without a distributed layer (Turso, LiteFS) — and even then with caveats.

A pragmatic heuristic used by the solo-developer community in 2026: **start with SQLite for simplicity; graduate to PostgreSQL when you see `SQLITE_BUSY` in logs more than once a week, when you need a second app server, or when your database exceeds 10GB.** The migration is annoying but not catastrophic for a project at early scale.

---

## Key Takeaways

1. **SQLite is not a toy** — it is a legitimate production database for read-heavy, single-server, embedded, and edge use cases. The 2025–2026 ecosystem (Litestream, Turso, WAL tuning) has substantially expanded its operational envelope.

2. **The core SQLite constraint is concurrent writes** — one writer at a time, always. For most side projects this is irrelevant. For write-heavy SaaS or multi-server deployments, it becomes the ceiling.

3. **PostgreSQL's complexity has been largely abstracted away** — managed providers (Supabase, Neon, Railway) give PostgreSQL's power with minimal operational burden. The "PostgreSQL requires DevOps expertise" objection weakened significantly by 2025.

4. **Migration is achievable but has real friction** — type system differences, schema translation, and connection pooling setup are the main pain points. Doing it under growth pressure is worse than doing it deliberately.

5. **The "might grow" hedge tilts toward PostgreSQL if concurrent writes are in scope** — if the side project's growth path involves multiple concurrent writers or multiple app servers, starting with PostgreSQL eliminates a forced migration. If growth is primarily more reads and more users hitting a single server, SQLite is viable further than most developers expect.

---

## Sources and Further Reading

- [SQLite: Appropriate Uses](https://www2.sqlite.org/whentouse.html) — official guidance from the SQLite authors on when to use and not use SQLite
- [How to Migrate from SQLite to PostgreSQL (Render)](https://render.com/articles/how-to-migrate-from-sqlite-to-postgresql) — practical migration steps, pain points, and when to trigger a migration
- [PostgreSQL vs SQLite for Solo Developers (SoloDevStack, 2026)](https://solodevstack.com/blog/postgresql-vs-sqlite-solo-developers) — decision criteria and operational comparison
- [DeployStack: PostgreSQL Migration Technical Changelog](https://deploystack.io/changelog/postgresql-migration-technical-changelog) — real-world case study of SQLite write bottlenecks at modest scale
- [SQLite for Side Projects: Why You Don't Always Need Postgres](https://stephencollinstech.substack.com/p/sqlite-for-side-projects-why-you) — argument for starting with SQLite
- [The SQLite Renaissance (DEV.to, 2026)](https://dev.to/pockit_tools/the-sqlite-renaissance-why-the-worlds-most-deployed-database-is-taking-over-production-in-2026-3jcc) — survey of the modern SQLite ecosystem
- [Turso: Beyond the Single-Writer Limitation](https://turso.tech/blog/beyond-the-single-writer-limitation-with-tursos-concurrent-writes) — concurrent writes tech preview for LibSQL/Turso
- [SQLite in Production: A Real-World Benchmark](https://shivekkhurana.com/blog/sqlite-in-production/) — WAL tuning and vertical scaling limits
- [PostgreSQL vs SQLite: When You Should Choose the "Wrong" Database (Medium)](https://medium.com/the-software-journal/postgresql-vs-sqlite-when-you-should-choose-the-wrong-database-70860f36bfad)
- [Why PostgreSQL Is Still One of the Best Databases in 2025 (Medium)](https://medium.com/@thisistanujgarg/why-postgresql-is-still-one-of-the-best-databases-you-can-choose-in-2025-079a804b2c47)
