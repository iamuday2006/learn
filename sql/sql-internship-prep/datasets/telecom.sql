-- ============================================================
-- telecom.sql  (PostgreSQL)
-- Telecom schema for interview practice.
-- Tables: users, plans, calls, data_usage (CDR-style records)
-- ============================================================

DROP TABLE IF EXISTS call_records;
DROP TABLE IF EXISTS data_usage;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS plans;

CREATE TABLE plans (
    plan_id       SERIAL PRIMARY KEY,
    plan_name     VARCHAR(50) NOT NULL,
    monthly_fee   NUMERIC(8,2) NOT NULL,
    data_limit_gb INT,        -- NULL = unlimited
    minutes_limit INT         -- NULL = unlimited
);

CREATE TABLE users (
    user_id       SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    phone_number  VARCHAR(15) UNIQUE NOT NULL,
    plan_id       INT NOT NULL REFERENCES plans(plan_id),
    signup_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    status        VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended','churned'))
);

CREATE TABLE call_records (
    call_id       SERIAL PRIMARY KEY,
    caller_id     INT NOT NULL REFERENCES users(user_id),
    callee_number VARCHAR(15) NOT NULL,
    call_date     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    duration_sec  INT NOT NULL CHECK (duration_sec >= 0),
    call_type     VARCHAR(10) NOT NULL CHECK (call_type IN ('local','international','roaming'))
);

CREATE TABLE data_usage (
    usage_id      SERIAL PRIMARY KEY,
    user_id       INT NOT NULL REFERENCES users(user_id),
    usage_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    mb_used       NUMERIC(10,2) NOT NULL CHECK (mb_used >= 0)
);

INSERT INTO plans (plan_name, monthly_fee, data_limit_gb, minutes_limit) VALUES
('Basic',   19.99,  5,   300),
('Standard',39.99,  25,  1500),
('Premium', 59.99,  100, 5000),
('Unlimited Pro', 89.99, NULL,  NULL);

INSERT INTO users (name, phone_number, plan_id, signup_date, status) VALUES
('Amelia Rose', '+12025550101', 1, '2022-03-01', 'active'),
('James Fox',   '+12025550102', 2, '2022-04-15', 'active'),
('Mia Clark',   '+12025550103', 3, '2022-05-20', 'active'),
('Alexander Reed','+12025550104', 4, '2022-06-01', 'churned'),
('Ella Ward',   '+12025550105', 2, '2022-07-11', 'active'),
('Benjamin Cole','+12025550106', 1, '2022-08-22', 'suspended'),
('Charlotte Hayes','+12025550107', 3, '2022-09-30', 'active'),
('Daniel Grant','+12025550108', 2, '2023-01-05', 'active');

INSERT INTO call_records (caller_id, callee_number, call_date, duration_sec, call_type) VALUES
(1, '+12025550999', '2023-01-02 10:00:00+00', 180, 'local'),
(1, '+12025550998', '2023-01-03 11:00:00+00', 60,  'local'),
(2, '+12025550997', '2023-01-02 09:00:00+00', 1200,'international'),
(2, '+12025550996', '2023-01-05 14:00:00+00', 300, 'local'),
(3, '+12025550995', '2023-01-01 08:00:00+00', 540, 'local'),
(3, '+12025550994', '2023-01-06 16:00:00+00', 90,  'roaming'),
(4, '+12025550993', '2023-01-02 12:00:00+00', 240, 'local'),
(4, '+12025550992', '2023-01-08 10:30:00+00', 720, 'international'),
(5, '+12025550991', '2023-01-04 15:00:00+00', 150, 'local'),
(6, '+12025550990', '2023-01-07 13:00:00+00', 30,  'local'),
(7, '+12025550989', '2023-01-09 11:45:00+00', 60,  'local'),
(8, '+12025550988', '2023-01-10 09:20:00+00', 900, 'local');

INSERT INTO data_usage (user_id, usage_date, mb_used) VALUES
(1, '2023-01-01', 120.5), (1, '2023-01-02', 300.0), (1, '2023-01-03', 80.2),
(2, '2023-01-01', 512.8), (2, '2023-01-02', 1024.0), (2, '2023-01-03', 2048.5),
(3, '2023-01-01', 90.0),  (3, '2023-01-05', 45.5),
(4, '2023-01-01', 500.0), (4, '2023-01-02', 600.0),
(5, '2023-01-01', 1500.0),(5, '2023-01-03', 2200.0),
(6, '2023-01-02', 15.0),
(7, '2023-01-01', 800.0), (7, '2023-01-04', 75.0),
(8, '2023-01-01', 3000.0);

-- Sample interview questions with this dataset:
-- 1. Total minutes per user per month (GROUP BY month)
-- 2. Users whose data usage exceeded their plan limit (JOIN + HAVING/WHERE)
-- 3. Daily active users over time
-- 4. Users with no calls (NOT EXISTS)
-- 5. Which plan has highest average call duration per user?
-- 6. Find users' nearest signup to x