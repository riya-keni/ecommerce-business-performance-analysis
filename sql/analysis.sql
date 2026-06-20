--Ecommerce Project
--Tables
--customers (customer_id, customer_name, city, signup_date)
--orders (order_id, customer_id, order_date, amount, order_status, payment_type)
--products (product_id, product_name, category, price, )
--order_items (item_id, product_id, order_id, quantity, unit_price)
--delivery (delivery_id, order_id, delivery_time, delivery_status)


-- SECTION 1 – BUSINESS OVERVIEW & KPI ANALYSIS

-- 1. What are the overall business KPIs such as total revenue, total profit, total orders, total customers, AOV, and overall profit margin?
-- ANS : 
-- Total Revenue
SELECT SUM(amount) AS total_revenue 
FROM orders
WHERE order_status = 'Delivered'
-- The total revenue for the business is 23,308,289.85

-- Total Profit
SELECT SUM((i.unit_price - p.cost_price) * i.quantity) AS total_profit
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id
JOIN orders o 
ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
-- The total profit for the business is 13,618,957.78

--Total Orders
SELECT COUNT(order_id) AS total_orders
FROM orders
-- Total 5000 orders are there
SELECT order_status, COUNT(*) 
FROM orders
GROUP BY order_status
-- From the 5000 orders, 4671 are successfully delivered, 265 are returned and 64 are cancelled

--Total Customers
SELECT COUNT(customer_id) AS total_customers
FROM customers
-- Total of 800 customers are there
SELECT COUNT(DISTINCT customer_id) 
FROM orders
-- From the 800 customers, 570 have placed an order

--AOV 
SELECT ROUND(AVG(amount),2) AS AOV
FROM orders
WHERE order_status = 'Delivered'
-- The AOV is 4990.00

-- Overall Profit Margin
--Formula used ((Revenue - COGS(cost of goods) )/ Revenue) * 100
SELECT  ROUND(((SUM(i.quantity *  i.unit_price) - SUM(p.cost_price * i.quantity))/ 
                SUM(i.quantity *  i.unit_price)) * 100.00 ,2) AS profit_margin
FROM orders o 
JOIN order_items i 
ON o.order_id = i.order_id
JOIN products p 
ON i.product_id = p.product_id
WHERE o.order_status = 'Delivered'
-- The overall profit margin for the business is 58.43%

-- 2. How do revenue and profit change over time?
SELECT EXTRACT(YEAR FROM o.order_date) AS order_year,
	   EXTRACT(MONTH FROM o.order_date) AS order_month, 
       SUM(i.unit_price * i.quantity) as total_revenue, 
       SUM((i.unit_price - p.cost_price) * i.quantity) AS total_profit
FROM orders o 
JOIN order_items i 
ON o.order_id = i.order_id
JOIN products p 
ON i.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY EXTRACT(YEAR FROM o.order_date), 
         EXTRACT(MONTH FROM o.order_date)
ORDER BY order_year, order_month
--

-- 3. Calculate cumulative revenue and cumulative profit over time.
SELECT order_year, 
       order_month, 
       SUM(total_revenue) OVER(ORDER BY order_year, order_month ) AS cumulative_revenue,
       SUM(total_profit) OVER(ORDER BY order_year, order_month) AS cumulative_profit
FROM 
(
    SELECT EXTRACT(YEAR FROM o.order_date) AS order_year,
	       EXTRACT(MONTH FROM o.order_date) AS order_month, 
           SUM(i.unit_price * i.quantity) as total_revenue, 
           SUM((i.unit_price - p.cost_price) * i.quantity) AS total_profit
    FROM orders o 
    JOIN order_items i 
    ON o.order_id = i.order_id
    JOIN products p 
    ON i.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY EXTRACT(YEAR FROM o.order_date), 
             EXTRACT(MONTH FROM o.order_date)
    ORDER BY order_year, order_month
) AS A

-- 4. Which months experienced unusually high or low business performance?
SELECT order_year, order_month, total_revenue,  
       CASE 
            WHEN rev_tile = 1 THEN 'Above Average Performance'
            WHEN rev_tile = 3 THEN 'Below Average Performance'
            ELSE 'Average Performance'
        END AS revenue_performance,
        total_profit,
        CASE 
            WHEN profit_tile = 1 THEN 'Above Average Performance'
            WHEN profit_tile = 3 THEN 'Below Average Performance'
            ELSE 'Average Performance'
        END AS profit_performance
    FROM 
    (
    SELECT EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month, 
        SUM(i.unit_price * i.quantity) AS total_revenue, 
        SUM((i.unit_price - p.cost_price) * i.quantity) AS total_profit, 
        NTILE(3) OVER (ORDER BY SUM(i.unit_price * i.quantity) DESC) as rev_tile, 
        NTILE(3) OVER(ORDER BY SUM((i.unit_price - p.cost_price) * i.quantity) DESC ) as profit_tile
    FROM orders o 
    JOIN order_items i 
    ON o.order_id = i.order_id
    JOIN products p 
    ON i.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY EXTRACT(YEAR FROM o.order_date),
            EXTRACT(MONTH FROM o.order_date)
) AS A
WHERE rev_tile IN (1,3) OR profit_tile IN (1,3)
ORDER BY order_year, order_month
-- 
-- 5. What seasonal patterns exist across different product categories?
SELECT p.category, 
       EXTRACT(YEAR FROM o.order_date) AS order_year, 
       EXTRACT(MONTH FROM o.order_date) AS order_month,
       SUM(i.quantity) AS total_units,
       SUM(i.quantity * i.unit_price) AS total_revenue
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id
JOIN orders o 
ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category, 
       EXTRACT(YEAR FROM o.order_date) , 
       EXTRACT(MONTH FROM o.order_date)
ORDER BY order_year, order_month
-- This method is not giving much idea here in sql hence the following is the query in pivot style
SELECT EXTRACT(YEAR FROM o.order_date) AS order_year, 
       EXTRACT(MONTH FROM o.order_date) AS order_month,
       SUM(CASE WHEN p.category = 'Small Appliances' THEN i.quantity ELSE 0 END) AS appliances_units_sold,
       SUM(CASE WHEN p.category = 'Small Appliances' THEN i.quantity * i.unit_price ELSE 0 END) AS sa_revenue,
       SUM(CASE WHEN p.category = 'Household' THEN i.quantity ELSE 0 END) AS household_units_sold,
       SUM(CASE WHEN p.category = 'Household' THEN i.quantity * i.unit_price ELSE 0 END) AS household_revenue,
       SUM(CASE WHEN p.category = 'Fashion Basics' THEN i.quantity ELSE 0 END) AS fashion_units_sold,
       SUM(CASE WHEN p.category = 'Fashion Basics' THEN i.quantity * i.unit_price ELSE 0 END) AS fashion_revenue,
       SUM(CASE WHEN p.category = 'ELectronics Accessories' THEN i.quantity ELSE 0 END) AS electronics_units_sold,
       SUM(CASE WHEN p.category = 'Electronics Accessories' THEN i.quantity * i.unit_price ELSE 0 END) AS electronics_revenue,
       SUM(CASE WHEN p.category = 'Kitchen Products' THEN i.quantity ELSE 0 END) AS kp_units_sold,
       SUM(CASE WHEN p.category = 'Kitchen Products' THEN i.quantity * i.unit_price ELSE 0 END) AS kp_revenue,
       SUM(CASE WHEN p.category = 'Personal Care' THEN i.quantity ELSE 0 END) AS pc_units_sold,
       SUM(CASE WHEN p.category = 'Personal Care' THEN i.quantity * i.unit_price ELSE 0 END) AS pc_revenue
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id
JOIN orders o 
ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY EXTRACT(YEAR FROM o.order_date) , 
         EXTRACT(MONTH FROM o.order_date)
