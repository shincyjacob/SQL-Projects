
SHOW FIELDS FROM orders FROM parch_posey; -- Check field type 

USE parch_posey;

-- Write a query to return the 10 earliest orders in the orders table. Include the id, occurred_at, and total_amt_usd.
	SELECT id, occurred_at, total_amt_usd
	FROM orders
	ORDER BY occurred_at
	LIMIT 10;

-- Write a query to return the top 5 orders in terms of largest total_amt_usd. Include the id, account_id, and total_amt_usd.
	SELECT id, account_id, total_amt_usd
	FROM orders
	ORDER BY total_amt_usd DESC 
	LIMIT 5;

-- Write a query to return the lowest 20 orders in terms of smallest total_amt_usd. Include the id, account_id, and total_amt_usd.
	SELECT id, account_id, total_amt_usd
	FROM orders
	ORDER BY total_amt_usd
	LIMIT 20;

SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id;

-- Pulls the first 10 rows and all columns from the orders table that have a total_amt_usd less than 500.
	SELECT *
	FROM orders
	WHERE total_amt_usd < 500
	LIMIT 10;

-- Filter the accounts table to include the company name, website, and the primary point of contact just for the Exxon Mobil company.
SELECT name, website, primary_poc
FROM accounts
WHERE name = 'Exxon Mobil';

-- Find the unit price for standard paper for each order. Limit the results to the first 10 orders, and include the id and account_id fields.
	SELECT id, account_id, round(standard_amt_usd/standard_qty,2) AS unit_price
	FROM orders
	LIMIT 10;

-- Write a query that finds the percentage of revenue that comes from poster paper for each order.
	SELECT id, account_id, round((poster_amt_usd/(standard_amt_usd + gloss_amt_usd + poster_amt_usd))*100,2) AS poster_per
	FROM orders
	LIMIT 10;

-- Find the account name, primary_poc, and sales_rep_id for Walmart, Target, and Nordstrom.
	SELECT name, primary_poc, sales_rep_id
	FROM accounts
	WHERE name IN ('Walmart' , 'Target', 'Nordstrom');

-- Find all information regarding individuals who were contacted via any method except using organic or adwords methods.
	SELECT *
	FROM web_events
	WHERE channel NOT IN ('organic', 'adwords');

-- Find all information regarding individuals who were contacted via the organic or adwords channels, and started their account at any point in 2016, sorted from newest to oldest.
	SELECT *
	FROM web_events
	WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
	ORDER BY occurred_at DESC;


#Joins
-- Provide a table for all the for all web_events associated with account name of Walmart.
	SELECT a.primary_poc, w.occurred_at, w.channel, a.name
	FROM web_events w
	JOIN accounts a
	ON w.account_id = a.id
	WHERE a.name = 'Walmart';

-- Provide a table that provides the region for each sales_rep along with their associated accounts. 
	SELECT r.name region, s.name rep, a.name account
	FROM sales_reps s
	JOIN region r
	ON s.region_id = r.id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	ORDER BY a.name;
    
-- Provide the name for each region for every order, as well as the account name and the unit price they paid for the order. 
	SELECT r.name region, a.name account, round(o.total_amt_usd/o.total,2) unit_price
	FROM region r
	JOIN sales_reps s
	ON s.region_id = r.id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id = a.id;

-- Provide a table that provides the region for each sales_rep along with their associated accounts. 
-- This time only for accounts where the sales rep has a last name starting with K and in the Midwest region. 
	SELECT r.name region, s.name rep, a.name account
	FROM sales_reps s
	JOIN region r
	ON s.region_id = r.id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	WHERE r.name = 'Midwest' AND s.name LIKE '% K%'
	ORDER BY a.name;

-- Provide the name for each region for every order, as well as the account name and the unit price they paid for the order. 
-- However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. 

	SELECT r.name region, a.name account, round(o.total_amt_usd/o.total,2) unit_price
	FROM region r
	JOIN sales_reps s
	ON s.region_id = r.id
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id = a.id
	WHERE o.standard_qty > 100 AND o.poster_qty > 50
	ORDER BY unit_price DESC;

