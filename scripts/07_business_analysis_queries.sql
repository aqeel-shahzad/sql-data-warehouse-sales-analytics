/*
===============================================================================
Script Name: 07_business_analysis_queries.sql
Purpose: Run business analysis queries on the Gold layer.

This script uses the final Gold views to answer business questions around:
- Sales performance
- Customer distribution
- Product performance
- Revenue contribution
- Order volume
===============================================================================
*/

USE DataWarehouse;
GO

-- ============================================================================
-- 1. Database Exploration
-- ============================================================================

-- View all tables and views in the database
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
ORDER BY 
    TABLE_SCHEMA,
    TABLE_NAME;
GO

-- View all columns in the Gold layer
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold'
ORDER BY 
    TABLE_NAME,
    ORDINAL_POSITION;
GO

-- ============================================================================
-- 2. Key Business Metrics
-- ============================================================================

-- Total sales
SELECT 
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;
GO

-- Total quantity sold
SELECT 
    SUM(quantity) AS total_quantity_sold
FROM gold.fact_sales;
GO

-- Average selling price
SELECT 
    AVG(price) AS average_selling_price
FROM gold.fact_sales;
GO

-- Total number of orders
SELECT 
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;
GO

-- Total number of products
SELECT 
    COUNT(DISTINCT product_key) AS total_products
FROM gold.dim_product;
GO

-- Total number of customers
SELECT 
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_customers;
GO

-- ============================================================================
-- 3. Customer Analysis
-- ============================================================================

-- Customers by country
SELECT 
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;
GO

-- Customers by gender
SELECT 
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;
GO

-- Customers by marital status
SELECT 
    marital_status,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY marital_status
ORDER BY total_customers DESC;
GO

-- Top 10 customers by revenue
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country,
    SUM(f.sales_amount) AS total_revenue,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country
ORDER BY total_revenue DESC;
GO

-- ============================================================================
-- 4. Product Analysis
-- ============================================================================

-- Products by category
SELECT 
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_product
GROUP BY category
ORDER BY total_products DESC;
GO

-- Revenue by product category
SELECT 
    p.category,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity_sold,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;
GO

-- Revenue by product subcategory
SELECT 
    p.category,
    p.subcategory,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity_sold,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
    ON f.product_key = p.product_key
GROUP BY 
    p.category,
    p.subcategory
ORDER BY total_revenue DESC;
GO

-- Top 10 products by revenue
SELECT TOP 10
    p.product_name,
    p.category,
    p.subcategory,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity_sold,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
    ON f.product_key = p.product_key
GROUP BY 
    p.product_name,
    p.category,
    p.subcategory
ORDER BY total_revenue DESC;
GO

-- Bottom 10 products by revenue
SELECT TOP 10
    p.product_name,
    p.category,
    p.subcategory,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_quantity_sold,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
    ON f.product_key = p.product_key
GROUP BY 
    p.product_name,
    p.category,
    p.subcategory
ORDER BY total_revenue ASC;
GO

-- ============================================================================
-- 5. Sales Trend Analysis
-- ============================================================================

-- Monthly sales trend
SELECT 
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(quantity) AS total_quantity_sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
ORDER BY order_month;
GO

-- Yearly sales trend
SELECT 
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(quantity) AS total_quantity_sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;
GO