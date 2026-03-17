# SQLite vs PostgreSQL for a Side Project That Might Grow

## Overview

Choosing between SQLite and PostgreSQL is one of the most common database decisions for side projects. Both are excellent, battle-tested databases, but they serve different contexts. This document covers the key tradeoffs, decision criteria, and a practical recommendation.

---

## SQLite

### What It Is
SQLite is a serverless, embedded relational database. The entire database lives in a single file on disk. There is no separate database process — the application reads and writes directly to the file.

### Strengths

- **Zero configuration**: No server to install, configure, or maintain. Works immediately after adding a library dependency.
- **Simplicity**: One file = one database. Backup is `cp myapp.db myapp.db.bak`. Migrations are simple file operations.
- **Portability**: The database file can be copied, emailed, or committed to version control. Great for development parity and local testing.
- **Performance for reads**: SQLite is extremely fast for read-heavy workloads on a single machine, often outperforming networked databases due to zero network overhead.
- **Low resource consumption**: No memory-hungry background process. Ideal for low-traffic apps, hobby projects, or apps running on small VMs.
- **Perfect for local/embedded use**: Mobile apps, desktop tools, CLI tools, and edge computing are natural fits.
- **Litestream / libSQL**: Modern tooling (Litestream for streaming replication, Turso/libSQL for distributed SQLite) has significantly expanded SQLite's production viability.

### Weaknesses

- **Concurrency limitations**: SQLite uses file-level locking. Only one writer can operate at a time. Under concurrent write loads, this becomes a serious bottleneck. WAL (Write-Ahead Logging) mode helps, but it is not a full solution.
- **No true client-server model**: Multiple application instances (e.g., horizontal scaling) cannot safely share a single SQLite file over a network filesystem.
- **Limited data types and features**: No native UUID type, no `RETURNING` clause in older versions, limited JSON support (improving), no stored procedures, no parallel query execution.
- **Schema migrations can be awkward**: SQLite does not support `ALTER TABLE DROP COLUMN` in older versions, and many migration tools have partial SQLite support.
- **No user/role management**: No built-in access control beyond file-system permissions.
- **Not suitable for distributed architectures**: If your app needs to run on multiple servers sharing the same database, SQLite requires workarounds (Litestream, Turso, etc.).

---

## PostgreSQL

### What It Is
PostgreSQL is a full client-server relational database with decades of development. It runs as a separate process (or cluster) and communicates over TCP/IP.

### Strengths

- **Concurrency**: MVCC (Multi-Version Concurrency Control) allows many simultaneous readers and writers without locking conflicts. Handles high concurrent workloads gracefully.
- **Rich feature set**: Native UUID, JSONB, arrays, range types, full-text search, window functions, CTEs, `RETURNING`, `ON CONFLICT`, lateral joins, and much more.
- **Horizontal and vertical scaling**: Supports read replicas, connection pooling (PgBouncer), partitioning, and integration with external sharding solutions.
- **Strong ecosystem**: Excellent support in every major ORM, migration tool, and hosting platform (Supabase, Neon, Railway, Render, AWS RDS, etc.).
- **Access control**: Fine-grained roles, schemas, and row-level security (RLS) make it suitable for multi-tenant applications.
- **Reliability and ACID compliance**: PostgreSQL is well known for correctness. It has extensive options for durability tuning.
- **Extensions**: PostGIS for geospatial data, pg_vector for AI embeddings, TimescaleDB for time series, and hundreds more.
- **Production-proven at scale**: Powers companies from small startups to companies with billions of records.

### Weaknesses

- **Operational overhead**: Requires a running server process. Local development requires Docker, a managed service, or a local install.
- **Resource usage**: Even idle PostgreSQL consumes more RAM and CPU than SQLite.
- **Setup friction**: Connection strings, credentials, and server management add cognitive overhead, especially for solo developers.
- **Cost**: Managed PostgreSQL hosting typically starts at $5–25/month. SQLite on a file system is free.
- **More complex backups**: Requires `pg_dump`, WAL archiving, or managed backup solutions rather than a simple file copy.