-- Find all the orders that occurred in 2015. 
	SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
	FROM accounts a
	JOIN orders o
	ON o.account_id = a.id
	WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
	ORDER BY o.occurred_at DESC;
    

# Aggregation
-- Find the total dollar amount of sales using the total_amt_usd in the orders table.
	SELECT SUM(total_amt_usd) AS total_dollar_sales
	FROM orders;

-- Find the total amount for each individual order that was spent on standard and gloss paper in the orders table. This should give a dollar amount for each order in the table.
	SELECT standard_amt_usd + gloss_amt_usd AS total_standard_gloss
	FROM orders;

-- Find the standard_amt_usd per unit of standard_qty paper. 
	SELECT round(SUM(standard_amt_usd)/SUM(standard_qty),3) AS standard_price_per_unit
	FROM orders;

-- When was the earliest order ever placed?
	SELECT MIN(occurred_at) 
	FROM orders;

-- When did the most recent (latest) web_event occur?
	SELECT MAX(occurred_at)
	FROM web_events;

-- Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order. 
	SELECT AVG(standard_qty) mean_standard, AVG(gloss_qty) mean_gloss, 
			   AVG(poster_qty) mean_poster, AVG(standard_amt_usd) mean_standard_usd, 
			   AVG(gloss_amt_usd) mean_gloss_usd, AVG(poster_amt_usd) mean_poster_usd
	FROM orders;
    
-- Which account (by name) placed the earliest order? 
	SELECT a.name, o.occurred_at
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	ORDER BY occurred_at
	LIMIT 1;

-- Find the total sales in usd for each account. 
	SELECT a.name, round(SUM(total_amt_usd),2) total_sales
	FROM orders o
	JOIN accounts a
	ON a.id = o.account_id
	GROUP BY a.name;

-- Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? 
	SELECT w.occurred_at, w.channel, a.name
	FROM web_events w
	JOIN accounts a
	ON w.account_id = a.id 
	ORDER BY w.occurred_at DESC
	LIMIT 1;

-- Find the total number of times each type of channel from the web_events was used. 
	SELECT w.channel, COUNT(*)
	FROM web_events w
	GROUP BY w.channel;
    
-- Who was the primary contact associated with the earliest web_event?
	SELECT a.primary_poc
	FROM web_events w
	JOIN accounts a
	ON a.id = w.account_id
	ORDER BY w.occurred_at
	LIMIT 1;
-- What was the smallest order placed by each account in terms of total usd. 
	SELECT a.name, MIN(total_amt_usd) smallest_order
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY a.name
	ORDER BY smallest_order;

-- Find the number of sales reps in each region. 
	SELECT r.name, COUNT(*) sales_reps
	FROM region r
	JOIN sales_reps s
	ON r.id = s.region_id
	GROUP BY 1
	ORDER BY 2;

-- For each account, determine the average amount of each type of paper they purchased across their orders. 
	SELECT a.name, round(AVG(o.standard_qty),2) avg_stand, round(AVG(o.gloss_qty),2) avg_gloss, round(AVG(o.poster_qty),2) avg_post
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY a.name;

-- Determine the number of times a particular channel was used in the web_events table for each sales rep. 
	SELECT s.name, w.channel, COUNT(*) num_of_events
	FROM accounts a
	JOIN web_events w
	ON a.id = w.account_id
	JOIN sales_reps s
	ON s.id = a.sales_rep_id
	GROUP BY 1,2
	ORDER BY 3 DESC;

-- Determine the number of times a particular channel was used in the web_events table for each region. \
	SELECT r.name, w.channel, COUNT(*) num_events
	FROM accounts a
	JOIN web_events w
	ON a.id = w.account_id
	JOIN sales_reps s
	ON s.id = a.sales_rep_id
	JOIN region r
	ON r.id = s.region_id
	GROUP BY 1,2
	ORDER BY 3 DESC;

-- Have any sales reps worked on more than one account?
	SELECT s.id, s.name, COUNT(*) num_accounts
	FROM accounts a
	JOIN sales_reps s
	ON s.id = a.sales_rep_id
	GROUP BY 1,2
	ORDER BY 3;

