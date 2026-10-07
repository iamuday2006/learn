# Database Scaling Cheat Sheet

**Vertical (scale-up)**: bigger server, simple, limited. **Horizontal (scale-out)**: more nodes, complex, scalable.

**Techniques**: Read Replicas (read scale), Caching (Redis) for hot reads, Connection Pooling (prevent exhaustion), Partitioning (same instance), Sharding (multi-node), Load Balancing.

**Read-heavy**: replicas + cache. **Write-heavy/large**: partition → shard. **Always**: pool + optimize indexes/queries first. **Don't shard prematurely**.