ORDER BY order_year, order_month
-- 

-- 6. Which months generated high revenue but weak profitability?
SELECT * FROM (
    SELECT order_year, order_month, total_revenue,  
        CASE 
                WHEN total_revenue > AVG(total_revenue) OVER() THEN 'Above Average'
                WHEN total_revenue < AVG(total_revenue) OVER() THEN 'Below Average'
                ELSE 'Average'
            END AS revenue_performance,
            total_profit,
            CASE 
                WHEN  profit_margin > AVG(profit_margin) OVER() THEN 'Above Average'
                WHEN profit_margin < AVG(profit_margin) OVER() THEN 'Below Average'
                ELSE 'Average'
            END AS profit_performance
        FROM 
        (
        SELECT EXTRACT(YEAR FROM o.order_date) AS order_year,
            EXTRACT(MONTH FROM o.order_date) AS order_month, 
            SUM(i.unit_price * i.quantity) AS total_revenue, 
            SUM((i.unit_price - p.cost_price) * i.quantity) AS total_profit, 
            ROUND(((SUM(i.quantity *  i.unit_price) - SUM(p.cost_price * i.quantity))/ 
                SUM(i.quantity *  i.unit_price)) * 100.00 ,2) AS profit_margin
        FROM orders o 
        JOIN order_items i 
        ON o.order_id = i.order_id
        JOIN products p 
        ON i.product_id = p.product_id
        WHERE o.order_status = 'Delivered'
        GROUP BY EXTRACT(YEAR FROM o.order_date),
                EXTRACT(MONTH FROM o.order_date)
    ) AS A
) AS B
WHERE revenue_performance = 'Above Average' AND  profit_performance = 'Below Average'
ORDER BY order_year, order_month
-- For the year 2024 the month of April, September and December generated high revenue but weak profitability.
-- For the year 2025 the month of June, November and December generated high revenue but weak profitability.

-- 7. Compare monthly revenue growth and profit growth trends.
SELECT order_year, 
       order_month, 
       monthly_revenue - LAG(monthly_revenue) OVER(ORDER BY order_year, order_month) AS revenue_change, 
       monthly_profit - LAG(monthly_profit) OVER(ORDER BY order_year, order_month) AS profit_change,
       monthly_profit_margin - LAG(monthly_profit_margin) OVER(ORDER BY order_year, order_month) AS profit_margin_change
FROM 
(
    SELECT EXTRACT(YEAR FROM o.order_date) AS order_year, 
        EXTRACT(MONTH FROM o.order_date) AS order_month, 
        SUM(i.quantity * i.unit_price) AS monthly_revenue, 
        SUM((i.unit_price - p.cost_price) * i.quantity) AS monthly_profit, 
        ROUND(((SUM(i.quantity *  i.unit_price) - SUM(p.cost_price * i.quantity))/ 
                SUM(i.quantity *  i.unit_price)) * 100.00 ,2) AS monthly_profit_margin
    FROM orders o 
    JOIN order_items i 
    ON o.order_id = i.order_id 
    JOIN products p 
    ON p.product_id = i.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY  EXTRACT(YEAR FROM o.order_date),
            EXTRACT(MONTH FROM o.order_date)
) AS A
ORDER BY order_year, order_month

-- 8. Which categories contribute the highest percentage of total revenue and total profit?
SELECT category, 
	   category_revenue, 
	   category_profit, 
	   ROUND(category_revenue * 100.00 / SUM(category_revenue) OVER(), 2) as revenue_contribution , 
	   ROUND(category_profit * 100.00 / SUM(category_profit) OVER() , 2)as profit_contribution 
FROM (
SELECT p.category, 
       SUM(i.quantity * i.unit_price) AS category_revenue, 
       SUM((i.unit_price - p.cost_price)*i.quantity) AS category_profit
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id
JOIN orders o 
ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
) AS A
ORDER BY revenue_contribution DESC
-- Kitchen Products has highest revenue contribution 25.04% with profit contribution of 23.27% 
-- Personal Care has the highest profit contribution of 24.00% with revenue contribution of 16.34%
-- Thus Kitchen Products and Personal Care category are good performing catergories

-- SECTION 2 – CUSTOMER ANALYTICS

-- 9. Compare repeat customers vs one-time customers based on revenue, profit, AOV, and order frequency.
SELECT 
      CASE 
          WHEN total_orders > 1 THEN 'repeat'
          ELSE 'one-time'
      END AS customer_type, 
      SUM(total_revenue) AS total_revenue, 
      SUM(total_profit) AS total_profit, 
      ROUND(SUM(total_revenue) / SUM(total_orders),2) AS AOV,
	  AVG(total_orders) AS customer_purchase_frequency
FROM (
    SELECT c.customer_id, 
        COUNT(DISTINCT o.order_id) AS total_orders, 
        SUM(i.quantity * i.unit_price) AS total_revenue, 
        SUM((i.unit_price - p.cost_price) * i.quantity) AS total_profit   
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id 
    JOIN order_items i 
    ON o.order_id = i.order_id
	JOIN products p 
	ON i.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id
) AS A 
GROUP BY CASE 
          WHEN total_orders > 1 THEN 'repeat'
          ELSE 'one-time'
         END
-- Revenue 
-- Repeat Customers : 22,177,950.01 , One-time Customers: 1,130,339.92
--Profit 
-- Repeat Customers : 12,978,268.60, One-time Customers: 640,689.18
--AOV
-- Repeat Customers : 5006.31, One-time Customers: 4690.21
-- Average Order Frequency for repeat customers is approximately 14 orders
-- Thus, Repeat Customers dominates  revenue and profit. 
--However there is not much difference in AOV between the Repeat and One-time customers
-- The relatively less difference in AOV indicates that the repeat customers are not placing much largere order but are buying in more frequency


-- 10. Which customers generate the highest profit contribution?
SELECT customer_id, 
       customer_name, 
       ROUND((total_profit /SUM(total_profit) OVER()) *100.00, 2) AS profit_contribution
FROM (
    SELECT c.customer_id, 
        c.customer_name, 
        SUM((i.unit_price - p.cost_price) * i.quantity) AS total_profit
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id 
    JOIN order_items i 
    ON o.order_id = i.order_id
    JOIN products p 
    ON i.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.customer_name
) AS A
ORDER BY profit_contribution DESC
-- Based on the data, the profit contribution is highly concentrated amomg small number of people. 

-- 11. Which customers have the highest return and cancellation behavior?
SELECT c.customer_id,
       c.customer_name, 
       COUNT(*) AS total_orders
       SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders, 
       SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders, 
       SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END)/COUNT(*) ,
       SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END)/COUNT(*)
JOIN orders o 
ON c.customer_id = o.customer_id
WHERE o.order_status IN ('Cancelled', 'Returned')
GROUP BY c.customer_id, c.customer_name 
HAVING SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) > 1 OR 
       SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) > 1 
-- The customer ids (509, 764, 189, 420, 658, 703, 786, 444, 416, 735, 159, 319, 779, 58 ,789,
-- 68, 559, 607, 382, 451, 98, 457, 564, 574, 598, 608, 208, 435) have the highest return and cancellation behavior.