-- How many accounts have more than 20 orders?
	SELECT count(*) FROM (
		SELECT a.id, a.name, COUNT(*) num_orders
		FROM accounts a
		JOIN orders o
		ON a.id = o.account_id
		GROUP BY a.id, a.name
		HAVING COUNT(*) > 20
		ORDER BY num_orders) t;

-- Which account has the most orders?
	SELECT a.id, a.name, COUNT(*) num_orders
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY a.id, a.name
	ORDER BY num_orders DESC
	LIMIT 1;

-- How many accounts spent more than 30,000 usd total across all orders?
SELECT COUNT(*) FROM (
	SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY a.id, a.name
	HAVING SUM(o.total_amt_usd) > 30000
	ORDER BY total_spent) t;

-- Which account has spent the most with us?
    SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY a.id, a.name
	ORDER BY total_spent DESC
	LIMIT 1;

-- Which account has spent the least with us?
	SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
	FROM accounts a
	JOIN orders o
	ON a.id = o.account_id
	GROUP BY a.id, a.name
	ORDER BY total_spent
	LIMIT 1;

-- Which accounts used facebook as a channel to contact customers more than 6 times?
	SELECT a.id, a.name, w.channel, COUNT(*) channel_used
	FROM accounts a
	JOIN web_events w
	ON a.id = w.account_id
	GROUP BY a.id, a.name, w.channel
	HAVING COUNT(*) > 6 AND w.channel = 'facebook'
	ORDER BY channel_used;

-- Which channel was most frequently used by most accounts?
	SELECT w.channel, COUNT(w.channel) channel_used
	FROM web_events w
	GROUP BY w.channel
	ORDER BY 2 DESC
	LIMIT 1;

-- Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. 
-- Do you notice any trends in the yearly sales totals?
	 SELECT YEAR(occurred_at) year,  round(SUM(total_amt_usd),2) total_spent
	 FROM orders
	 GROUP BY 1
	 ORDER BY 2 DESC;
     
-- Which month did Parch & Posey have the greatest sales in terms of total dollars? 
	SELECT MONTH(occurred_at) order_month, SUM(total_amt_usd) total_spent
	FROM orders
	-- WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
	GROUP BY 1
	ORDER BY 2 DESC; 
    
-- Which year did Parch & Posey have the greatest sales in terms of total number of orders? 
	SELECT Year(occurred_at) year,  COUNT(*) total_sales
	FROM orders
	GROUP BY 1
	ORDER BY 2 DESC;

-- Which month did Parch & Posey have the greatest sales in terms of total number of orders? 
	SELECT Month( occurred_at) month, COUNT(*) total_sales
	FROM orders
	-- WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
	GROUP BY 1
	ORDER BY 2 DESC; 

-- In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
	SELECT Year(o.occurred_at) year, Month(o.occurred_at) month, SUM(o.gloss_amt_usd) total_spent
	FROM orders o 
	JOIN accounts a
	ON a.id = o.account_id
	WHERE a.name = 'Walmart'
	GROUP BY 1,2
	ORDER BY 3 DESC
    LIMIT 1;

-- Write a query to display for each order the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or less than $3000.
	SELECT account_id, total_amt_usd,
	CASE WHEN total_amt_usd > 3000 THEN 'Large'
	ELSE 'Small' END AS order_level
	FROM orders;

-- Write a query to display the number of orders in each of three categories, based on the total number of items in each order. 
-- The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
	SELECT CASE WHEN total >= 2000 THEN 'At Least 2000'
	   WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
	   ELSE 'Less than 1000' END AS order_category,
	COUNT(*) AS order_count
	FROM orders
	GROUP BY 1;

-- We would like to understand 3 different branches of customers based on the amount associated with their purchases. 
-- The top branch includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. The second branch is between 200,000 and 100,000 usd. The lowest branch is anyone under 100,000 usd. \

	SELECT a.name, SUM(total_amt_usd) total_spent, 
		 CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
		 WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
		 ELSE 'low' END AS customer_level
	FROM orders o
	JOIN accounts a
	ON o.account_id = a.id 
	GROUP BY a.name
	ORDER BY 2 DESC;

