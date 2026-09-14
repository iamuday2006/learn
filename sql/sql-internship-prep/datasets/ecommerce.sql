-- ============================================================
-- ecommerce.sql  (PostgreSQL)
-- E-commerce schema for interview practice.
-- Tables: customers, products, categories, orders, order_items, payments
-- ============================================================

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    email         VARCHAR(100) UNIQUE NOT NULL,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    city          VARCHAR(50),
    country       VARCHAR(50),
    signup_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active     BOOLEAN DEFAULT TRUE
);

CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    category_id   INT REFERENCES categories(category_id),
    price         NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_qty     INT NOT NULL DEFAULT 0
);

CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customers(customer_id),
    order_date    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status        VARCHAR(20) NOT NULL DEFAULT 'pending',
    total_amount  NUMERIC(12,2) NOT NULL DEFAULT 0
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id      INT NOT NULL REFERENCES orders(order_id),
    product_id    INT NOT NULL REFERENCES products(product_id),
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    NUMERIC(10,2) NOT NULL
);

CREATE TABLE payments (
    payment_id    SERIAL PRIMARY KEY,
    order_id      INT NOT NULL REFERENCES orders(order_id),
    amount        NUMERIC(12,2) NOT NULL,
    payment_date  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    method        VARCHAR(20) NOT NULL DEFAULT 'card'
);

INSERT INTO customers (email, first_name, last_name, city, country, signup_date, is_active) VALUES
('alice.m@example.com',  'Alice',   'Meyer',   'Berlin',        'Germany', '2023-01-15', TRUE),
('bob.k@example.com',    'Bob',     'Kovacs',  'Budapest',      'Hungary', '2023-02-01', TRUE),
('carol.w@example.com',  'Carol',   'Weber',   'Vienna',        'Austria', '2023-02-20', TRUE),
('daniel.l@example.com', 'Daniel',  'Larsen',  'Copenhagen',    'Denmark', '2023-03-10', TRUE),
('erin.j@example.com',   'Erin',    'Jones',   'Dublin',        'Ireland', '2023-04-05', FALSE),
('frank.o@example.com',  'Frank',   'O''Brien','Dublin',        'Ireland', '2023-05-12', TRUE),
('grace.p@example.com',  'Grace',   'Petty',   'London',        'UK',      '2023-06-18', TRUE),
('henry.r@example.com',  'Henry',   'Ross',    'Manchester',    'UK',      '2023-07-01', TRUE),
('irene.s@example.com',  'Irene',   'Smith',   'Sydney',        'Australia','2023-08-22', TRUE),
('jack.t@example.com',   'Jack',    'Taylor',  'Melbourne',     'Australia','2023-09-15', TRUE);

INSERT INTO categories (category_name) VALUES
('Electronics'), ('Clothing'), ('Books'), ('Home & Garden'), ('Sports');

INSERT INTO products (product_name, category_id, price, stock_qty) VALUES
('Wireless Mouse',        1, 29.99,  150),
('Mechanical Keyboard',   1, 89.99,   60),
('USB-C Hub',             1, 49.50,  200),
('T-Shirt (M)',           2, 19.99,  300),
('Jeans (32/34)',         2, 59.00,   80),
('SQL for Interviews',    3, 39.99,  120),
('Data Engineering Book', 3, 49.99,   90),
('Desk Lamp',             4, 24.75,  150),
('Yoga Mat',              5, 34.20,  110),
('Running Shoes',         5, 79.99,   45);

INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES
(1, '2023-10-01 10:00:00+00', 'delivered',  29.99),
(1, '2023-11-05 11:30:00+00', 'delivered', 139.98),
(2, '2023-10-15 09:15:00+00', 'delivered',  49.50),
(3, '2023-11-01 14:00:00+00', 'shipped',   109.98),
(4, '2023-11-10 08:45:00+00', 'pending',    39.99),
(5, '2023-08-01 12:00:00+00', 'cancelled',  19.99),
(6, '2023-11-12 16:20:00+00', 'delivered',  59.00),
(6, '2023-11-20 10:00:00+00', 'shipped',   114.19),
(7, '2023-11-15 18:00:00+00', 'delivered',  24.75),
(8, '2023-11-18 09:30:00+00', 'pending',    79.99),
(9, '2023-11-22 13:45:00+00', 'delivered',  49.99),
(10,'2023-11-25 10:10:00+00', 'delivered',  34.20),
(2, '2023-11-28 15:00:00+00', 'pending',    89.99),
(1, '2023-12-01 09:00:00+00', 'delivered', 39.99);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 29.99),
(2, 2, 1, 89.99),
(2, 3, 1, 49.50),
(3, 3, 1, 49.50),
(4, 2, 1, 89.99),
(4, 4, 1, 19.99),
(5, 6, 1, 39.99),
(6, 4, 1, 19.99),
(7, 5, 1, 59.00),
(8, 5, 1, 59.00),
(8, 7, 1, 49.99),
(8, 4, 1, 19.99),
(8, 6, 1, 39.99),
(9, 8, 1, 24.75),
(10, 10, 1, 79.99),
(11, 7, 1, 49.99),
(12, 9, 1, 34.20),
(13, 2, 1, 89.99),
(14, 6, 1, 39.99);

INSERT INTO payments (order_id, amount, payment_date, method) VALUES
(1, 29.99,  '2023-10-01 10:05:00+00', 'card'),
(2, 139.98, '2023-11-05 11:35:00+00', 'paypal'),
(3, 49.50,  '2023-10-15 09:20:00+00', 'card'),
(4, 109.98, '2023-11-01 14:05:00+00', 'card'),
(5, NULL,   NULL, 'card'),
(6, 19.99,  '2023-08-01 12:05:00+00', 'bank'),
(7, 59.00,  '2023-11-12 16:25:00+00', 'card'),
(9, 24.75,  '2023-11-15 18:05:00+00', 'paypal'),
(11, 49.99, '2023-11-22 13:50:00+00', 'card'),
(12, 34.20, '2023-11-25 10:15:00+00', 'card');

-- Sample interview questions with this dataset:
-- 1. Top 3 products by revenue
-- 2. Customers with no orders (LEFT JOIN)
-- 3. Monthly revenue (orders + payments join)
-- 4. Running total of revenue per month
-- 5. Repeat customers (customers with >1 order)