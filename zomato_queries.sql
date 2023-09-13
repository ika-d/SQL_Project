use zomato;

CREATE TABLE goldusers_signup (
userid integer,
gold_signup_date date); 

INSERT INTO goldusers_signup VALUES (1,'2017-09-22');
INSERT INTO goldusers_signup VALUES (3,'2017-04-21');

CREATE TABLE users (
userid integer,
signup_date date);

INSERT INTO users VALUES (1,'2014-09-02');
INSERT INTO users VALUES (2,'2015-01-15');
INSERT INTO users VALUES (3,'2014-04-11');

CREATE TABLE sales (
userid integer,
created_date date,
product_id integer);

INSERT INTO sales VALUES (1,'2017-04-19',2);
INSERT INTO sales VALUES (3,'2019-12-18',1);
INSERT INTO sales VALUES (2,'2020-07-20',3);
INSERT INTO sales VALUES (1,'2019-10-23',2);
INSERT INTO sales VALUES (1,'2018-03-19',3);
INSERT INTO sales VALUES (3,'2016-12-20',2);
INSERT INTO sales VALUES (1,'2016-11-09',1);
INSERT INTO sales VALUES (1,'2016-05-20',3);
INSERT INTO sales VALUES (2,'2017-09-24',1);
INSERT INTO sales VALUES (1,'2017-03-11',2); 
INSERT INTO sales VALUES (1,'2016-03-11',1);
INSERT INTO sales VALUES (3,'2016-11-10',1); 
INSERT INTO sales VALUES(3,'2017-12-07',2);
INSERT INTO sales VALUES (3,'2016-12-15',2); 
INSERT INTO sales VALUES (2,'2017-11-08',2);
INSERT INTO sales VALUES (2,'2018-11-08',3);

CREATE TABLE product (
product_id integer,
product_name text,
price integer);

INSERT INTO product VALUES (1,'p1',980);
INSERT INTO product VALUES (2,'p2',870);
INSERT INTO product VALUES (3,'p3',330);

select * from goldusers_signup;
select * from product;
select * from sales;
select * from users;


# Total amount spent by each customer
select s.userid, sum(p.price) as total_amount_spent
from sales s
inner join product p
on s.product_id = p.product_id
group by s.userid;


# Number of visits to the website by each customer
select userid, count(distinct created_date) as num_of_visit
from sales
group by userid;


# First product purchased by each customer
with cte as
(select *,
rank() over(partition by userid order by created_date) as rnk
from sales)

select *
from cte
where rnk = 1;


# Most purchased product on the menu and number of times was it purchased by each customer
select product_id
from sales 
group by product_id
order by count(product_id) desc
limit 1;


select userid, count(product_id) as count_of_purchase
from sales
where product_id = (
select product_id
from sales 
group by product_id
order by count(product_id) desc
limit 1)
group by userid
order by 1;


# Most popular item for each customer
with cte1 as
(select userid, product_id, count(product_id) as purchase_count
from sales
group by userid, product_id),

cte2 as
(select *,
rank() over(partition by userid order by purchase_count desc) as rnk
from cte1)

select *
from cte2
where rnk = 1;


# First product purchased by each customer after becoming a member
with cte1 as
(select s.*, g.gold_signup_date 
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and s.created_date >= g.gold_signup_date),

cte2 as
(select *,
rank() over(partition by userid order by created_date) as rnk
from cte1)

select userid, product_id
from cte2
where rnk = 1;


# Last product purchased by each customer before becoming a member
with cte1 as
(select s.*, g.gold_signup_date 
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and s.created_date <= g.gold_signup_date),

cte2 as
(select *,
rank() over(partition by userid order by created_date desc) as rnk
from cte1)

select userid, product_id
from cte2
where rnk = 1;


# Total number of orders and amount spent by each customer before becoming member
with cte1 as
(select s.*, g.gold_signup_date 
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and s.created_date <= g.gold_signup_date),

cte2 as
(select c1.*, p.price
from cte1 as c1
inner join product p
on c1.product_id = p.product_id)

select userid, count(created_date) as num_of_orders, sum(price) as amount_spent
from cte2
group by userid
order by 1;


# Suppose, buying each product generates purchasing points (5 Rs = 2 Zomato points)
# e.g. 5 Rs spent on p1 generates 1 Zomato point, for p2 10 Rs = 5 Zomato points and for p3 5 Rs = 1 Zomato point
# Calculate points collected by each customer 

with cte1 as
(select s.*, p.price
from sales s
inner join product p
on s.product_id = p.product_id),

cte2 as
(select c1.userid, c1.product_id, sum(price) as amount_spent
from cte1 c1
group by c1.userid, c1.product_id
order by 1),

cte3 as
(select *,
case when product_id = 1 then 5 
when product_id = 2 then 2 
when product_id = 3 then 5 else 0 end as points
from cte2 as c2),

cte4 as
(select *, round(amount_spent/points, 0) as points_earned
from cte3)

select userid, sum(points_earned) as points_earned_by_each_customer, sum(points_earned)*2.5 as total_cashback_earned
from cte4
group by userid;


# For which product most points have been given till now
with cte1 as
(select s.*, p.price
from sales s
inner join product p
on s.product_id = p.product_id),

cte2 as
(select c1.userid, c1.product_id, sum(price) as amount_spent
from cte1 c1
group by c1.userid, c1.product_id
order by 1),

cte3 as
(select *,
case when product_id = 1 then 5 
when product_id = 2 then 2 
when product_id = 3 then 5 else 0 end as points
from cte2 as c2),

cte4 as
(select *, round(amount_spent/points, 0) as points_earned
from cte3)

select product_id, sum(points_earned) as points_earned_by_each_product
from cte4
group by product_id
order by 2 desc;


# In the first year after a customer joins the Gold program (including their join date), irrespective of what product the customer has purchased, they earn 5 zomato points  for every 10 Rs spent
# Who earned more between 1 and 3 and how much points had they earned in the first year
with cte as
(select s.*, g.gold_signup_date 
from sales s
inner join goldusers_signup g
on s.userid = g.userid
and s.created_date >= g.gold_signup_date
and s.created_date <= adddate(g.gold_signup_date, 365))

select c.*, p.price, p.price*0.5 as total_points_earned
from cte c
inner join product p
on c.product_id = p.product_id;


# Rank all the transactions of the customers
select *,
rank() over(partition by userid order by created_date) as rnk
from sales;


# Rank all the transactions for each Gold member and for each non-gold member transactions display N/A
with cte as
(select s.*, g.gold_signup_date
from sales s
left join goldusers_signup g
on s.userid = g.userid
and s.created_date >= g.gold_signup_date)

select *, 
case when gold_signup_date is null then 'N/A' else rank() over(partition by userid order by created_date desc) end as rnk
from cte;


