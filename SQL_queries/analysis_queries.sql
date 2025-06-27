SELECT * FROM orders;

-- top 10 highest revenue generating products

SELECT product_id, SUM(selling_price) AS sales
from orders
GROUP BY product_id
ORDER BY sales DESC;

-- Top 5 highest selling product in each region
WITH cte AS (
SELECT DISTINCT region , product_id , SUM(selling_price) AS sales  
FROM orders
GROUP BY region , product_id
-- ORDER BY region , sales DESC
)
SELECT * 
FROM (
SELECT *
,row_number() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
FROM cte) AS A
WHERE rn <= 5;

-- Month over month growth comparison for 2022 AND 2023 sales
WITH cte AS (
	SELECT YEAR(order_date) AS order_year,month(order_date) AS order_month,SUM(selling_price) AS sales
	FROM orders
	GROUP BY YEAR(order_date),month(order_date)
	ORDER BY YEAR(order_date),month(order_date)
)
SELECT order_month
,SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022
,SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- select ROUND(selling_price,3) 
-- FROM orders
-- ORDER BY CEIL(selling_price) DESC;

ALTER TABLE orders
MODIFY COLUMN order_date DATE;

-- For each catagory which month had highest sales
WITH cte AS (
	 SELECT category,DATE_FORMAT(order_date, '%Y/%m') AS order_year_month,SUM(selling_price) AS sales
	 FROM orders
	 GROUP BY category,order_year_month
	 -- ORDER BY category,order_year_month 
)
SELECT * FROM(
	SELECT * 
	,ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
	FROM cte
)AS A
WHERE rn = 1;

-- which sub_category had highest  growth by profit in 2023 as compared to 2022

with cte as (
select sub_category, year(order_date) as order_year,
sum(selling_price) as sales
from orders
group by sub_category, year(order_date)
-- ordes by year(order_date), month (order_date)
),
cte2 as(
select sub_category
,sum(case when order_year=2022 then sales else 0 end) as sales_2022
,sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select *
,(sales_2023-sales_2022)*100/sales_2022
from cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc;