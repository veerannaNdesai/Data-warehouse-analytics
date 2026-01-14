

--which category is contributing the most over the entire sales
use datawarehouse

with cw_sales as(
select 
p.product_category,
sum(f.sales_amount)  pw_sale
from gold.fact_sales f
left join gold.dim_products p on
f.product_key = p.product_key
group by p.product_category)
select 
product_category,
pw_sale,
sum(pw_sale) over() total_sale,
concat(round(((cast(pw_sale as float)/sum(pw_sale) over())*100),2),'%') as percent_sale
from cw_sales
order by pw_sale desc;