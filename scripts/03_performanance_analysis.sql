--Performance Analysis
	
	with current_year_sales as (
	select 
	year(f.order_date) order_year,
	p.product_name,
	sum(f.sales_amount) as total_sales
	from
	gold.fact_sales f 
	left join gold.dim_products p
	on f.product_key = p.product_key
	where year(f.order_date) is not null
	group by p.product_name,year(f.order_date)
	)
	select 
	order_year,
	product_name,
	total_sales,
	avg(total_sales) over (partition by product_name) avg_sales,
	total_sales - avg(total_sales) over (partition by product_name) as diff_sales,
	case
		when  total_sales - avg(total_sales) over (partition by product_name) > 0 then 'Above Avg'
		when  total_sales - avg(total_sales) over (partition by product_name) < 0 then 'Below Avg'
		else 'Avg'
	end as flag_sales,
	lag(total_sales) over (partition by product_name order by order_year) as py_sales,
	coalesce(lag(total_sales) over (partition by product_name order by order_year),0) as updated_py_sales
	from 
	current_year_sales
	order by product_name,order_year;