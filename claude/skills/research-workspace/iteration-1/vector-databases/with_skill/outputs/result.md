# Research: Vector Databases

## What They Are and How They Work

### The Core Problem

Traditional relational databases search by exact match. SQL can instantly find all rows where `age > 25`, but it cannot answer "find documents semantically similar to this query." When you process unstructured content (text, images, audio) through a machine learning model, the output is a *vector embedding*: a dense array of floating-point numbers (typically 384 to 4096 dimensions) that encodes semantic meaning. Things with similar meaning end up geometrically close in that high-dimensional space.

Vector databases are purpose-built to store these embeddings and answer **nearest-neighbor queries** at scale — finding the top-k vectors closest to a query vector, often in milliseconds across millions or billions of records.

### Distance Metrics

The three primary similarity functions are:

- **Cosine similarity** — angle between vectors, most common for text (direction matters, not magnitude)
- **L2/Euclidean distance** — absolute geometric distance, common for image embeddings
- **Inner product (dot product)** — used when magnitude encodes relevance score (e.g., recommendation systems)

### Indexing Algorithms

Naive (brute-force) search scans every vector and is O(n) — unusable beyond a few hundred thousand vectors. Production systems use **Approximate Nearest Neighbor (ANN)** algorithms that trade a small amount of recall for orders-of-magnitude speedup.

**HNSW (Hierarchical Navigable Small World)**
The dominant algorithm for most use cases. Builds a multi-layer graph structure where each layer is progressively sparser. Queries traverse from coarse to fine layers, following greedy graph traversal to find approximate neighbors. Advantages: very fast queries (sub-millisecond at millions scale), high recall (~95-99%), supports incremental inserts. Drawbacks: high memory overhead (the graph structure lives in RAM), build time scales roughly O(n log n), and random inserts degrade performance in write-heavy workloads.

**IVF (Inverted File Index)**
Clusters vectors using k-means at build time, then at query time only searches the nearest clusters (controlled by `nprobe` parameter). Lower memory footprint than HNSW since the cluster assignment table replaces a full graph. Best suited for static or slowly-changing datasets and large-scale deployments where memory is a constraint. Accuracy is tunable via `nprobe`: higher = better recall, higher latency.

**PQ (Product Quantization)**
A *compression* technique rather than an indexing strategy. Splits high-dimensional vectors into subvectors and quantizes each to a learned codebook, reducing storage by 4-32x with modest recall loss. Almost always combined with IVF (IVF-PQ) for billion-scale deployments where storing full float32 vectors is cost-prohibitive.

**Flat (brute-force)**
Exact search with perfect recall. Practical only for small collections (<100K vectors) or as a re-ranking layer on top of ANN candidates.

The practical rule: **HNSW for most production workloads; IVF-PQ when you need billion-scale with constrained memory.**

---

## The Landscape: Databases That Exist

### Dedicated Vector-Native Databases

**Qdrant**
Written in Rust (Apache 2.0). As of Q1 2026 benchmarks, the fastest open-source option at ~4ms p50 latency across 1M vectors with 1536 dimensions. Standout feature: rich payload filtering that doesn't sacrifice query speed, making it well-suited for multi-tenant SaaS architectures where each user has private data sharing one cluster. Supports HNSW and scalar/binary quantization. Self-hosted or managed (Qdrant Cloud).

**Milvus / Zilliz Cloud**
The most feature-complete open-source vector database. Supports 8 indexing algorithms including GPU-accelerated indexes. Designed for enterprise-scale deployments, capable of trillion-vector search. ~6ms p50 in benchmarks. Managed version is Zilliz Cloud. Complex to operate self-hosted; architecture separates storage, compute, and coordination into distinct services. Best for organizations with large teams and massive scale requirements.

**Weaviate**
Open-source, schema-based, with a built-in knowledge graph and first-class hybrid search (combining BM25 keyword + vector). Strong GraphQL API. ~12ms p50. Native module system for auto-vectorizing data via external models (OpenAI, Cohere, Hugging Face). Good fit when you need hybrid keyword+semantic search out of the box.

**Chroma**
Lightweight, Python-first, embedded-first. Minimal setup — runs in-process or as a lightweight server. Deep LangChain and LlamaIndex integration. ~12ms p50, but not designed for horizontal scale. The overwhelmingly popular choice for prototyping and local development. Not suited for production at significant scale.

**LanceDB**
Columnar storage format (Apache Lance), disk-backed, embedded. No separate server process required. Particularly strong for analytics workloads and multi-modal data (stores vectors alongside structured data and raw files). Growing in popularity for agent memory and local deployments.

### Managed Cloud Services

