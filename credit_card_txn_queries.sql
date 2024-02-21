use credit_card;
select * from txn;

#1 Top 5 cities with highest spends and their percentage contribution of total credit card spends
with cte1 as
(select city, SUM(amount) as city_spend
from txn
group by city)
, cte2 as
(select SUM(amount) as total_credit_card_spends
from txn)
, cte3 as
(select *,
DENSE_RANK() over(order by c1.city_spend desc) drnk
from cte1 c1, cte2 c2)
select city, city_spend, round((city_spend/total_credit_card_spends)*100,2) as percentage_contribution
from cte3
where drnk <= 5;
 
#2 Month with the highest spend and amount spent in that month for each card type
with cte1 as
(select YEAR(transaction_date) as trans_year
, MONTH(transaction_date) as trans_month
, SUM(amount) as total_amount
from txn
group by YEAR(transaction_date), MONTH(transaction_date)
order by total_amount desc
limit 1)
select card_type, YEAR(transaction_date) as trans_year
, MONTH(transaction_date) as trans_month, SUM(amount) as total_spend
from txn
where YEAR(transaction_date) in (select trans_year from cte1)
and MONTH(transaction_date) in (select trans_month from cte1)
group by card_type, YEAR(transaction_date), MONTH(transaction_date);

#3 Transaction details for each card type when it reaches a cumulative of 1000000 total spends
with cte1 as
(select *
, SUM(amount) over(partition by card_type order by transaction_date, transaction_id) as cum_amt
from txn)
, cte2 as
(select *
, DENSE_RANK() over(partition by card_type order by cum_amt) as drnk
from cte1
where cum_amt >= 1000000)
select * 
from cte2
where drnk = 1;

# Alternate Solution (using LAG Window FUNCTION)
with cte1 as
(select *
, SUM(amount) over(partition by card_type order by transaction_date, transaction_id) as cum_amt
from txn)
, cte2 as
(select *
, LAG(cum_amt, 1) over(partition by card_type order by transaction_date, transaction_id) as prev_cum_amt
from cte1)
select * 
from cte2
where cum_amt >= 1000000 and prev_cum_amt < 1000000;

#4 City which had lowest percentage spend for gold card type
with cte1 as
(select city
, SUM(amount) as total_amt
, SUM(case when card_type = 'Gold' then amount end) as gold_card_amt
from txn
group by city)
select city, round((gold_card_amt/total_amt)*100,2) as per_spend
from cte1
where gold_card_amt > 0
order by per_spend
limit 1;

#5 write a query to print 3 columns: city, highest_expense_type, lowest_expense_type
with cte1 as
(select city, exp_type, SUM(amount) as total_amt 
from txn
group by city, exp_type)
, cte2 as
(select *
, DENSE_RANK() over(partition by city order by total_amt) as drnk_lowest
, DENSE_RANK() over(partition by city order by total_amt desc) as drnk_highest
from cte1)
select city
, MAX(case when drnk_highest = 1 then exp_type end) as highest_expense_type
, MAX(case when drnk_lowest = 1 then exp_type end) as lowest_expense_type
from cte2
group by city;

#6 Find percentage contribution of spends by females for each expense type
select exp_type
, SUM(amount) as total_exp_type_amt
, SUM(case when gender = 'F' then amount end) as female_contribution
, round(SUM(case when gender = 'F' then amount end)/SUM(amount)*100,2) as per_contribution
from txn
group by exp_type
order by per_contribution;

#7 which card and expense type combination saw the highest month over month growth in Jan 2014
with cte1 as
(select YEAR(transaction_date) as trans_year
, MONTH(transaction_date) as trans_month
, card_type, exp_type, SUM(amount) as total_amt
from txn
group by YEAR(transaction_date), MONTH(transaction_date), card_type, exp_type)
, cte2 as
(select * 
, LAG(total_amt, 1) over(partition by card_type, exp_type order by trans_year, trans_month) as prev_trans_amt
from cte1)
select *, round(((total_amt - prev_trans_amt)/prev_trans_amt*100),2) as mom_growth 
from cte2
where trans_year = '2014' and trans_month = '1'
order by mom_growth desc
limit 1;

#8 which city has highest total spend to total no of transcations ratio during weekends 
select city, round(SUM(amount)/COUNT(1)) as ratio
from txn
where WEEKDAY(transaction_date) in ('1', '7')
group by city
order by ratio desc
limit 1;

#9 which city took least number of days to reach its 500th transaction after the first transaction in that city
with cte1 as
(select city
from txn
group by city
having COUNT(1) >= 500)
, cte2 as
(select * 
, ROW_NUMBER() over(partition by city order by transaction_date, transaction_id) as rn
from txn
where city in (select city from cte1))
, cte3 as
(select city, MIN(transaction_date) as first_trans_date, MAX(transaction_date) as five_hundredth_trans_date
from cte2
where rn <= 500
group by city)
select *, DATEDIFF(five_hundredth_trans_date, first_trans_date) as diff_no_of_days 
from cte3
order by diff_no_of_days
limit 1;