

--change over time

	select 
	FORMAT(order_date,'yyyy-MMM') as order_date,
	sum(sales_amount) as total_sales,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_quantity
	from gold.fact_sales
	where month(order_date) is not null
	group by FORMAT(order_date,'yyyy-MMM')
	order by FORMAT(order_date,'yyyy-MMM');