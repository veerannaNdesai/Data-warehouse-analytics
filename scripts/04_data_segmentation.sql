

--Group customers into three segments based on their spending behaviour
with cte_customers as (
select
c.customer_key,
sum(f.sales_amount) as total_spending,
min(f.order_date) as first_order,
max(f.order_date) as last_order
from 
gold.fact_sales f left join 
gold.dim_customers c on
f.customer_key = c.customer_key
group by c.customer_key
)
select 
case when DATEDIFF(month,first_order,last_order) >= 12 and total_spending > 5000 then 'VIP'
	 when DATEDIFF(month,first_order,last_order) >= 12 and total_spending <= 5000 then 'Regular'
	 else 'New'
end as flag_customer,
sum(1) as flag_count
from
cte_customers
group by case when DATEDIFF(month,first_order,last_order) >= 12 and total_spending > 5000 then 'VIP'
	 when DATEDIFF(month,first_order,last_order) >= 12 and total_spending <= 5000 then 'Regular'
	 else 'New'
end 