---

## Key Tradeoffs Summary

| Dimension              | SQLite                          | PostgreSQL                        |
|------------------------|----------------------------------|-----------------------------------|
| Setup complexity       | Near zero                        | Moderate (server required)        |
| Concurrency            | Limited (single writer)          | Excellent (MVCC)                  |
| Scalability            | Single machine / file            | Multi-instance, replication       |
| Feature richness       | Moderate, improving              | Extensive                         |
| Portability            | Single file                      | Requires server or managed host   |
| Cost (hosting)         | Essentially free                 | $5–25+/month managed             |
| Ecosystem support      | Good, some gaps                  | Universal                         |
| Migration tooling      | Partial support in some tools    | Full support everywhere           |
| Production viability   | Good for low-to-medium traffic   | Excellent at all scales           |
| Learning curve         | Very low                         | Low to moderate                   |

---

## When to Use SQLite

- The project is a personal tool, CLI, desktop app, or mobile app.
- Traffic is low and write concurrency is not a concern (hobby blogs, personal dashboards, internal tools with a handful of users).
- You want maximum simplicity and minimal infrastructure.
- You are building a prototype and want to iterate fast without managing a server.
- You plan to use Litestream or Turso if replication/durability becomes needed.
- The application will only ever run as a single process.

## When to Use PostgreSQL

- You anticipate significant user growth or concurrent traffic.
- The application is multi-tenant or will serve many users simultaneously.
- You need advanced features: JSONB, full-text search, geospatial, vector embeddings, row-level security, etc.
- The project will eventually be deployed in a scalable, multi-instance architecture.
- You want the broadest ecosystem support without worrying about feature gaps later.
- You are building something you want to take seriously from the start and do not mind a small setup cost.

---

## Practical Recommendation for a Side Project That Might Grow

**Start with PostgreSQL** if you are building something with genuine growth ambitions and you are comfortable with minor setup overhead.

The reasoning:

1. **Migration cost is high**: Moving from SQLite to PostgreSQL later is painful. Data migration, schema translation, and testing all take time. Starting with PostgreSQL avoids this.
2. **Managed hosting is cheap and easy**: Supabase, Neon, Railway, and Render all offer free or near-free tiers for PostgreSQL. The operational overhead argument has largely collapsed in 2024–2026.
3. **Feature access from day one**: You will not hit walls with PostgreSQL. If you later need JSONB, RLS, or vector search, it is already there.
4. **Ecosystem confidence**: ORMs (Prisma, Drizzle, SQLAlchemy, ActiveRecord) and migration tools (Flyway, Liquibase, Alembic) treat PostgreSQL as a first-class citizen.

**Use SQLite** if:
- The project is truly a local tool or personal utility with no plans for multi-user deployment.
- You want absolute zero-friction development and the scope is intentionally small.
- You are using a modern SQLite stack (Litestream + object storage for replication) and understand its constraints.

**The pragmatic middle ground**: Some teams use SQLite in development (via a library like `better-sqlite3`) and PostgreSQL in production. This works but introduces subtle behavioral differences that can cause hard-to-debug issues. It is generally better to use PostgreSQL in both environments, especially with Docker making local Postgres trivial.

---

## Final Verdict

For a side project that **might grow**, PostgreSQL is the safer long-term bet. The gap between SQLite and PostgreSQL in terms of setup friction has narrowed dramatically with modern managed services. The gap in capability and scalability ceiling, however, remains wide. Choosing PostgreSQL from the start means you never have to migrate, never hit concurrency walls, and have access to the full feature set as your project evolves.

SQLite remains an excellent choice for the right use case — but "a project that might grow" is precisely the scenario where PostgreSQL's advantages compound over time.
