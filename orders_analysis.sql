-- ============================================================
-- Project  : Retail Orders Analysis
-- Dataset  : Kaggle - ankitbansal06/retail-orders
-- Tool     : SQL Server (T-SQL)
-- About    : Analysis of retail orders data including revenue,
--            profit, regional performance and YoY growth
-- ============================================================

USE OrdersAnalysisProject;

SELECT * FROM df_orders;

DROP TABLE df_orders;

CREATE TABLE df_orders (
	[order_id]	INT PRIMARY KEY,
	[order_date] DATE,
	[ship_mode]  VARCHAR(20),
    [segment]  VARCHAR(20),
    [country]  VARCHAR(20),
    [city]     VARCHAR(20),
    [state]	   VARCHAR(20),
    [postal_code] VARCHAR(20),
    [region]  VARCHAR(20),
    [category] VARCHAR(20),
    [sub_category] VARCHAR(20),
    [product_id]  VARCHAR(50),
    [quantity] INT,
    [discount]  DECIMAL(7,2),
    [sale_price] DECIMAL(7,2),
    [profit] DECIMAL(7,2)
);

SELECT * from df_orders;


-- find top 10 highest reveue generating products 
SELECT top 10 product_id, sum(sale_price) as sales
from df_orders
GROUP BY product_id 
ORDER BY sales DESC;

-- find top 5 highest selling products in each region
WITH region_product_sales AS(
	SELECT 
		region, product_id, SUM(sale_price) AS total_sales,
		DENSE_RANK() OVER(PARTITION BY region ORDER BY SUM(sale_price) DESC) AS rnk
	FROM df_orders
	GROUP BY region, product_id
	)
SELECT region, product_id, total_sales, rnk
FROM region_product_sales
WHERE rnk <=5
ORDER BY region, rnk;

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

SELECT
	MONTH(order_date) AS order_month,
	SUM(CASE WHEN YEAR(order_date) = 2022 THEN sale_price ELSE 0 END) AS sales_2022,
	SUM(CASE WHEN YEAR(order_date) = 2023 THEN sale_price ELSE 0 END) AS sales_2023
FROM df_orders
GROUP BY MONTH(order_date)
order by order_month;

--for each category which month had highest sales
WITH highest_sales_month AS(
SELECT	
	category,
	FORMAT(order_date, 'yyyyMM') AS order_year_month,
	SUM(sale_price) AS sales,
	ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(sale_price) DESC) AS rnk
FROM df_orders
GROUP BY category,FORMAT(order_date, 'yyyyMM')
)
SELECT category, order_year_month, sales
FROM highest_sales_month
WHERE rnk = 1;

-- which sub category had highest growth by profit in 2023 compare to 2022.

WITH profit_by_year AS(
	SELECT 
		sub_category, 
		SUM(CASE WHEN YEAR(order_date) = 2022 THEN profit ELSE 0 END) AS profit_2022,
		SUM(CASE WHEN YEAR(order_date) = 2023 THEN profit ELSE 0 END) AS profit_2023
	FROM df_orders
	GROUP BY sub_category
)

SELECT TOP 1 
		sub_category, 
		profit_2022,
		profit_2023,
		(profit_2023 - profit_2022) AS growth
FROM profit_by_year
ORDER BY growth DESC;

-- Find total revenue, total profit, total orders and profit margin %
SELECT 
	COUNT(DISTINCT order_id) AS total_orders,
	ROUND(SUM(sale_price), 2) AS total_sale, 
	ROUND(SUM(profit),2) AS total_profit, 
	ROUND((SUM(profit) / SUM(sale_price)) * 100, 2) as profit_margin_percentage
FROM df_orders;

-- Find average discount given per category
SELECT category, ROUND(AVG(discount), 2) AS average_discount
FROM df_orders
GROUP BY category 
ORDER BY average_discount DESC;

-- Find states with negative profit (losing money!)
SELECT 
    state,
    ROUND(SUM(profit), 2) AS total_profit
FROM df_orders
GROUP BY state
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- Find percentage contribution of each category to total revenue
SELECT 
	category,
	ROUND(SUM(sale_price), 2) AS category_sales,
	ROUND(SUM(sale_price) * 100.0 / SUM(SUM(sale_price)) OVER(), 2) AS percentage_of_total
	FROM df_orders
	GROUP BY category
	ORDER BY category_sales DESC;
	
-- Running total of sales by order date
SELECT 
	order_date,
	SUM(sale_price) AS daily_sales,
	ROUND(SUM(SUM(sale_price)) OVER(ORDER BY order_date), 2) AS running_total
FROM df_orders
GROUP BY order_date
ORDER BY order_date;

