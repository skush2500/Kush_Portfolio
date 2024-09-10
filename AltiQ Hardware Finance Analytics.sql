Use gdb0041;

SELECT * FROM gdb0041.fact_sales_monthly;
select distinct platform from dim_customer;

Select * from dim_customer;

Select * from dim_product;

# division-->segment-->Category-->Product-->Variant

# Task 1: Create report for CROM India Customer

Select * from dim_customer
where customer like "%croma%";

select * from fact_sales_monthly 
where 
	customer_code = 90002002
	and get_fiscal_year(date) = 2021
    and get_fiscal_quarter(date) = "Q4"
order by date;

# retrieve product and variant

select * from dim_product;

select 
	s.date, s.product_code, p.product, p.variant, 
    s.sold_quantity, 
    g.gross_price,
    g.gross_price*s.sold_quantity as gross_price_total
    from fact_sales_monthly as s 
JOIN dim_product as p
on p.product_code = s.product_code
join fact_gross_price as g
on 
	g.product_code = s.product_code 
    and g.fiscal_year = get_fiscal_year(s.date)
where
	customer_code = 90002002
	and get_fiscal_year(date) = 2021
order by date;

# CROM (Customer of AltiQ) monthly total sales
select s.date, SUM(g.gross_price*s.sold_quantity) as gross_price_total
from fact_sales_monthly as s
JOIN fact_gross_price as g ON
	g.product_code = s.product_code and
    g.fiscal_year=get_fiscal_year(s.date)
where customer_code = 90002002
Group by s.date
order by s.date asc;

select
            get_fiscal_year(date) as fiscal_year,
            sum(round(sold_quantity*g.gross_price,2)) as yearly_sales
	from fact_sales_monthly s
	join fact_gross_price g
	on 
	    g.fiscal_year=get_fiscal_year(s.date) and
	    g.product_code=s.product_code
	where
	    customer_code=90002002
	group by get_fiscal_year(date)
	order by fiscal_year;

# Store Procedure

call gdb0041.get_monthly_gross_sales_for_customer(90002002);

Select sum(sold_quantity) as total_qty from fact_sales_monthly as s
join dim_customer c
on s.customer_code = c.customer_code
where get_fiscal_year(s.date) = 2021 and c.market = "India"
group by c.market;

# Store Procedure
set @out_badge = '0';
call gdb0041.get_market_badge('Indonesia', 2020, @out_badge);
select @out_badge;

	