-- Identify top performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales. \
	SELECT s.name, COUNT(*) Orders_placed, round(SUM(o.total_amt_usd),2) total_spent, 
		 CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
		 WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
		 ELSE 'low' END AS sales_rep_level
	FROM orders o
	JOIN accounts a
	ON o.account_id = a.id 
	JOIN sales_reps s
	ON s.id = a.sales_rep_id
	GROUP BY 1
	ORDER BY 3 DESC;

-- Average number of events a day for each channel.
	SELECT channel, AVG(events) AS average_events
	FROM (
        SELECT date(occurred_at) AS day,
					 channel, COUNT(*) as events
			  FROM web_events 
			  GROUP BY 1,2) sub
	GROUP BY channel
	ORDER BY 2 DESC;

-- Orders that took place in same month and year as first order placed
	SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gls, AVG(poster_qty) avg_pst
	FROM orders
	WHERE Extract(Year_Month from occurred_at) = 
		 (SELECT Extract(Year_Month from MIN(occurred_at)) FROM orders);

-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
	SELECT t3.rep_name, t3.region_name, t3.total_amt
	FROM(SELECT region_name, MAX(total_amt) total_amt
		 FROM(SELECT s.name rep_name, r.name region_name, round(SUM(o.total_amt_usd),2) total_amt
				 FROM sales_reps s
				 JOIN accounts a
				 ON a.sales_rep_id = s.id
				 JOIN orders o
				 ON o.account_id = a.id
				 JOIN region r
				 ON r.id = s.region_id
				 GROUP BY 1, 2) t1
		 GROUP BY 1) t2
	JOIN (SELECT s.name rep_name, r.name region_name, round(SUM(o.total_amt_usd),2) total_amt
		 FROM sales_reps s
		 JOIN accounts a
		 ON a.sales_rep_id = s.id
		 JOIN orders o
		 ON o.account_id = a.id
		 JOIN region r
		 ON r.id = s.region_id
		 GROUP BY 1,2
		 ORDER BY 3 DESC) t3
	ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;

-- For the region with the largest sales total_amt_usd, how many total orders were placed
	SELECT r.name, COUNT(o.total) total_orders
	FROM sales_reps s
	JOIN accounts a
	ON a.sales_rep_id = s.id
	JOIN orders o
	ON o.account_id = a.id
	JOIN region r
	ON r.id = s.region_id
	GROUP BY r.name
	HAVING SUM(o.total_amt_usd) = (
		  SELECT MAX(total_amt)
		  FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
				  FROM sales_reps s
				  JOIN accounts a
				  ON a.sales_rep_id = s.id
				  JOIN orders o
				  ON o.account_id = a.id
				  JOIN region r
				  ON r.id = s.region_id
				  GROUP BY r.name) sub);

-- How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?
	SELECT COUNT(*)
	FROM (
		   SELECT a.name
		   FROM orders o
		   JOIN accounts a
		   ON a.id = o.account_id
		   GROUP BY 1
		   HAVING SUM(o.total) > (SELECT total 
					   FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
							 FROM accounts a
							 JOIN orders o
							 ON o.account_id = a.id
							 GROUP BY 1
							 ORDER BY 2 DESC
							 LIMIT 1) t1)
				 ) t2;

-- For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?
	SELECT w.channel, COUNT(*)
	FROM accounts a
	JOIN web_events w
	ON a.id = w.account_id AND a.id =  (SELECT id
						 FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
							   FROM orders o
							   JOIN accounts a
							   ON a.id = o.account_id
							   GROUP BY a.id, a.name
							   ORDER BY 3 DESC
							   LIMIT 1) t)
	GROUP BY 1;

-- What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
	SELECT AVG(tot_spent)
	FROM (
		  SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
		  FROM orders o
		  JOIN accounts a
		  ON a.id = o.account_id
		  GROUP BY a.id, a.name
		  ORDER BY 3 DESC
		   LIMIT 10) t;

