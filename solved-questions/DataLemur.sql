-- source : https://datalemur.com/

#easy
-- 1. Write a query to list the top three cities that have the most completed trade orders in descending order. Output the city and number of orders. (RobinHood)
SELECT city, count(*) trade_orders
FROM trades t
join users u
on t.user_id = u.user_id
where status = 'Completed'
group by 1
order by 2 desc
limit 3;


-- 2. Assume you are given the tables about Facebook pages and page likes. Write a query to returns the page IDs of all the Facebook pages that don't have any likes. The output should be in ascending order. (Meta)
SELECT p.page_id
from pages p
left join page_likes l
on p.page_id = l.page_id
where liked_date is null
order by 1;


-- 3. Assume that you are given the table containing information on viewership by device type (where the three types are laptop, tablet, and phone). Define “mobile” as the sum of tablet and phone viewership numbers. Write a query to compare the viewership on laptops versus mobile devices. Output the total viewership for laptop and mobile devices in the format of "laptop_views", "mobile_views". (NY Times)
SELECT 
sum(case when device_type = 'laptop' then 1 else 0 end) laptop_views,
sum(case when device_type in ('tablet', 'phone') then 1 else 0 end) mobile_views
FROM viewership;


-- 4. Assume you are given the table for purchasing activity by product type. Write a query to calculate the cumulative purchases for each product type over time in chronological order. Output the transaction date, product type, and the cumulative number of quantities purchased (conveniently abbreviated as cum_purchased). (Amazon)
SELECT order_date, product_type, 
SUM(quantity) OVER (partition by product_type order by order_date) cum_purchased
FROM total_trans
order by 1;


-- 5. Write a query to find the top 2 power users who sent the most messages on Microsoft Teams in August 2022. Display the IDs of these 2 users along with the total number of messages they sent. Output the results in descending count of the messages. (Microsoft)
SELECT sender_id, count(*) msgs_sent
FROM messages
where extract(month from sent_date) = 8 and
extract(year from sent_date) = 2022
group by 1
order by 2 desc
limit 2;


-- 6. Assume that you are given the table containing information on various orders made by eBay customers. Write a query to obtain the user id and highest number of products purchased by the top 3 customers among those who have spent at least $1,000 in total. Output the user id and number of products in descending order. To break ties, the user with the higher amount of spending takes precedence. (eBay)
SELECT user_id, count(*) purchases
FROM user_transactions
group by user_id
having sum(spend) >= 1000
order by 2 desc, sum(spend) desc
limit 3;


-- 7. Assume you are given the table containing tweet data. Write a query to obtain a histogram of tweets posted per user in 2022. Output the tweet count per user as the bucket, and then the number of Twitter users who fall into that bucket. (Twitter)
SELECT no_of_tweets, count(*) users FROM(
  SELECT user_id, count(user_id)  no_of_tweets
  FROM tweets
  WHERE EXTRACT (year from tweet_date) = 2022
  GROUP BY 1)t
GROUP BY 1
ORDER BY 1;
 

-- 8. Microsoft Azure's capacity planning team wants to understand how much data its customers are using, and how much spare capacity is left in each of it's data centers. You’re given three tables: customers, datacenters, and forecasted_demand. Write a query to find the total monthly unused server capacity for each data center. Output the data center id in ascending order and the total spare capacity. (Microsoft)
with monthly_demand_table as (
SELECT datacenter_id, sum(monthly_demand) monthly_demand
FROM forecasted_demand
GROUP BY 1)
SELECT m.datacenter_id, monthly_capacity - monthly_demand spare_capacity
FROM monthly_demand_table m
JOIN datacenters d
on m.datacenter_id = d.datacenter_id
ORDER BY 1;


-- 9. Assume you are given the table containing information on user purchases. Write a query to obtain the number of users who purchased the same product on two or more different days. Output the number of users. (Stitch Fix)
SELECT count(*) FROM
(SELECT distinct p1.user_id
FROM purchases p1
JOIN purchases p2
ON p1.user_id = p2.user_id
and p1.product_id = p2.product_id
and date(p1.purchase_date) <> date(p2.purchase_date))t
 
