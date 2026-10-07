# 11. Database Design (Real-World)

> Practical design exercises covering: E-com, Banking, College, Food Delivery, Ride Sharing, Social Media. For each: Requirements → Entities → Relationships → Keys → Schema → Normalization → Indexes → Transactions → Scaling.

## 1. Design Approach (Universal)

For every system:

`	ext
1. Requirements (functional/non-functional)
   ↓
2. Identify Entities (nouns)
   ↓
3. Attributes + Keys (PK/FK)
   ↓
4. Relationships + Cardinality + Participation
   ↓
5. Conceptual ER → Logical Relational (mapping)
   ↓
6. Normalize (aim 3NF/BCNF)
   ↓
7. Indexes (read/write trade-off)
   ↓
8. Transactions & ACID (critical flows)
   ↓
9. Scaling Considerations (reads/writes, HA)
`

## 2. 1. E-commerce (Amazon/Flipkart)

### Requirements
Users browse/products, cart, orders, payments, tracking, inventory.

### Entities
users, products, categories, brands, carts, cart_items, orders, order_items, payments, addresses, reviews, inventory

### Core Schema (Key Tables)

`sql
users(user_id PK, email UNIQUE, name, password_hash, phone, created_at)
addresses(addr_id PK, user_id FK→users, street, city, state, pincode, is_default)
categories(cat_id PK, name, parent_cat_id FK self)
products(prod_id PK, name, sku UNIQUE, price, cat_id FK, brand_id FK, desc)
inventory(prod_id PK/FK→products, stock_qty, updated_at)
carts(cart_id PK, user_id FK UNIQUE)
cart_items(cart_id FK, prod_id FK, qty, PK(cart_id,prod_id))
orders(order_id PK, user_id FK, addr_id FK, status, total_amt, order_date)
order_items(order_id FK, prod_id FK, qty, unit_price, PK(order_id,prod_id))
payments(pay_id PK, order_id FK UNIQUE, method, amount, status, txn_id)
reviews(review_id PK, prod_id FK, user_id FK, rating, comment)
`

### Relationships
User 1:M Orders/Addresses, Order 1:M OrderItems, Product M:N via OrderItems/CartItems, Order 1:1 Payment.

### Normalization
3NF. Avoid redundancy (price stored in order_items for historical accuracy).

### Indexes
users(email) UNIQUE, products(sku) UNIQUE, products(cat_id), orders(user_id, order_date), order_items(order_id), payments(order_id)

### Critical Transactions
**Place Order**: Check inventory, reserve/deduct stock, create order+items, payment, clear cart – must be atomic (ACID). Use transaction + row-level locks on inventory.

### Scaling
Read replicas (catalog/search), product search (maybe denorm/cache), partition orders by order_date or shard by user_id, cache hot products (Redis).

## 3. 2. Banking System

### Requirements
Accounts, customers, transfers, transactions, branches, loans, ATM. **Strong correctness (ACID, SERIALIZABLE for critical).**

### Entities
customers, branches, accounts, transactions, loans, loan_payments

### Schema

`sql
customers(cust_id PK, name, email UNIQUE, phone, aadhaar/pan)
branches(branch_id PK, name, city)
accounts(acc_no PK, cust_id FK, branch_id FK, type(CHECKING/SAVINGS), balance, status)
transactions(txn_id PK, from_acc FK→accounts(acc_no), to_acc FK→accounts, type(DEBIT/CREDIT/TRANSFER), amount, txn_date, status)
loans(loan_id PK, cust_id FK, acc_no FK, amount, interest, status, start_date)
loan_payments(pay_id PK, loan_id FK, amount, due_date, paid_date)
`

### Normalization
3NF. Critical integrity.

### Indexes
ccounts(cust_id), 	ransactions(from_acc, txn_date), 	ransactions(to_acc, txn_date), 	ransactions(txn_date)

### Critical Transactions (ACID)
**Fund Transfer**: Debit source, Credit dest – **atomic**. Must ensure balance >= 0 (CHECK or app). Prefer **SERIALIZABLE** or proper locking to prevent negative balances/lost updates. Use row locks on both accounts.

**Business rule**: Total conserved, double-entry conceptually (transaction records both sides).

### Scaling
Write-heavy core (OLTP). Read replicas for statements/reports. Partition transactions by date, HA (replication+clustering), strong durability (WAL). Avoid denorm on balances (compute or maintain with care).

## 4. 3. College Management System

### Requirements
Students, departments, professors, courses, enrollments, attendance, grades, fees.

### Entities
departments, professors, students, courses, enrollments, attendance, fees, exams, results

### Schema

`sql
departments(dept_id PK, name, hod_id FK→professors)
professors(prof_id PK, name, dept_id FK, email UNIQUE)
students(stud_id PK, name, dept_id FK, email UNIQUE, roll_no UNIQUE, dob)
courses(course_id PK, title, credits, dept_id FK, prof_id FK)
enrollments(stud_id FK, course_id FK, sem, grade, PK(stud_id,course_id,sem))
attendance(att_id PK, stud_id FK, course_id FK, date, present BOOLEAN)
exams(exam_id PK, course_id FK, exam_type, date)
results(res_id PK, stud_id FK, exam_id FK, marks)
fees(fee_id PK, stud_id FK, amount, sem, status, due_date, paid_date)
`

