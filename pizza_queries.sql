use pizza_db;
select count(*) from pizza_data;

select * from pizza_data;

#KPIs
#1
select sum(total_price) Total_Revenue from pizza_data;

#2
select sum(total_price) / count(distinct order_id) Avg_Order_Value from pizza_data;

#3
select sum(quantity) Total_Pizzas_Sold from pizza_data;

#4
select count(distinct order_id) Total_Orders from pizza_data;

#5
select cast(sum(quantity) as decimal(10,2)) / cast(count(distinct order_id) as decimal(10,2)) 
from pizza_data;

select cast(cast(sum(quantity) as decimal(10,2)) / cast(count(distinct order_id) as decimal(10,2)) as decimal(10,2)) Avg_Pizza_per_Order 
from pizza_data;


#For Charts
#1
select pizza_category, sum(total_price) Total_sales, 
round(sum(total_price)*100 / (select(sum(total_price)) from pizza_data), 2) as Total_Sales_Percent
from pizza_data
group by pizza_category;


#2
select pizza_size, sum(total_price) Total_sales, 
round(sum(total_price)*100 / (select(sum(total_price)) from pizza_data),2)Total_Sales_Percent
from pizza_data
group by pizza_size;


#3
select pizza_category, sum(quantity) Total_Pizzas_Sold
from pizza_data
group by pizza_category;


#4
select pizza_name, sum(quantity) Total_Pizzas_Sold
from pizza_data
group by pizza_name
order by Total_Pizzas_Sold desc
limit 5;


#5
select pizza_name, sum(quantity) Total_Pizzas_Sold
from pizza_data
group by pizza_name
order by Total_Pizzas_Sold
limit 5;






