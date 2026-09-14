# 28 — Connection Pooling 🟡

**Priority: 🟡 GOOD TO KNOW** — answer: "Why not a new connection per query?"

---

## Concept

**Connecting to PostgreSQL is expensive** — forking a new backend process, allocating ~5–10 MB of memory, authenticating, etc. Connection pooling **reuses** existing connections from a fixed pool.

```text
Application
    ↓ connection request
Connection Pool (PgBouncer / Pgpool / Hikari / SQLAlchemy pool)
    ↓ reuse existing backend
PostgreSQL
```

### Why pools exist
- **Limit total backend connections** — a PG server with 200 connections may use ~1–2 GB memory, more for heavy queries.
- **Avoid connection exhaustion** — hundreds of concurrent API requests each spawning a new PG connection → server crashes.
- **Queue requests** — if the pool is full, requests wait rather than failing immediately.

---

## Key terms

| Term | Meaning |
|------|---------|
| `max_connections` | Hard limit in PostgreSQL config (default ~100) |
| Pool size | How many connections the app holds open |
| Idle timeout | Close unused connections after N seconds |
| Connection exhaustion | Pool empty → requests block or fail |

**Rule of thumb:** `max_connections` = pool size × number of application instances + small buffer. If you have 3 app servers, maybe 20 connections each = 60 total → set `max_connections = 100`.

---

## Simple explanation you can say in an interview

> "Instead of opening a new PostgreSQL connection per query, the application grabs a connection from a fixed-size pool, reuses it, and returns it when done. This avoids the overhead of process creation per query and prevents the server from running out of memory under load. Tools like PgBouncer (standalone) or HikariCP (in-app) handle this."

---

## Interview Question (Level 3)

**Q:** Why don't applications create a new PostgreSQL connection for every query?

**A:**
1. Each connection forks a PG backend (~5–10 MB RAM).
2. Creating a connection takes time (TCP handshake + auth).
3. Under load, you'd exhaust `max_connections` very quickly → new connections fail → downtime.
4. Pooling amortizes the cost and bounds resource usage.

---

## Tricky Question (Level 5)

**Q:** What happens when the pool is empty?

**A:** Depends on the pool config:
- **HikariCP (Java):** blocks for a timeout, then throws an exception.
- **PgBouncer:** queues requests (if `server_idle_timeout` hasn't closed the connection yet).
- In all cases, **request latency increases** under pool exhaustion — a symptom you'll see in monitoring.

**Follow-up:** "What's the fix when pool is exhausted?" → Investigate long-running queries holding connections, tune pool size, or add a separate read-only pool for analytics.

---

## PgBouncer at a high level

- Lightweight process in front of PostgreSQL.
- Transaction-mode: pools at **transaction** level — a connection is returned after COMMIT (good for short transactions).
- Session-mode: same connection returned to same client (needed for prepared statements, LISTEN/NOTIFY).
- Run PgBouncer on the same host or dedicated small VM, point app at PgBouncer instead of PG.

---

## Real-world scenario

Your FastAPI app crashes under load with `FATAL: too many connections`. The fix:

1. Check `max_connections`: 100.
2. Check current connections: 110 → hitting limit.
3. Introduce PgBouncer with `default_pool_size = 25`, `max_client_conn = 1000`.
4. Point app at PgBouncer on port 5432 instead of PG.
5. Monitor connection usage.

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "PgBouncer modes?" / "Pool exhaustion?" / "HikariCP vs PgBouncer?" / "How many connections should I set?"