CREATE TABLE SALES1 (
  CUSTOMER_ID VARCHAR(1),
  ORDER_DATE DATE,
  PRODUCT_ID INTEGER
);

INSERT INTO SALES1 VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE MENU1 (
  PRODUCT_ID INTEGER,
  PRODUCT_NAME VARCHAR(5),
  PRICE INTEGER
);

INSERT INTO MENU1 VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE MEMBERS1 (
  CUSTOMER_ID VARCHAR(1),
  JOIN_DATE DATE
);

INSERT INTO MEMBERS1 VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
/* Que 1.*/

select customer_id, sum(price) from sales1 s join menu1 m
on s.product_id = m.product_id
group by customer_id;

/* Que 2*/

select customer_id, count(distinct(order_date)) from sales1 group by customer_id;

/* Que. 3*/

with cte_table as (select customer_id, min(order_date) as fod from sales1 group by customer_id) 
select s.customer_id, m.product_name from sales1 s join cte_table ct
on s.customer_id = ct.customer_id
join menu1 m 
on m.product_id = s.product_id
where s.order_date = ct.fod;

/* Que. 4*/

select product_name, count(*) as max_sold from sales1 s
join menu1 m 
on m.product_id = s.product_id
group by product_name
order by max_sold desc limit 1;

/* Que 5 */

with cte_table as (select customer_id, product_id, count(product_id) as product_sales from sales1 
 group by customer_id, product_id ) 

select customer_id, product_id, max(product_sales) from cte_table
group by customer_id;


/* Que 6 and 7*/

with cte_tabel as (
select s.customer_id, me.product_name, s.order_date,
dense_rank()  over(partition by s.customer_id order by s.order_date desc) as rk
from sales1 s
join menu1 me on s.product_id = me.product_id
join members1 m on m.customer_id = s.customer_id
where s.order_date<m.join_date ) 

/* Que 8 */
select s.customer_id, count(s.product_id), sum(me.price) from sales1 s 
left join members1 m on m.customer_id = s.customer_id
left join menu1 me on me.product_id = s.product_id
where s.order_date<m.join_date or m.join_date is NULL
group by s.customer_id;


/* Que 9*/
select s.customer_id, sum(
case
when product_name = "sushi" then (price*20)
else (price*10)  
end )as points
from sales1 s
join menu1 m on s.product_id = m.product_id
group by s.customer_id;

/* Que 10 */

with cte_table as (select s.CUSTOMER_ID, ORDER_DATE, PRODUCT_NAME, PRICE, JOIN_DATE, date_add(join_date, interval 6 day) as required_date, month(order_date) as month_no
from sales1 s 
left join members1 m on m.customer_id = s.customer_id
join menu1 me on me.product_id = s.product_id)

select customer_id, sum(
case
when order_date>=join_date and order_date<=required_date then price*20
when product_name = "sushi" then price*20
else price*10
end) as points
from cte_table
where month_no = 1
group by customer_id;

/* Que 1 Bonus */
select s.customer_id, order_date, product_name, price,
case
when order_date>=join_date then "Y"
else "N"
end as memeber_status
from sales1 s 
left join members1 m on m.customer_id = s.customer_id
join menu1 me on me.product_id = s.product_id;

/* Que 2 Bonus */
with cte_table as (
select s.customer_id, order_date, product_name, price,
case
when order_date>=join_date then "Y"
else "N"
end as member_status
from sales1 s 
left join members1 m on m.customer_id = s.customer_id
join menu1 me on me.product_id = s.product_id)

select *,
case 
when member_status = "Y" then dense_rank() over (partition by customer_id, member_status order by order_date) 
else "NULL" 
end as ranking
from cte_table;


