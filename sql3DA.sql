CREATE TABLE employee (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) ,
    last_name VARCHAR(50) ,
    age INT ,
    salary DECIMAL(10, 2) ,
    designation VARCHAR(50),
    dept_id INT,
    m_id INT -- Manager ID
);
INSERT INTO employee (first_name, last_name, age, salary, designation, dept_id, m_id) VALUES
('John', 'Doe', 35, 60000.00, 'Sales', 1, NULL),    -- A manager (no m_id)
('Jane', 'Smith', 28, 48000.00, 'Sales', 1, 1),    -- Reports to John
('Alice', 'Johnson', 40, 75000.00, 'Manager', 2, NULL),  -- A manager (no m_id)
('Bob', 'Brown', 30, 50000.00, 'Developer', 2, 3),  -- Reports to Alice
('Charlie', 'Davis', 45, 90000.00, 'Manager', 3, NULL),  -- Manager in Dept 3
('David', 'Wilson', 32, 55000.00, 'Sales', 1, 1),  -- Reports to John
('Emma', 'Taylor', 29, 72000.00, 'Developer', 2, 3),  -- Reports to Alice
('Frank', 'Moore', 33, 47000.00, 'Analyst', 3, 5),  -- Reports to Charlie
('Grace', 'Lee', 27, 51000.00, 'Sales', 1, 1),   -- Reports to John
('Hannah', 'White', 26, 65000.00, 'Developer', 3, 5);  -- Reports to Charlie

-- ====================================================================
-- QUESTION 1: TRANSACTION MANAGEMENT (UPDATE & ROLLBACK)
-- ====================================================================

-- 1. Start a transaction.
START TRANSACTION;

-- Check current salaries in Sales department before the update (Optional, for verification)
SELECT emp_id, first_name, salary AS Salary_Before_Update
FROM employee
WHERE dept_id = 1;

-- 2. Update the salaries of all employees in the Sales department (dept_id = 1) by 10%.
UPDATE employee
SET salary = salary * 1.10
WHERE dept_id = 1;

-- Check salaries after the update (Optional, for verification)
SELECT emp_id, first_name, salary AS Salary_After_Update
FROM employee
WHERE dept_id = 1;

-- 3. Roll back the transaction (simulating an error).
ROLLBACK;

-- 4. Verify whether the salaries remained unchanged after the rollback.
-- If the rollback was successful, the salaries should match the original values.
SELECT emp_id, first_name, salary AS Salary_After_Rollback
FROM employee
WHERE dept_id = 1;


-- ====================================================================
-- QUESTION 2: STORED PROCEDURE TO GET EMPLOYEE DETAILS BY DEPARTMENT
-- ====================================================================

-- Stored procedures require a change in delimiter for creation in some environments (like MySQL)
DELIMITER //

CREATE PROCEDURE GetEmployeesByDepartment (
    IN department_id INT
)
BEGIN
    SELECT
        emp_id,
        CONCAT(first_name, ' ', last_name) AS full_name,
        designation,
        salary,
        age
    FROM
        employee
    WHERE
        dept_id = department_id
    ORDER BY
        emp_id;
END //

DELIMITER ;

-- Example of how to call the stored procedure:
-- CALL GetEmployeesByDepartment(1); -- Get details for Sales department
-- CALL GetEmployeesByDepartment(2); -- Get details for Department 2


-- ====================================================================
-- QUESTION 3: STORED PROCEDURE TO INCREASE SALARY BASED ON DEPARTMENT
-- ====================================================================

DELIMITER //

CREATE PROCEDURE IncreaseSalaryByDepartment (
    IN department_id INT,
    IN percentage_increase DECIMAL(5, 2)
)
BEGIN
    -- Start a transaction to ensure all updates or none are applied
    START TRANSACTION;

    UPDATE employee
    SET salary = salary * (1 + (percentage_increase / 100))
    WHERE dept_id = department_id;

    -- Commit the transaction if the update was successful
    COMMIT;

    -- Return the updated employees (optional verification step)
    SELECT
        emp_id,
        CONCAT(first_name, ' ', last_name) AS full_name,
        salary AS new_salary,
        designation
    FROM
        employee
    WHERE
        dept_id = department_id;
END //

DELIMITER ;

-- Example of how to call the stored procedure:
-- CALL IncreaseSalaryByDepartment(3, 5.00); -- Increase salaries in Dept 3 by 5%


-- ====================================================================
-- QUESTION 4: FIND THE HIGHEST-PAID EMPLOYEE IN EACH DEPARTMENT
-- ====================================================================

-- Using a Window Function (ROW_NUMBER) or Common Table Expression (CTE) for efficiency

WITH RankedEmployees AS (
    SELECT
        e.dept_id,
        CONCAT(e.first_name, ' ', e.last_name) AS full_name,
        e.salary,
        e.designation,
        -- Rank employees within each department based on salary (descending)
        ROW_NUMBER() OVER(PARTITION BY e.dept_id ORDER BY e.salary DESC) as rank_num
    FROM
        employee e
)
SELECT
    re.dept_id,
    re.full_name,
    re.salary,
    re.designation
FROM
    RankedEmployees re
WHERE
    re.rank_num = 1; -- Select only the employee with rank 1 (highest salary)
