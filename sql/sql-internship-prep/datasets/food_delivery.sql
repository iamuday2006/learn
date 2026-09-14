-- ============================================================
-- food_delivery.sql  (PostgreSQL)
-- Food delivery schema for interview practice.
-- Tables: restaurants, customers, orders, order_items, riders
-- ============================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS riders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS restaurants;

CREATE TABLE restaurants (
    restaurant_id   SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    cuisine         VARCHAR(30) NOT NULL,
    city            VARCHAR(50) NOT NULL,
    rating          NUMERIC(2,1) CHECK (rating >= 0 AND rating <= 5),
    opens_at        TIME,
    closes_at       TIME
);

CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    city            VARCHAR(50),
    joined_date     DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE riders (
    rider_id        SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    vehicle         VARCHAR(20) NOT NULL DEFAULT 'bike',
    joined_date     DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE orders (
    order_id        SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    restaurant_id   INT NOT NULL REFERENCES restaurants(restaurant_id),
    rider_id        INT REFERENCES riders(rider_id),
    order_time      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    delivered_time  TIMESTAMPTZ,
    status          VARCHAR(20) NOT NULL DEFAULT 'placed'
                    CHECK (status IN ('placed','preparing','out_for_delivery','delivered','cancelled')),
    total_amount    NUMERIC(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES orders(order_id),
    item_name       VARCHAR(100) NOT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),
    price           NUMERIC(10,2) NOT NULL
);

INSERT INTO restaurants (name, cuisine, city, rating, opens_at, closes_at) VALUES
('Pizza Palace',   'Italian',  'Berlin',   4.5, '11:00', '23:00'),
('Sushi Spot',     'Japanese', 'Berlin',   4.8, '12:00', '22:00'),
('Taco Town',      'Mexican',  'Munich',   4.2, '10:00', '23:00'),
('Green Bowl',     'Vegan',    'Hamburg',  4.7, '08:00', '21:00'),
('Burger Barn',    'American', 'Berlin',   4.0, '10:00', '01:00'),
('Curry House',    'Indian',   'Frankfurt',4.6, '11:30', '23:30');

INSERT INTO customers (name, email, city, joined_date) VALUES
('Zoe Wright',  'zoe@example.com', 'Berlin',   '2023-01-10'),
('Leo Hart',    'leo@example.com', 'Berlin',   '2023-02-14'),
('Nina Bell',   'nina@example.com','Munich',   '2023-03-01'),
('Owen Cross',  'owen@example.com','Hamburg',  '2023-04-20'),
('Uma Frost',   'uma@example.com', 'Frankfurt','2023-05-05'),
('Ray Stone',   'ray@example.com', 'Berlin',   '2023-06-15'),
('Sara Quinn',  NULL,              'Munich',   '2023-07-01');

INSERT INTO riders (name, vehicle, joined_date) VALUES
('Max Run',   'bike',   '2023-01-02'),
('Nia Fly',   'car',    '2023-02-01'),
('Ollie Pace','bike',   '2023-03-11'),
('Tess Swift','bike',   '2023-04-25');

INSERT INTO orders (customer_id, restaurant_id, rider_id, order_time, delivered_time, status, total_amount) VALUES
(1, 1, 1, '2023-10-01 12:10:00+00', '2023-10-01 12:45:00+00', 'delivered',        25.50),
(1, 1, 1, '2023-10-15 18:30:00+00', '2023-10-15 19:05:00+00', 'delivered',        32.00),
(2, 2, 2, '2023-10-02 13:00:00+00', '2023-10-02 13:40:00+00', 'delivered',        41.25),
(3, 3, 1, '2023-10-03 19:00:00+00', '2023-10-03 19:20:00+00', 'delivered',        18.75),
(4, 4, 3, '2023-10-04 09:00:00+00', '2023-10-04 09:30:00+00', 'delivered',        22.10),
(5, 6, 4, '2023-10-05 20:15:00+00', '2023-10-05 20:50:00+00', 'delivered',        28.90),
(6, 5, NULL, '2023-10-06 12:00:00+00', NULL, 'preparing',      12.50),
(2, 2, 2, '2023-10-20 17:00:00+00', NULL, 'cancelled',         0.00),
(7, 3, 1, '2023-10-21 12:30:00+00', '2023-10-21 12:55:00+00', 'delivered',        16.40),
(7, 3, 3, '2023-10-25 18:45:00+00', '2023-10-25 19:10:00+00', 'delivered',        21.90),
(1, 5, 1, '2023-11-01 12:05:00+00', '2023-11-01 12:35:00+00', 'delivered',        14.99),
(6, 6, 4, '2023-11-02 19:10:00+00', '2023-11-02 19:55:00+00', 'delivered',        35.40);

INSERT INTO order_items (order_id, item_name, quantity, price) VALUES
(1, 'Margherita',     1, 11.50),
(1, 'Tiramisu',       1, 6.00),
(1, 'Garlic Bread',   1, 8.00),
(2, 'Pepperoni',      1, 14.50),
(2, 'Cheese Sticks',  1, 9.50),
(2, 'Drink',          1, 8.00),
(3, 'Salmon Roll',    2, 12.50),
(3, 'Miso Soup',      1, 16.25),
(4, 'Tacos x3',       1, 10.75),
(4, 'Nachos',         1, 8.00),
(5, 'Buddha Bowl',    1, 22.10),
(6, 'Butter Chicken', 1, 19.50),
(6, 'Naan',           2, 4.70),
(9, 'Taco Bowl',      1, 16.40),
(10,'Burrito',        1, 12.90),
(10,'Limeade',        1, 9.00),
(11,'Double Burger',  1, 14.99),
(12,'Lamb Curry',     1, 24.90),
(12,'Garlic Naan',    2, 5.25);

-- Sample interview questions with this dataset:
-- 1. Average delivery time per restaurant (delivered_time - order_time)
-- 2. Restaurants with no orders (LEFT JOIN)
-- 3. Total revenue by cuisine
-- 4. Orders with no rider assigned
-- 5. Weekday vs weekend order volume (EXTRACT(DOW))
-- 6. Highest-revenue restaurant per city