OR 
 
WITH ranking AS (
  SELECT user_id, 
    RANK() OVER (PARTITION BY user_id, product_id 
      ORDER BY DATE(purchase_date) ASC) purchase_no 
  FROM purchases
) 
SELECT COUNT(DISTINCT user_id) AS users_num 
FROM ranking 
WHERE purchase_no >= 2;


-- 10. Assume you are given the table that shows job postings for all companies on the LinkedIn platform. Write a query to get the number of companies that have posted duplicate job listings (two jobs at the same company with the same title and description). (Linkedin)
SELECT COUNT(distinct j1.company_id)
FROM job_listings j1
JOIN job_listings j2
ON j1.company_id = j2.company_id
AND j1.title = j2.title
AND j1.description = j2.description
AND j1.job_id <> j2.job_id;
 
OR
 
WITH jobs_grouped AS (
  SELECT 
    company_id, 
    title, 
    description, 
    COUNT(job_id) AS job_count
  FROM job_listings
  GROUP BY 
    company_id, 
    title, 
    description
)
 
SELECT 
  COUNT(DISTINCT company_id) AS duplicate_companies
FROM jobs_grouped
WHERE job_count > 1;
 

-- 11. Given a table of Facebook posts, for each user who posted at least twice in 2021, write a query to find the number of days between each user’s first post of the year and last post of the year in the year 2021. Output the user and number of the days between each user's first and last post. (Meta)
SELECT user_id, EXTRACT('day' from (max(post_date) - min(post_date))) day_diff
FROM posts
WHERE extract(year from post_date) = 2021
GROUP BY 1
HAVING EXTRACT('day' from (max(post_date) - min(post_date))) > 0;


-- 12. Assume you have an events table on app analytics. Write a query to get the click-through rate percentage (CTR %) per app in 2022. Output the results in percentage rounded to 2 decimal places. (Meta)
SELECT app_id, round(clicks/imp*100,2)  ctr
FROM(
SELECT app_id, 
cast(sum(case when event_type = 'click' then 1 else 0 end) as decimal(9,2)) clicks,
cast(sum(case when event_type = 'impression' then 1 else 0 end) as decimal(9,2)) imp
FROM events
WHERE EXTRACT(year from timestamp) = 2022
GROUP BY app_id) t;


-- 13. Assume you are given the table on Uber transactions made by users. Write a query to obtain the third transaction of every user. Output the user id, spend and transaction date. (Uber)
with txn as(
SELECT *, 
dense_rank() over(partition by user_id order by transaction_date) rnk_
FROM transactions)
SELECT user_id, spend, transaction_date
FROM txn
WHERE rnk_ = 3;


-- 14. The LinkedIn Creator team is looking for power creators who use their personal profile as a company or influencer page. If someone's LinkedIn page has more followers than the company they work for, we can safely assume that person is a power creator. Write a query to return the IDs of these LinkedIn power creators. (LinkedIn)
SELECT profile_id 
FROM personal_profiles p
JOIN company_pages c
ON p.employer_id = c.company_id
WHERE p.followers > c.followers;


-- 15. Assume you are given the table containing information on Amazon customers and their spend on products belonging to various categories. Identify the top two highest-grossing products within each category in 2022. Output the category, product, and total spend. (Amazon)
SELECT category, product, total_spend
FROM (
SELECT category, product, sum(spend) total_spend, 
rank() over (partition by category order by sum(spend) desc) rnk_
FROM product_spend
WHERE EXTRACT(year from transaction_date) = 2022
GROUP BY 1,2) t
WHERE rnk_ < 3;


-- 16. Assume you are given the table on transactions from users. Bucketing users based on their latest transaction date, write a query to obtain the number of users who made a purchase and the total number of products bought for each transaction date. Output the transaction date, number of users and number of products. (Walmart)
SELECT transaction_date, count(distinct user_id) users, count(distinct product_id) products
FROM
(SELECT *, 
rank() over (partition by user_id order by transaction_date desc) rnk
FROM user_transactions) t
WHERE rnk = 1
GROUP BY 1;
 

