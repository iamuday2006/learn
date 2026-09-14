-- ============================================================
-- banking.sql  (PostgreSQL)
-- Banking schema for interview practice.
-- Tables: accounts, customers, transactions
-- ============================================================

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    ssn_last_4      VARCHAR(4),
    city            VARCHAR(50),
    customer_since  DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE accounts (
    account_id      SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    account_type    VARCHAR(20) NOT NULL CHECK (account_type IN ('checking','savings','credit')),
    balance         NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    opened_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    is_closed       BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE transactions (
    transaction_id  SERIAL PRIMARY KEY,
    account_id      INT NOT NULL REFERENCES accounts(account_id),
    txn_type        VARCHAR(10) NOT NULL CHECK (txn_type IN ('deposit','withdrawal','transfer','payment')),
    amount          NUMERIC(14,2) NOT NULL CHECK (amount > 0),
    txn_date        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    description     TEXT
);

INSERT INTO customers (name, ssn_last_4, city, customer_since) VALUES
('Liam Walker',  '1234', 'New York',  '2020-01-10'),
('Olivia King',  '5678', 'Chicago',   '2020-03-22'),
('Noah Hill',    '9012', 'Miami',     '2021-06-15'),
('Emma Scott',   '3456', 'Seattle',   '2021-08-01'),
('Ava Young',    '7890', 'Boston',    '2022-02-14'),
('Ethan Green',  '2345', 'Austin',    '2022-09-30');

INSERT INTO accounts (customer_id, account_type, balance, opened_date, is_closed) VALUES
(1, 'checking', 4520.50, '2020-01-10', FALSE),
(1, 'savings',  12000.00,'2020-01-10', FALSE),
(2, 'checking', 215.35,  '2020-03-22', FALSE),
(2, 'credit',   1450.00, '2020-03-22', FALSE),
(3, 'checking', 1250.00, '2021-06-15', FALSE),
(4, 'checking', 0.00,    '2021-08-01', FALSE),
(4, 'savings',  750.00,  '2021-08-01', FALSE),
(5, 'checking', 9999.99, '2022-02-14', FALSE),
(6, 'checking', 45.00,   '2022-09-30', FALSE),
(6, 'credit',   0.00,    '2022-09-30', FALSE),
(3, 'savings',  0.00,    '2021-07-01', TRUE);

INSERT INTO transactions (account_id, txn_type, amount, txn_date, description) VALUES
(1, 'deposit',   2500.00, '2023-01-05 09:00:00+00', 'salary'),
(1, 'withdrawal', 120.00, '2023-01-07 18:30:00+00', 'atm'),
(1, 'transfer',   300.00, '2023-01-10 12:00:00+00', 'to savings'),
(2, 'deposit',   500.00,  '2023-01-12 08:00:00+00', 'transfer from checking'),
(3, 'deposit',   1800.00, '2023-01-06 09:15:00+00', 'salary'),
(3, 'withdrawal', 45.00,  '2023-01-09 20:00:00+00', 'atm'),
(5, 'deposit',   1200.00, '2023-01-08 10:00:00+00', 'cash'),
(5, 'payment',    500.00, '2023-01-15 11:00:00+00', 'rent'),
(7, 'deposit',   100.00,  '2023-01-11 09:30:00+00', 'transfer'),
(8, 'deposit',   5000.00, '2023-01-04 14:00:00+00', 'salary'),
(8, 'withdrawal',1500.00, '2023-01-14 16:45:00+00', 'atm'),
(9, 'deposit',   2500.00, '2023-01-03 08:10:00+00', 'salary'),
(9, 'withdrawal',200.00,  '2023-01-13 19:00:00+00', 'atm'),
(10,'payment',   1500.00, '2023-01-16 10:30:00+00', 'card payment'),
(2, 'deposit',   300.00,  '2023-01-17 12:00:00+00', 'transfer'),
(4, 'payment',    250.00, '2023-01-18 09:00:00+00', 'card payment');

-- Sample interview questions with this dataset:
-- 1. Running balance per account (SUM OVER)
-- 2. Accounts that never had a transaction (LEFT JOIN / NOT EXISTS)
-- 3. Customers with a single account vs multiple accounts
-- 4. Largest single withdrawal per account
-- 5. flagged unusual: amount > 3x average for that account