-- What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.
	SELECT round(AVG(avg_amt),2)
	FROM (
		SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
		FROM orders o
		GROUP BY 1
		HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) avg_all_orders
									   FROM orders o)) t;

# CTE (Common Table Expression)
-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
	WITH t1 AS (
	  SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
	   FROM sales_reps s
	   JOIN accounts a
	   ON a.sales_rep_id = s.id
	   JOIN orders o
	   ON o.account_id = a.id
	   JOIN region r
	   ON r.id = s.region_id
	   GROUP BY 1,2
	   ORDER BY 3 DESC), 
	t2 AS (
	   SELECT region_name, MAX(total_amt) total_amt
	   FROM t1
	   GROUP BY 1)
	SELECT t1.rep_name, t1.region_name, t1.total_amt
	FROM t1
	JOIN t2
	ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;

-- What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.
	WITH t1 AS (
	   SELECT AVG(o.total_amt_usd) avg_all
	   FROM orders o
	   JOIN accounts a
	   ON a.id = o.account_id),
	t2 AS (
	   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
	   FROM orders o
	   GROUP BY 1
	   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
	SELECT AVG(avg_amt)
	FROM t2;
    
# Data Cleaning
-- Create two groups: one group of company names that start with a number and a second group of those company names that start with a letter.
	SELECT CASE WHEN LEFT(name, 1) IN ('0','1','2','3','4','5','6','7','8','9')
        THEN 'starts with number'
        ELSE 'starts with letter'
    END AS first_letter, COUNT(*)
	FROM accounts
	GROUP BY 1;

SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 1 ELSE 0 END AS num, 
         CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 0 ELSE 1 END AS letter
      FROM accounts) t1;

-- Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?
	with t1 as 
		(SELECT CASE WHEN LEFT(UPPER(name), 1) IN ('A' , 'E', 'I', 'O', 'U') THEN 'starts with vowel'
			ELSE 'starts with consonants'
		END AS first_letter,
		COUNT(*) count_letter
		FROM accounts
		GROUP BY 1),
	t2 as 
		(SELECT COUNT(*) count_total FROM accounts)
	SELECT t1.first_letter, t1.count_letter * 100 / t2.count_total letter_proportion
	FROM t1, t2;

SELECT SUM(vowels) vowels, SUM(other) other
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                        THEN 1 ELSE 0 END AS vowels, 
          CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                       THEN 0 ELSE 1 END AS other
         FROM accounts) t1;

-- Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.
	SELECT LEFT(primary_poc, position(' ' IN primary_poc) -1 ) first_name, 
	RIGHT(primary_poc, LENGTH(primary_poc) - position(' ' IN primary_poc)) last_name
	FROM accounts;
    select substring(primary_poc,1,position(' ' IN primary_poc) -1) first_name,
    substring(primary_poc,position(' ' IN primary_poc) +1,length(primary_poc)) last_name
    from accounts;
select instr(primary_poc,' ') from accounts;
-- Each company in the accounts table wants to create an email address for each primary_poc. 
-- The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
	WITH t1 AS (
		 SELECT LEFT(primary_poc, position(' ' IN primary_poc) -1 ) first_name,  
		 RIGHT(primary_poc, LENGTH(primary_poc) - position(' ' IN primary_poc)) last_name, name
		 FROM accounts)
	SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com')
	FROM t1;

-- Create an email address in above solution that will work by removing all of the spaces in the account name.
	WITH t1 AS (
		 SELECT LEFT(primary_poc, position(' ' IN primary_poc) -1 ) first_name,  
		 RIGHT(primary_poc, LENGTH(primary_poc) - position(' ' IN primary_poc)) last_name, name
		 FROM accounts)
	SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
	FROM  t1;

-- Create an initial password. 
-- The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces.
	WITH t1 AS (
		 SELECT LEFT(primary_poc, position(' ' IN primary_poc) -1 ) first_name,  
		 RIGHT(primary_poc, LENGTH(primary_poc) - position(' ' IN primary_poc)) last_name, name
		 FROM accounts)
	SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com') email, 
    concat(LEFT(LOWER(first_name), 1),RIGHT(LOWER(first_name), 1),LEFT(LOWER(last_name), 1),RIGHT(LOWER(last_name), 1),LENGTH(first_name),
    LENGTH(last_name),REPLACE(UPPER(name), ' ', '')) pwd
	FROM t1;