-- 17. For every customer that bought Photoshop, return a list of their customer_id, and how much they spent in total for other Adobe products excluding Photoshop. Sort your answer by customer_id in ascending order. (Adobe)
SELECT customer_id, SUM(revenue)
FROM adobe_transactions
WHERE customer_id in (
SELECT customer_id
FROM adobe_transactions
WHERE product = 'Photoshop')
AND product <> 'Photoshop'
GROUP BY 1
ORDER BY 1;
 
 
-- 18. Given a table of candidates and their skills, you're tasked with finding the candidates best suited for an open Data Science job. You want to find candidates who are proficient in Python, Tableau, and PostgreSQL. Write a SQL query to list the candidates who possess all of the required skills for the job. Sort the output by candidate ID in ascending order. (Linkedin)
 
SELECT distinct candidate_id 
FROM
(SELECT *,
RANK() OVER (PARTITION BY candidate_id ORDER BY skill) rnk
FROM candidates
WHERE skill in ('Python', 'Tableau', 'PostgreSQL')) t
WHERE rnk=3 
ORDER BY 1;
 
OR
 
SELECT candidate_id
FROM candidates
WHERE skill IN ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(skill) = 3
ORDER BY candidate_id;


-- 19. You are trying to identify all Subject Matter Experts at Accenture. An employee is a subject matter expert if they have 8 or more years of work experience in a given domain, or if they have 12 or more years of experience across 2 different domains. Write a SQL query to return the employee id of all the subject matter experts. (Accenture)
SELECT employee_id
FROM employee_expertise
GROUP BY employee_id
HAVING (SUM(years_of_experience) >= 8 AND COUNT(domain) = 1) 
  OR (SUM(years_of_experience) >=12 AND COUNT(domain) = 2);
 

-- 20. Given a table of bank deposits and withdrawals, return the final balance for each account. (Paypal)
SELECT  DISTINCT account_id,
SUM(amount_txn) OVER (PARTITION BY account_id) final_amount
FROM
(SELECT *,
CASE WHEN transaction_type = 'Deposit' THEN amount
WHEN transaction_type = 'Withdrawal' THEN - amount END AS amount_txn
FROM transactions) t
ORDER BY 1;


-- 21. Your team at Accenture is helping a Fortune 500 client revamp their compensation and benefits program. The first step in this analysis is to manually review employees who are potentially overpaid or underpaid. An employee is considered to be potentially overpaid if they earn more than 2 times the average salary for people with the same title. Similarly, an employee might be underpaid if they earn less than half of the average for their title. We'll refer to employees who are both underpaid and overpaid as compensation outliers for the purposes of this problem. Write a query that shows the following data for each compensation outlier: employee ID, salary, and whether they are potentially overpaid or potentially underpaid. (Accenture)
WITH avg_sal_Calc AS 
(SELECT *, 
round(AVG(salary) OVER (PARTITION BY title),2) avg_salary
FROM employee_pay),
status_calc AS 
(SELECT *,
CASE WHEN salary > 2*avg_salary THEN 'Overpaid'
WHEN salary < 0.5*avg_salary THEN 'Underpaid' END AS status
FROM avg_sal_Calc)
SELECT employee_id, salary, status
FROM status_calc
WHERE status IS NOT NULL;
 

-- 22. You are given a table of PayPal payments showing the payer, the recipient, and the amount paid. A two-way unique relationship is established when two people send money back and forth. Write a query to find the number of two-way unique relationships in this data. (Paypal)
SELECT count(*)/2 unique_relationship
FROM
(SELECT distinct p1.payer_id,p1.recipient_id
FROM payments p1
JOIN payments p2
ON p1.payer_id = p2.recipient_id
AND p1.recipient_id = p2.payer_id) t;


#medium

-- 23. Assume you are given the table on user transactions. Write a query to obtain the list of customers whose first transaction was valued at $50 or more. Output the number of users. (Etsy)
SELECT count(distinct user_id) users
FROM(
SELECT *, 
rank() over (partition by user_id order by transaction_date) rnk
FROM user_transactions) t
WHERE rnk = 1
and spend >= 50;


-- 24. The table contains information about tweets over a given period of time. Calculate the 3-day rolling average of tweets published by each user for each date that a tweet was posted. Output the user id, tweet date, and rolling averages rounded to 2 decimal places. (Twitter)
SELECT user_id, tweet_date, 
round(avg(tweets) over (partition by user_id order by tweet_date
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) avg_tweets
FROM
(SELECT user_id, tweet_date, count(*) tweets
FROM tweets
GROUP BY user_id, tweet_date) t
-- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW means the values in tweets in previous 2 rows and current row is added and then averaged (to get 3 days rolling average).


-- 25. Google marketing managers are analyzing the performance of various advertising accounts over the last month. They need your help to gather the relevant data. Write a query to calculate the return on ad spend (ROAS) for each advertiser across all ad campaigns. Round your answer to 2 decimal places, and order your output by the advertiser_id. (Google)
SELECT advertiser_id, 
round(cast(sum(revenue)/sum(spend) as numeric),2) roas
FROM ad_campaigns
GROUP BY 1
ORDER BY 1;


-- 26. The LinkedIn Creator team is looking for power creators who use their personal profile as a company or influencer page. If someone's LinkedIn page has more followers than the company they work for, we can safely assume that person is a power creator. Write a query to return the IDs of these LinkedIn power creators. Assumption: A person can work at multiple companies. (LinkedIn)
with company_followers as (
SELECT p.profile_id, max(c.followers) company_flwrs
FROM personal_profiles p
JOIN employee_company e
ON e.personal_profile_id = p.profile_id
JOIN company_pages c
ON e.company_id = c.company_id
group by profile_id)
select c.profile_id
from company_followers c
join personal_profiles p
on c.profile_id = p.profile_id
and c.company_flwrs < p.followers;
 

-- 27. Given the reviews table, write a query to get the average stars for each product every month. The output should include the month, product_id, and average star rating. (Amazon)
SELECT extract(month from submit_date) months, product_id, 
round(avg(stars),2) avg_stars
FROM reviews
group by 1,2
order by 1,2;


-- 28. Assume there are three Spotify tables containing information about the artists, songs, and music charts. Write a query to determine the top 5 artists whose songs appear in the Top 10 of the global_song_rank table the highest number of times. (Spotify)
SELECT artist_name, artist_rnk
FROM 
(SELECT artist_name, count(rank) song_appearances,
dense_rank() over (order by count(rank) desc) artist_rnk
FROM artists a
JOIN songs s
ON a.artist_id = s.artist_id
JOIN global_song_rank g
ON g.song_id = s.song_id
where rank <= 10
group by 1) t
where artist_rnk<=5

-- 29. In consulting, being "on the bench" means you have a gap between two client engagements. Google wants to know how many days of bench time each consultant had in 2021. Assume that each consultant is only staffed to one consulting engagement at a time. Write a query to pull each employee ID and their total bench time in days during 2021. (Google)
SELECT employee_id, 365 - sum(end_date-start_date+1)
FROM staffing s
JOIN consulting_engagements c
ON s.job_id = c.job_id
WHERE is_consultant = 'true'
GROUP BY 1;


-- 30. New TikTok users sign up with their emails, so each signup requires a text confirmation to activate the new user's account. Write a SQL query to find the confirmation rate of people who confirmed their signups with text messages. Round the result to 2 decimal places. (TikTok)
SELECT round(sum(signup)::numeric/count(*),2) confirmation_rate
FROM
(SELECT user_id,
  CASE WHEN texts.email_id IS NOT NULL THEN 1 ELSE 0 END AS signup
  FROM emails
  LEFT JOIN texts
  ON emails.email_id = texts.email_id
  AND signup_action = 'Confirmed') t
  
  
-- 31. New TikTok users sign up with their emails and each user receives a text confirmation to activate their account. Assume you are given the below tables about emails and texts. Write a query to display ids of the users who did not confirm on the first day of sign up, but confirmed on the second day. (TikTok)
SELECT user_id
FROM emails e
JOIN texts t
ON e.email_id = t.email_id
WHERE signup_action = 'Confirmed'
and EXTRACT(day from (action_date-signup_date)) = 1;


-- 32. Assume the history table keeps track of the songs that users have listened to in the past, and the weekly table has information of the song between August 1 and August 7, 2022. Write a query to show the user id, song id, and the number of times the user has listened to the songs as of August 4, 2022 in descending order. (Spotify)
SELECT user_id, song_id, sum(tally) tally
FROM
(SELECT user_id, song_id, tally
FROM songs_history s
UNION
SELECT user_id, song_id, 1 as tally
FROM songs_weekly w
WHERE listen_time between '08/01/2022' and '08/05/2022') t
GROUP BY 1,2
ORDER BY 3 desc;

-- 33. Assume you are given the table below containing information on user session activity. Write a query that ranks users according to their total session durations (in minutes) by descending order for each session type between the start date (2022-01-01) and end date (2022-02-01). Output the user id, session type, and the ranking of the total session duration. (Twitter)
SELECT user_id, session_type,
rank() over (partition by session_type order by sum(duration) desc) rnk
FROM sessions
WHERE start_date between '2022/01/01' and '2022/02/02'
GROUP BY user_id, session_type;


-- 34. Assume you are given the tables below containing information on Snapchat users, their ages, and their time spent sending and opening snaps. Write a query to obtain a breakdown of the time spent sending vs. opening snaps (as a percentage of total time spent on these activities) for each of the different age groups. (Snapchat)
with t as 
(SELECT age_bucket, 
sum(case when activity_type = 'send' then time_spent else 0 end) send_time,
sum(case when activity_type = 'open' then time_spent else 0 end) open_time,
sum(time_spent) total_time
FROM activities a
JOIN age_breakdown b
ON a.user_id = b.user_id
WHERE activity_type IN ('send','open')
GROUP BY 1
ORDER BY 1)
SELECT age_bucket, 
round(send_time/total_time*100,2) send_perc, round(open_time/total_time*100,2) open_perc
FROM t;


-- 35. Assume you are given the table below containing the information on the searches attempted and the percentage of invalid searches by country. Write a query to obtain the percentage of invalid search result. Output the country (in ascending order), total number of searches and percentage of invalid search rounded to 2 decimal places. (Google)
SELECT country, sum(num_search) total_searches,
round(sum(invalid_search)/sum(num_search)*100,2) invalid_search_pct
FROM
(SELECT country, num_search, num_search*invalid_result_pct/100 invalid_search
FROM search_category
WHERE num_search is not null and invalid_result_pct is not null) t
GROUP BY 1
ORDER BY 1;


-- 36. Assume you are given the table below containing information on user reviews. Write a query to obtain the number and percentage of businesses that are top rated. A top-rated business is defined as one whose reviews contain only 4 or 5 stars. Output the number of businesses and percentage of top rated businesses rounded to the 2 decimal places. (Yelp)
SELECT count(*) top_business, 
round(count(*)::decimal/(SELECT count(*) FROM reviews)*100,2) top_business_pct
FROM reviews
WHERE review_stars in (4,5);


-- 37. Assume you are given the table below containing measurement values obtained from a sensor over several days. Measurements are taken several times within a given day. Write a query to obtain the sum of the odd-numbered and even-numbered measurements on a particular day, in two different columns. (Google)
SELECT date(measurement_time),
sum(case when mod(rnk,2) <> 0 then measurement_value else 0 end) odd_sum,
sum(case when mod(rnk,2) = 0 then measurement_value else 0 end) even_sum
FROM
(SELECT *, date(measurement_time),
row_number() over (partition by date(measurement_time) order by measurement_time) rnk
FROM measurements) t
GROUP BY 1
ORDER BY 1;


-- 38. Assume you are given the two tables containing information on Etsy user signups and user purchases. Write a query to obtain the percentage of users who signed up and made a purchase within the same week of signing up. Finally, convert the decimal result into a percentage value rounded to 2 decimal places. (Etsy)
SELECT round(count(users)::decimal/(SELECT count(distinct user_id) FROM signups)*100,2) single_purchase_pct
FROM
(SELECT distinct s.user_id users
FROM signups s
LEFT JOIN user_purchases p
ON s.user_id = p.user_id
WHERE extract(day from (purchase_date-signup_date)) <= 7) t;


-- 39. Assume you are given the tables on Walmart transactions and products. Find the top 3 products that are most frequently bought together (purchased in the same transaction). Output the name of product #1, name of product #2 and number of combinations in descending order. (Walmart)
with product_txn as(SELECT transaction_id, t.product_id, p.product_name 
FROM transactions t
JOIN products p
ON t.product_id = p.product_id),
product_count as(
SELECT t1.transaction_id, t1.product_id, t1.product_name product1,
t2.product_id, t2.product_name product2
FROM product_txn t1
JOIN product_txn t2
ON t1.transaction_id = t2.transaction_id
AND t1.product_id > t2.product_id)
SELECT product1, product2, count(*) combo_num
FROM product_count
GROUP BY 1,2
LIMIT 3;
 

-- 40. When you log in to your retailer client's database, you notice that their product catalog data is full of gaps in the category column. Can you write a SQL query that returns the product catalog with the missing data filled in? (Accenture)
SELECT product_id,
FIRST_VALUE(category) OVER (PARTITION BY category_count) category_,
name
FROM
(SELECT *,
COUNT(category) OVER (ORDER BY product_id) category_count
FROM products) t;


-- 41. Each salesperson earns a fixed base salary and a percentage of commission on their total deals. Also, if they beat their quota, any sales after that receive an accelerator, which is just a higher commission rate applied to their commissions after they hit the quota.
Based on the aforementioned, write a query to calculate the total compensation earned by each salesperson. Output the employee id and total compensation in descending order.
When a salesperson does not hit the target (quota), the employee receives a fixed salary and a commission on the total deals.
When a salesperson hits the target (amount of total deals is equivalent to or higher than the quota), the compensation package includes: a fixed base, a regular commission on quota hit, and a regular commission and accelerated commission on the balance of quota hit (total deals - quota). (Oracle)
WITH final_deal AS 
(SELECT employee_id, sum(deal_size) deal
FROM deals 
GROUP BY 1),
emp_deals AS 
(SELECT e.employee_id, base, quota, accelerator, commission, deal
FROM employee_contract e
JOIN final_deal d
ON e.employee_id = d.employee_id)
SELECT employee_id,
CASE WHEN deal >= quota THEN base + (commission*quota) + (accelerator*commission*(deal-quota))
ELSE base + (commission*deal) END AS compensation
FROM emp_deals
ORDER BY 2 desc;

-- 42. The Airbnb marketing analytics team is trying to understand what are the most common marketing channels that lead users to book their first rental on Airbnb. Write a query to find the top marketing channel and percentage of first rental bookings from the aforementioned marketing channel. Round the percentage to the closest integer. Assume there are no ties. (Airbnb)
WITH booking_channel AS 
(SELECT * 
FROM booking_attribution
WHERE booking_id IN
(SELECT booking_id 
FROM bookings
WHERE booking_date IN(
SELECT min(booking_date)
FROM bookings
GROUP BY user_id))),
channel_count AS
(SELECT channel, count(*) channel_booking
FROM booking_channel
GROUP BY 1)
SELECT channel, 
round(channel_booking::numeric/(SELECT count(distinct user_id) FROM bookings)*100.0,0) first_booking
FROM channel_count
WHERE channel is not null
ORDER BY 2 desc
LIMIT 1;
 

-- 43. You are given a list of numbers representing how many emails each Microsoft Outlook user has in their inbox. Before the Product Management team can work on features related to inbox zero or bulk-deleting email, they simply want to know what the mean, median, and mode are for the number of emails. Output the median, median and mode (in this order). Round the mean to the closest integer and assume that there are no ties for mode. (MS)
SELECT round(avg(email_count),0) mean, round(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY email_count) ::decimal,0) median,
MODE() WITHIN GROUP (ORDER BY email_count) 
FROM inbox_stats;


