# 02. ER Model (Entity–Relationship Model)

> Covers: 01:56:00 – ER Model, 02:50:09 – Extended ER Features, 03:20:02 – How to Think and Formulate ER Diagram, 03:45:59 – Designing ER Model of Facebook, 04:05:29 – Relational Model (intro boundary)

## 1. What is ER Model?

**ER Model** is a high-level conceptual data model used to represent real-world entities, their attributes, and relationships between them. It’s used in **database design (conceptual design)** before converting to relational schema.

- Developed by Peter Chen
- Graphical representation via **ER Diagrams (ERDs)**
- Helps visualize structure, identify entities/relationships, avoid redundancy early

## 2. Basic Concepts

### Entity
An **Entity** is a real-world object, person, place, concept, or event about which we store data.

**Examples**: Student, Employee, Product, Order, Department

### Entity Set
Collection of similar entities (e.g., all students).

### Attributes
Properties/characteristics of an entity.

| Type | Definition | Example |
|---|---|---|
| **Simple (Atomic)** | Cannot be divided further | RollNo, Age, Email |
| **Composite** | Can be divided into smaller parts | Name → (FirstName, LastName), Address → (Street, City, Pin) |
| **Multivalued** | Can have multiple values | PhoneNumbers {98765, 87654}, Hobbies |
| **Derived** | Computed from other attributes | Age derived from DOB, TotalPrice from items |
| **Key Attribute** | Uniquely identifies entity | StudentID, RollNo, Email |

**Notation note**: Multivalued often shown as double oval, Derived as dashed oval (conceptual).

### Keys (Quick)
- **Key Attribute**: Unique identifier (part of PK candidate)
- **Composite Key**: Multiple attributes uniquely identify

## 3. Relationships

**Relationship**: Association between two (or more) entities. **Relationship Set**: Collection of similar relationships.

**Example**: Student **Enrols** in Course. (Student – Enrols – Course)

### Degree of Relationship
- **Unary (Recursive)**: Self-relation (Employee manages Employee)
- **Binary**: 2 entities (most common) – Student Enrolls Course
- **Ternary**: 3 entities (Supplier supplies Parts to Project)

## 4. Cardinality (Mapping Cardinality)

Describes **how many instances** of one entity relate to another (1:1, 1:M, M:N).

| Cardinality | Meaning | Example |
|---|---|---|
| **1:1 (One-to-One)** | One entity A relates to at most 1 of B, vice versa | Person ↔ Passport (one person has one passport, one passport to one person) |
| **1:M (One-to-Many)** | One A relates to many B, B relates to 1 A | Department → Employees (1 dept has many employees, 1 employee in 1 dept) |
| **M:N (Many-to-Many)** | Many A relate to many B | Students ↔ Courses (student enrolls many, course has many students) |

## 5. Participation (Total/Partial)

Describes **minimum participation** (constraint on whether every entity in set must participate).

| Participation | Meaning | Example |
|---|---|---|
| **Total (Mandatory)** | Every entity **must** participate in relationship (double line) | Every Employee **must** work in some Department (if total) |
| **Partial (Optional)** | Some entities **may or may not** participate (single line) | Some Employees may be Managers (optional), others not |

**Combined with cardinality** gives precise constraints (min/max).

## 6. Strong Entity vs Weak Entity

| Aspect | Strong Entity | Weak Entity |
|---|---|---|
| Definition | Exists independently | Cannot exist without strong entity (depends on owner) |
| Key | Has a **Primary Key** (unique) | No complete PK of its own; has **Partial Key (Discriminator)** |
| Relationship | Regular relationship | Connected via **Identifying Relationship** |
| Notation | Rectangle | Double Rectangle |
| Identifying Rel. | Single diamond/line usually | **Double Diamond** |
| Example | Employee(EmpID PK, Name) | Dependent(DependentName, DOB, Relation) depends on Employee (EmpID + DependentName can form key conceptually) |

**Identifying Relationship**: Relationship where weak entity depends on strong entity for existence + identification.

## 7. Extended ER (EER) Features

### Specialization
**Process of breaking a higher-level entity into lower-level sub-entities** based on distinguishing attributes (top-down).

- **Definition**: Subset of entities have unique attributes
- **Example**: Employee → Manager, Developer, Tester (each has specific attrs: bonus, tech_stack, testing_tools)
- **Notation**: ISA (triangle) or "is-a" hierarchy

### Generalization
**Reverse of specialization** – combine multiple lower-level entities into higher-level (bottom-up). Identify common attributes.

- **Example**: Car, Truck share common → generalized to Vehicle
- **Same hierarchy, direction differs (design view)**

### Inheritance
Sub-entities inherit attributes/relationships of parent (superclass). Supports **attribute/relationship inheritance**.

### Aggregation
Represents **relationship between relationships** (treat a relationship set + entities as a higher-level entity to relate to another).

