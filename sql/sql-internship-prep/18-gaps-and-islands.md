# 18 — Gaps and Islands 🟡

**Priority: 🟡 GOOD TO KNOW** — asked by Data/DE teams; medium difficulty, big impress factor.

---

## How to recognize it

- "Consecutive days a user was active"
- "Longest streak"
- "Number of contiguous ranges"
- "Find missing seats/serial numbers/dates"

**Islands** = consecutive (contiguous) groups. **Gaps** = the missing stretches between them.

---

## Core technique — subtract the row number

The magic trick: in a sorted sequence, `value - ROW_NUMBER()` is **constant within a consecutive streak** and jumps between streaks.

Example on sorted days:
```
day        rn    day - rn
2023-01-01 1     2022-12-31
2023-01-02 2     2022-12-31
2023-01-03 3     2022-12-31   <- streak 1
2023-01-05 4     2023-01-01   <- gap! streak 2
2023-01-06 5     2023-01-01
2023-01-07 6     2023-01-01   <- streak 2
```
Group by `day - rn` → each group is one island.

For DATE, do it with `day::date - rn * INTERVAL '1 day'` or join day with rn and compare via integer days.

---

## Example — consecutive active days per user (active-user streaks)

```sql
WITH daily AS (
    SELECT DISTINCT user_id, DATE_TRUNC('day', event_ts)::DATE AS day
    FROM events
),
numbered AS (
    SELECT user_id, day,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY day) AS rn
    FROM daily
)
SELECT user_id,
       MIN(day) AS streak_start,
       MAX(day) AS streak_end,
       COUNT(*) AS days_in_streak
FROM numbered
GROUP BY user_id, (day - rn * INTERVAL '1 day')
ORDER BY user_id, streak_start;
```

**Gotcha:** you must cast `day` (a date) back to a date after subtracting, because `day - rn * interval` yields a timestamp. In integer-space columns (e.g., `visit_sequence`), just subtract directly.

---

## IE example — longest streak per user

```sql
WITH islands AS (
    -- same numbered CTE as above, then:
    SELECT user_id, day - rn * INTERVAL '1 day' AS grp, day
    FROM numbered
)
SELECT user_id, COUNT(*) AS streak_length
FROM islands
GROUP BY user_id, grp
ORDER BY user_id, streak_length DESC;
```

---

## Common mistake

- Not taking `DISTINCT` dates first → the same day counted multiple times → fake "consecutive" days.
- Wrong anchor for `day - rn`: the subtraction must be same-units (timestamp minus interval, or integer minus integer).
- Mixing islands across groups — always PARTITION BY the entity.

---

## Interview variations

1. **Find missing ids** (gaps):
```sql
SELECT s.n AS missing_id
FROM generate_series(1, (SELECT MAX(product_id) FROM products)) AS s(n)
LEFT JOIN products p ON p.product_id = s.n
WHERE p.product_id IS NULL;
```
2. **Longest winning streak per team** — partition by team, order by match date, islands on result='W'.
3. **Generate missing date ranges in a calendar.**
4. **Sessionization**: "consecutive activity within 30 minutes = one session" — a *temporal* gap pattern.

---

## Real-world scenario

GA-style sessions: collapse a user's events into sessions where a gap > 30 min starts a new session.

```sql
WITH events_ordered AS (
    SELECT user_id, event_ts,
           LAG(event_ts) OVER (PARTITION BY user_id ORDER BY event_ts) AS prev_ts
    FROM events
),
flagged AS (
    SELECT user_id, event_ts,
           CASE WHEN prev_ts IS NULL
                     OR event_ts - prev_ts > INTERVAL '30 minutes'
                THEN 1 ELSE 0 END AS is_new_session
    FROM events_ordered
),
session_ids AS (
    SELECT user_id, event_ts,
           SUM(is_new_session) OVER (PARTITION BY user_id ORDER BY event_ts) AS session_id
    FROM flagged
)
SELECT user_id, session_id,
       MIN(event_ts) AS session_start, MAX(event_ts) AS session_end
FROM session_ids
GROUP BY user_id, session_id
ORDER BY user_id, session_start;
```
This is a **great** answer to "how do you do sessionization in SQL?"

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "Day - rn trick?" / "Longest streak?" / "Missing ids?" / "Sessionization?"