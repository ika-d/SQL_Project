use faasos;

CREATE TABLE driver (
driver_id integer,
reg_date date); 

INSERT INTO driver VALUES (1,'2021-01-01');
INSERT INTO driver VALUES (2,'2021-01-03');
INSERT INTO driver VALUES (3,'2021-01-08');
INSERT INTO driver VALUES (4,'2021-01-15');


CREATE TABLE ingredients (
ingredients_id integer,
ingredients_name varchar(60)); 

INSERT INTO ingredients VALUES (1,'BBQ Chicken');
INSERT INTO ingredients VALUES (2,'Chilli Sauce');
INSERT INTO ingredients VALUES (3,'Chicken');
INSERT INTO ingredients VALUES (4,'Cheese');
INSERT INTO ingredients VALUES (5,'Kebab');
INSERT INTO ingredients VALUES (6,'Mushrooms');
INSERT INTO ingredients VALUES (7,'Onions');
INSERT INTO ingredients VALUES (8,'Egg');
INSERT INTO ingredients VALUES (9,'Peppers');
INSERT INTO ingredients VALUES (10,'Schezwan Sauce');
INSERT INTO ingredients VALUES (11,'Tomatoes');
INSERT INTO ingredients VALUES (12,'Tomato Sauce');


CREATE TABLE rolls (
roll_id integer,
roll_name varchar(30)); 

INSERT INTO rolls VALUES (1	,'Non Veg Roll');
INSERT INTO rolls VALUES (2	,'Veg Roll');


CREATE TABLE roll_recipe (
roll_id integer,
ingredients varchar(24)); 

INSERT INTO roll_recipe VALUES (1,'1,2,3,4,5,6,8,10');
INSERT INTO roll_recipe VALUES (2,'4,6,7,9,11,12');


CREATE TABLE driver_order (
order_id integer,
driver_id integer,
pickup_time datetime,
distance VARCHAR(7),
duration VARCHAR(10),
cancellation VARCHAR(23));


INSERT INTO driver_order VALUES (1,1,'2021-01-01 18:15:34','20km','32 minutes','');
INSERT INTO driver_order VALUES (2,1,'2021-01-01 19:10:54','20km','27 minutes','');
INSERT INTO driver_order VALUES (3,1,'2021-01-03 00:12:37','13.4km','20 mins','NaN');
INSERT INTO driver_order VALUES (4,2,'2021-01-04 13:53:03','23.4','40','NaN');
INSERT INTO driver_order VALUES (5,3,'2021-01-08 21:10:57','10','15','NaN');
INSERT INTO driver_order VALUES (6,3,null,null,null,'Cancellation');
INSERT INTO driver_order VALUES (7,2,'2020-01-08 21:30:45','25km','25mins',null);
INSERT INTO driver_order VALUES (8,2,'2020-01-10 00:15:02','23.4 km','15 minute',null);
INSERT INTO driver_order VALUES (9,2,null,null,null,'Customer Cancellation');
INSERT INTO driver_order VALUES (10,1,'2020-01-11 18:50:20','10km','10minutes',null);


CREATE TABLE customer_order (
order_id integer,
customer_id integer,
roll_id integer,
not_include_items VARCHAR(4),
extra_items_included VARCHAR(4),
order_date datetime);


INSERT INTO customer_order VALUES (1,101,1,'','','2021-01-01 18:05:02');
INSERT INTO customer_order VALUES (2,101,1,'','','2021-01-01 19:00:52');
INSERT INTO customer_order VALUES (3,102,1,'','','2021-01-02 23:51:23');
INSERT INTO customer_order VALUES (3,102,2,'','NaN','2021-01-02 23:51:23');
INSERT INTO customer_order VALUES (4,103,1,'4','','2021-01-04 13:23:46');
INSERT INTO customer_order VALUES (4,103,1,'4','','2021-01-04 13:23:46');
INSERT INTO customer_order VALUES (4,103,2,'4','','2021-01-04 13:23:46');
INSERT INTO customer_order VALUES (5,104,1,null,'1','2021-01-08 21:00:29');
INSERT INTO customer_order VALUES (6,101,2,null,null,'2021-01-08 21:03:13');
INSERT INTO customer_order VALUES (7,105,2,null,'1','2021-01-08 21:20:29');
INSERT INTO customer_order VALUES (8,102,1,null,null,'2021-01-09 23:54:33');
INSERT INTO customer_order VALUES (9,103,1,'4','1,5','2021-01-10 11:22:59');
INSERT INTO customer_order VALUES (10,104,1,null,null,'2021-01-11 18:34:49');
INSERT INTO customer_order VALUES (10,104,1,'2,6','1,4','2021-01-11 18:34:49');


select * from driver;
select * from ingredients;
select * from rolls;
select * from roll_recipe;
select * from driver_order;
select * from customer_order;


# Roll Metrics

# How many rolls were ordered
select count(order_id) as total_rolls_ordered
from customer_order;

# How many unique orders were made
select count(distinct order_id) as unique_orders
from customer_order;

# How many unique customers
select count(distinct customer_id) as unique_customers
from customer_order;

# How many successful orders delivered by each driver
select driver_id, count(order_id) as order_delivered
from driver_order
where duration is not null
group by driver_id;

# How many of each type of roll was delivered
select roll_id, count(roll_id) as num_of_each_roll_delivered
from driver_order d
inner join customer_order c
on d.order_id = c.order_id
where d.duration is not null
group by roll_id;

# How many veg and non-veg rolls were ordered by each customer
select customer_id,
sum(case when roll_id = 1 then 1 else 0 end) as num_of_nonveg,
sum(case when roll_id <> 1 then 1 else 0 end) as num_of_veg
from customer_order
group by customer_id;

# Maximum number of rolls delivered in a single order





