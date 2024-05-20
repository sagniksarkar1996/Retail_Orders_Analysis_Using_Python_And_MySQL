#Find top 10 highest reveue generating products 
select product_id,round(sum(sale_price),1) as sales
from orders
group by product_id
order by sales desc 
limit 10;

#Find top 5 highest selling products in each region
with cte as (
select region,product_id,sum(sale_price) as sales
from orders
group by region,product_id)
select * from (
select *
, row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn<=5;

#Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as (
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from orders
group by year(order_date),month(order_date)
order by year(order_date),month(order_date)
	)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month;

#For each category which month had highest sales 
SELECT 
    category,
    order_year_month,
    sales,
    rn
FROM (
    SELECT 
        category,
        DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
        SUM(sale_price) AS sales,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(sale_price) DESC) AS rn
    FROM 
        orders
    GROUP BY 
        category, 
        order_year_month
) AS ranked_sales
WHERE 
    rn = 1;
    
#Which sub category had highest growth by profit percentage in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from orders
group by sub_category,year(order_date)
-- order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select *
,(sales_2023-sales_2022)*100/sales_2022 as profit_percentage
from  cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc limit 1;