- **When needed**: M:N between entities + need to relate that whole association to a third entity.
- **Example**: Student enrolls Course (relationship ENROLL) — and Instructor evaluates that enrollment (grade). Instead of ternary messy, model ENROLL as aggregated entity.
- **Notation**: Dashed rectangle around relationship (conceptually)

> Aggregation is less common in modern ER; sometimes modeled differently or handled in relational.

## 8. How to Think & Formulate an ER Diagram (Step-by-Step)

Systematic approach:

`	ext
1. Understand Problem Statement / Requirements
   ↓
2. Identify Entities (nouns: objects, people, places, events)
   ↓
3. Identify Attributes for each entity (properties)
   ↓
4. Identify Primary Keys (candidate keys → PK)
   ↓
5. Identify Relationships (verbs: works_in, enrolls, places)
   ↓
6. Determine Cardinality (1:1, 1:M, M:N)
   ↓
7. Determine Participation (Total/Partial)
   ↓
8. Identify Weak Entities (if any) + Identifying Relationships
   ↓
9. Check for Specialization/Generalization/Aggregation (if needed)
   ↓
10. Draw ER Diagram (clean, readable)
   ↓
11. Validate against requirements (no info loss, minimal redundancy)
   ↓
12. Map to Relational Model (Phase 5)
`

**Tips**:
- Nouns → likely Entities/Attributes. Verbs → Relationships.
- Watch for M:N: will become separate relation (junction/bridge table) in relational.
- Don’t model operations, model data.
- Prefer clarity over over-engineering.

## 9. Practical Examples

### A. College Management
**Entities**: Student, Course, Professor, Department, Enrollment
- Student (StudentID PK, Name, DOB, Email)
- Department (DeptID PK, Name)
- Professor (ProfID PK, Name, DeptID FK)
- Course (CourseID PK, Title, Credits, DeptID FK, ProfID FK)
- Enrollment (StudentID FK, CourseID FK, Grade) – junction (M:N resolved)

**Relationships**: Student–Enrollment–Course (M:N), Professor teaches Course (1:M), Dept has Students/Professors (1:M)

### B. E-commerce
**Entities**: User, Product, Order, OrderItem, Payment, Cart
- User (UserID PK)
- Product (ProductID PK, Name, Price, Stock)
- Order (OrderID PK, UserID FK, OrderDate, Status)
- OrderItem (OrderID FK, ProductID FK, Qty, Price) – M:N Order–Product
- Payment (PaymentID PK, OrderID FK, Amount, Method)

### C. Banking
**Entities**: Customer, Account, Transaction, Branch
- Customer (CustID PK)
- Account (AccNo PK, CustID FK, Type, Balance, BranchID FK)
- Transaction (TxnID PK, AccNo FK, Type, Amount, Date)
- Branch (BranchID PK, Name, Address)

### D. Social Media (Facebook-like)
Key entities: User, Post, Comment, Like, FriendRequest, Group, Message
- User (UserID PK)
- Post (PostID PK, UserID FK, Content, Time)
- Comment (CommentID PK, PostID FK, UserID FK, Text)
- FriendRequest (ReqID PK, FromUser FK, ToUser FK, Status)
- Message (MsgID PK, SenderID FK, ReceiverID FK, Content)

### E. Food Delivery (Swiggy/Zomato-like)
Entities: Customer, Restaurant, MenuItem, Order, OrderItem, DeliveryAgent, Payment
- Restaurant (RestID PK)
- MenuItem (ItemID PK, RestID FK)
- Order (OrderID PK, CustID FK, RestID FK, AgentID FK, Status)
- OrderItem (OrderID FK, ItemID FK, Qty)

## 10. ER → Relational (Preview)

Key mapping rule (covered fully in 03):
- **Entity** → Table
- **Simple Attribute** → Column
- **Composite** → Split columns (or keep flattened)
- **Multivalued** → Separate table
- **1:1** → FK on either (or merge)
- **1:M** → FK on Many-side
- **M:N** → **Junction (Bridge) Table** with FKs + composite PK
- **Weak Entity** → Table with FK to Strong + Partial Key as part of PK

## Key Takeaways (Interview)

- ER Model = **conceptual design** (what to store), before relational (how).
- Cardinality (how many) + Participation (mandatory/optional) = complete relationship constraints.
- **M:N must become bridge table** in relational — common exam/interview point.
- Specialization/Generalization show inheritance/hierarchy.
- Weak entity needs identifying relationship + partial key.

## Interview Qs (Quick)

**Q1. Difference between Strong and Weak Entity?**
- Strong has PK, exists independently. Weak has no complete PK, depends on strong via identifying relationship (has partial key).

**Q2. What is Cardinality vs Participation?**
- Cardinality = max mapping (1:1/1:M/M:N). Participation = min (total mandatory / partial optional).

**Q3. Why convert M:N to bridge table?**
- Relational model can’t represent M:N directly; bridge table has FKs to both, composite PK (or unique) resolving relationship.

**Q4. Specialization vs Generalization?**
- Specialization = top-down (split). Generalization = bottom-up (merge). Same hierarchy conceptually.