-- 12. Which customer segments and cohorts contribute the highest revenue and profit?
--Since segments are not mentioned we would consider different segments such as 
--Based on repeat and one time customers
SELECT customer_type, 
       total_orders,
       ROUND(total_orders * 100.00/ SUM(total_orders) OVER() , 2) AS order_contribution,
       total_revenue, 
       ROUND(total_revenue *100.00/ SUM(total_revenue) OVER(), 2) AS revenue_contribution,
       total_profit,
       ROUND(total_profit * 100.00/SUM(total_profit) OVER(), 2) AS profit_contribution
FROM(
    SELECT CASE 
                WHEN orders_count > 1 THEN 'repeat'
                ELSE 'one time'
            END AS customer_type, 
            SUM(orders_count) AS total_orders, 
            SUM(revenue)AS total_revenue,
            SUM(profit) AS total_profit
    FROM (
        SELECT c.customer_id, 
            COUNT(DISTINCT o.order_id) AS orders_count, 
            SUM(i.unit_price * i.quantity) AS revenue,
            SUM((i.unit_price - p.cost_price) *i.quantity) AS profit
        FROM customers c 
        JOIN orders o 
        ON c.customer_id = o.customer_id
        JOIN order_items i 
        ON o.order_id = i.order_id
        JOIN products p 
        ON i.product_id = p.product_id
        WHERE o.order_status = 'Delivered'
        GROUP BY c.customer_id
    ) AS A
    GROUP BY  CASE 
                WHEN orders_count > 1 THEN 'repeat'
                ELSE 'one time'
            END
) AS B
-- The repeat customers contribute the highest towards revenue and profit. 
-- Around 95%  of contribution for revenue as well as profit comes from repeat customers

-- Based on city
SELECT city, 
       total_orders,
       ROUND(total_orders * 100.00/ SUM(total_orders) OVER() , 2) AS order_contribution,
       total_revenue, 
       ROUND(total_revenue *100.00/ SUM(total_revenue) OVER(), 2) AS revenue_contribution,
       total_profit,
       ROUND(total_profit * 100.00/SUM(total_profit) OVER(), 2) AS profit_contribution
FROM (
	SELECT c.city, 
	        COUNT(DISTINCT o.order_id) AS total_orders, 
	        SUM(i.unit_price * i.quantity) AS total_revenue,
	        SUM((i.unit_price - p.cost_price) *i.quantity) AS total_profit
	    FROM customers c 
	    JOIN orders o 
	    ON c.customer_id = o.customer_id
	    JOIN order_items i 
	    ON o.order_id = i.order_id
	    JOIN products p 
	    ON i.product_id = p.product_id
	    WHERE o.order_status = 'Delivered'
	    GROUP BY c.city
	ORDER BY total_profit DESC
) AS A
-- Customers from the cities Bangalore, Bhopal, Hyderabad, Lucknow and Kochi contribute the highest towards revenue and profit. 
-- Around 70% of revenue and profit contribution comes from the customers in these cities.

-- Based on acquisition date(cohort analysis)
SELECT customer_type, 
       total_orders,
       ROUND(total_orders * 100.00/ SUM(total_orders) OVER() , 2) AS order_contribution,
       total_revenue, 
       ROUND(total_revenue *100.00/ SUM(total_revenue) OVER(), 2) AS revenue_contribution,
       total_profit,
       ROUND(total_profit * 100.00/SUM(total_profit) OVER(), 2) AS profit_contribution
FROM (
    SELECT customer_type, 
        SUM(order_count) AS total_orders, 
        SUM(revenue) AS total_revenue, 
        SUM(profit) AS total_profit
    FROM (
        SELECT c.customer_id,
            CASE 
                    WHEN EXTRACT(YEAR FROM MIN(o.order_date)) = 2025 THEN 'new customer'
                    WHEN EXTRACT(YEAR FROM MIN(o.order_date)) = 2024 THEN 'mid cohort customers'
                    ELSE 'old customer'
                END AS customer_type, 
                COUNT(DISTINCT o.order_id) AS order_count, 
                SUM(i.unit_price * i.quantity) AS revenue,
                SUM((i.unit_price - p.cost_price) *i.quantity) AS profit
        FROM customers c 
        JOIN orders o 
        ON c.customer_id = o.customer_id 
        JOIN order_items i 
        ON o.order_id = i.order_id 
        JOIN products p 
        ON i.product_id = p.product_id
        WHERE o.order_status = 'Delivered'
        GROUP BY c.customer_id
    ) AS A
    GROUP BY customer_type
) AS B 
-- The old customers contribute highest towards revenue and profit
-- Around 93% of contribution in revenue and profit comes from old customers

-- Based on spending behaviour 
SELECT customer_type, 
       total_orders,
       ROUND(total_orders * 100.00/ SUM(total_orders) OVER() , 2) AS order_contribution,
       total_revenue, 
       ROUND(total_revenue *100.00/ SUM(total_revenue) OVER(), 2) AS revenue_contribution,
       total_profit,
       ROUND(total_profit * 100.00/SUM(total_profit) OVER(), 2) AS profit_contribution
FROM (
    SELECT CASE 
                WHEN per_rnk <=0.20 THEN 'High Spenders'
                WHEN per_rnk <=0.60 THEN 'Mid Spenders'
                ELSE 'Low Spenders'
            END AS customer_type, 
            SUM(orders) AS total_orders, 
            SUM(revenue) AS total_revenue, 
            SUM(profit) AS total_profit
    FROM(
        SELECT c.customer_id, 
            COUNT(DISTINCT o.order_id) as orders, 
            SUM(i.unit_price * i.quantity) AS revenue, 
            SUM((i.unit_price - p.cost_price) *i.quantity) AS profit, 
           PERCENT_RANK() OVER( ORDER BY SUM(i.unit_price * i.quantity) DESC) AS per_rnk
        FROM customers c 
        JOIN orders o 
        ON c.customer_id = o.customer_id 
        JOIN order_items i 
        ON o.order_id = i.order_id 
        JOIN products p 
        ON i.product_id = p.product_id
        WHERE o.order_status = 'Delivered'
        GROUP BY c.customer_id
        ) AS A
    GROUP BY CASE 
                WHEN per_rnk <=0.20 THEN 'High Spenders'
                WHEN per_rnk <=0.60 THEN 'Mid Spenders'
                ELSE 'Low Spenders'
            END
) AS B 
-- The High Spending customers contribute the highest towards revenue and profit
-- Around 82.74% of revenue contribution and 83.76% of profit contribution comes from High spending customers.

-- 13. Identify potentially churned customers based on recency of purchases.
WITH customer_last_purchase AS (
    SELECT c.customer_id, 
           c.customer_name, 
           MAX(o.order_date) AS latest_order_date
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.customer_name
), 
customer_inactivity AS (
    SELECT customer_id, 
           customer_name, 
           latest_order_date,
           ((SELECT MAX(order_date) FROM orders WHERE order_status = 'Delivered')- latest_order_date) AS inactive_days
    FROM customer_last_purchase
) 
SELECT customer_id, 
       customer_name,
       latest_order_date, 
	   inactive_days,
       CASE 
            WHEN inactive_days BETWEEN 0 AND 30 THEN 'Active'
            WHEN inactive_days BETWEEN 31 AND 90 THEN 'Warm'
            WHEN inactive_days BETWEEN 91 AND 180 THEN 'At risk'
            WHEN inactive_days > 180 THEN 'Churned'
        END AS churned_status
