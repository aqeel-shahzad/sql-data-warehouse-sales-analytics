/*
===============================================================================
Report Name: customer_analysis.sql
Purpose: Analyse customer behaviour and customer contribution to sales.

This report includes:
- Customer distribution by country
- Customer distribution by gender
- Customer distribution by marital status
- Top customers by revenue
- Customer order behaviour
- Customer recency analysis
===============================================================================
*/

USE DataWarehouse;
GO

-- ============================================================================
-- 1. Customers by Country
-- ============================================================================

SELECT 
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;
GO

-- ============================================================================
-- 2. Customers by Gender
-- ============================================================================

SELECT 
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;
GO

-- ============================================================================
-- 3. Customers by Marital Status
-- ============================================================================

SELECT 
    marital_status,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY marital_status
ORDER BY total_customers DESC;
GO

-- ============================================================================
-- 4. Customer Revenue Contribution
-- ============================================================================

SELECT TOP 20
    c.customer_key,
    c.customer_id,
    c.customer_number,
    c.first_name,
    c.last_name,
    c.country,
    c.gender,
    c.marital_status,
    COUNT(DISTINCT f.order_number) AS total_orders,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity,
    AVG(f.price) AS avg_price
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_key,
    c.customer_id,
    c.customer_number,
    c.first_name,
    c.last_name,
    c.country,
    c.gender,
    c.marital_status
ORDER BY total_revenue DESC;
GO

-- ============================================================================
-- 5. Customer Behaviour Summary
-- ============================================================================

SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country,
    c.gender,
    COUNT(DISTINCT f.order_number) AS total_orders,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity,
    MIN(f.order_date) AS first_order_date,
    MAX(f.order_date) AS last_order_date,
    DATEDIFF(MONTH, MAX(f.order_date), GETDATE()) AS months_since_last_order
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
WHERE f.order_date IS NOT NULL
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country,
    c.gender
ORDER BY total_revenue DESC;
GO

-- ============================================================================
-- 6. Revenue by Country
-- ============================================================================

SELECT 
    c.country,
    COUNT(DISTINCT c.customer_key) AS total_customers,
    COUNT(DISTINCT f.order_number) AS total_orders,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_revenue DESC;
GO