**Pinecone**
The original "zero-ops" vector database as a service. Serverless model where you pay per query and storage without managing infrastructure. ~8ms p50. Excellent developer experience and documentation. Went through a high-profile valuation correction (raised at ~$750M in 2023, reportedly exploring sale in mid-2025 before stabilizing under new leadership). Serverless tier has cold-start latency (seconds) if the index is idle — dedicated tiers are required for latency-sensitive production apps.

**Redis (Redis Query Engine)**
Redis 8 added native vector search as a first-class feature (not a module). ~5ms p50, ~20ms p99, with 250K QPS throughput demonstrated at 1B vectors in ScyllaDB-comparable tests. Best option when you already have Redis in your stack and want to avoid introducing new infrastructure. Supports HNSW, IVF, and FLAT indexes plus hybrid search (FT.HYBRID, GA in Redis 8.4+).

### Vector Search in Existing Databases

**pgvector (PostgreSQL extension)**
Adds `vector` data type and HNSW/IVF-Flat indexes to PostgreSQL. The compelling argument: transactional consistency between relational data and embeddings, zero new infrastructure, familiar operations (backups, monitoring, replication). ~18ms p50 at 1M vectors — slower than dedicated systems, but workloads up to ~10M vectors with good indexing are practical. At >10M vectors or very high QPS, dedicated systems pull ahead decisively. The right question is whether your constraints actually require a dedicated vector DB, not which is theoretically faster.

**Elasticsearch / OpenSearch**
Battle-tested distributed search engines with vector search added via HNSW (kNN). ~15ms p50. Strong BM25 keyword search + vector hybrid. Enterprise operational maturity (security, snapshots, observability) is unmatched. The 2026 consensus: vector search has become *a feature of existing databases*, and Elasticsearch/OpenSearch are strong choices when you already run them or need sophisticated text + vector hybrid search.

**MongoDB Atlas Vector Search**
Integrated into MongoDB's document model. Supports hybrid full-text + vector search with rich JSON filtering. Practical for teams already on MongoDB who don't want a second database.

**ScyllaDB Vector Search**
GA as of January 2026. Demonstrated 250K QPS and 2ms p99 at 1 billion vectors. Compelling for teams running ScyllaDB for their primary data who want unified infrastructure.

### The Market Shift: Vector Search as a Feature

A notable trend: by 2025-2026, the original "pure-play vector database" narrative has shifted. Vectors have become a feature of existing platforms rather than a standalone category. Every major database vendor (Postgres, Redis, MongoDB, Elasticsearch, Snowflake, Databricks) now supports vector search. This has compressed the addressable market for dedicated vector databases and driven consolidation. The practical implication: the threshold for needing a dedicated vector database is now higher than it was in 2023.

---

## Performance and Architecture Tradeoffs

### Benchmark Summary (Q1 2026, 1M vectors, 1536 dimensions)

| Database | p50 latency | p99 latency | Notes |
|---|---|---|---|
| Qdrant (OSS/managed) | 4ms | 25ms | Best open-source speed |
| Redis (OSS/managed) | 5ms | 20ms | Best p99 among fast options |
| Milvus (OSS/managed) | 6ms | 35ms | Most index variety |
| Pinecone (managed) | 8ms | 45ms | Best managed DX |
| Chroma (OSS) | 12ms | 70ms | Not optimized for scale |
| Weaviate (OSS/managed) | 12ms | 65ms | Better with hybrid search |
| Elasticsearch (OSS/managed) | 15ms | 75ms | Strong hybrid |
| pgvector (OSS) | ~18ms | N/A | With proper HNSW tuning |

*Source: Salt Technologies AI benchmark dataset, Q1 2026, CC BY 4.0*

### Key Architecture Tradeoffs

**In-memory vs. disk-backed**
HNSW indexes typically require the full graph in RAM (30-50% memory overhead beyond raw vector storage). At 10M 1536-dim float32 vectors, that's ~60GB of raw vectors plus graph overhead. IVF-PQ dramatically reduces this at a recall cost. LanceDB and IVF-based systems can work effectively disk-backed.

**Write-heavy vs. read-heavy**
HNSW degrades with high-frequency random inserts since the graph must be updated dynamically. Systems with write-heavy patterns (streaming embeddings) need either: async index rebuilds (Milvus does this), buffer layers before indexing, or IVF-based approaches with periodic reindexing.

**Recall vs. latency tuning**
HNSW's `ef_search` (search width) and IVF's `nprobe` both govern the recall-latency tradeoff. Production systems typically target 95-99% recall — getting from 99% to 100% often doubles latency. Benchmarks without stated recall numbers are misleading.

