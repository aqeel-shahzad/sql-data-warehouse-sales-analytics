/*
===============================================================================
Report Name: sales_trend_analysis.sql
Purpose: Analyse sales performance over time.

This report includes:
- Monthly sales trends
- Running total sales
- Moving average price
- Year-over-year product sales comparison
===============================================================================
*/

USE DataWarehouse;
GO

-- ============================================================================
-- 1. Monthly Sales Trend
-- ============================================================================

SELECT 
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
ORDER BY order_month;
GO

-- ============================================================================
-- 2. Running Total Sales and Moving Average Price
-- ============================================================================

WITH monthly_sales AS (
    SELECT 
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS order_month,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)

SELECT 
    order_month,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_sales,
    AVG(avg_price) OVER (
        ORDER BY order_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_price_3_months
FROM monthly_sales
ORDER BY order_month;
GO

-- ============================================================================
-- 3. Year-over-Year Product Sales Comparison
-- ============================================================================

WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_product p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)

SELECT 
    order_year,
    product_name,
    current_sales,

    AVG(current_sales) OVER (
        PARTITION BY product_name
    ) AS avg_sales,

    current_sales - AVG(current_sales) OVER (
        PARTITION BY product_name
    ) AS diff_from_avg,

    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
        ELSE 'Average'
    END AS avg_performance,

    LAG(current_sales) OVER (
        PARTITION BY product_name 
        ORDER BY order_year
    ) AS previous_year_sales,

    current_sales - LAG(current_sales) OVER (
        PARTITION BY product_name 
        ORDER BY order_year
    ) AS diff_from_previous_year,

    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS year_over_year_change

FROM yearly_product_sales
ORDER BY 
    product_name,
    order_year;
GO