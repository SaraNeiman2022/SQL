/* This project uses a modified set of tables based on the 'Zomato' data set
provided by Ashutosh Kumar's YouTube video which can be found here:

https://www.youtube.com/watch?v=BlN4U7GF704&list=LL&index=2&ab_channel=AshutoshKumar

Insert statements were derived from SQL scripts provided in the above video's description. */

/* Create tables*/

DROP TABLE IF EXISTS goldusers_signup;
CREATE TABLE `goldusers_signup` (
   `userid` int DEFAULT NULL,
   `gold_signup_date` date DEFAULT NULL
 );

DROP TABLE IF EXISTS product;
CREATE TABLE `product` (
   `product_id` int DEFAULT NULL,
   `product_name` text,
   `price` int DEFAULT NULL
 );
 
 DROP TABLE IF EXISTS sales;
 CREATE TABLE `sales` (
   `userid` int DEFAULT NULL,
   `created_date` date DEFAULT NULL,
   `product_id` int DEFAULT NULL
 );
 
  DROP TABLE IF EXISTS users;
 CREATE TABLE `users` (
   `userid` int DEFAULT NULL,
   `signup_date` date DEFAULT NULL
 )
 
 /* Data analysis and findings */
 
-- what is the total amount each customer spent?
SELECT userid, SUM(p.price)
FROM sales s 
JOIN product p
on s.product_id = p.product_id
group by userid;

-- How many days has each customer visited ZOMATO?
SELECT userid, COUNT(distinct created_date)
FROM sales 
GROUP BY userid;

-- what was the first product purchased by each customer?
SELECT * FROM
(SELECT *, rank() over (partition by userid order by created_date) as rnk from sales) okay
WHERE rnk =1
;

-- What is the most purchased item and how many times it was purchased by each customer?
Select userid, count(product_id) 
From sales 
Where product_id = 
	(Select product_id
	From sales 
	group by 1
	order by count(product_id) desc
	limit 1)
Group by userid;

-- which item was most pooular for each customer?
select * from
(select *, rank() over(partition by userid order by cnt desc) rnk 
From 
	(Select userid, product_id, count(product_id) as cnt
	from sales 
	group by 1,2) Temp) Temp2
where rnk=1;
    