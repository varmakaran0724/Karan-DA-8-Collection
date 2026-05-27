--
-- SQL Script for creating Employees and Departments tables
-- and inserting data into the Employees table.
--

-- 1. Create the Employees table
CREATE TABLE Employees (
    id INT PRIMARY KEY,              -- Employee ID (Primary Key)
    name VARCHAR(100) NOT NULL,      -- Employee Name
    age INT,                         -- Employee Age
    salary DECIMAL(10, 2)            -- Employee Salary
);

-- 2. Create the Departments table
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,         -- Department ID (Primary Key)
    dept_name VARCHAR(100) NOT NULL  -- Department Name
);

-- 3. Insert records into the Employees table
INSERT INTO Employees (id, name, age, salary) VALUES
(1, 'John Doe', 30, 50000.00),
(2, 'Jane Smith', 28, 60000.00),
(3, 'Robert Brown', 35, 75000.00);