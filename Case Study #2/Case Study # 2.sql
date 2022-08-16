DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  /* A. Pizza Metrix */
  
  /* Que. 1*/
  select count(pizza_id) from customer_orders;
  
  /* Que. 2 */
  select count(distinct(customer_id)) from customer_orders;
  
  /* Que. 3 */
  select *,
  case
  when cancellation = "" or cancellation is NULL or cancellation = "null" then "Delivered"
  else "Cancelled"
  end as order_status
  from runner_orders;
  
  select runner_id, count(*) from runner_orders 
  where cancellation = "" or cancellation = "null" or cancellation is NULL
  group by runner_id;
  
  /* Que. 4 */
  select pizza_id, count(*) from customer_orders c
  join runner_orders r on c.order_id = r.order_id 
  where cancellation = "" or cancellation = "null" or cancellation is NULL
  group by pizza_id;
  
 /* Que. 5 */
 select customer_id, pizza_name, count(*) from customer_orders c
 join pizza_names p on c.pizza_id = p.pizza_id
 group by customer_id, pizza_name;
 
  /* select * from customer_orders c
 join pizza_names p on c.pizza_id = p.pizza_id */
 
 /* Que. 6 */
 select c.order_id, count(pizza_id) as pizza_per_order from customer_orders c
 join runner_orders r on c.order_id = r.order_id
 where cancellation = "" or cancellation = "null" or cancellation is NULL
 group by c.order_id order by pizza_per_order desc limit 1;
 
 /* Que. 7 */
  select customer_id, count(*),
  case
  when (exclusions = "" or exclusions = "null") and (extras = "null" or extras is NULL or extras = "") then "No Change"
  else "At least 1 Change"
  end as changes
  from customer_orders c
 join runner_orders r on c.order_id = r.order_id
 where cancellation = "" or cancellation = "null" or cancellation is NULL 
group by customer_id, changes;

/* Que. 8 */
select count(pizza_id) from (
select pizza_id,
  case
  when (exclusions != "" and exclusions != "null") and (extras != "null" and extras is not NULL and extras != "") then "Two type Changes"
  else "1 Type Change or NO Change"
  end as changes
  from customer_orders c
 join runner_orders r on c.order_id = r.order_id
 where cancellation = "" or cancellation = "null" or cancellation is NULL ) nt
 where changes = "Two type Changes";
 
 /*group by changes
 having changes = "Two type Changes" * /
 
 /* Que. 9 */
 select hour(order_time) as order_hour, count(*) as no_of_orders from customer_orders
 group by order_hour;
 
 /* Que. 10 */
 select dayname(order_time) as day_name, count(*) from customer_orders 
 group by day_name;
 
 
 
 
/* B. Runner and Customer Experience */

/* Que. 1 */
select *, week(registration_date,0) as signup_week from runners ;


/* Que. 2 */
with cte_table as (select c.order_id, runner_id, order_time, pickup_time, timestampdiff(minute, order_time, pickup_time) as time_diff from customer_orders c
join runner_orders r on c.order_id = r.order_id
where pickup_time != "null"
group by c.order_id)

select runner_id, avg(time_diff) from cte_table group by runner_id;


/* Que. 3 */
with cte_table as (select c.order_id, count(pizza_id) as pizza_quantity, timestampdiff(minute, order_time, pickup_time) as time_diff from customer_orders c
join runner_orders r on c.order_id = r.order_id
where pickup_time != "null" 
group by c.order_id)

select pizza_quantity, avg(time_diff) from cte_table group by pizza_quantity;

/* Que. 4 */
with cte_table as (select c.order_id, customer_id, replace(distance, "km","") as distance_km from customer_orders c
join runner_orders r on c.order_id = r.order_id
where distance != "null"
group by c.order_id)

select customer_id, round(avg(distance_km),2) from cte_table group by customer_id;

/* Que. 5 */
select max(duration_min) - min(duration_min) as delivery_time_diff from (select *, REGEXP_SUBSTR(duration,"[0-9]+") as duration_min from runner_orders
where duration != "null") nt;

/* Que. 6 */
with cte_table as (select c.order_id, runner_id, replace(distance, "km","") as distance_km, REGEXP_SUBSTR(duration,"[0-9]+") as duration_min from customer_orders c
join runner_orders r on c.order_id = r.order_id
where distance != "null"
group by c.order_id)

select order_id, runner_id, round(distance_km/duration_min,2) as average_speed_per_order from cte_table group by order_id, runner_id;

/* Que. 7 */
