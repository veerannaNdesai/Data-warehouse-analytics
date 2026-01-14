/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================

--Gathers essential fields such as names, ages, and transaction details.

if OBJECT_ID('gold.report_customers','V') is not null
	drop view gold.report_customers;
go

create view gold.report_customers as

with base_query as(
select 
f.order_number,
f.product_key,
f.sales_amount,
f.order_date,
f.quantity,
p.customer_key,
p.customer_number,
p.gender,
concat(p.first_name,' ',
p.last_name) as customer_name,
DATEDIFF(year,p.birthdate,getdate()) as age
from 
gold.fact_sales f 
left join gold.dim_customers p
on f.customer_key = p.customer_key
where f.order_date is not null)
, customer_aggregation as( 
select 
customer_key,
customer_number,
gender,
customer_name,
age,
max(order_date) as last_order_date,
count(distinct order_number) total_orders,
sum(sales_amount) total_sales,
sum(quantity) total_quantity,
count(distinct product_key) as total_products,
DATEDIFF(month,min(order_date),max(order_date)) as lifespan,
DATEDIFF(month,max(order_date),getdate()) as recency
from base_query
group by 
customer_key,
customer_number,
gender,
customer_name,
age)
select
customer_key,
customer_number,
gender,
customer_name,
age,
CASE 
	 WHEN age < 20 THEN 'Under 20'
	 WHEN age between 20 and 29 THEN '20-29'
	 WHEN age between 30 and 39 THEN '30-39'
	 WHEN age between 40 and 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
CASE 
    WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
    WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
    ELSE 'New'
END AS customer_segment,
total_orders,
total_sales,
total_quantity,
lifespan,
recency,
case 
    when total_orders = 0 then 0
	else total_sales / total_orders 
end as avg_order_value,
case 
	when lifespan = 0 then total_sales
	else total_sales/lifespan
end as avg_monthly_spends
from customer_aggregation;