FROM customer_inactivity
ORDER BY inactive_days DESC;

-- 14. Do newer customers place higher-value orders compared to older customers?
SELECT customer_type, 
       SUM(revenue) AS total_revenue, 
       SUM(num_orders) AS total_orders, 
       SUM(revenue)/SUM(num_orders) AS AOV
FROM (
    SELECT c.customer_id, 
           MIN(o.order_date) as first_purchase_date, 
           SUM(o.amount) AS revenue, 
           COUNT(order_id) AS num_orders,
            CASE 
                WHEN EXTRACT(YEAR FROM MIN(o.order_date)) = 2025 THEN 'new customer'
                WHEN EXTRACT(YEAR FROM MIN(o.order_date)) = 2024 THEN 'mid cohort customers'
                ELSE 'old customer'
            END AS customer_type
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
	GROUP BY c.customer_id
) AS A
GROUP BY customer_type
-- There is no significance difference between order value of customers belonging to different cohorts. 

-- 15. Which customers generate high revenue but low profitability?
SELECT customer_id,
       customer_name,
       total_revenue,
       total_profit,
       ROUND(profit_margin,2) AS profit_margin,
       revenue_performance,
       profit_performance
FROM (
    SELECT customer_id,
           customer_name,
           total_revenue,
           total_profit,
           profit_margin,
           CASE 
                WHEN rev_tile = 1 THEN 'High Revenue'
                WHEN rev_tile = 3 THEN 'Low Revenue'
                ELSE 'Average Revenue'
           END AS revenue_performance,
           CASE 
                WHEN pm_tile = 1 THEN 'High Profit Margin'
                WHEN pm_tile = 3 THEN 'Low Profit Margin'
                ELSE 'Average Profit Margin'
           END AS profit_performance
    FROM (
        SELECT c.customer_id,
               c.customer_name,
               COUNT(DISTINCT o.order_id) AS orders,
               SUM(i.unit_price * i.quantity) AS total_revenue,
               SUM((i.unit_price - p.cost_price) * i.quantity) AS total_profit,
               ((SUM(i.quantity * i.unit_price) - SUM(p.cost_price * i.quantity))
                / SUM(i.quantity * i.unit_price)) * 100.00 AS profit_margin,
               NTILE(3) OVER(
                    ORDER BY SUM(i.unit_price * i.quantity) DESC
               ) AS rev_tile,
               NTILE(3) OVER(
                    ORDER BY (
                        (SUM(i.quantity * i.unit_price) - SUM(p.cost_price * i.quantity))
                        / SUM(i.quantity * i.unit_price)
                    ) * 100.00 DESC
               ) AS pm_tile
        FROM customers c
        JOIN orders o
        ON c.customer_id = o.customer_id
        JOIN order_items i
        ON o.order_id = i.order_id
        JOIN products p
        ON i.product_id = p.product_id
        WHERE o.order_status = 'Delivered'
        GROUP BY c.customer_id, c.customer_name
    ) AS A
) AS B
WHERE revenue_performance = 'High Revenue'
AND profit_performance = 'Low Profit Margin';
-- The Customer ID's (598, 420, 449, 150, 764, 416, 415, 294, 505, 189, 693, 634, 82, 689, 468, 228, 
-- 155, 231, 145, 627, 301, 383, 758, 188, 557, 471, 779, 15) have High revenue but weak profitability

-- 16. What is the retention trend across customer cohorts over time?
SELECT DATE_TRUNC('month',first_order_date) AS first_order_month, retention_month
    , COUNT(DISTINCT b.customer_id) AS active_customers
FROM(
SELECT a.customer_id, first_order_date, o.order_date, 
        ((EXTRACT(YEAR FROM o.order_date) -  EXTRACT(YEAR FROM first_order_date)) *12
        +(EXTRACT(MONTH FROM o.order_date) -  EXTRACT(MONTH FROM first_order_date))) AS retention_month
FROM(
SELECT c.customer_id , 
       MIN(o.order_date) AS first_order_date
FROM 
customers c 
JOIN orders o 
ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id
) AS a 
JOIN orders o 
ON a.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
) AS b 
GROUP BY DATE_TRUNC('month',first_order_date), retention_month

-- SECTION 3 – PRODUCT & CATEGORY ANALYSIS

-- 17. Which product & categories generate high revenue but weak profit margins?
SELECT *
FROM (
    SELECT product_id, 
           product_name, 
           category, 
           revenue, 
            profit, 
            CASE 
                    WHEN revenue > AVG(revenue) OVER() THEN 'High Revenue'
                    WHEN revenue < AVG(revenue) OVER() THEN 'Low Revenue'
                    ELSE 'Avg Revenue'
            END AS revenue_type, 
            CASE 
                WHEN profit_margin > AVG(profit_margin) OVER() THEN 'High Profit'
                WHEN profit_margin < AVG(profit_margin) OVER() THEN 'Low Profit'
                ELSE 'Avg Profit'
            END AS profit_type 
    FROM (
        SELECT p.product_id, 
		       p.product_name, p.category, 
               SUM(i.unit_price * i.quantity) AS revenue, 
               SUM((i.unit_price - p.cost_price)* i.quantity) AS profit,
               ROUND((SUM(i.unit_price * i.quantity) - SUM(p.cost_price * i.quantity)) *100.00 / SUM(i.unit_price * i.quantity), 2) AS profit_margin
        FROM products p 
        JOIN order_items i 
        ON p.product_id = i.product_id
        JOIN orders o 
        ON i.order_id = o.order_id
        WHERE o.order_status = 'Delivered'
        GROUP BY p.product_id, p.product_name, p.category
    ) AS A
) AS B
WHERE revenue_type = 'High Revenue' AND profit_type = 'Low Profit'

-- The Product ID's (87, 92, 114, 119, 120, 96, 111, 123) belonging to Kitchen Products and Small Appliances category generate high revenue but weak profitability

-- 18. Compare top revenue products vs top profitable products.
SELECT product_id, 
       product_name, 
       rev_rnk, profit_rnk ,
       (rev_rnk - profit_rnk) As rnk_diff,
       ABS(rev_rnk - profit_rnk) AS abs_diff
FROM (
SELECT p.product_id,
       p.product_name, 
       SUM(i.unit_price * i.quantity) AS revenue, 
       SUM((i.unit_price - p.cost_price) * i.quantity) AS profit, 
       RANK() OVER(ORDER BY  SUM(i.unit_price * i.quantity) DESC) AS rev_rnk, 
       RANK() OVER(ORDER BY SUM((i.unit_price - p.cost_price) * i.quantity) DESC) AS profit_rnk     
FROM products p 
JOIN order_items i
ON p.product_id = i.product_id
JOIN orders o 
ON o.order_id = i.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_id,
       p.product_name
) AS A
ORDER BY abs_diff DESC

-- 19. Which products have the highest return and cancellation rates?
SELECT p.product_id, p.product_name, 
       COUNT(DISTINCT o.order_id) total_orders,
       ROUND((SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.00 / COUNT(DISTINCT o.order_id)), 2) AS cancellation_rate, 
       ROUND(SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) * 100.00 / COUNT(DISTINCT o.order_id), 2) AS return_rate
