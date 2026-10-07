# 03. Relational Model

> Covers: 04:05:29 – Relational Model, 05:00:43 – ER Model to Relational Model

## 1. What is Relational Model?

**Relational Model** (Codd, 1970) represents data as a collection of **relations (tables)**. Each relation has **tuples (rows)** and **attributes (columns)**. Data is organized into 2D tables with well-defined structure.

**Core idea**: Store data in tables and use **keys + constraints** to establish relationships between tables.

## 2. Key Terminology

| Term | Meaning | Example |
|---|---|---|
| **Relation** | Table in relational DB | students, courses |
| **Tuple** | Row/Record in a relation | (101, "Alice", "CS") |
| **Attribute** | Column/Field | id, 
ame, dept |
| **Domain** | Set of valid values for an attribute | Age domain: 0–120, Email: valid format conceptually |
| **Relation Schema** | Structure: R(A1,...,An) with attribute names/types | students(id INT, name TEXT, email TEXT) |
| **Relation Instance** | Current set of tuples in relation (state) | Actual rows at given time |
| **Degree** | Number of attributes (columns) | students with 3 cols → degree 3 |
| **Cardinality** | Number of tuples (rows) | 5000 students → cardinality 5000 |

## 3. Keys in Relational Model

Keys identify tuples uniquely and establish relationships.

| Key | Definition | Notes |
|---|---|---|
| **Super Key** | Set of one+ attributes that **uniquely identify** a tuple. May include extra attrs. | Largest set conceptually |
| **Candidate Key** | Minimal super key (no unnecessary attribute). Can uniquely ID tuple. | Each candidate can be PK |
| **Primary Key (PK)** | Chosen candidate key. Uniquely IDs every row. **Cannot be NULL**. | One per table |
| **Alternate Key** | Candidate keys **not** chosen as PK | "Secondary" unique identifiers |
| **Foreign Key (FK)** | Attribute(s) referencing PK of another table. Ensures **referential integrity**. | Links relations |
| **Composite Key** | Key made of **two or more attributes** together | e.g. (OrderID, ProductID) in OrderItem |
| **Surrogate Key** | Artificial key (usually auto-increment) | e.g. id BIGSERIAL, uuid |

**Example (Users)**: email could be candidate; user_id (int) chosen as PK → email is alternate key.

## 4. Constraints

| Constraint | Purpose |
|---|---|
| **Entity Integrity** | No PK attribute can be **NULL**. Ensures each tuple uniquely identifiable |
| **Referential Integrity** | FK value must match existing PK in referenced table, or be NULL (if allowed). Prevents orphan records |
| **Domain Constraints** | Values must be from valid domain (data type, range, format) |
| **Key Constraints** | Uniqueness of PK/UNIQUE keys |
| **Check Constraints** | Custom rule (e.g. ge > 0, salary >= 0) |

**Orphan Record**: FK points to non-existent PK → violates referential integrity.

## 5. ER Model → Relational Model (Mapping)

Goal: Convert conceptual ER to logical relational schema (tables + keys + FKs).

### Rule 1: Strong Entity → Table
Create table with all simple attributes. PK = key attribute of entity.

**ER**: Student(StudentID PK, Name, DOB) → **Rel**: student(student_id PK, name, dob)

### Rule 2: Weak Entity → Table
Create table. Include **FK** to owner (strong) entity's PK. **Partial key** + FK together form **composite PK** (common).

**ER**: Weak Dependent depends on Employee(EmpID) with partial key DependentName  
**Rel**: dependent(emp_id FK→employee, dep_name, relation) → PK = (emp_id, dep_name)

### Rule 3: Simple, Composite, Multivalued Attributes

- **Simple**: Direct column
- **Composite**: Flatten to separate columns (Address → street, city, pin) OR keep as is if app treats as whole (less common)
- **Multivalued**: **Cannot** put multiple values in one column (violates 1NF). Create **separate table** with FK + attribute.

**Example Multivalued**: Employee(EmpID, PhoneNumbers)  
**Mapping**: employee(emp_id PK, ...) + emp_phone(emp_id FK, phone_no PK/composite) (or just unique)

### Rule 4: 1:1 Relationship

Options:
1. **Merge** both entities into one table (if always related, total)
2. **Add FK** on either side (prefer side with **total participation** to avoid NULLs)
3. **Add FK + UNIQUE** on FK side

**Example**: Person(1) —(has)— (1) Passport  
Often put passport_no FK UNIQUE in person (or vice versa).

### Rule 5: 1:M (One-to-Many)

**Simplest**: Put **Foreign Key** on the **"Many" side** referencing "One" side's PK.

**Example**: Department(1) — has — (M) Employee  
→ employee(dept_id FK → department(dept_id))

### Rule 6: M:N (Many-to-Many)

**Must create a new relation (Junction/Bridge/Intersection Table)**.

Bridge table contains:
- FKs to **both** participating entities
- Often forms **composite PK** = (FK1, FK2)
- May include relationship attributes (e.g. enrollment_date, grade)

