# ACID & Transactions Cheat Sheet

**Transaction**: all-or-nothing unit (BEGIN/COMMIT/ROLLBACK/SAVEPOINT)

**ACID**: A Atomicity, C Consistency, I Isolation, D Durability

**WAL**: log before data → enables redo/undo on crash
**Undo**: uncommitted revert. **Redo**: committed replay
**Checkpoint**: flush dirty pages, shorten recovery
