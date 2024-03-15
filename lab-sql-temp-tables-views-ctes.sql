-- lab-sql-temp-table-cte-view-solution.sql
USE sakila;


-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals.

DROP VIEW customer_rental_summary;
CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(*) AS rental_count
FROM 
    customer AS c
    JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id
ORDER BY 
    rental_count DESC;

-- Step 2:  Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer. The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE customer_payment_summary AS (
    SELECT 
        crs.customer_id,
        SUM(p.amount) AS total_paid
    FROM 
        customer_rental_summary AS crs
        JOIN rental AS r ON crs.customer_id = r.customer_id
        JOIN payment AS p ON r.rental_id = p.rental_id
    GROUP BY 
        crs.customer_id
);

-- Step 3: Create a CTE and the Customer Summary Report
-- Now, create a CTE that joins the rental summary view with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
-- And using the CTE, create the query to generate the customer summary report.
WITH customer_summary_report AS(
SELECT 
    crs.customer_name,
    crs.email,
    crs.rental_count,
    cps.total_paid
FROM 
    customer_rental_summary AS crs
    JOIN customer_payment_summary AS cps ON crs.customer_id = cps.customer_id)

-- Create the query to generate the customer summary report.
SELECT 
    *,
    total_paid / rental_count AS average_payment_per_rental
FROM 
    customer_summary_report
ORDER BY 
    rental_count DESC;