FROM products p 
JOIN order_items i
ON p.product_id = i.product_id
JOIN orders o 
ON o.order_id = i.order_id
GROUP BY p.product_id, p.product_name
HAVING ROUND((SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.00 / COUNT(DISTINCT o.order_id)), 2) > 1 
OR ROUND(SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) * 100.00 / COUNT(DISTINCT o.order_id), 2) > 1
ORDER BY return_rate DESC, cancellation_rate DESC;

-- 20. Which products are frequently purchased together?
SELECT p1.product_id, p1.product_name , p2.product_id, p2.product_name , COUNT(*) AS purchase_frequency
FROM order_items i1 
JOIN order_items i2 
ON i1.order_id = i2.order_id
JOIN products p1 
ON i1.product_id =  p1.product_id
JOIN products p2 
ON i2.product_id = p2.product_id
JOIN orders o 
ON i1.order_id = o.order_id
WHERE o.order_status = 'Delivered'
AND p1.product_id < p2.product_id
GROUP BY p1.product_id, p1.product_name , p2.product_id, p2.product_name 
ORDER BY purchase_frequency DESC
-- These products are frequently purchased toghether (32,124), (32,39), (32,35), (32,142), (26,32), (32,33), (27,32), 
--(32,38), (23,32), (22,32), (80,136), (30,32), (21,32), (32,141), (96,111), (32,34), (50,96), (45,96), (14,15), 
-- (25,32), (32,40), (32,125), (32,36), (96,127), (67,136), (75,136), (96,143), (64,80)

-- 21. Which categories maintain stable profitability throughout the year?
SELECT category, STDDEV(profit)
FROM (
    SELECT p.category, 
        EXTRACT(YEAR FROM o.order_date) AS order_year, 
        EXTRACT(MONTH FROM o.order_date) AS order_month, 
        SUM((i.unit_price - p.cost_price) * i.quantity) AS profit
    FROM products p 
    JOIN order_items i 
    ON p.product_id = i.product_id 
    JOIN orders o 
    ON i.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.category, 
            EXTRACT(YEAR FROM o.order_date) AS order_year, 
            EXTRACT(MONTH FROM o.order_date) AS order_month 
    ORDER BY order_year ASC, order_month ASC
) AS A
GROUP BY category
-- Small appliances show a stable profitability through out the year and is comparatively less volatile that other categories

-- 22. Which products show the most consistent sales performance over time?
SELECT product_name, ROUND(STDDEV(revenue),2) AS std_dev
FROM (
    SELECT p.product_name, 
        EXTRACT(YEAR FROM o.order_date) AS order_year, 
        EXTRACT(MONTH FROM o.order_date) AS order_month, 
        SUM(i.unit_price  * i.quantity) AS revenue
    FROM products p 
    JOIN order_items i 
    ON p.product_id = i.product_id 
    JOIN orders o 
    ON i.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.product_name, 
            EXTRACT(YEAR FROM o.order_date) , 
            EXTRACT(MONTH FROM o.order_date)
    ORDER BY order_year ASC, order_month ASC
) AS A
GROUP BY product_name
ORDER BY std_dev ASC;

-- 23. Which products generate high sales volume but low profitability?
SELECT * 
FROM (
    SELECT product_id, product_name, units_sold, profit_margin,
            CASE 
                    WHEN units_sold > AVG(units_sold) OVER() THEN 'High Volume'
                    WHEN units_sold < AVG(units_sold) OVER() THEN 'Low Volume'
                    ELSE 'Avg Volume'
            END AS volume_type, 
                CASE 
                    WHEN profit_margin > AVG(profit_margin) OVER() THEN 'High Margin'
                    WHEN profit_margin < AVG(profit_margin) OVER() THEN 'Low Margin'
                    ELSE 'Avg Margin'
            END AS profitability_type 
    FROM (
        SELECT p.product_id, 
            p.product_name, 
            SUM(i.quantity) AS units_sold, 
            ((SUM(i.quantity *  i.unit_price) - SUM(p.cost_price * i.quantity))/ 
              SUM(i.quantity *  i.unit_price)) * 100.00  AS profit_margin
        FROM products p 
        JOIN order_items i 
        ON p.product_id = i.product_id 
        JOIN orders o 
        ON i.order_id = o.order_id
        WHERE o.order_status = 'Delivered'
        GROUP BY p.product_id, p.product_name
    ) AS A
) AS B 
WHERE volume_type = 'High Volume' AND profitability_type = 'Low Margin'

-- 24. Which categories generate high order volume but low profitability?
SELECT * 
FROM (
    SELECT category, order_volume, profit_margin,
                CASE 
                        WHEN order_volume > AVG(order_volume) OVER() THEN 'High Volume'
                        WHEN order_volume < AVG(order_volume) OVER() THEN 'Low Volume'
                        ELSE 'Avg Volume'
                END AS volume_type, 
                    CASE 
                        WHEN profit_margin > AVG(profit_margin) OVER() THEN 'High Margin'
                        WHEN profit_margin < AVG(profit_margin) OVER() THEN 'Low Margin'
                        ELSE 'Avg Margin'
                END AS profitability_type 
    FROM (
        SELECT p.category, 
            COUNT(DISTINCT i.order_id) as order_volume , 
            ((SUM(i.quantity *  i.unit_price) - SUM(p.cost_price * i.quantity))
              /SUM(i.quantity *  i.unit_price)) * 100.00  AS profit_margin
        FROM products p 
        JOIN order_items i 
        ON p.product_id = i.product_id 
        JOIN orders o 
        ON i.order_id = o.order_id
        WHERE o.order_status = 'Delivered'
        GROUP BY p.category
    ) AS A 
) AS B 
WHERE volume_type = 'High Volume' AND profitability_type = 'Low Margin'
-- Kitchen Products category has low profit margin despite of having high order volume

-- 25. Which categories experience strong seasonal demand spikes?
SELECT p.category, 
       EXTRACT(YEAR FROM o.order_date) AS order_year, 
       EXTRACT(MONTH FROM o.order_date) AS order_month, 
       SUM(i.quantity) AS units_sold
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id 
JOIN orders o 
ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category, 
         EXTRACT(YEAR FROM o.order_date) , 
         EXTRACT(MONTH FROM o.order_date) 
-- Pivot style query
SELECT EXTRACT(YEAR FROM o.order_date) AS order_year, 
       EXTRACT(MONTH FROM o.order_date) AS order_month,
       SUM(CASE WHEN p.category = 'Small Appliances' THEN i.quantity ELSE 0 END) AS appliances_units_sold,
       SUM(CASE WHEN p.category = 'Household' THEN i.quantity ELSE 0 END) AS household_units_sold,
       SUM(CASE WHEN p.category = 'Fashion Basics' THEN i.quantity ELSE 0 END) AS fashion_units_sold,
       SUM(CASE WHEN p.category = 'Electronics Accessories' THEN i.quantity ELSE 0 END) AS electronics_units_sold,
       SUM(CASE WHEN p.category = 'Kitchen Products' THEN i.quantity ELSE 0 END) AS kp_units_sold,
       SUM(CASE WHEN p.category = 'Personal Care' THEN i.quantity ELSE 0 END) AS pc_units_sold
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id
JOIN orders o 
ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY EXTRACT(YEAR FROM o.order_date) , 
         EXTRACT(MONTH FROM o.order_date)
ORDER BY order_year, order_month