-- write a query to correct the Date format
	with t1 as (SELECT date,left(date,2) mnth, substr(date,4,2) dy, substr(date,7,4) yy
	FROM sf_crime_data)
	select cast(concat(yy,'-',mnth,'-',dy) as date) as date_
	from t1;
    
	select cast(occurred_at as date) from orders;

-- COALESCE to replace NULL values
	SELECT COALESCE(o.id, a.id) filled_id, a.name, a.website,  o.occurred_at, 
	COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, 
	COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
	FROM accounts a
	LEFT JOIN orders o
	ON a.id = o.account_id;


# Window Functions

-- Running total using window function
	SELECT standard_amt_usd,SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
	FROM orders;
    
-- Partitioned Running Total Using Window Functions
	SELECT year(occurred_at) as year, standard_amt_usd, 
		   SUM(standard_amt_usd) OVER (PARTITION BY year(occurred_at) ORDER BY occurred_at) AS running_total
	FROM orders;

-- Ranking Total Paper Ordered by Account
	SELECT id, account_id, total,
		   RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
	FROM orders;

-- Aggregate in window function
	SELECT id, account_id,
		   Year(occurred_at) AS year,
		   DENSE_RANK() OVER account_year_window AS _rank,
		   total_amt_usd,
		   SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
		   COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
		   AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
		   MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
		   MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
	FROM orders 
	WINDOW account_year_window AS (PARTITION BY account_id ORDER BY Year(occurred_at));

-- Comparing a row to previous row
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead_,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
	SELECT account_id,
		   SUM(standard_qty) AS standard_sum
	  FROM orders 
	 GROUP BY 1
	 ) temp;

-- Divide the accounts into 4 levels in terms of the amount of standard_qty for their orders. 
	SELECT account_id, occurred_at, standard_qty,
		   NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
	  FROM orders;

-- Divide the accounts into two levels in terms of the amount of gloss_qty for their orders. 
	SELECT account_id, occurred_at, gloss_qty,
		   NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS standard_quartile
	  FROM orders;

-- Divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders. 
	SELECT account_id, occurred_at, total_amt_usd,
		   NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS standard_quartile
	  FROM orders;
      
# Advanced Joins
-- Joins with comparison operator
	SELECT accounts.name as account_name,
		   accounts.primary_poc as poc_name,
		   sales_reps.name as sales_rep_name
	  FROM accounts
	  LEFT JOIN sales_reps
		ON accounts.sales_rep_id = sales_reps.id
	   AND accounts.primary_poc < sales_reps.name;

-- Self Join
	SELECT o1.id AS o1_id,
		   o1.account_id AS o1_account_id,
		   o1.occurred_at AS o1_occurred_at,
		   o2.id AS o2_id,
		   o2.account_id AS o2_account_id,
		   o2.occurred_at AS o2_occurred_at
	  FROM orders o1
	 LEFT JOIN orders o2
	   ON o1.account_id = o2.account_id
	  AND o2.occurred_at > o1.occurred_at
	  AND o2.occurred_at <= o1.occurred_at + 1
	ORDER BY o1.account_id, o1.occurred_at;
    
-- Appending Data via UNION
	SELECT *
	FROM accounts 
	UNION ALL 
	SELECT *
	FROM accounts ;
-- Pretreating Tables before doing a UNION
	SELECT *
		FROM accounts
		WHERE name = 'Walmart'
	UNION ALL
	SELECT *
	  FROM accounts
	  WHERE name = 'Disney';
-- Performing Operations on a Combined Dataset
	WITH union_accounts AS (
		SELECT *
		  FROM accounts
		UNION ALL
		SELECT *
		  FROM accounts
	)
	SELECT name,
		   COUNT(*) AS name_count
	 FROM union_accounts 
	GROUP BY 1
	ORDER BY 2 DESC;