#hard

-- 44. Facebook is analyzing its user signup data for June 2022. Write a query to generate the churn rate by week in June 2022. Output the week number (1, 2, 3, 4, ...) and the corresponding churn rate rounded to 2 decimal places. (Meta)
with churn_calc as (SELECT *,
case when signup_date between '05/30/2022' and '06/05/2022' then 1
when signup_date between '06/06/2022' and '06/12/2022' then 2
when signup_date between '06/13/2022' and '06/19/2022' then 3
when signup_date between '06/20/2022' and '06/26/2022' then 4
else 5
end as week,
case when extract(day from (last_login-signup_date)) <= 28 then 1 else 0 end as churn
FROM users
WHERE signup_date between '06/01/2022' and '07/01/2022')
SELECT week signup_week,
round(sum(churn)* 100/count(*)::decimal,2) churn_rate
FROM churn_calc
GROUP BY 1
ORDER BY 1; 
-- Note : Other method to find the week number for the month of ‘June’:
(EXTRACT(WEEK FROM signup_date) 
    - EXTRACT(WEEK FROM DATE_TRUNC('Month', signup_date)))  +  1 
    AS signup_week
 

-- 45. Assume you have a table containing information on Facebook user actions. Write a query to obtain the active user retention in July 2022. Output the month (in numerical format 1, 2, 3) and the number of monthly active users (MAUs). (Meta)
with retention_Calc as
(SELECT u1.user_id, u1.event_date event1, u2.event_date event2
FROM user_actions u1
JOIN user_Actions u2
ON u1.user_id = u2.user_id
and u1.event_id <> u2.event_id
and u1.event_date < u2.event_date
and extract(month from u2.event_date)=7
and extract(year from u2.event_date)=2022)
SELECT extract(month from event2),count(distinct user_id)
FROM retention_calc
WHERE extract(month from event2)-extract(month from event1) = 1
GROUP BY 1;