-- 26. Which categories have the highest average order value?
SELECT p.category, 
       SUM(i.unit_price * i.quantity) AS revenue, 
       COUNT(DISTINCT i.order_id) AS order_volume, 
       ROUND(SUM(i.unit_price * i.quantity)/COUNT(DISTINCT i.order_id),2) AS AOV
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id 
JOIN orders o 
ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
ORDER BY AOV DESC
 --Electronics Accecories and Personal Care have highest AOV

-- 27. Which categories suffer the highest profit leakage due to returns?
SELECT p.category,
       SUM(CASE WHEN o.order_status = 'Returned' THEN i.unit_price * i.quantity ELSE 0 END) AS revenue_lost, 
	   ROUND(SUM(CASE WHEN o.order_status = 'Returned' THEN i.unit_price * i.quantity ELSE 0 END) *100.00/ SUM (i.unit_price * i.quantity),2) AS percent_rev_lost,
       SUM(CASE WHEN o.order_status = 'Returned' THEN(i.unit_price - p.cost_price)*i.quantity ELSE 0 END) AS profit_lost, 
	   ROUND(SUM(CASE WHEN o.order_status = 'Returned' THEN(i.unit_price - p.cost_price)*i.quantity ELSE 0 END) * 100.00 / SUM((i.unit_price - p.cost_price)*i.quantity),2) AS percent_profit_lost
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id
JOIN orders o 
ON i.order_id = o.order_id
GROUP BY p.category
ORDER BY percent_profit_lost DESC
-- Small Appliances and Fashion Basics category has highest profit leakage due to returns 

-- 28. Which product categories experience the highest average discounting?
-- DISCOUNT % = (Price - Unit Price) / Price * 100
SELECT p.category, 
       AVG((p.price - i.unit_price) * 100.00/p.price ) AS avg_discount_percent
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id 
JOIN orders o 
ON o.order_id = i.order_id
WHERE o.order_status = 'Delivered'
AND i.unit_price < p.price 
GROUP BY p.category
ORDER BY avg_discount_percent DESC
--Small Appliances experience the highest average discounting 

-- SECTION 4 – OPERATIONAL & DELIVERY ANALYSIS

-- 29. Which payment methods have the highest cancellation and return rates?
SELECT payment_type,
       cancelled_orders, 
       ROUND((cancelled_orders / total_orders )* 100.00, 2) AS cancellation_rate, 
       returned_orders, 
       ROUND((returned_orders / total_orders) * 100.00, 2) AS return_rate
FROM (
    SELECT payment_type, 
       COUNT(order_id) AS total_orders,
       SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders, 
       SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders
FROM orders
GROUP BY payment_type
) AS A
ORDER BY cancellation_rate DESC, return_rate DESC
-- COD has highest cancellation and return rate. COD is the also the only payment type that has cancelled orders.

-- 30. Compare delivery performance across different cities.
SELECT c.city, 
       AVG(d.delivery_time) AS avg_delivery_time 
FROM delivery d
JOIN orders o
ON d.order_id = o.order_id
JOIN customers c
On o.customer_id = c.customer_id
WHERE d.delivery_status = 'Delivered'
GROUP BY c.city
ORDER BY avg_delivery_time ASC
-- The average delivery time accross all cities is almost similar. 
-- Pune, Nagpur and Vadodhra has an avg delivery time of 3 days While other cities have 4 days 

-- 31. Compare delivery performance across different product categories.
SELECT p.category, AVG(d.delivery_time) AS avg_delivery_time
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id
JOIN delivery d 
ON i.order_id = d.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY p.category
-- No significant difference is observed among different product categories

-- 32. How do discounts impact profitability across different product categories?
WITH discount_data AS (
SELECT i.item_id, 
       p.category, 
       (((p.price - i.unit_price) * 100.00) /p.price) AS discount_percent,
	   CASE 
	       WHEN (((p.price - i.unit_price) * 100.00) /p.price) > 0 AND (((p.price - i.unit_price) * 100.00) /p.price) <= 20 THEN 'Low'
		   WHEN (((p.price - i.unit_price) * 100.00) /p.price) >20 AND (((p.price - i.unit_price) * 100.00) /p.price)<= 40 THEN 'Mid-level'
		   WHEN (((p.price - i.unit_price) * 100.00) /p.price) > 40 THEN 'High'
		END AS discount_level,
	   i.unit_price * i.quantity AS revenue, 
	   p.cost_price * i.quantity AS COGS
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id
JOIN orders o 
ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
AND i.unit_price < p.price
),
profitability_data AS (
SELECT category, discount_level, 
       ROUND((SUM(revenue) - SUM(COGS)) *100/ SUM(revenue),2) AS profit_margin
FROM discount_data
GROUP BY category, discount_level
)
SELECT category, discount_level,
       CASE
	        WHEN profit_margin >= 40 THEN 'High'
			WHEN profit_margin >=20 AND profit_margin < 40 THEN 'Mid'
			ELSE 'Low'
	  END AS profitability_level, 
	  profit_margin
FROM profitability_data
ORDER BY category ASC, 
		 CASE WHEN discount_level = 'High' THEN 1
		      WHEN discount_level = 'Mid-level' THEN 2 
			  ELSE 3
		 END
-- High to mid-level discounts leads to low profitability across all categories

-- 33. Do delayed deliveries correlate with lower profitability?
SELECT delivery_type, 
	   ROUND((SUM(revenue) - SUM(COGS)) *100.00/ SUM(revenue),2) AS profit_margin
FROM (
	SELECT d.delivery_id ,
	      (i.quantity * i.unit_price) AS revenue, 
	      (i.quantity * p.cost_price) AS COGS, 
	      CASE 
	                WHEN delivery_time <= 3 THEN 'Fast-delivery'
	                WHEN delivery_time > 3 AND delivery_time <=5 THEN 'Standard-delivery'
	                WHEN delivery_time > 5 THEN 'Delayed-delivery'
	        END AS delivery_type
	FROM delivery d 
	JOIN order_items i 
	ON d.order_id = i.order_id
	JOIN products p 
	ON i.product_id = p.product_id
	WHERE d.delivery_status = 'Delivered'
) AS A
GROUP BY delivery_type
-- There is no such evidence that delayed deliverie correlate with lower profitaility. 
-- The profitability is approximately same across all delivery types.

-- 34. How does delivery time vary based on order value?
SELECT CASE 
            WHEN tile = 1 THEN 'High Order Value'
            WHEN tile = 2 THEN 'Mid Order Value'
            WHEN tile = 3 THEN 'Low Order Value'
        END AS order_value_type, 
        AVG(delivery_time) AS avg_delivery_time
FROM(
    SELECT o.order_id, 
        d.delivery_time, 
        NTILE(3) OVER(ORDER BY o.amount DESC) AS tile
    FROM  delivery d 
    JOIN orders o 
    ON d.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
) AS A
GROUP BY CASE 
            WHEN tile = 1 THEN 'High Order Value'
            WHEN tile = 2 THEN 'Mid Order Value'
            WHEN tile = 3 THEN 'Low Order Value'
        END
-- The avg delivery time is consistent across different order value and no correlation is between delivery time and order value

