


--commulatative analysis
	select 
	order_date,
	total_sales,
	sum(total_sales) over (partition by order_date order by order_date 
	rows between unbounded preceding and current row) as comm_sales
	from 
	(
	select 
	format(order_date,'yyyy-MMM') as order_date,
	sum(sales_amount) as total_sales
	from gold.fact_sales
	where format(order_date,'yyyy-MMM') is not null
	group by format(order_date,'yyyy-MMM')
	)t;