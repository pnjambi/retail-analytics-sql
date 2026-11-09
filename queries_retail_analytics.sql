SET search_path TO retail_analytics;
SELECT * FROM retail_analytics.customers c ;
SELECT * FROM retail_analytics.orders;

--============================= Section A — SQL fundamentals======================================--

-- 1. Retrieve all customer records.
SELECT * FROM retail_analytics.customers c ;

-- 2. Display customer names, cities, and segments.
SELECT 
	customer_name, city, customer_segment 
FROM retail_analytics.customers c ;

-- 3. Find customers living in Nairobi
SELECT 
	customer_id, customer_name, city
FROM retail_analytics.customers
WHERE city = 'Nairobi';

-- 4. Find customers registered after January 1, 2025.
SELECT 
	customer_id, customer_name, registration_date
FROM retail_analytics.customers
WHERE registration_date > '01-01-2025'
ORDER BY registration_date ASC;

-- 5. Display all unique customer cities.
SELECT DISTINCT 
	city
FROM retail_analytics.customers;

-- 6. Retrieve the 10 most recent orders.
SELECT * FROM retail_analytics.orders o ;

SELECT 
	order_id, product_name, order_date
FROM retail_analytics.orders o 
ORDER BY order_date desc
LIMIT 10;

-- 7. Find orders with unit prices above KSh 10,000
SELECT 
	order_id, product_name,unit_price 
FROM retail_analytics.orders o
WHERE unit_price > 10000
ORDER BY unit_price desc;

-- 8. Find customers whose names start with A.
SELECT customer_name
FROM retail_analytics.customers c 
WHERE customer_name LIKE 'A%'; 

-- 9. Retrieve orders with quantities between 2 and 5
SELECT 
	order_id, quantity
FROM retail_analytics.orders o 
WHERE o.quantity BETWEEN 2 AND 5 -- use 'BETWEEN' operator to select values within the said range.
ORDER BY o.quantity  desc;

-- 10. Find orders paid through M-Pesa.
SELECT 
	order_id, product_name, payment_method
FROM retail_analytics.orders o 
WHERE payment_method = 'M-Pesa';

--============================= Section B — Aggregation and grouping======================================--
-- 11.  Count all customers.
SELECT DISTINCT count(*) AS customers
FROM retail_analytics.customers;

--12. Count all orders.
SELECT count(*) AS orders
FROM retail_analytics.orders o ;

-- 13. Calculate completed-order revenue.
SELECT 
	sum(quantity * unit_price * (1 - discount / 100.0)) AS revenue 
FROM retail_analytics.orders o 
WHERE order_status = 'Completed';

-- 14. Calculate the average completed-order value.
SELECT 
	 round(avg(unit_price),2) AS avg_completed_order_value
FROM retail_analytics.orders o 
WHERE order_status = 'Completed';

--15. Find the highest and lowest product prices.
SELECT
 max(unit_price)
FROM retail_analytics.orders o;

SELECT
 min(unit_price)
FROM retail_analytics.orders o;

-- 16. Calculate revenue by product category.
SELECT 
	product_category,
	sum(quantity * unit_price * (1 - discount / 100.0)) AS category_revenue
FROM retail_analytics.orders
WHERE ORDER_status = 'Completed'
GROUP BY product_category ;

-- 17. Count customers by city.
SELECT 
	city, count(customer_id) AS total_customers
FROM retail_analytics.customers c 
GROUP BY city
ORDER BY total_customers desc;

-- 18. Calculate quantity sold by product.
SELECT 
	product_name, sum(quantity)
FROM retail_analytics.orders o 
GROUP BY product_name ;

-- 19. Find categories generating more than KSh 100,000 in revenue.
SELECT 
	product_category, 
	sum(quantity * unit_price * (1 - discount / 100.0)) AS category_revenue 
FROM retail_analytics.orders o 
WHERE order_status = 'Completed'
GROUP BY product_category
HAVING sum(quantity * unit_price * (1 - discount / 100.0))> 100000;

--20. Calculate the percentage of cancelled orders.
SELECT 
	round((SELECT count(order_id)
	FROM retail_analytics.orders
	WHERE order_status = 'Cancelled'),2) * 100.0
	/
	count(order_id) AS percentage_cancelled_orders
FROM retail_analytics.orders;



--============================= Section C — Joins and customer analytics ======================================--

-- 21. Display orders with customer names and cities.
SELECT 
	o.order_id, o.product_name, c.customer_name, c.city 
FROM retail_analytics.orders o 
LEFT JOIN retail_analytics.customers c USING (customer_id);

-- 22. Calculate total spending by customer.
SELECT 
	 c.customer_name, sum(o.quantity * o.unit_price) AS customer_spend