-- 35. Which cities generate the strongest operational performance considering delivery time, returns, and profitability?
WITH delivery_performance AS (
    SELECT c.city, 
           AVG(d.delivery_time) AS avg_delivery_time
    FROM  customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id
    JOIN delivery d 
    ON o.order_id = d.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.city
), 
returns_performance AS(
    SELECT c.city, 
           SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders, 
           COUNT(DISTINCT o.order_id ) AS total_orders, 
           ROUND(SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) *100.00 / COUNT(DISTINCT o.order_id ),2) AS return_rate
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id
    GROUP BY c.city
), 
profitability_performance AS (
    SELECT c.city, 
           ROUND(((SUM(i.quantity *  i.unit_price) - SUM(p.cost_price * i.quantity)) /  SUM(i.quantity *  i.unit_price)) * 100.00, 2) AS profit_margin
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id
    JOIN order_items i 
    ON o.order_id = i.order_id
    JOIN products p 
    ON i.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.city
)
SELECT dp.city, 
       dp.avg_delivery_time, 
       rp.return_rate, 
       pp.profit_margin
FROM delivery_performance dp 
JOIN returns_performance rp 
ON dp.city = rp.city
JOIN profitability_performance pp 
ON rp.city = pp.city
ORDER BY  pp.profit_margin DESC,  rp.return_rate ASC, dp.avg_delivery_time  ASC
-- The top 10 cities with strong operational performance are Indore, Lucknow, Nashik, Nagpur, 
-- Kochi, Vadodara, Mumbai, Bhopal, Pune, Delhi

-- 36. What is the distribution of fast, standard, and delayed deliveries?
SELECT delivery_type, 
       num_deliveries, 
       num_deliveries * 100.00/ SUM(num_deliveries) OVER() AS contribution_percent
FROM(
    SELECT 
            CASE 
                WHEN delivery_time <= 3 THEN 'Fast-delivery'
                WHEN delivery_time > 3 AND delivery_time <=5 THEN 'Standard-delivery'
                WHEN delivery_time > 5 THEN 'Delayed-delivery'
        END AS delivery_type, 
        COUNT(*) AS num_deliveries 
    FROM delivery
    WHERE delivery_status = 'Delivered'
    GROUP BY  CASE 
                WHEN delivery_time <= 3 THEN 'Fast-delivery'
                WHEN delivery_time > 3 AND delivery_time <= 5 THEN 'Standard-delivery'
                WHEN delivery_time > 5 THEN 'Delayed-delivery'
            END
) AS A
--  36.44% of orders are delivered as fast delivery, 15.48% are standard delivery and 48.08% were standard-delivery

-- 37. Which categories experience the highest delayed delivery rates?
SELECT category, 
      COUNT(*) AS total_delivery,
      SUM(CASE WHEN delivery_type = 'Delayed-delivery' THEN 1 ELSE 0 END) AS delayed_deliveries, 
	  ROUND(SUM(CASE WHEN delivery_type = 'Delayed-delivery' THEN 1 ELSE 0 END) *100.00/ COUNT(*),2) AS delayed_delivery_percent 
FROM(
    SELECT p.category, 
        d.delivery_time, 
        CASE 
                    WHEN delivery_time <= 3 THEN 'Fast-delivery'
                    WHEN delivery_time > 3 AND delivery_time <= 5 THEN 'Standard-delivery'
                    WHEN delivery_time > 5 THEN 'Delayed-delivery'
            END AS delivery_type 
    FROM products p 
    JOIN order_items i 
    ON p.product_id = i.product_id 
    JOIN delivery d 
    ON i.order_id = d.order_id
    WHERE d.delivery_status = 'Delivered'
) AS A
GROUP BY category
ORDER BY delayed_delivery_percent DESC

-- 38. How do delivery delays impact customer return behavior?
SELECT CASE 
                WHEN delivery_time <= 3 THEN 'Fast-delivery'
                WHEN delivery_time > 3 AND delivery_time <=5 THEN 'Standard-delivery'
                WHEN delivery_time > 5 THEN 'Delayed-delivery'
        END AS delivery_type, 
        COUNT(*) AS total_orders,
        SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders, 
        ROUND(SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) *100.00/COUNT(*),2) AS return_rate
FROM delivery d 
JOIN orders o 
ON d.order_id = o.order_id
GROUP BY CASE 
                WHEN delivery_time <= 3 THEN 'Fast-delivery'
                WHEN delivery_time > 3 AND delivery_time <=5 THEN 'Standard-delivery'
                WHEN delivery_time > 5 THEN 'Delayed-delivery'
        END
ORDER BY return_rate DESC 
-- Yes delayed deliveries has highest return rate of 23% while othere delivery type has 0 to 1% of return rate

-- SECTION 5 – PROFITABILITY & BUSINESS EFFICIENCY

-- 39. Which product categories generate the highest total profit and profit margins?
SELECT category, 
       profit,
	   RANK() OVER(ORDER BY profit DESC) AS profit_rnk, 
	   profit_margin, 
	   RANK() OVER(ORDER BY profit_margin DESC) AS profit_mrgn_rnk
FROM (
	SELECT p.category, 
	       SUM((i.unit_price - p.cost_price) * i.quantity) AS profit,
	       ROUND(((SUM(i.quantity *  i.unit_price) - SUM(p.cost_price * i.quantity)) /  SUM(i.quantity *  i.unit_price)) * 100.00,2) AS profit_margin   
	FROM products p 
	JOIN order_items i 
	ON p.product_id = i.product_id 
	JOIN orders o 
ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category
) AS A
-- Personal Care, Kitchen Products and are the categories with highest total profit and profit margins

-- 40. How do returns impact monthly profitability trends?
WITH montly_return_rate AS (
    SELECT EXTRACT(YEAR FROM o.order_date) AS order_year, 
           EXTRACT(MONTH FROM o.order_date) AS order_month, 
           COUNT(*) AS total_orders, 
           SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders, 
           ROUND(SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) * 100.00 /  COUNT(*),2) AS return_rate 
    FROM orders o 
    GROUP BY EXTRACT(YEAR FROM o.order_date) , 
             EXTRACT(MONTH FROM o.order_date)
    ORDER BY order_year ASC, order_month ASC
), 
monthly_profitability_rate AS (
    SELECT EXTRACT(YEAR FROM o.order_date) AS order_year, 
           EXTRACT(MONTH FROM o.order_date) AS order_month, 
           ROUND(((SUM(i.quantity *  i.unit_price) - SUM(p.cost_price * i.quantity)) /  SUM(i.quantity *  i.unit_price)) * 100.00 ,2) AS profit_margin
    FROM orders o 
    JOIN order_items i 
    ON o.order_id = i.order_id 
    JOIN products p 
    ON p.product_id = i.product_id
    GROUP BY EXTRACT(YEAR FROM o.order_date) , 
             EXTRACT(MONTH FROM o.order_date)
    ORDER BY order_year ASC, order_month ASC
)
SELECT mrr.order_year, 
       mrr.order_month,
       mrr.return_rate, 
       mpr.profit_margin 
FROM montly_return_rate mrr 
JOIN monthly_profitability_rate mpr 
ON mrr.order_year = mpr.order_year 
AND mrr.order_month = mpr.order_month
ORDER BY mrr.order_year ASC, 
       mrr.order_month ASC

-- 41. Which payment methods are associated with the highest profitability?
SELECT o.payment_type,
       ROUND(((SUM(i.unit_price * i.quantity) - SUM(p.cost_price * i.quantity)) * 100.00)
               / SUM(i.unit_price * i.quantity),2) AS profit_margin 
FROM orders o 
JOIN order_items i 
ON o.order_id = i.order_id 
JOIN products p 
ON i.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY o.payment_type
ORDER BY profit_margin DESC;
-- No significant difference between profitability of different payment methods