**Example**: Student(M) — enrolls — (N) Course  
→ enrollment(student_id FK, course_id FK, grade, enrolled_at)  
→ **PK** = (student_id, course_id)

### Rule 7: Recursive Relationship

Self-referencing FK.

**Example**: Employee manages Employee  
→ employee(emp_id PK, name, manager_id FK → employee(emp_id), NULL allowed)

### Rule 8: Specialization/Generalization

Mapping approaches:
1. **Single Table (Union)**: Combine all into one with **type** flag + nullable subtype attrs (denormalized, simple)
2. **Subclass Tables (Vertical Split)**: Superclass table + one per subclass with **same PK** (shared PK = FK+PK)
3. **Concrete Table per Subclass**: Duplicate common attrs in each (less normalized)

**Most common (normalized)**: Superclass table + subclass tables with PK referencing superclass.

**Example**: Employee(EmpID PK) specialized to Manager(bonus), Engineer(tech_stack)  
→ employee(emp_id PK, name, ...)  
→ manager(emp_id PK FK→employee, bonus)  
→ engineer(emp_id PK FK→employee, tech_stack)

## 6. Example Walkthrough: Student–Course (M:N)

**ER**: Student (sid PK), Course (cid PK), enrolls (M:N) with attribute grade

**Relational**:
`sql
CREATE TABLE student (
  sid INT PRIMARY KEY,
  sname VARCHAR(50),
  email VARCHAR(100) UNIQUE
);

CREATE TABLE course (
  cid INT PRIMARY KEY,
  cname VARCHAR(50),
  credits INT
);

CREATE TABLE enrollment (
  sid INT REFERENCES student(sid),
  cid INT REFERENCES course(cid),
  grade CHAR(1),
  PRIMARY KEY (sid, cid)
);
`

**Why bridge**: Can't put cid array in student or vice versa. Bridge resolves cleanly.

## 7. Practical PostgreSQL Examples

`sql
-- Strong entity
CREATE TABLE department (
  dept_id SERIAL PRIMARY KEY,
  dept_name VARCHAR(100) NOT NULL UNIQUE
);

-- Strong entity with FK (1:M)
CREATE TABLE employee (
  emp_id SERIAL PRIMARY KEY,
  emp_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  dept_id INT REFERENCES department(dept_id) ON DELETE SET NULL
);

-- Weak entity (1:M from employee, identifying)
CREATE TABLE dependent (
  emp_id INT REFERENCES employee(emp_id) ON DELETE CASCADE,
  dep_name VARCHAR(50) NOT NULL,
  relation VARCHAR(20),
  dob DATE,
  PRIMARY KEY (emp_id, dep_name)
);

-- M:N via bridge
CREATE TABLE project (
  proj_id SERIAL PRIMARY KEY,
  proj_name VARCHAR(100) NOT NULL
);

CREATE TABLE works_on (
  emp_id INT REFERENCES employee(emp_id) ON DELETE CASCADE,
  proj_id INT REFERENCES project(proj_id) ON DELETE CASCADE,
  hours INT CHECK (hours > 0),
  PRIMARY KEY (emp_id, proj_id)
);
`

**Notes**: ON DELETE CASCADE/SET NULL shows referential integrity behavior. CHECK enforces domain constraint.

## 8. ER vs Relational Model (Comparison)

| Aspect | ER Model (Conceptual) | Relational Model (Logical/Physical view) |
|---|---|---|
| Focus | "What" to model (real-world) | "How" to store (tables/keys) |
| Form | Diagrammatic (rectangles/diamonds/ovals) | Tabular (relations) |
| Relationships | Shown directly (1:1/1:M/M:N) | Implemented via FKs, bridge tables |
| Multivalued | Represented | Normalized to separate table (1NF) |
| Weak Entity | Explicit | FK + composite PK |
| Ease | Better for communication with non-technical | Closer to DB implementation |
| Stage | Conceptual design | Logical design (before SQL) |

## Key Takeaways (Interview)

- **Relational model = tables + tuples + attributes** with keys/constraints.
- **1:M** → FK on Many side. **M:N** → Bridge table (critical).
- **Weak entity** → needs FK to strong + partial key in composite PK.
- **Referential Integrity** prevents orphans; **Entity Integrity** prevents NULL PK.
- **ER→Relational** is the bridge between analysis & implementation.

## Interview Qs

**Q1. Explain Super Key vs Candidate Key vs Primary Key?**
- Super = any set uniquely ID-ing. Candidate = minimal super. PK = chosen candidate (not NULL, stable).

**Q2. Why M:N becomes junction table?**
- RDBMS can't directly store M:N; junction holds pairs + relationship data, uses composite PK.

**Q3. How to map weak entity to relational?**
- Create table with FK to strong entity + partial key; PK = (strong_PK + partial_key).

**Q4. Difference between ER and Relational Model?**
- ER is conceptual (visual), Relational is logical/tabular focused on storage structure.