FROM retail_analytics.orders o 
LEFT JOIN retail_analytics.customers c USING (customer_id)
WHERE o.order_status = 'Completed'
GROUP BY  c.customer_name
ORDER BY customer_spend DESC;

-- 23. Identify customers who have never ordered.

SELECT 
	c.customer_id, customer_name
FROM retail_analytics.customers c
LEFT JOIN retail_analytics.orders o 
	ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

-- 24. Find the 10 highest-spending customers.
SELECT o.customer_id, c.customer_name, sum(quantity * unit_price) AS customer_spend
FROM retail_analytics.orders o
LEFT JOIN retail_analytics.customers c 
	ON o.customer_id  = c.customer_id 
WHERE o.order_status = 'Completed'
GROUP BY o.customer_id, c.customer_name
ORDER BY customer_spend DESC
LIMIT 10;

--25. Calculate revenue by customer city.
SELECT 
	c.city, 
	sum(quantity * unit_price * (1 - discount / 100.0)) AS city_revenue
FROM retail_analytics.orders o 
LEFT JOIN retail_analytics.customers c
	USING(customer_id)
WHERE order_status = 'Completed'
GROUP BY city
ORDER BY city_revenue desc;

-- 26. Identify customers with more than five orders.
SELECT customer_name,count(order_id) AS no_orders
FROM retail_analytics.orders o
LEFT JOIN retail_analytics.customers c 
	USING (customer_id)
WHERE order_status ='Completed'
GROUP BY customer_name
HAVING count(order_id) > 5
ORDER BY no_orders desc;

--27. Calculate average customer spending by segment.

SELECT 
	customer_segment, 
	ROUND(avg(quantity * unit_price),2) AS customer_spend
FROM retail_analytics.orders o 
LEFT JOIN retail_analytics.customers c 
	USING(customer_id)
WHERE order_status = 'Completed'
GROUP BY c.customer_segment
ORDER BY customer_spend DESC;

-- 28. Identify the most popular category among VIP customers.

SELECT 
	product_category, 
	count(o.customer_id ) AS most_popular
FROM retail_analytics.orders o
LEFT JOIN retail_analytics.customers c 
	USING (customer_id)
WHERE o.order_status = 'Completed'
GROUP BY o.product_category, customer_segment 
HAVING customer_segment = 'VIP'
ORDER BY most_popular desc;

--============================= Section D — Subqueries and CTEs  ======================================--

-- 29. Find customers spending above the average total spending per purchasing customer.


SELECT 
	customer_id,
	customer_name, 
	sum(quantity * unit_price) AS customer_spending
FROM retail_analytics.orders o 
LEFT JOIN retail_analytics.customers c USING (customer_id)
WHERE o.order_status  = 'Completed'
GROUP BY customer_id, customer_name
HAVING sum(quantity * unit_price) > (SELECT 
										AVG(quantity * unit_price)
									FROM retail_analytics.orders o
									WHERE o.order_status = 'Completed')
ORDER BY customer_spending desc;

-- 30. Find products priced above the overall average unit price.
SELECT DISTINCT product_name, unit_price
FROM retail_analytics.orders o 
WHERE unit_price > (SELECT round(avg(unit_price),2)
					FROM retail_analytics.orders o )
ORDER BY o.unit_price desc;

