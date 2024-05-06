SELECT * FROM df_orders;

-- 1st question
-- find top 10 highest reveue generating products

SELECT category, product_id, truncate(SUM(sale_price), 1) as sales
FROM df_orders
GROUP BY product_id, category
ORDER BY SUM(sale_price) DESC
LIMIT 10;

-- 2nd questions
-- find top 5 highest selling products in each region

with cte as (
SELECT region, product_id, TRUNCATE(SUM(sale_price),2) as sales
FROM df_orders
GROUP BY region,product_id),
new_cte as(
Select *,
row_number() OVER(partition by region order by sales desc)as rn
from cte)
Select * from new_cte
Where rn <=5;

-- 3rd question
-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte as (
SELECT YEAR(order_date) as order_year, 
month(order_date) as order_month, sum(sale_price) as sales
from df_orders
GROUP BY YEAR(order_date), month(order_date)
order by YEAR(order_date), month(order_date)
)
SELECT order_month,
truncate(sum(case when order_year=2022 then sales else 0 end),2) as sales_2022,
truncate(sum(case when order_year=2023 then sales else 0 end),2) as sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- 4th questions
-- for each category which month had highest sales 

with cte as
(SELECT category, MONTHNAME(order_date) as month, YEAR(order_date) as year, TRUNCATE(SUM(sale_price),2) as sales
FROM df_orders
GROUP BY category, MONTHNAME(order_date),YEAR(order_date)
Order By month, sales DESC),
n_cte as(
SELECT *,
row_number() OVER (PARTITION BY category ORDER BY sales DESC) as rn
FROM cte
)
SELECT * FROM n_cte
WHERE rn =1;

-- 5th question
-- which sub category had highest growth by profit in 2023 compare to 2022

with cte as (
SELECT sub_category, YEAR(order_date) as order_year, sum(sale_price) as sales
from df_orders
GROUP BY sub_category, YEAR(order_date)
order by YEAR(order_date)
),
n_cte as (
SELECT sub_category,
truncate(sum(case when order_year=2022 then sales else 0 end),2) as sales_2022,
truncate(sum(case when order_year=2023 then sales else 0 end),2) as sales_2023
FROM cte
GROUP BY sub_category
)
SELECT *, truncate((sales_2023 - sales_2022)*100/sales_2022,2) as YOY_growth
FROM n_cte
ORDER BY YOY_growth DESC
LIMIT 1;