### Relationships
Dept 1:M Prof/Student/Course, Course M:N Student via Enrollment, Prof 1:M Courses, M:N via attendance/exams.

### Normalization
3NF. Enrollment resolves M:N cleanly.

### Indexes
students(email, roll_no) UNIQUE, enrollments(course_id, sem), ttendance(course_id,date), esults(exam_id)

### Transactions
Enrollment (capacity checks), fee payment (atomic), grade submission.

### Scaling
Mostly OLTP, read-heavy for reports (grades/attendance). Can use read replicas, partition attendance/results by semester/date if large.

## 5. 4. Food Delivery (Swiggy/Zomato)

### Requirements
Customers, restaurants, menu, orders, order items, delivery agents, payments, tracking, ratings.

### Entities
customers, restaurants, menu_items, orders, order_items, delivery_agents, payments, order_status_logs, ratings

### Schema

`sql
customers(cust_id PK, name, phone UNIQUE, email)
restaurants(rest_id PK, name, owner_id, city, status, pincode)
menu_items(item_id PK, rest_id FK, name, price, category, is_available)
delivery_agents(agent_id PK, name, phone UNIQUE, status(AVAILABLE/BUSY/OFFLINE), current_city)
orders(order_id PK, cust_id FK, rest_id FK, agent_id FK NULL, addr_id, total_amt, status, order_time, est_delivery)
order_items(order_id FK, item_id FK, qty, unit_price, PK(order_id,item_id))
payments(pay_id PK, order_id FK UNIQUE, method, amount, status, txn_id)
order_status_logs(log_id PK, order_id FK, status, changed_at, notes)
ratings(rating_id PK, order_id FK UNIQUE, cust_id FK, rest_id FK, agent_id FK, rating, comment)
`

### Relationships
Restaurant 1:M MenuItems, Order 1:M OrderItems, Order 1:1 Payment/Rating, Agent 0:M Orders (assigned).

### Normalization
3NF. Store unit_price in order_items (price can change later).

### Indexes
estaurants(city, status), menu_items(rest_id,is_available), orders(cust_id,order_time), orders(rest_id,status,order_time), orders(agent_id,status), orders(status,order_time) (live orders), delivery_agents(status,current_city)

### Critical Transactions
**Place Order**: Validate availability (menu + restaurant open), create order atomically, deduct inventory if tracked, payment. Use transaction + optimistic/pessimistic as needed.

**Assign Delivery**: Agent status update (AVAILABLE→BUSY) + order assignment – atomic to avoid double-assignment (row lock on agent+order).

### Scaling
High write (orders), high read (live tracking). Use **Redis** for live order status, agent location, cart. Shard orders by order_time (range) or by est_id/city for geo, read replicas for history, partition order_status_logs by date. Geo-indexing for nearby restaurants/agents.

## 6. 5. Ride Sharing (Uber/Ola)

### Requirements
Riders, drivers, rides, trip status, pricing, payments, locations, ratings. Real-time + geo critical.

### Entities
users(riders/drivers), drivers, rides, ride_locations, payments, ratings

### Schema

`sql
users(user_id PK, name, phone UNIQUE, role(RIDER/DRIVER), email)
drivers(driver_id PK, user_id FK UNIQUE, vehicle_no, vehicle_type, status(ONLINE/OFFLINE/BUSY), current_lat, current_long, city)
riders(rider_id PK, user_id FK UNIQUE)
rides(ride_id PK, rider_id FK, driver_id FK NULL, pickup_lat,pickup_long, dest_lat,dest_long, city, status, fare, distance_km, start_time, end_time)
ride_locations(loc_id PK, ride_id FK, lat,long, ts)
payments(pay_id PK, ride_id FK UNIQUE, method, amount, status, txn_id)
ratings(rating_id PK, ride_id FK UNIQUE, rider_id FK, driver_id FK, rating, comment)
`

### Normalization
3NF. Time-series (locations) separate for high volume.

### Indexes
drivers(status,city), drivers(current_city) + consider **spatial** (PostGIS) on (lat,long). ides(rider_id,start_time), ides(driver_id,status,start_time), ides(status,city,start_time), ide_locations(ride_id,ts)

### Critical Transactions
**Ride Request → Match**: Find nearby available driver, mark driver BUSY + assign ride atomically (prevent double-accept). Need locking/atomic update (SELECT FOR UPDATE or conditional UPDATE).

**Trip Completion**: End ride, compute fare, mark complete, process/payment, free driver – atomic.

### Scaling
Real-time heavy: use Redis for driver availability/locations (geo sets), WebSockets. **Time-series** for locations (high volume) → partition ide_locations by ride_id or date, consider TimescaleDB or archive old. Shard rides by date/city. Spatial indexing (PostGIS) for nearby search. Read replicas for history.