**Filtering**
Metadata filtering (returning only vectors matching certain attributes) is where many databases struggle. Naive post-filtering (find top-k, then filter) can miss relevant results. Pre-filtering (narrow by metadata first, then search) can miss vectors in small filter sets. Qdrant's payload-based filtering and Milvus's partition-level filtering handle this most gracefully. pgvector's approach: SQL WHERE clause alongside the vector search — conceptually clean but can be slow without careful indexing.

**Single-tenant vs. multi-tenant**
For SaaS apps with per-user data isolation, Qdrant's collection+payload architecture performs especially well. Alternatives: separate collections per tenant (expensive at scale), or metadata-filtered single collection (degrades with many tenants).

---

## Use Cases and Real-World Applications

### Retrieval-Augmented Generation (RAG)
The primary driver of vector database adoption. LLMs have a knowledge cutoff and a fixed context window — they can't reason over your private data without it being injected at query time. RAG flow: embed user query → nearest-neighbor search against document embeddings → inject retrieved chunks into LLM context → generate grounded response. The quality of retrieval directly determines whether the LLM answers accurately or halluccinates.

Emerging best practices for RAG (2025-2026):
- **Semantic chunking** over fixed-size chunking (LLM-detected breakpoints preserve context)
- **Late chunking** (embed full documents, retrieve chunks) for better global context
- **GraphRAG** (vectors + knowledge graphs) for multi-hop reasoning that pure vector search struggles with
- **Hybrid search** (BM25 + dense vectors, RRF fusion) consistently outperforms pure vector search on most RAG benchmarks

### Semantic Search
Replace or augment keyword search. Users searching "battery dies fast" surface reviews about "charge doesn't hold." Applied across e-commerce product search, internal document search, customer support knowledge bases, and code search.

### Recommendation Systems
User and item embeddings placed in the same space; nearest-neighbor queries surface similar products, content, or users. Netflix, Spotify, and similar platforms use embedding-based recommendations at scale.

### Anomaly Detection / Fraud Detection
Normal patterns cluster together; outlier vectors (fraud signals, network intrusions) are distant from clusters. Vector databases enable real-time nearest-neighbor scoring.

### Multimodal Search
CLIP and similar models embed images and text into a shared vector space. Search images by text query, find similar images, or cross-modal retrieval.

### Agent Memory
LLM agents need persistent memory across sessions. Vector databases store past interactions as embeddings; the agent retrieves relevant memories via similarity search at each turn.

### Deduplication
Find near-duplicate documents, images, or records at scale by clustering embeddings with high cosine similarity.

---

## How to Pick One: Selection Framework

### Step 1: Determine if you actually need a dedicated vector database

Use pgvector or your existing database's built-in vector search first if:
- You already run PostgreSQL, Redis, MongoDB, or Elasticsearch
- Your dataset is under ~5-10M vectors
- You don't need very high QPS (under ~1,000 queries/second)
- Operational simplicity and cost matter more than peak performance

Graduate to a dedicated vector database when:
- Dataset exceeds 10-50M vectors with strict latency SLAs
- Very high QPS (thousands of concurrent queries)
- Complex filtering at scale degrades performance noticeably
- You need GPU-accelerated indexing or multi-vector search

### Step 2: Match against your constraints

| Situation | Recommended Path |
|---|---|
| Prototype / local dev | **Chroma** or **LanceDB** (embedded, zero ops) |
| Already on PostgreSQL | **pgvector** (start here, migrate later if needed) |
| Already on Redis | **Redis Query Engine** (Redis 8+) |
| Zero-ops managed, fastest DX | **Pinecone** (dedicated tier for latency-sensitive) |
| Open-source, high performance, advanced filtering | **Qdrant** |
| Multi-tenant SaaS, per-user isolation | **Qdrant** (payload partitioning) |
| Enterprise-grade, maximum scale (billions+), GPU | **Milvus / Zilliz Cloud** |
| Hybrid keyword + vector search, schema-first | **Weaviate** or **Elasticsearch** |
| Existing MongoDB stack | **MongoDB Atlas Vector Search** |

### Step 3: Evaluate across these axes