-- 46. Assume you are given a table containing information on user transactions for particular products. Write a query to obtain the year-on-year growth rate for the total spend of each product for each year. Output the year (in ascending order) partitioned by product id, current year's spend, previous year's spend and year-on-year growth rate (percentage rounded to 2 decimal places). (Wayfair)
with total_spend as
(SELECT extract(year from transaction_date) year_, product_id, 
sum(spend) over (partition by product_id, extract(year from transaction_date)) current_spend
FROM user_transactions
ORDER BY 2,1),
previous_calc as 
(SELECT *,
LAG(current_spend) over (partition by product_id) previous_spend
FROM total_spend)
SELECT year_, product_id, current_spend, previous_spend,
round((current_spend-previous_spend)/previous_Spend*100,2) yoy_growth_rate
FROM previous_calc;


-- 47. Say you have access to all the transactions for a given merchant account. Write a query to print the cumulative balance of the merchant account at the end of each day, with the total balance reset back to zero at the end of the month. Output the transaction date and cumulative balance. (Visa)
SELECT txn_date,
sum(txn) over (partition by extract(month from txn_date) order by txn_date) transactions
FROM
(SELECT date(transaction_date) txn_date,
sum(case when type = 'deposit' then amount
when type = 'withdrawal' then -amount end) txn
FROM transactions
GROUP BY 1) t;

