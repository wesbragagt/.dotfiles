### SQLite vs PostgreSQL for a Growing Side Project

- **SQLite** is zero-setup (single file, no server), excellent for prototypes and solo-dev projects, with great read performance and simple backups
- **SQLite breaks** at concurrent writes (single writer at a time), complex multi-table joins (3-10x slower), and multi-server deployments
- **PostgreSQL** handles concurrent writers via MVCC, has an advanced query optimizer, and offers rich features (JSONB, FTS, materialized views, pgvector, PostGIS)
- **PostgreSQL costs** more in setup, memory, and operational overhead (backups, monitoring, vacuuming)
- **Growth path**: SQLite breaks when write throughput exceeds capacity (~10K-100K req/day), multiple servers need shared DB, or complex analytics emerge. Migration tools like pgloader exist but require refactoring for type differences
- **2026 trend**: Turso, LiteFS, Litestream enable replicated SQLite at the edge for read-heavy architectures

**Decision**: Start with SQLite if solo dev + simple queries + mostly reads. Start with PostgreSQL if building SaaS, expecting concurrent users, or need multi-server deployment.

**Sources**
- [PostgreSQL vs SQLite for Solo Developers (2026)](https://solodevstack.com/blog/postgresql-vs-sqlite-solo-developers)
- [PostgreSQL vs SQLite: scaling path without downtime](https://cr0x.net/en/sqlite-to-postgresql-no-downtime/)
- [SQLite vs PostgreSQL: A Detailed Comparison](https://www.datacamp.com/blog/sqlite-vs-postgresql-detailed-comparison)
- [SQLite in Production? Not So Fast for Complex Queries](https://yyhh.org/blog/2026/01/sqlite-in-production-not-so-fast-for-complex-queries)
- [SQLite vs PostgreSQL for Rails SaaS in 2026](https://build.omaship.com/guides/sqlite-vs-postgresql-rails-saas-2026)
