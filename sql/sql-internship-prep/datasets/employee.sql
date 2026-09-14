-- ============================================================
-- employee.sql  (PostgreSQL)
-- Classic employee/company schema for interview practice.
-- Tables: departments, employees, salaries (history), projects
-- ============================================================

DROP TABLE IF EXISTS project_assignments;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS salaries;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id   SERIAL PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    location        VARCHAR(50)
);

CREATE TABLE employees (
    employee_id     SERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    department_id   INT REFERENCES departments(department_id),
    manager_id      INT REFERENCES employees(employee_id), -- self referencing (hierarchy)
    job_title       VARCHAR(50) NOT NULL,
    hire_date       DATE NOT NULL,
    salary          NUMERIC(10,2) NOT NULL CHECK (salary >= 0)
);

CREATE TABLE salaries (
    salary_id       SERIAL PRIMARY KEY,
    employee_id     INT NOT NULL REFERENCES employees(employee_id),
    salary          NUMERIC(10,2) NOT NULL,
    effective_from  DATE NOT NULL,
    effective_to    DATE
);

CREATE TABLE projects (
    project_id      SERIAL PRIMARY KEY,
    project_name    VARCHAR(100) NOT NULL,
    start_date      DATE,
    end_date        DATE
);

CREATE TABLE project_assignments (
    assignment_id   SERIAL PRIMARY KEY,
    project_id      INT NOT NULL REFERENCES projects(project_id),
    employee_id     INT NOT NULL REFERENCES employees(employee_id),
    assigned_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    role            VARCHAR(50)
);

INSERT INTO departments (department_name, location) VALUES
('Engineering', 'Berlin'),
('Data',        'Berlin'),
('Sales',       'Hamburg'),
('Marketing',   'Munich'),
('HR',          'Berlin');

INSERT INTO employees (name, department_id, manager_id, job_title, hire_date, salary) VALUES
('Sarah Connor',   1, NULL, 'VP Engineering',  '2018-01-15', 150000.00),
('Kyle Reese',     1, 1,    'Senior Engineer', '2019-03-10', 110000.00),
('John Doe',       1, 2,    'Engineer',        '2021-06-01', 80000.00),
('Jane Smith',     2, 1,    'Data Lead',       '2020-02-20', 105000.00),
('Bob Martin',     2, 4,    'Data Analyst',    '2022-07-11', 70000.00),
('Alice Johnson',  2, 4,    'Data Engineer',   '2023-01-09', 90000.00),
('Charlie Brown',  2, 4,    'Data Scientist',  '2021-09-01', 95000.00),
('Dana White',     3, NULL, 'Sales Manager',   '2017-05-30', 90000.00),
('Eve Adams',      3, 8,    'Sales Rep',       '2022-04-18', 55000.00),
('Frank Miller',   4, NULL, 'Marketing Lead',  '2019-11-05', 85000.00),
('Grace Lee',      4, 10,   'Marketing Spec',  '2023-03-14', 60000.00),
('Hank Green',     5, NULL, 'HR Lead',         '2016-08-22', 75000.00);

INSERT INTO salaries (employee_id, salary, effective_from, effective_to) VALUES
(1, 120000.00, '2018-01-15', '2019-12-31'),
(1, 150000.00, '2020-01-01', NULL),
(2, 90000.00,  '2019-03-10', '2020-12-31'),
(2, 110000.00, '2021-01-01', NULL),
(4, 90000.00,  '2020-02-20', '2021-12-31'),
(4, 105000.00, '2022-01-01', NULL),
(5, 65000.00,  '2022-07-11', '2023-06-30'),
(5, 70000.00,  '2023-07-01', NULL),
(6, 85000.00,  '2023-01-09', NULL),
(7, 90000.00,  '2021-09-01', '2022-08-31'),
(7, 95000.00,  '2022-09-01', NULL);

INSERT INTO projects (project_name, start_date, end_date) VALUES
('Data Platform Migration', '2023-02-01', '2023-11-30'),
('AI Lead Scoring',          '2023-04-15', NULL),
('CRM Refresh',              '2023-06-01', '2023-12-15');

INSERT INTO project_assignments (project_id, employee_id, assigned_date, role) VALUES
(1, 6, '2023-02-05', 'Engineer'),
(1, 4, '2023-02-05', 'Lead'),
(1, 7, '2023-03-01', 'Analyst'),
(2, 5, '2023-04-20', 'Analyst'),
(2, 6, '2023-04-20', 'Engineer'),
(2, 7, '2023-04-20', 'Scientist'),
(3, 9, '2023-06-05', 'Sales Rep'),
(3, 2, '2023-06-10', 'Engineer');

-- Sample interview questions with this dataset:
-- 1. Second highest salary overall + per department
-- 2. Employees who earn more than their department average
-- 3. Top 3 earners per department
-- 4. Employee hierarchy (manager → direct reports) with self join
-- 5. Salary history - latest salary per employee
-- 6. Departments with no employees (LEFT JOIN)
-- 7. Employees with salary > manager salary