-- 48. Assume you are given the table containing information on user sessions, including their start and end times. Write a query to obtain the user session that is concurrent with the other user sessions. Output the session id and number of concurrent user sessions. (Pinterest)
SELECT s1.session_id, count(*) concurrent_users
FROM sessions s1
JOIN sessions s2
ON s2.start_time BETWEEN s1.start_time and s1.end_time
and s1.session_id <> s2.session_id
GROUP BY 1
ORDER BY 2 desc;


-- 49. Facebook wants to create a new algorithm of friend recommendations based on people who are showing interest in attending 2 or more of the same private events. A user interested in attending would have either 'going' or 'maybe' as their attendance status. Note that friend recommendations are unidirectional, meaning if user x and user y should be recommended to each other, the result table should have both user x recommended to user y and user y recommended to user x. Also, note that the result table should not contain duplicates (i.e., user y should not be recommended to user x multiple times). (Meta)
with events as
(select * from event_rsvp where attendance_status in ('going','maybe')),
recommend_Calc as
(SELECT distinct e1.user_id user_a, e2.user_id user_b
FROM events e1
JOIN events e2
ON e1.user_id <> e2.user_id
and e1.event_id = e2.event_id)
SELECT user_a, user_b
FROM recommend_calc r
JOIN friendship_status f
ON r.user_a = f.user_a_id
and r.user_b = f.user_b_id
and status = 'not_friends'
ORDER BY 1;
 