1. **Scale**: How many vectors today? In 12 months? At 1M, almost everything works. At 100M+, only purpose-built systems remain competitive.
2. **Latency SLA**: p50 of 10ms vs. 50ms matters differently for user-facing search vs. batch pipelines.
3. **Write pattern**: Mostly static corpus (IVF fine), continuous ingestion (HNSW with async rebuild or Qdrant), high-frequency updates (avoid pure HNSW).
4. **Filtering complexity**: Heavy metadata filtering? Test filtering performance specifically — it's where many benchmarks lie.
5. **Operational overhead**: Managed service vs. self-hosted. Self-hosting Milvus is non-trivial. Qdrant is simpler. pgvector is trivially operated.
6. **Cost structure**: Pinecone charges per query+storage (predictable for low-volume, expensive at high QPS). Self-hosted pays compute. pgvector costs nothing extra beyond your Postgres instance.
7. **Ecosystem integration**: LangChain and LlamaIndex support all major options. Framework-specific depth varies — Chroma has the tightest LangChain integration for local dev.
8. **Hybrid search requirement**: If you need BM25+vector fusion, Weaviate and Elasticsearch are the strongest native options. pgvector + a full-text search approach is also feasible.

### Step 4: Reality-check the embedding model choice

A critical but often overlooked variable: **the embedding model has more impact on retrieval quality than the choice of database**. A better embedding model (e.g., Voyage-4 for legal/finance, text-embedding-3-large as a general-purpose default) on a mediocre database typically outperforms a weak model on the fastest database. Choose your embedding model before finalizing your database architecture.

---

## Key Takeaways

- Vector databases store high-dimensional embeddings and answer similarity queries; they are the memory layer for AI applications.
- HNSW is the dominant indexing algorithm (best recall-latency balance); IVF-PQ is used for billion-scale with constrained memory.
- The dedicated vector DB market has consolidated significantly since 2023 — vectors are now a feature of most major databases, raising the bar for when a specialized system is justified.
- For most teams starting out: pgvector (if on Postgres), Redis Query Engine (if on Redis), or Chroma (new project, local dev).
- Qdrant is the best open-source dedicated option in 2026 for performance and advanced filtering; Milvus for maximum scale; Pinecone for zero-ops managed.
- Hybrid search (keyword + vector) consistently outperforms pure vector search — don't design a system that does only dense retrieval.
- Benchmark numbers without stated recall, filter selectivity, and concurrency are misleading — test your actual workload.

---

## Sources and Further Reading

- [Best Vector Databases in 2026: Complete Comparison Guide (Encore)](https://encore.dev/articles/best-vector-databases) — March 2026
- [Vector Database Benchmark 2026 | Top 10 Compared (Salt Technologies AI)](https://www.salttechno.ai/datasets/vector-database-performance-benchmark-2026/) — February 2026, CC BY 4.0
- [Vector Database Complete Guide 2026 (QubitTool)](https://qubittool.com/blog/vector-database-complete-guide) — February 2026
- [Best Vector Databases in 2026: A Complete Comparison Guide (Firecrawl)](https://www.firecrawl.dev/blog/best-vector-databases-2025) — Updated February 2026
- [pgvector vs Dedicated Vector Databases: When PostgreSQL Is Enough](https://zenvanriel.com/ai-engineer-blog/pgvector-vs-dedicated-vector-db/) — February 2026
- [A Practical Guide for Choosing a Vector Database (Superlinked/VectorHub)](https://superlinked.com/vectorhub/articles/choosing-vdb) — December 2025
- [TopK Bench: Benchmarking Real-World Vector Search](https://www.topk.io/blog/20251201-topk-bench) — December 2025
- [ScyllaDB Vector Search: 1B Vectors with 2ms P99s and 250K QPS](https://www.scylladb.com/2025/12/01/scylladb-vector-search-1b-benchmark/) — December 2025
- [Vector Database Use Cases: RAG, Search & More (Redis)](https://redis.io/blog/vector-database-use-cases/) — March 2026
- [From Vector Hype to Hybrid Reality: Is Elasticsearch Still the Right Bet?](https://pureinsights.com/blog/2026/from-vector-hype-to-hybrid-reality-is-elasticsearch-still-the-right-bet/) — March 2026
- [Vector Database Comparison 2026 (Reintech)](https://reintech.io/blog/vector-database-comparison-2026-pinecone-weaviate-milvus-qdrant-chroma) — December 2025
- [HNSW for Vector Databases Explained](https://medium.com/@sidjain1412/hnsw-for-vector-databases-explained-dcda67dd0664) — December 2025
- [Vector Database Indexing Methods: IVF, HNSW, and PQ](https://medium.com/@kiranvutukuri/95-vector-database-indexing-methods-ivf-hnsw-and-product-quantization-c4a6243929db) — January 2026
- [Vector Databases for RAG: Complete Applications Guide (Digital Applied)](https://www.digitalapplied.com/blog/vector-databases-rag-applications-guide) — January 2026
- [The Architecture Behind Vector Databases in Modern AI Systems (Medium)](https://medium.com/@tararoutray/the-architecture-behind-vector-databases-in-modern-ai-systems-17a6c8a19095) — March 2026