-- 31. Use a CTE to identify the three highest-revenue months.
WITH monthly_revenue AS (
	SELECT 
		TO_CHAR(order_date, 'YYYY-MM') AS month_name,
		sum(quantity * unit_price * (1 - discount / 100.0)) AS revenue
	FROM retail_analytics.orders o 
	WHERE order_status = 'Completed'
	GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT month_name, revenue
FROM monthly_revenue
ORDER BY revenue DESC
LIMIT 3;

-- 32. Find customers purchasing from at least three categories.
WITH customer_purchases AS (
	SELECT 
		customer_id, 
		COUNT(DISTINCT product_category) AS count_purchase_category,
		STRING_AGG(DISTINCT product_category,', ' ORDER BY product_category) AS category_names
	FROM retail_analytics.orders
	GROUP BY customer_id
	HAVING COUNT(DISTINCT product_category) >= 3
) 
SELECT cp.customer_id, c.customer_name, count_purchase_category, cp.category_names
FROM customer_purchases cp
JOIN retail_analytics.customers c
	ON c.customer_id= cp.customer_id
ORDER BY customer_id ASC;

-- 33. Use a CTE to calculate category revenue, cost, profit, and profit margin.
WITH sales_metrics AS (
	SELECT 
		product_category,
		sum(quantity * unit_price * (1 - discount / 100.0)) AS revenue,
		sum(quantity  * cost_price) AS cost,
		sum(quantity * unit_price * (1 - discount / 1000.0) - quantity  * cost_price) AS profit,
		sum(quantity * unit_price * (1 - discount / 100.0) - quantity  * cost_price)
		/ NULLIF(sum(quantity * unit_price * (1 - discount / 100.0)), 0) * 100.0 AS profit_margin_percent
		FROM retail_analytics.orders 
		WHERE order_status = 'Completed'
		GROUP BY product_category
)
SELECT product_category, revenue, COST, profit, profit_margin_percent
FROM sales_metrics 
ORDER BY profit desc ;

-- 34. Find customers whose latest completed order is more than 90 days before the latest order date in the dataset.

WITH last_days_ordered AS (SELECT customer_id,
			(SELECT MAX(order_date) FROM retail_analytics.orders) AS latest_dataset_date,
			max(order_date) AS customer_latest_order_date,
			(SELECT MAX(order_date) FROM retail_analytics.orders)  -
			max(order_date) AS total_days
	FROM retail_analytics.orders o
	WHERE order_status = 'Completed'
	GROUP BY customer_id
)
SELECT lod.customer_id, c.customer_name, customer_latest_order_date , total_days 
FROM last_days_ordered lod
JOIN retail_analytics.customers c ON c.customer_id = lod.customer_id
ORDER BY total_days DESC;


-- ========================================================================================================
									-- SECTION D: SUBQUERIES AND CTEs
-- ========================================================================================================

-- 35. Rank customers by spending using RANK()
WITH customer_spend AS (
	SELECT 
		o.customer_id, customer_name,
		sum(quantity * o.unit_price) AS total_spend
	FROM retail_analytics.orders o 
	JOIN retail_analytics.customers c ON c.customer_id = o.customer_id 
	WHERE o.order_status  = 'Completed'
	GROUP BY o.customer_id, customer_name)
SELECT customer_name, rank() over(ORDER BY total_spend DESC)
FROM customer_spend;

-- 36. Number each customer's orders by recency using ROW_NUMBER().
SELECT 
	customer_id, 
	o.order_date, 
	row_number() over(ORDER BY order_date DESC) AS row_numb_recent_orders
FROM retail_analytics.orders o 
WHERE o.order_status  = 'Completed';

-- 37. Rank products within categories using DENSE_RANK().
SELECT product_name, o.product_category, dense_rank() over(ORDER BY o.product_category asc)
FROM retail_analytics.orders o
GROUP BY o.product_category, product_name;

-- 38. Calculate cumulative monthly revenue.
SELECT 
	TO_CHAR(order_date, 'YYYY-MM') AS year_month, 
	sum(o.quantity * o.unit_price) AS revenue
FROM retail_analytics.orders o
WHERE o.order_status  = 'Completed'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY year_month asc; 

-- 39. Compare monthly revenue using LAG().
SELECT 
	TO_CHAR(order_date, 'YYYY-MM') AS year_month,
	sum(o.quantity * o.unit_price) AS revenue,
	lag(sum(o.quantity * o.unit_price)) OVER(ORDER BY TO_CHAR(order_date, 'YYYY-MM')) AS  previous_revenue
FROM retail_analytics.orders o
WHERE o.order_status  = 'Completed'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY year_month asc; 

-- 40. Calculate month-over-month revenue growth (%).
WITH month_over_month_revenue AS (SELECT  
	TO_CHAR(order_date, 'YYYY-MM') AS year_month,
	sum(o.quantity * o.unit_price) - lag(sum(o.quantity * o.unit_price)) OVER(ORDER BY TO_CHAR(order_date, 'YYYY-MM')) AS revenue_diff,
	sum(o.quantity * o.unit_price) + lag(sum(o.quantity * o.unit_price)) OVER(ORDER BY TO_CHAR(order_date, 'YYYY-MM'))AS two_months_revenue
	FROM retail_analytics.orders o
	WHERE o.order_status  = 'Completed'
	GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT year_month, Round((revenue_diff/two_months_revenue) * 100.0,2) AS monthly_revenue_growth_percent
FROM month_over_month_revenue
ORDER BY year_month ASC;

-- 41. Divide customers into four spending groups using NTILE(4).
SELECT 
	o.customer_id, customer_name, sum(quantity * unit_price) AS customer_spend,
	ntile(4) OVER (ORDER BY sum(quantity * unit_price) desc)
FROM retail_analytics.orders o
LEFT JOIN retail_analytics.customers c 
	ON o.customer_id  = c.customer_id 
WHERE o.order_status = 'Completed'
GROUP BY o.customer_id, customer_name
ORDER BY customer_spend DESC;

-- 42. Calculate each category's share of total revenue using window functions.
SELECT 
	product_category,
	sum(quantity * unit_price * (1 - discount / 100.0)) AS category_revenue,
	sum(sum(quantity * unit_price * (1 - discount / 100.0)))
		OVER () AS all_category_revenue,
	ROUND((sum(quantity * unit_price * (1 - discount / 100.0)) 
	/
	sum(sum(quantity * unit_price * (1 - discount / 100.0)))
		OVER ()) * 100,2) AS total_revenue_share_pct
FROM retail_analytics.orders
WHERE ORDER_status = 'Completed'
GROUP BY product_category ; 



-- ========================================================================================================
									-- SECTION F: Advanced business intelligence
-- ========================================================================================================


-- 43. Create a monthly_sales_summary view (month, orders, revenue, cost, profit), then select from it.
--DROP VIEW monthly_sales_summary;
CREATE OR REPLACE VIEW monthly_sales_summary AS 
	SELECT 
		TO_CHAR(order_date, 'YYYY-MM') AS sales_month,
		sum(quantity * unit_price * (1 - discount / 100.0)) AS revenue,
		sum(quantity * cost_price) AS COST,
		sum(quantity * unit_price * (1 - discount / 100.0))
			- sum(quantity * cost_price) AS profit
	FROM retail_analytics.orders
	WHERE order_status = 'Completed'
	GROUP BY TO_CHAR(order_date, 'YYYY-MM')
	ORDER BY sales_month asc;

SELECT * FROM monthly_sales_summary;
	
-- 44. Create a PL/pgSQL function that returns completed-order revenue for a supplied customer ID — 
  -- show it for one customer and for an ID that does not exist (it must return 0).
--DROP FUNCTION completed_order_revenue(integer);
CREATE OR REPLACE FUNCTION completed_order_revenue(f_customer_id INT)
RETURNS numeric
LANGUAGE plpgsql
AS $$
DECLARE
    revenue NUMERIC;
BEGIN
	SELECT 
		sum(o.quantity * o.unit_price * (1 - discount / 100.0)) AS revenue
 	INTO revenue
	FROM  retail_analytics.orders o
	WHERE o.customer_id = f_customer_id
		AND o.order_status = 'Completed';
	RETURN revenue;
END;
$$;

SELECT * FROM completed_order_revenue(9999);


-- 45. Segment customers into High, Medium and Low Value, and explain why you chose your thresholds.
WITH customer_spend_summary AS (
	SELECT 
		o.customer_id, 
		c.customer_name, 
		sum(quantity * unit_price * (1 - discount / 100.0)) AS customer_spend
	FROM retail_analytics.orders o
	LEFT JOIN retail_analytics.customers c 
		ON o.customer_id  = c.customer_id 
	WHERE o.order_status = 'Completed'
	GROUP BY o.customer_id, c.customer_name
	ORDER BY customer_spend DESC
),
customer_ranking AS (
	SELECT 
		customer_id, 
		customer_name, 
		customer_spend,
		NTILE(3) OVER (ORDER BY customer_spend DESC) AS spending_group
	FROM customer_spend_summary
) 
SELECT 
	customer_id, 
	customer_name, 
	customer_spend,
    CASE
        WHEN spending_group = 1 THEN 'High Value'
        WHEN spending_group = 2 THEN 'Medium Value'
        WHEN spending_group = 3 THEN 'Low Value'
    END AS customer_segment
FROM customer_ranking
ORDER BY customer_spend DESC;


-- 46. Produce a management report: top five customers, top five products, 
 -- the most profitable category, and the lowest-revenue month.

---top 5 customers by total spending
WITH customer_spending AS ( 
	SELECT o.customer_id, c.customer_name, sum(quantity * unit_price) AS customer_spend
	FROM retail_analytics.orders o
	LEFT JOIN retail_analytics.customers c 
		ON o.customer_id  = c.customer_id 
	WHERE o.order_status = 'Completed'
	GROUP BY o.customer_id, c.customer_name
	ORDER BY customer_spend DESC
	LIMIT 5
)

-- top 5 products by total revenue
SELECT DISTINCT 
	product_name, 
	sum(quantity * unit_price * (1 - discount / 100.0)) AS products_revenue
FROM retail_analytics.orders o 
WHERE order_status = 'Completed'
GROUP BY product_name
ORDER BY products_revenue DESC
LIMIT 5;

-- most profitable category by profit
SELECT 
	product_category,
	sum(quantity * unit_price * (1 - discount / 100.0))
			- sum(quantity * cost_price) AS profit
FROM retail_analytics.orders
WHERE ORDER_status = 'Completed'
GROUP BY product_category
ORDER BY profit desc
LIMIT 1;

-- lowest-revenue month
WITH monthly_revenue AS (
	SELECT 
		TO_CHAR(order_date, 'YYYY-MM') AS month_name,
		sum(quantity * unit_price * (1 - discount / 100.0)) AS revenue
	FROM retail_analytics.orders o 
	WHERE order_status = 'Completed'
	GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT month_name, revenue
FROM monthly_revenue
ORDER BY revenue asc
LIMIT 1;