-- 42. Compare revenue rankings vs profit rankings across categories.
SELECT p.category, 
       SUM(i.unit_price * i.quantity) AS revenue, 
       RANK() OVER(ORDER BY SUM(i.unit_price * i.quantity) DESC) AS rev_rnk,
	   SUM((i.unit_price - p.cost_price) * i.quantity) AS profit,
	   RANK() OVER(ORDER BY SUM((i.unit_price - p.cost_price) * i.quantity) DESC) AS profit_rnk
FROM products p 
JOIN order_items i 
ON p.product_id = i.product_id 
JOIN orders o 
ON i.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category

-- 43. Which customer segments generate the strongest profit margins?
--Based on repeat and one time customers
SELECT CASE 
            WHEN orders_count > 1 THEN 'repeat'
            ELSE 'one time'
        END AS customer_type, 
        ROUND((SUM(revenue) - SUM(COGS)) *100.00/ SUM(revenue),2) AS profit_margin
FROM (
    SELECT c.customer_id, 
           COUNT(DISTINCT o.order_id) AS orders_count,
           SUM(i.quantity * i.unit_price) AS revenue, 
           SUM(i.quantity * p.cost_price) AS COGS
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id
    JOIN order_items i 
    ON o.order_id = i.order_id
    JOIN products p 
    ON i.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id
) AS A
GROUP BY  CASE 
            WHEN orders_count > 1 THEN 'repeat'
            ELSE 'one time'
          END
-- Repeat and One-time customers have approximately equal profit margins 

-- Based on acquistion date(cohort analyis)
SELECT customer_type, 
       ROUND((SUM(revenue) - SUM(COGS)) *100.00 / SUM(revenue),2) AS profit_margin
FROM (
    SELECT c.customer_id,
           CASE 
                WHEN EXTRACT(YEAR FROM MIN(o.order_date)) = 2025 THEN 'new customer'
                WHEN EXTRACT(YEAR FROM MIN(o.order_date)) = 2024 THEN 'mid cohort customers'
                ELSE 'old customer'
            END AS customer_type, 
            COUNT(DISTINCT o.order_id) AS order_count, 
            SUM(i.unit_price * i.quantity) AS revenue,
            SUM( p.cost_price*i.quantity) AS COGS
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id 
    JOIN order_items i 
    ON o.order_id = i.order_id 
    JOIN products p 
    ON i.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id
) AS A
GROUP BY customer_type
-- Customer from all the cohorts generate almost the same profitability, new customers have a slighly higher profit margin of 60%

-- Based on spending behaviour 
SELECT CASE 
            WHEN per_rnk <= 0.20 THEN 'High Spenders'
            WHEN tile <=0.60 THEN 'Mid Spenders'
            ELSE 'Low Spenders'
        END AS customer_type, 
       ROUND((SUM(revenue) - SUM(COGS)) *100.00 / SUM(revenue),2) AS profit_margin
FROM(
    SELECT c.customer_id, 
        COUNT(DISTINCT o.order_id) as orders, 
        SUM(i.unit_price * i.quantity) AS revenue, 
        SUM(p.cost_price *i.quantity) AS COGS, 
        PERCENT_RANK() OVER( ORDER BY SUM(i.unit_price * i.quantity) DESC) AS per_rnk
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id 
    JOIN order_items i 
    ON o.order_id = i.order_id 
    JOIN products p 
    ON i.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id
    ) AS A
GROUP BY CASE 
            WHEN per_rnk <= 0.20 THEN 'High Spenders'
            WHEN tile <=0.60 THEN 'Mid Spenders'
            ELSE 'Low Spenders'
        END
-- High spenders have the highest profit margin of 59.85%, followed by mid-spenders of 46.78% a
-- Low spenders have the lowest profit margin of 22.93%

-- 44. Which cities contribute the highest profitability?
-- Profit contribution percent
SELECT city, 
       ROUND(profit * 100.00/ SUM(profit) OVER(),2 )AS contribution 
FROM (
    SELECT c.city, 
        SUM((i.unit_price - p.cost_price) * i.quantity) AS profit, 
    FROM customers c 
    JOIN orders o 
    ON c.customer_id = o.customer_id
    JOIN order_items i 
    ON o.order_id = i.order_id
    JOIN products p 
    ON i.product_id = p.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.city
)
ORDER BY contribution DESC
--Banglore has the highest profit cotribution of 31.81% followed by Bhopal wit 14.40% and 
-- then Hyderabad ad Lucknow with approximately 10%

-- Profit margin ranking
SELECT c.city, 
       ROUND(((SUM(i.quantity *  i.unit_price) - SUM(p.cost_price * i.quantity)) /  SUM(i.quantity *  i.unit_price)) * 100.00,2) AS profit_margin   
FROM customers c 
JOIN orders o 
ON c.customer_id = o.customer_id
JOIN order_items i 
ON o.order_id = i.order_id
JOIN products p 
ON i.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city
ORDER BY profit_margin DESC
-- Indore has the highest profit margin of 70.20% followed by Lucknow with 69.07% and Nashik with 69.01%
--Rest cities generate a profit margin between the range of 40 to 65%

-- 45. How does profitability vary across different order value segments?
SELECT CASE 
            WHEN tile = 1 THEN 'High order value'
            WHEN tile = 2 THEN 'Mid order value'
            ELSE 'Low order value'
        END AS order_value_segment, 
        ROUND((SUM(revenue) - SUM(COGS)) * 100.00 / SUM(revenue),2) AS profit_margin
FROM(
    SELECT o.order_id, 
        SUM(i.quantity * i.unit_price) AS revenue, 
        SUM(p.cost_price * i.quantity) AS COGS, 
        NTILE(3) OVER(ORDER BY SUM(i.quantity * i.unit_price) DESC) AS tile 
    FROM orders o 
    JOIN order_items i 
    ON o.order_id = i.order_id
    JOIN products p 
    ON p.product_id = i.product_id
    WHERE o.order_status = 'Delivered'
    GROUP BY o.order_id
) AS A
GROUP BY CASE 
            WHEN tile = 1 THEN 'High order value'
            WHEN tile = 2 THEN 'Mid order value'
            ELSE 'Low order value'
        END 
-- Higher order value shows the most profiability of 68.49%, Mid order value shows 45.47% profitability
-- while low order values shows the least profitaility with 9.61% profit margin

-- 46. Which categories maintain the most stable profit margins over time?
SELECT category, STDDEV(profit_margin) pm_stddev
FROM (
    SELECT p.category, 
        EXTRACT(YEAR FROM o.order_date) AS order_year, 
        EXTRACT(MONTH FROM o.order_date) AS order_month, 
        ROUND(((SUM(i.quantity *  i.unit_price) - SUM(p.cost_price * i.quantity)) /  SUM(i.quantity *  i.unit_price)) * 100.00,2) AS profit_margin   
    FROM products p 
    JOIN order_items i 
    ON p.product_id = i.product_id 
    JOIN orders o 
    ON i.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    GROUP BY p.category, 
            EXTRACT(YEAR FROM o.order_date) , 
            EXTRACT(MONTH FROM o.order_date)
    ORDER BY order_year ASC, order_month ASC
) AS A
GROUP BY category
ORDER BY pm_stddev ASC
-- Personal Category has the most stable profit margin while Small Appliances have the most volatile profit margin