-- Find ship mode most used per region
WITH ship_mode_rank AS (
	SELECT 
		region, 
		ship_mode, 
		COUNT(*) AS total_orders,
		RANK() OVER(PARTITION BY region ORDER BY COUNT(*) DESC) AS rnk
FROM df_orders
GROUP BY region, ship_mode
)

SELECT 
	region, 
	ship_mode, 
	total_orders
FROM ship_mode_rank
WHERE rnk = 1
ORDER BY region;


-- Find products that were profitable in 2022 but loss making in 2023
WITH product_vice_profit AS (
	SELECT 
		product_id,
		SUM(CASE WHEN YEAR(order_date) = 2022 THEN profit ELSE 0 END) AS profit_2022,
		SUM(CASE WHEN YEAR(order_date) = 2023 THEN profit ELSE 0 END) AS profit_2023
FROM df_orders
GROUP BY product_id
)
SELECT product_id,
ROUND(profit_2022, 2) AS  profit_2022,
ROUND(profit_2023, 2) AS profit_2023
FROM product_vice_profit
WHERE profit_2022 > 0
AND profit_2023 < 0
ORDER BY profit_2023 ASC;

-- Year over year growth percentage by category
WITH yearly_category_growth AS (
SELECT 
	category, 
	SUM(CASE WHEN YEAR(order_date) = 2022 THEN sale_price ELSE 0 END) AS sale_2022,
	SUM(CASE WHEN YEAR(order_date) = 2023 THEN sale_price ELSE 0 END) AS sale_2023
FROM df_orders
GROUP BY category
)
SELECT 
	category,
	sale_2022,
	sale_2023,
	ROUND(((sale_2023 - sale_2022) / sale_2022 * 100.0), 2) AS growth_per
FROM yearly_category_growth
ORDER BY growth_per;
	

-- Find top 3 most profitable sub categories per region
WITH top_subcategories AS(
SELECT 
	Region,
	sub_category,
	SUM(profit) AS total_profit
FROM df_orders
GROUP BY Region, sub_category

),
ranked_subcategories AS(
SELECT 
	Region,
	sub_category,
	ROUND(total_profit,2) AS total_profit,
	DENSE_RANK() OVER(PARTITION BY region ORDER BY total_profit DESC) AS rnk
FROM top_subcategories
)
SELECT 
	Region,
	sub_category,
	total_profit,
	rnk
FROM ranked_subcategories
WHERE rnk <=3
ORDER BY region, rnk;

-- Customer segment analysis - which segment is most valuable

SELECT 
	segment,
	COUNT(DISTINCT order_id) AS total_orders,
	ROUND(SUM(sale_price), 2) AS total_revenue,
	ROUND(SUM(profit), 2) AS total_profit,
	ROUND(AVG(sale_price),0) AS average_order_value,
	CONCAT(ROUND(SUM(profit)/SUM(sale_price) * 100.0, 2), '%') AS profit_margin_percentage
FROM df_orders
GROUP BY segment
ORDER BY total_profit DESC;

-- best performing state
SELECT 
    state,
    COUNT(DISTINCT order_id)AS total_orders,
    ROUND(SUM(sale_price), 2) AS total_revenue,
    ROUND(SUM(profit), 2)AS total_profit,
    ROUND(AVG(discount), 2) AS avg_discount,
    ROUND((SUM(profit) / SUM(sale_price)) * 100, 2) AS profit_margin_pct
FROM df_orders
GROUP BY state
ORDER BY total_profit DESC;

-- sale growth from 2022 to 2023
SELECT 
	SUM(CASE WHEN YEAR(order_date) = 2022 THEN sale_price ELSE 0 END) AS sale_2022,
	SUM(CASE WHEN YEAR(order_date) = 2023 THEN sale_price ELSE 0 END) AS sale_2023,
	ROUND(
        SUM(CASE WHEN YEAR(order_date) = 2023 THEN sale_price ELSE 0 END) -
        SUM(CASE WHEN YEAR(order_date) = 2022 THEN sale_price ELSE 0 END)
    , 2) AS sales_growth,
	ROUND(
		(SUM(CASE WHEN YEAR(order_date) = 2023 THEN sale_price ELSE 0 END) -
        SUM(CASE WHEN YEAR(order_date) = 2022 THEN sale_price ELSE 0 END)) * 100.0 / 
		NULLIF(SUM(CASE WHEN YEAR(order_date) = 2022 THEN sale_price ELSE 0 END), 0), 2) AS growth_pct
FROM df_orders;

-- category vise averge discount and profit_marh
SELECT category, 
    ROUND(AVG(discount), 2) AS avg_discount,
    ROUND((SUM(profit) / SUM(sale_price)) * 100, 2) AS profit_margin_pct
FROM df_orders
GROUP BY category
ORDER BY avg_discount DESC;









		

