### Vector Databases

- **What they are**: Specialized databases for storing and querying high-dimensional vectors (embeddings), enabling similarity search by numerical distance rather than exact match. Core workflow: generate embeddings with ML models, store in vector DB, query by similarity (cosine, Euclidean, dot product), retrieve nearest neighbors via ANN algorithms
- **Key algorithms**: HNSW (most common, high recall, memory-intensive), IVF (lower memory, partitions vectors into clusters), DiskANN/PQ (compressed vectors for billion-scale)
- **Major options**: Pinecone (fully managed, $200-400/mo at scale, ~25-50ms p50), Qdrant (open-source Rust, fastest at 8-40ms p99), Weaviate (native hybrid search BM25+vector, GraphQL API), Milvus (distributed, billions of vectors, requires K8s), pgvector (PostgreSQL extension, free, scales to ~50M vectors), Chroma (lightweight embedded, prototyping)
- **Hybrid search** (keyword + vector in one query) significantly improves RAG quality — only Weaviate does this natively

**How to Pick**
- <1M vectors: pgvector or Chroma
- 1-10M: pgvector or Qdrant
- 10-100M: Qdrant or Weaviate
- >100M: Pinecone or Milvus
- Zero ops wanted: Pinecone. Existing Postgres: pgvector. Self-hosted simplicity: Qdrant. K8s expertise: Milvus
- Always benchmark with your actual data — vendor benchmarks rarely match production

**Sources**
- [The Ultimate Guide to Vector Databases in 2026](https://codeboxr.com/the-ultimate-guide-to-vector-databases-in-2026/)
- [Vector Database Complete Guide 2026: Comparison](https://viadreams.cc/pl/blog/vector-database-guide/)
- [What is a Vector Database & How Does it Work? - Pinecone](https://www.pinecone.io/learn/vector-database/)
- [Comparing the best open source vector databases - Redis](https://redis.io/en/blog/best-open-source-vector-databases-comparison/)
- [Vector Database Comparison 2026](https://jishulabs.com/blog/vector-database-comparison-2026)
