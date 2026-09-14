# 10 — String Functions 🟡

**Priority: 🟡 GOOD TO KNOW** — basics will be used; deep functions rarely.

---

## Concept

String manipulation shows up in **data cleaning** (fuzzy matches, standardizing values) more than in core analytics. Know the common set in PostgreSQL:

| Function | Purpose | Example → Result |
|----------|---------|------------------|
| `LENGTH(s)` / `CHAR_LENGTH(s)` | length | `LENGTH('abc')` → 3 |
| `UPPER(s)` / `LOWER(s)` | case | `LOWER('SQL')` → 'sql' |
| `INITCAP(s)` | title case | `INITCAP('ada lovelace')` → 'Ada Lovelace' |
| `CONCAT(a, b)` / `\|\|` | concatenate | `'a' \|\| 'b'` → 'ab' |
| `CONCAT_WS('-', a, b)` | join with separator | → 'a-b' |
| `TRIM(s)`, `LTRIM`, `RTRIM` | trim whitespace | `TRIM('  x  ')` → 'x' |
| `SUBSTRING(s FROM pos FOR len)` | substring | `SUBSTRING('abcdef' FROM 2 FOR 3)` → 'bcd' |
| `POSITION('a' IN 'banana')` | find position | → 2 |
| `STRPOS(s, 'a')` | find position | → 2 |
| `LEFT(s, n)`, `RIGHT(s, n)` | first/last n chars | `LEFT('abc', 2)` → 'ab' |
| `REPLACE(s, from, to)` | replace | `REPLACE('a-b','-','')` → 'ab' |
| `SPLIT_PART(s, delim, n)` | nth part | `SPLIT_PART('a,b,c', ',', 2)` → 'b' |
| `REVERSE(s)` | reverse | `REVERSE('abc')` → 'cba' |
| `REGEXP_REPLACE(s, pat, rep)` | regex replace | |
| `REGEXP_MATCHES(s, pat)` | regex match | |
| `NULLIF(a, b)` | NULL if equal | for divide-by-zero |
| `COALESCE(a, b)` | first non-null | |

**Concatenation & NULL:** `'a' || NULL` → NULL in PG. Use `CONCAT_WS` or `COALESCE` for NULL-safe joins.

```sql
SELECT 'a' || NULL;        -- NULL   (trap!)
SELECT CONCAT_WS('-', 'a', NULL);  -- 'a'  (NULL-safe)
```

---

## Simple Example

```sql
-- Clean names
SELECT email,
       LOWER(email)                 AS lower_email,
       SPLIT_PART(email, '@', 1)    AS username,
       SPLIT_PART(email, '@', 2)    AS domain
FROM customers;
```

---

## Interview Question (Level 3)

**Q:** Find customers whose email domain is gmail.

```sql
SELECT * FROM customers
WHERE email LIKE '%@gmail.com';
```
vs regex:
```sql
SELECT * FROM customers
WHERE email ~* '@gmail\.com$';
```
`~*` = case-insensitive regex match; `.` is a regex wildcard, so escape `\.`.

---

## Tricky Question (Level 5)

**Q:** `LIKE '%_%'` — does it match a single underscore? What does it match?

`_` matches exactly one char; `%` matches any string. So `'_'` in LIKE means *exactly one character* — `LIKE '_'` matches `'a'`, not `'-'`.
- `LIKE 'a_b'` → matches 'axb','a1b' but NOT 'a long b'.
- To match a literal underscore, escape it: `LIKE 'a\_b' ESCAPE '\'` or use `POSITION('_' IN s) > 0`.

---

## Interview Follow-Up Chain

**Q:** Standardize phone numbers missing country code.

```sql
SELECT phone,
       CASE WHEN LEFT(phone, 1) = '+' THEN phone
            ELSE '+1' || phone END AS normalized
FROM users;
```

**Q:** How do you find near-duplicate names (fuzzy match)?  
**A:** Normalize case/whitespace, maybe `LOWER(REPLACE(name,' ',''))` and group; mention `pg_trgm` similarity in PostgreSQL for advanced fuzzy matching.

---

## Real-World Scenario

ETL cleaning: the raw `customers.name` column has inconsistent casing/spacing. Normalize in one pass:

```sql
SELECT customer_id,
       TRIM(REGEXP_REPLACE(INITCAP(name), '\s+', ' ', 'g')) AS clean_name
FROM raw_customers;
```
Order matters: title-case first, then squash multiple spaces.

---

## MySQL quick comparison

| PostgreSQL | MySQL |
|------------|-------|
| `LENGTH` (chars) | `CHAR_LENGTH` (chars), `LENGTH` (bytes) |
| `\|\|` concat | `CONCAT()` (string concat) |
| `POSITION` / `STRPOS` | `INSTR(s, sub)` |
| `REGEXP_REPLACE(s, pat, rep)` | `REGEXP_REPLACE(s, pat, rep)` (8.0+) |

---

## Checklist

- [ ] I understand the concept
- [ ] I can explain it without notes
- [ ] I can write SQL for it
- [ ] I can solve an interview problem
- [ ] I can explain common edge cases
- [ ] I can answer follow-up questions

**Follow-ups:** "LIKE vs ILIKE?" / "Concat with NULL?" / "Split a column?" / "Regex basics?"