## 7. 6. Social Media (Instagram/LinkedIn-like)

### Requirements
Users, posts, media, likes, comments, follows, messages, notifications. High read/write, feed critical.

### Entities
users, posts, media, likes, comments, follows, messages, notifications

### Schema

`sql
users(user_id PK, username UNIQUE, email UNIQUE, name, bio, is_private)
follows(follower_id FK→users, followee_id FK→users, created_at, PK(follower_id,followee_id))
posts(post_id PK, user_id FK, caption, created_at, visibility(PUBLIC/PRIVATE))
media(media_id PK, post_id FK, url, media_type(IMG/VIDEO), order_idx)
likes(like_id PK, post_id FK, user_id FK, created_at, UNIQUE(post_id,user_id))
comments(comment_id PK, post_id FK, user_id FK, parent_id FK→comments NULL, text, created_at)
messages(msg_id PK, sender_id FK, receiver_id FK, content, read_at, created_at)
notifications(notif_id PK, user_id FK, type, actor_id FK, post_id FK NULL, read, created_at)
`

### Relationships
User 1:M Posts, Post 1:M Media/Likes/Comments, Self-referential for comment threads, M:N follows (self), 1:M messages/notifications.

### Normalization
3NF. Avoid denorm counters early (can compute counts).

### Indexes
users(username,email) UNIQUE, posts(user_id,created_at), posts(created_at) (global feed), media(post_id,order_idx), likes(post_id), comments(post_id,created_at,parent_id), ollows(followee_id), ollows(follower_id), messages(sender_id,created_at), messages(receiver_id,read_at,created_at), 
otifications(user_id,read,created_at)

### Transactions
Like/comment (atomic), follow/unfollow (simple). Feed generation often **eventual consistency** (fan-out on write or read).

### Scaling (Feed Strategy)
- **Fan-out on Write**: When user posts, push to followers' feeds (lists in Redis). Fast reads, slower writes (celebs/high follower count problem).
- **Fan-out on Read**: Pull posts of follows on read. Cheap writes, expensive reads (joins).
- **Hybrid**: Fan-out to regular, pull for celebrities (selective).
- **Counters**: Denorm likes/comments count later if hot (or keep computed via counts). Cache feeds in **Redis** (lists), shard posts by user_id or time-range partition by created_at, media to object storage (S3). Messages partition by created_at or shard by user pair.

## 8. Design Checklist Summary

| Area | What to Cover |
|---|---|
| **Requirements** | Functional + non-functional (scale, correctness, latency) |
| **Entities** | Core + supporting (logs, junctions) |
| **Keys** | PK, FK, UNIQUE, composite PK for M:N |
| **Schema** | Clean, FK constraints, CHECK where useful |
| **Normalization** | Aim **3NF/BCNF** for OLTP; justify denorm if used |
| **Indexes** | Cover hot queries (WHERE/JOIN/ORDER BY), avoid over-indexing |
| **Transactions** | Critical flows (money, inventory, assignment) – identify ACID needs |
| **Scaling** | Reads (replicas/cache), Writes (partitioning/sharding), HA, Geo, Real-time, Archival |

## Key Takeaways (Interview)

- **Start from requirements** → entities → relationships → schema → normalize → optimize (indexes) → transactions → scale.
- **Historical data**: Store prices/unit_price in order_items (immutable facts).
- **Money-critical**: Prefer correctness (ACID, SERIALIZABLE when needed), row locks, double-entry/transaction logs.
- **M:N → bridge/junction** with composite PK.
- **Real-time systems** (rides) need Redis + spatial + careful atomic assignment.
- **Social feeds** trade-off: fan-out write vs read (eventual consistency acceptable).
- **Normalize first, denormalize only when measured/read-heavy bottleneck.**

## Interview Qs

**Q1. How would you design e-commerce order placement? (Transactions)**
- Atomic transaction: validate inventory (check stock >= qty, lock rows), deduct stock, create orders+order_items, create payment record, clear cart/rollback on failure. Ensures consistency (no oversell).

**Q2. Banking transfer – ensure correctness?**
- Use transaction with debit+credit, CHECK balance>=0, row-level locks, consider SERIALIZABLE. ACID guarantees all-or-nothing + durability.

**Q3. Ride-sharing: avoid double driver assignment?**
- Conditional UPDATE + row lock: UPDATE drivers SET status='BUSY' WHERE driver_id=X AND status='AVAILABLE' RETURNING * (atomic). If 0 rows affected, try next. Or SELECT FOR UPDATE in transaction.

**Q4. Social media feed – fan-out on write vs read?**
- Write: push to follower feeds (fast reads, heavy writes for influencers). Read: pull follows' posts (cheap writes, heavy reads). Hybrid common.

**Q5. When store unit_price in order_items vs products.price?**
- Store in order_items at order time (snapshot) – price can change later; order history must remain accurate.
