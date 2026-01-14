use datawarehouse
/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================

if object_id('gold.report_products','v') is not null
	drop view gold.report_products;
go

create view gold.report_products as
with base_query as (
select 
f.order_number,
f.order_date,
f.quantity,
f.sales_amount,
f.customer_key,
p.category_id,
p.product_id,
p.product_key,
p.product_number,
p.product_name,
p.product_cost,
p.product_category,
p.product_subcategory,
p.product_startdate
from 
gold.fact_sales f left join
gold.dim_products p on
f.product_key = p.product_key
where f.order_date is not null
),product_aggregation as (
select 
product_key,
product_name,
product_cost,
product_category category,
product_subcategory subcategory,
max(order_date) as latest_order,
count(distinct order_number) as total_orders,
sum(sales_amount) as total_sales,
count(distinct customer_key) total_customers,
DATEDIFF(month,min(order_date),max(order_date)) as lifespan
from base_query
group by product_key,
product_name,
product_cost,
product_category,
product_subcategory
)
select 
product_key,
product_name,
product_cost,
category,
subcategory,
total_orders,
CASE
	WHEN total_sales > 50000 THEN 'High-Performer'
	WHEN total_sales >= 10000 THEN 'Mid-Range'
	ELSE 'Low-Performer'
END AS product_segment,
total_customers,
lifespan,
datediff(month,latest_order,getdate()) as recency,
total_sales/total_orders as avg_order_revenue,
total_sales/lifespan as avg_monthly_revenue
from product_aggregation;