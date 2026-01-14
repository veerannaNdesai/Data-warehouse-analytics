

--segment products into cost ranges and
--count how many products fall into each segment

with product_range_table as (
select 
distinct product_name,
product_cost,
case when product_cost between 0 and 100 then 'Below 100'
	when product_cost between 100 and 500 then '100-500'
	when product_cost between 500 and 1000 then '500-1000'
	else 'Above 1000'
end as Product_range
from gold.dim_products)

select 
Product_range,
count(Product_range) as cnt
from product_range_table
group by Product_range;