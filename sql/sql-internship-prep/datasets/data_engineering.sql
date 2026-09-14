-- ============================================================
-- data_engineering.sql  (PostgreSQL)
-- Realistic data-engineering flavored schema.
-- Tables: events (raw), sessions, users_dim, orders_fact (star-ish)
-- Designed around ETL/analytics questions: DAU/MAU, retention,
-- rolling metrics, dedup, watermark-style incremental loading.
-- ============================================================

DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS user_dim;
DROP TABLE IF EXISTS orders_fact;
DROP TABLE IF EXISTS product_dim;

CREATE TABLE user_dim (
    user_id         SERIAL PRIMARY KEY,
    email           VARCHAR(100) UNIQUE,
    country         VARCHAR(50),
    device          VARCHAR(20),
    account_created DATE NOT NULL DEFAULT CURRENT_DATE,
    is_test_user    BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE product_dim (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category        VARCHAR(50) NOT NULL
);

CREATE TABLE orders_fact (
    order_id        SERIAL PRIMARY KEY,
    user_id         INT NOT NULL REFERENCES user_dim(user_id),
    product_id      INT NOT NULL REFERENCES product_dim(product_id),
    order_ts        TIMESTAMPTZ NOT NULL,
    amount          NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    status          VARCHAR(20) NOT NULL DEFAULT 'completed'
                    CHECK (status IN ('completed','refunded','failed'))
);

-- Raw event log - like a clickstream table
CREATE TABLE events (
    event_id        SERIAL PRIMARY KEY,
    user_id         INT REFERENCES user_dim(user_id),
    event_name      VARCHAR(50) NOT NULL,
    event_ts        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    page            VARCHAR(100),
    payload         JSONB
);

CREATE TABLE sessions (
    session_id      SERIAL PRIMARY KEY,
    user_id         INT NOT NULL REFERENCES user_dim(user_id),
    session_start   TIMESTAMPTZ NOT NULL,
    session_end     TIMESTAMPTZ,
    device          VARCHAR(20),
    country         VARCHAR(50)
);

CREATE INDEX idx_events_user_ts  ON events (user_id, event_ts);
CREATE INDEX idx_events_name_ts  ON events (event_name, event_ts);
CREATE INDEX idx_orders_user_ts  ON orders_fact (user_id, order_ts);
CREATE INDEX idx_orders_date     ON orders_fact (order_ts);
CREATE INDEX idx_sessions_user   ON sessions (user_id, session_start);

INSERT INTO user_dim (email, country, device, account_created, is_test_user) VALUES
('u1@example.com', 'US', 'desktop', '2023-01-01', FALSE),
('u2@example.com', 'US', 'mobile',  '2023-01-01', FALSE),
('u3@example.com', 'DE', 'desktop', '2023-01-15', FALSE),
('u4@example.com', 'DE', 'mobile',  '2023-02-01', FALSE),
('u5@example.com', 'IN', 'mobile',  '2023-02-10', FALSE),
('u6@example.com', 'US', 'tablet',  '2023-03-05', FALSE),
('u7@example.com', 'UK', 'desktop', '2023-04-01', FALSE),
('u8@example.com', 'US', 'mobile',  '2023-05-01',  TRUE),
('u9@example.com', 'FR', 'desktop', '2023-06-01', FALSE),
('u10@example.com','IN', 'mobile',  '2023-07-01', FALSE);

INSERT INTO product_dim (product_name, category) VALUES
('Analytics Pro',  'SaaS'),
('Storage GB pack','Infra'),
('Tickets',        'Support'),
('Consulting hrs', 'Services');

INSERT INTO orders_fact (user_id, product_id, order_ts, amount, status) VALUES
(1, 1, '2023-01-10 10:00:00+00', 99.00,  'completed'),
(1, 1, '2023-02-10 10:00:00+00', 99.00,  'completed'),
(2, 2, '2023-01-12 09:00:00+00', 19.00,  'completed'),
(2, 3, '2023-01-15 14:00:00+00', 49.00,  'refunded'),
(3, 1, '2023-01-20 08:30:00+00', 99.00,  'completed'),
(4, 2, '2023-02-05 11:00:00+00', 19.00,  'completed'),
(5, 3, '2023-02-15 12:00:00+00', 49.00,  'completed'),
(1, 2, '2023-03-01 13:00:00+00', 19.00,  'completed'),
(3, 1, '2023-03-15 09:00:00+00', 99.00,  'refunded'),
(6, 4, '2023-03-20 10:00:00+00', 500.00, 'completed'),
(7, 1, '2023-04-10 10:00:00+00', 99.00,  'completed'),
(8, 3, '2023-05-01 09:00:00+00', 0.00,   'failed'),
(9, 2, '2023-06-15 15:00:00+00', 19.00,  'completed'),
(1, 4, '2023-07-01 10:00:00+00', 200.00, 'completed'),
(5, 1, '2023-07-20 11:00:00+00', 99.00,  'completed'),
(10,3, '2023-08-15 12:00:00+00', 49.00,  'completed');

INSERT INTO events (user_id, event_name, event_ts, page, payload) VALUES
(1, 'page_view',   '2023-01-05 08:00:00+00', '/home',  '{"source":"ads"}'),
(1, 'page_view',   '2023-01-05 08:05:00+00', '/signup','{"source":"ads"}'),
(1, 'signup',      '2023-01-05 08:10:00+00', '/signup','{}'),
(2, 'page_view',   '2023-01-06 09:00:00+00', '/home',  '{"source":"organic"}'),
(1, 'page_view',   '2023-01-07 10:00:00+00', '/home',  '{"source":"email"}'),
(3, 'page_view',   '2023-01-10 11:00:00+00', '/pricing','{}'),
(4, 'page_view',   '2023-02-01 12:00:00+00', '/home',  '{"source":"ads"}'),
(1, 'purchase',    '2023-01-10 10:00:00+00', '/checkout','{"order_id":1}'),
(3, 'purchase',    '2023-01-20 08:30:00+00', '/checkout','{"order_id":3}'),
(1, 'page_view',   '2023-01-15 14:00:00+00', '/docs',  '{}'),
(1, 'page_view',   '2023-02-01 10:00:00+00', '/home',  '{"source":"email"}'),
(1, 'page_view',   '2023-03-01 10:00:00+00', '/home',  '{"source":"email"}'),
(1, 'page_view',   '2023-03-15 10:00:00+00', '/pricing','{}'),
(1, 'page_view',   '2023-07-01 10:00:00+00', '/home',  '{"source":"email"}'),
(5, 'page_view',   '2023-07-20 11:00:00+00', '/signup','{}'),
(5, 'signup',      '2023-07-20 11:05:00+00', '/signup','{}'),
(9, 'page_view',   '2023-06-15 14:00:00+00', '/home',  '{"source":"referral"}');

-- Note: the following duplicates are INTENTIONAL for dedup practice:
INSERT INTO events (user_id, event_name, event_ts, page, payload) VALUES
(2, 'page_view',   '2023-01-06 09:00:00+00', '/home',  '{"source":"organic"}'),
(1, 'purchase',    '2023-01-10 10:00:00+00', '/checkout','{"order_id":1}');

INSERT INTO sessions (user_id, session_start, session_end, device, country) VALUES
(1, '2023-01-05 08:00:00+00', '2023-01-05 08:15:00+00', 'desktop', 'US'),
(1, '2023-01-07 10:00:00+00', '2023-01-07 10:10:00+00', 'desktop', 'US'),
(2, '2023-01-06 09:00:00+00', '2023-01-06 09:20:00+00', 'mobile',  'US'),
(3, '2023-01-10 11:00:00+00', '2023-01-10 11:30:00+00', 'desktop', 'DE'),
(4, '2023-02-01 12:00:00+00', '2023-02-01 12:05:00+00', 'mobile',  'DE'),
(1, '2023-02-01 10:00:00+00', '2023-02-01 10:12:00+00', 'desktop', 'US'),
(1, '2023-03-01 10:00:00+00', '2023-03-01 10:08:00+00', 'desktop', 'US'),
(5, '2023-07-20 11:00:00+00', '2023-07-20 11:25:00+00', 'mobile',  'IN'),
(9, '2023-06-15 14:00:00+00', '2023-06-15 14:40:00+00', 'desktop', 'FR');

-- Sample data-engineering questions:
-- 1. DAU by day (count distinct users from events) filtering test users
-- 2. MAU by month
-- 3. Customer acquisition: counts by month (account_created)
-- 4. Revenue by month (orders_fact, status='completed')
-- 5. 7-day rolling revenue (window function)
-- 6. Deduplicate events table (ROW_NUMBER over natural key)
-- 7. Avg session length by device (sessions)
-- 8. Retention: users with activity in month N and N+1
-- 9. Latest order per user