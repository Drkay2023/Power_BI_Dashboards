create database cofee_sales;

use cofee_sales;

select * from coffee_shop_sales;

describe coffee_shop_sales;

alter table coffee_shop_sales
add column transaction_date_new date;

update coffee_shop_sales
set transaction_date_new = str_to_date(transaction_date, '%c/%e/%Y');

alter table coffee_shop_sales
drop column transaction_date;

alter table coffee_shop_sales
change transaction_date_new transaction_date date;

update coffee_shop_sales
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');

alter table coffee_shop_sales
modify column transaction_time time;

select * from coffee_shop_sales;

select round(sum(unit_price * transaction_qty)) as Total_Sales
from coffee_shop_sales
where
-- month(transaction_date) = 5 -- may month
month(transaction_date) = 3; -- march month;

-- selected month / current monbth(CM) - may = 5
-- previous month (PM) -april = 4

select
	month(transaction_date) as month, -- number of month
    round(sum(unit_price * transaction_qty)) as Total_Sales, -- total sales column
    round((sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty), 1) -- month difference(CM - PM)
    over (order by month(transaction_date))) / lag(sum(unit_price * transaction_qty), 1) -- month dfifference / PM
    over (order by month(transaction_date)) * 100) as MoM_increase_percentage -- month dfifference / PM as percentage
from
	coffee_shop_sales
where
	month(transaction_date) in (4,5)
group by
	month(transaction_date)
order by
	month(transaction_date);

-- for total orders

select count(transaction_id) as Total_Orders
from
	coffee_shop_sales
where
	month(transaction_date) = 3; -- march month
    
-- for month over month orders

select
	month(transaction_date) as month, -- number of month
    count(transaction_id) as Total_Orders, -- total orders column
    (count(transaction_id) - lag(count(transaction_id), 1) -- month difference(CM - PM)
    over (order by month(transaction_date))) / lag(count(transaction_id), 1) -- month dfifference / PM
    over (order by month(transaction_date)) * 100 as MoM_increase_percentage -- month dfifference / PM as percentage
from
	coffee_shop_sales
where
	month(transaction_date) in (4,5)
group by
	month(transaction_date)
order by
	month(transaction_date);
    
-- for total quantity sold

select round(sum(transaction_qty)) as Total_Qty_Sold
from coffee_shop_sales
where
month(transaction_date) = 5; -- may month
-- month(transaction_date) = 3; -- march month;

-- for month over month quantity sold

select
	month(transaction_date) as month, -- number of month
    round(sum(transaction_qty)) as Total_Qty_Sold, -- total sales column
    round((sum(transaction_qty) - lag(sum(transaction_qty), 1) -- month difference(CM - PM)
    over (order by month(transaction_date))) / lag(sum(transaction_qty), 1) -- month dfifference / PM
    over (order by month(transaction_date)) * 100) as MoM_increase_percentage -- month dfifference / PM as percentage
from
	coffee_shop_sales
where
	month(transaction_date) in (4,5)
group by
	month(transaction_date)
order by
	month(transaction_date);
    
select
	concat(round(sum(unit_price * transaction_qty)/1000, 1), 'k') as Total_Sales,
    concat(round(sum(transaction_qty)/1000, 1), 'k') as Total_Qty_Sold,
    concat(round(count(transaction_id)/1000, 1), 'k') as Total_Orders
from
	coffee_shop_sales
where
	transaction_date = '2023-03-27';
    
-- weekends - sat & sun
-- weekdays - mon - fri

select
	case when dayofweek(transaction_date) in (1,7) then 'weekends'
    else 'weekdays'
    end as day_type,
    round(sum(unit_price * transaction_qty)) as Total_Sales
from coffee_shop_sales
where month(transaction_date) = 5 -- may
group by
	case when dayofweek(transaction_date) in (1,7) then 'weekends'
    else 'weekdays'
    end;
    
select
	store_location,
    round(sum(unit_price * transaction_qty)) as Total_Sales
from coffee_shop_sales
where month(transaction_date) = 5
group by store_location;


select
	concat(round(avg(Total_Sales)/1000, 1), 'k') as avg_Sales
from
	(
    select 
    sum(unit_price * transaction_qty) as Total_Sales
    from coffee_shop_sales
    where month(transaction_date) = 5
    group by transaction_date
    ) as inner_query;
    

select
	day(transaction_date) as day_of_month,
    concat(round(sum(unit_price * transaction_qty)/1000, 1), 'k') as Total_Sales
from coffee_shop_sales
where month(transaction_date) = 5
group by day(transaction_date)
order by day(transaction_date);

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        -- concat(round(SUM(unit_price * transaction_qty)/1000, 1), 'k') AS total_sales,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
select
	product_category,
    SUM(unit_price * transaction_qty) AS total_sales
FROM 
	coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
	product_category
order by SUM(unit_price * transaction_qty) desc;

-- top ten products

select
	product_type,
    SUM(unit_price * transaction_qty) AS total_sales
FROM 
	coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5 and product_category = 'Coffee' -- Filter for May
GROUP BY 
	product_type
order by SUM(unit_price * transaction_qty) desc
limit 10;

-- total sales in hours and minutes

select
    SUM(unit_price * transaction_qty) AS total_sales,
    sum(transaction_qty) as total_Qty_sold,
    count(*) as total_orders
FROM 
	coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5 -- Filter for May
    and dayofweek(transaction_date) = 1 -- Filter for sunday
    and hour(transaction_time) = 14; -- Filter for 8 hours;

select 
	hour(transaction_time),
    SUM(unit_price * transaction_qty) AS total_sales
    FROM 
	coffee_shop_sales
WHERE 
	MONTH(transaction_date) = 5 -- Filter for May
group by hour(transaction_time)
order by hour(transaction_time) desc;

-- day of wek

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