-- 50. Google's marketing team is making a Superbowl commercial and needs a simple statistic to put on their TV ad: the median number of searches a person made last year. However, at Google scale, querying the 2 trillion searches is too costly. Luckily, you have access to the summary table which tells you the number of searches made last year and how many Google users fall into that bucket. Write a query to report the median of searches made by a user. Round the median to one decimal point. (Google)
SELECT round(PERCENTILE_CONT(0.50) within group (
    order by searches)::decimal,1) median
FROM
(SELECT GENERATE_SERIES(1, num_users), searches
  FROM search_frequency)t
-- https://www.youtube.com/watch?v=vyUQsKCyJ9g
-- generate_series(start, stop, step) to deliver a series from start to stop incrementing by step. Default step = 1. [PostgreSQL]
 

-- 51. DoorDash's Growth Team is trying to make sure new users (those who are making orders in their first 14 days) have a great experience on all their orders in their 2 weeks on the platform.
-- Unfortunately, many deliveries are being messed up because:
-- the orders are being completed incorrectly (missing items, wrong order, etc.)
-- the orders aren't being received (wrong address, wrong drop off spot)
-- the orders are being delivered late (the actual delivery time is 30 minutes later than when the order was placed). Note that the estimated_delivery_timestamp is automatically set to 30 minutes after the order_timestamp.
-- Write a query to find the bad experience rate in the first 14 days for new users who signed up in June 2022. Output the percentage of bad experience rounded to 2 decimal places. (DoorDash)
with temp1 as
(SELECT * 
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
and extract(day from (order_timestamp-signup_timestamp)) <= 14
WHERE extract(month from signup_timestamp) = 6
and extract(year from signup_timestamp) = 2022) 
SELECT 
round(sum(case when status <> 'completed successfully' or actual_delivery_timestamp IS NULL
or estimated_delivery_timestamp < actual_delivery_timestamp then 1 else 0 end)/count(*)::decimal*100,2) bad_exp
FROM temp1 
JOIN trips 
ON temp1.trip_id = trips.trip_id;

 
-- 52. Write a query to update the Facebook advertiser's status using the daily_pay table. Advertiser is a two-column table containing the user id and their payment status based on the last payment and daily_pay table has current information about their payment. Only advertisers who paid will show up in this table. Output the user id and current payment status. (Meta)
SELECT coalesce(d.user_id,a.user_id) user_id, 
case when paid is null then 'CHURN' 
when paid is not null and status is null then 'NEW'
when paid is not null and status = 'CHURN' then 'RESURRECT'
when paid is not null then 'EXISTING' end as new_status
FROM daily_pay d
FULL JOIN advertiser a
ON d.user_id = a.user_id;
 

-- 53. In an effort to identify high-value customers, Amazon asked for your help to obtain data about users who go on shopping sprees. A shopping spree occurs when a user makes purchases on 3 or more consecutive days. List the user ids who have gone on at least 1 shopping spree. (Amazon)
with t1 as (
SELECT user_id, transaction_date - rank() over (partition by user_id order by transaction_date)* interval '1 day' date_group 
FROM transactions),
t2 as(
SELECT user_id, date_group, count(*) consecutive_days
FROM t1
GROUP BY 1,2)
SELECT distinct user_id
FROM t2
WHERE consecutive_days >= 3;

