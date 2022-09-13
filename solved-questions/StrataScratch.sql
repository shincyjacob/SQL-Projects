-- source : https://platform.stratascratch.com/coding?code_type=3

-- 1. Find the titles of workers that earn the highest salary. Output the highest-paid title or multiple titles that share the highest salary. (DoorDash)

SELECT t.worker_title as best_paid from(
SELECT w.salary, t.worker_title,
row_number() over(order by salary desc) rank_
FROM worker w
JOIN title t
ON w.worker_id = t.worker_ref_id
ORDER BY 3) t
WHERE rank_ <= 2;


OR 

SELECT  t.worker_title
FROM worker w
        JOIN  title t 
ON w.worker_id = t.worker_ref_id
WHERE
    w.salary = (SELECT MAX(salary)   FROM worker);


-- 2. Write a query that calculates the difference between the highest salaries found in the marketing and engineering departments. Output just the absolute difference in salaries. (DoorDash)

SELECT 
    ROUND(MAX(CASE WHEN d.department = 'marketing' THEN e.salary ELSE 0 END) - 
MAX(CASE WHEN d.department = 'engineering' THEN e.salary ELSE 0 END), 0) salary_diff
FROM
    db_employee e
        JOIN
    db_dept d ON e.department_id = d.id;
    

-- 3. Find employees who are earning more than their managers. Output the employee's first name along with the corresponding salary. (DropBox)

SELECT  e.first_name employee, e.salary salary
FROM employee e
        JOIN
    employee m ON e.manager_id = m.id
WHERE
    e.salary > m.salary;
    
    
-- 4. Meta/Facebook has developed a new programing language called Hack.To measure the popularity of Hack they ran a survey with their employees. The survey included data on previous programing familiarity as well as the number of years of experience, age, gender and most importantly satisfaction with Hack. Due to an error location data was not collected, but your supervisor demands a report showing average popularity of Hack by office location. Luckily the user IDs of employees completing the surveys were stored. Based on the above, find the average popularity of the Hack per office location.
Output the location along with the average popularity. (Meta)

SELECT 
    e.location, AVG(h.popularity) popularity
FROM facebook_employees e
        JOIN facebook_hack_survey h
 ON e.id = h.employee_id
GROUP BY 1
ORDER BY 1;


-- 5. What is the overall friend acceptance rate by date? Your output should have the rate of acceptances by the date the request was sent. Order by the earliest date to latest. (Meta)

WITH sent as (
SELECT * FROM fb_friend_requests 
WHERE action = 'sent'),
accepted as (
SELECT * FROM fb_friend_requests 
WHERE action = 'accepted’'),
SELECT s.date, COUNT(a.user_id_receiver)/COUNT(s.user_id_sender) acceptance_rate
FROM sent s
LEFT JOIN accepted a
ON s.user_id_Sender = a.user_id_Sender
GROUP BY 1
ORDER BY date;


-- 6. Calculate the total revenue from each customer in March 2019. Include only customers who were active in March 2019.

SELECT cust_id, sum(total_order_cost) revenue
FROM orders
WHERE order_date BETWEEN '2019-03-01' AND '2019-03-31'
-- where year(order_date) = 2019 and month(order_date) = 03
GROUP BY 1
ORDER BY 2 desc;


-- 7. Find the date with the highest total energy consumption from the Meta/Facebook data centers. Output the date along with the total energy consumption across all data centers. (Meta)

SELECT date, SUM(consumption)
FROM
    (SELECT *
    FROM fb_eu_energy 
    UNION ALL 
	SELECT *
    FROM fb_asia_energy 
    UNION ALL
    SELECT *
    FROM fb_na_energy) t
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- 8. Calculate each user's average session time. A session is defined as the time difference between a page_load and page_exit. For simplicity, assume a user has only 1 session per day and if there are multiple of the same events on that day, consider only the latest page_load and earliest page_exit. Output the user_id and their average session time. (Meta)

WITH page_load as(
SELECT user_id, DATE(timestamp) date, MAX(timestamp) load_time
FROM facebook_web_log
WHERE action = 'page_load'
GROUP BY 1,2),
page_exit as (
SELECT user_id, DATE(timestamp) date, MIN(timestamp) exit_time
FROM facebook_web_log
WHERE action = 'page_exit'
GROUP BY 1,2)
SELECT l.user_id, AVG(TIMESTAMPDIFF(second,l.load_time,e.exit_time))
FROM page_load l
JOIN page_exit e
ON l.user_id = e.user_id
AND l.date = e.date
GROUP BY 1;


-- 9. Find the popularity percentage for each user on Meta/Facebook. The popularity percentage is defined as the total number of friends the user has divided by the total number of users on the platform, then converted into a percentage by multiplying by 100.
Output each user along with their popularity percentage. Order records in ascending order by user id. The 'user1' and 'user2' column are pairs of friends. (Meta)

WITH users as
(SELECT DISTINCT user1 users from facebook_friends 
UNION
 SELECT DISTINCT user2 users from facebook_friends)
SELECT users, SUM(CASE WHEN users IN (user1,user2) THEN 1 ELSE 0 END)/
(SELECT COUNT(*) FROM users)*100 percentage_popularity
FROM users, facebook_friends
GROUP BY users
ORDER BY users;


-- 10. We have a table with employees and their salaries, however, some of the records are old and contain outdated salary information. Find the current salary of each employee assuming that salaries increase each year. Output their id, first name, last name, department ID, and current salary. Order your list by employee ID in ascending order. (MS)

SELECT id, first_name, last_name, department_id, MAX(salary)
FROM ms_employee_salary
GROUP BY 1 , 2 , 3 , 4
ORDER BY id;


-- 11. Find the total number of downloads for paying and non-paying users by date. Include only records where non-paying customers have more downloads than paying customers. The output should be sorted by earliest date first and contain 3 columns: date, non-paying downloads, paying downloads. (MS)

SELECT date,
    SUM(CASE WHEN paying_customer = 'no' THEN downloads END) non_paying,
    SUM(CASE WHEN paying_customer = 'yes' THEN downloads END) paying
FROM ms_download_facts d
        JOIN
    ms_user_dimension u ON u.user_id = d.user_id
        JOIN
    ms_acc_dimension a ON a.acc_id = u.acc_id
GROUP BY 1
HAVING non_paying > paying
ORDER BY 1;


-- 12. Compare each employee's salary with the average salary of the corresponding department. Output the department, first name, and salary of employees along with the average salary of that department. (Salesforce)

WITH A AS(
SELECT DEPARTMENT, AVG(SALARY) AVG_SALARY
FROM EMPLOYEE
GROUP BY 1)
SELECT E.DEPARTMENT, FIRST_NAME, SALARY, AVG_SALARY 
FROM EMPLOYEE E
JOIN A
ON A.DEPARTMENT = E.DEPARTMENT
ORDER BY 1;

OR

SELECT DEPARTMENT, FIRST_NAME, SALARY, 
AVG(SALARY) OVER (PARTITION BY DEPARTMENT) AVG_SALARY 
FROM EMPLOYEE;


-- 13. Find the highest target achieved by the employee or employees who work under the manager id 13. Output the first name of the employee and target achieved. The solution should show the highest target achieved under manager_id=13 and which employee(s) achieved it. (Salesforce)

SELECT FIRST_NAME, TARGET 
FROM SALESFORCE_EMPLOYEES 
WHERE MANAGER_ID='13'  
AND TARGET = (
    SELECT MAX(TARGET)
    FROM SALESFORCE_EMPLOYEES
    WHERE MANAGER_ID = 13
    );

OR

SELECT FIRST_NAME, TARGET
FROM(
SELECT *, DENSE_RANK() OVER (PARTITION BY MANAGER_ID ORDER BY TARGET DESC) RANK_
FROM SALESFORCE_EMPLOYEES) T
WHERE MANAGER_ID = 13
AND RANK_ = 1;


-- 14. Find the employee with the highest salary per department. Output the department name, employee's first name along with the corresponding salary. (Twitter)

SELECT DEPARTMENT, FIRST_NAME, SALARY FROM(
SELECT *, DENSE_RANK() OVER (PARTITION BY DEPARTMENT ORDER BY SALARY DESC) RNK
FROM EMPLOYEE) T
WHERE RNK = 1;

OR

SELECT FIRST_NAME AS EMPLOYEE_NAME, DEPARTMENT , SALARY 
FROM EMPLOYEE  
WHERE SALARY IN (SELECT MAX(SALARY) FROM EMPLOYEE GROUP BY DEPARTMENT)  ;


-- 15. Find the top business categories based on the total number of reviews. Output the category along with the total number of reviews. Order by total reviews in descending order. (Yelp)

[PostgreSQL functions]
– string_to_array : split a string into array elements using supplied delimiter
– unnest() : expand an array to a set of rows

SELECT UNNEST(STRING_TO_ARRAY(CATEGORIES,';')) AS CATEGORY,
SUM(REVIEW_COUNT) REVIEW_COUNT
FROM YELP_BUSINESS
GROUP BY 1
ORDER BY 2 DESC;


-- 16. Find the review_text that received the highest number of  'cool' votes. Output the business name along with the review text with the highest number of 'cool' votes. (Yelp)

SELECT BUSINESS_NAME, REVIEW_TEXT
FROM YELP_REVIEWS
WHERE COOL = (SELECT MAX(COOL) FROM YELP_REVIEWS);


-- 17. Find the top 5 states with the most 5 star businesses. Output the state name along with the number of 5-star businesses and order records by the number of 5-star businesses in descending order. In case there are ties in the number of businesses, return all the unique states. If two states have the same result, sort them in alphabetical order. (Yelp)

SELECT STATE, STAR_COUNT
FROM(
SELECT *, RANK() OVER (ORDER BY STAR_COUNT DESC) RNK
FROM(
SELECT STATE, COUNT(STARS) STAR_COUNT
FROM YELP_BUSINESS
WHERE STARS = 5
GROUP BY 1
ORDER BY STATE) T
) T1
WHERE RNK <= 5;


-- 18. Find matching hosts and guests pairs in a way that they are both of the same gender and nationality. Output the host id and the guest id of the matched pair. (AirBnB)

SELECT DISTINCT H.HOST_ID, G.GUEST_ID
FROM AIRBNB_HOSTS H
JOIN AIRBNB_GUESTS G
ON H.NATIONALITY = G.NATIONALITY
AND H.GENDER = G.GENDER;


-- 19. Find the number of apartments per nationality that are owned by people under 30 years old. Output the nationality along with the number of apartments. Sort records by the apartments count in descending order. (AirBnB)

WITH HOST_DISTINCT AS (
SELECT DISTINCT HOST_ID, NATIONALITY, AGE FROM AIRBNB_HOSTS
ORDER BY HOST_ID)
SELECT H.NATIONALITY, COUNT(*) APARTMENT_COUNT
FROM HOST_DISTINCT H
JOIN AIRBNB_UNITS U
ON H.HOST_ID = U.HOST_ID
WHERE U.UNIT_TYPE = 'APARTMENT'
AND H.AGE < 30
GROUP BY 1;


-- 20. Rank guests based on the number of messages they've exchanged with the hosts. Guests with the same number of messages as other guests should have the same rank. Do not skip rankings if the preceding rankings are identical. Output the rank, guest id, and number of total messages they've sent. Order by the highest number of total messages first. (AirBnB)

SELECT DENSE_RANK() OVER (ORDER BY MESSAGES DESC) RANK_,
ID_GUEST, MESSAGES
FROM (
SELECT ID_GUEST, SUM(N_MESSAGES) MESSAGES
FROM AIRBNB_CONTACTS
GROUP BY 1) T;


-- 21. Count the number of user events performed by MacBookPro users. Output the result along with the event name. Sort the result based on the event count in the descending order. (Apple)
SELECT EVENT_NAME, COUNT(*) NUMBER_OF_EVENTS
FROM PLAYBOOK_EVENTS
WHERE DEVICE = 'MACBOOK PRO'
GROUP BY 1
ORDER BY 2 DESC;


-- 22. Find the activity date and the pe_description of facilities with the name 'STREET CHURROS' and with a score of less than 95 points. (City of Los Angeles)

SELECT ACTIVITY_DATE, PE_DESCRIPTION
FROM LOS_ANGELES_RESTAURANT_HEALTH_INSPECTIONS
WHERE FACILITY_NAME = 'STREET CHURROS'
AND SCORE < 95;


-- 23. Find libraries who haven't provided the email address in circulation year 2016 but their notice preference definition is set to email. Output the library code. (City of San Francisco)

SELECT DISTINCT HOME_LIBRARY_CODE
FROM LIBRARY_USAGE
WHERE PROVIDED_EMAIL_ADDRESS = 0
AND CIRCULATION_ACTIVE_YEAR = '2016'
AND NOTICE_PREFERENCE_DEFINITION = 'EMAIL';


-- 24. Find the base pay for Police Captains. Output the employee name along with the corresponding base pay. (City of San Francisco)

SELECT EMPLOYEENAME, BASEPAY
FROM SF_PUBLIC_SALARIES
WHERE JOBTITLE LIKE '%CAPTAIN%POLICE%';


-- 25. Find the last time each bike was in use. Output both the bike number and the date-timestamp of the bike's last use (i.e., the date-time the bike was returned). Order the results by bikes that were most recently used. (Lyft)

SELECT BIKE_NUMBER, MAX(END_TIME)
FROM DC_BIKESHARE_Q1_2012
GROUP BY 1
ORDER BY 2 DESC;


-- 26. Find all Lyft drivers who earn either equal to or less than 30k USD or equal to or more than 70k USD. Output all details related to retrieved records. (Lyft)

SELECT * 
FROM LYFT_DRIVERS
WHERE YEARLY_SALARY <= 30000
OR YEARLY_SALARY >= 70000;

OR 

SELECT * 
FROM LYFT_DRIVERS
WHERE YEARLY_SALARY NOT BETWEEN 30000 AND 70000;


-- 27. Find all posts which were reacted to with a heart. For such posts output all columns from facebook_posts table. (Meta)

SELECT DISTINCT P.* 
FROM FACEBOOK_POSTS P
JOIN FACEBOOK_REACTIONS R
ON P.POST_ID = R.POST_ID
WHERE R.REACTION = 'HEART';


-- 28. Count the number of movies that Abigail Breslin was nominated for an oscar. (Netflix)

SELECT COUNT(*) MOVIES
FROM OSCAR_NOMINEES
WHERE NOMINEE = 'ABIGAIL BRESLIN';


-- 29. Find the average total compensation based on employee titles and gender. Total compensation is calculated by adding both the salary and bonus of each employee. However, not every employee receives a bonus so disregard employees without bonuses in your calculation. Employees can receive more than one bonus. Output the employee title, gender (i.e., sex), along with the average total compensation.  (City of San Francisco)

WITH BONUS AS (
SELECT DISTINCT WORKER_REF_ID,
SUM(BONUS) OVER (PARTITION BY WORKER_REF_ID ) BONUS FROM SF_BONUS)
SELECT EMPLOYEE_TITLE,SEX, AVG(SALARY+BONUS) AVG_COMPENSATION
FROM BONUS B
LEFT JOIN SF_EMPLOYEE E
ON B.WORKER_REF_ID = E.ID
GROUP BY 1,2
ORDER BY 3 DESC;


-- 30. Write a query that'll identify returning active users. A returning active user is a user that has made a second purchase within 7 days of any other of their purchases. Output a list of user_ids of these returning active users. (Amazon)

SELECT DISTINCT USER_ID FROM(
SELECT *,
LEAD(CREATED_AT) OVER (PARTITION BY USER_ID ORDER BY CREATED_AT) LD
FROM AMAZON_TRANSACTIONS) T
WHERE DATEDIFF(LD,CREATED_AT)<7;


-- 31. Find the Olympics with the highest number of athletes. The Olympics game is a combination of the year and the season, and is found in the 'games' column. Output the Olympics along with the corresponding number of athletes. (ESPN)

SELECT GAMES, COUNT(DISTINCT ID) ATHLETES
FROM OLYMPICS_ATHLETES_EVENTS
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- 32. Find the most profitable company from the financial sector. Output the result along with the continent. (Forbes)

SELECT COMPANY, CONTINENT 
FROM FORBES_GLOBAL_2010_2014 WHERE PROFITS = (
SELECT MAX(PROFITS)
FROM FORBES_GLOBAL_2010_2014
WHERE SECTOR = 'FINANCIALS');


-- 33. Find the 3 most profitable companies in the entire world. Output the result along with the corresponding company name. Sort the result based on profits in descending order. (Forbes)

SELECT COMPANY, PROFITS
FROM FORBES_GLOBAL_2010_2014
ORDER BY 2 DESC
LIMIT 3;


-- 34. Find the number of times the words 'bull' and 'bear' occur in the contents. We're counting the number of times the words occur so words like 'bullish' should not be included in our count. Output the word 'bull' and 'bear' along with the corresponding number of occurrences. (Google)

[PostgreSQL]
SELECT WORDS,COUNT(*) FROM (
SELECT UNNEST(STRING_TO_ARRAY(CONTENTS, ' ')) WORDS
FROM GOOGLE_FILE_STORE) T
WHERE WORDS = 'bull’' OR WORDS = 'bear’
GROUP BY WORDS;

OR 

SELECT "bull" AS WORD, (SELECT COUNT(*) AS COUNT FROM GOOGLE_FILE_STORE WHERE LOWER(CONTENTS) LIKE '% bull %'
    ) AS COUNT
UNION
SELECT "bear" AS WORD, (SELECT COUNT(*) AS COUNT FROM GOOGLE_FILE_STORE WHERE LOWER(CONTENTS) LIKE '% bear %'
    ) AS COUNT


-- 35. Find the rate of processed tickets for each type. (Meta)

SELECT type, SUM(processed)/COUNT(*)
FROM facebook_complaints
GROUP BY type;


-- 36. Find how many times each artist appeared on the Spotify ranking list Output the artist name along with the corresponding number of occurrences. Order records by the number of occurrences in descending order. (Spotify)

SELECT ARTIST, COUNT(*) APPEARANCES
FROM SPOTIFY_WORLDWIDE_DAILY_SONG_RANKING
GROUP BY 1
ORDER BY 2 DESC;


-- 37. What were the top 10 ranked songs in 2010? Output the rank, group name, and song name but do not show the same song twice. Sort the result based on the year_rank in ascending order. (Spotify)

SELECT DISTINCT YEAR_RANK, GROUP_NAME, SONG_NAME
FROM BILLBOARD_TOP_100_YEAR_END
WHERE YEAR = '2010'
LIMIT 10;


-- 38. Find songs that have ranked in the top position. Output the track name and the number of times it ranked at the top. Sort your records by the number of times the song was in the top position in descending order. (Spotify)

SELECT TRACKNAME, COUNT(*) NUMBER_OF_TIMES_AT_TOP
FROM SPOTIFY_WORLDWIDE_DAILY_SONG_RANKING
WHERE POSITION = 1
GROUP BY 1
ORDER BY 2 DESC;


-- 39. Find all wineries which produce wines by possessing aromas of plum, cherry, rose, or hazelnut. To make it more simple, look only for singular form of the mentioned aromas.  Output unique winery values only. (Wine Magazine)

SELECT DISTINCT winery, description
FROM winemag_p1
WHERE LOWER(DESCRIPTION) REGEXP '(plum|rose|cherry|hazelnut)([^a-z])'
ORDER BY 1;


-- 40. Find the top 5 businesses with most reviews. Assume that each row has a unique business_id such that the total reviews for each business is listed on each row. Output the business name along with the total number of reviews and order your results by the total reviews in descending order. (Yelp)

SELECT name, review_count
FROM yelp_business
ORDER BY 2 desc
LIMIT 5;


-- 41. Given a table of purchases by date, calculate the month-over-month percentage change in revenue. The output should include the year-month date (YYYY-MM) and percentage change, rounded to the 2nd decimal point, and sorted from the beginning of the year to the end of the year. The percentage change column will be populated from the 2nd month forward and can be calculated as ((this month's revenue - last month's revenue) / last month's revenue)*100. (Amazon)

with revenue_table as (select DATE_FORMAT(created_at, '%Y-%m') y_m, sum(value) revenue
from sf_transactions
group by 1),
previous_revenue as(
select *, lag(revenue) over () previous_value
from revenue_table)
select y_m, round(((revenue-previous_value)/previous_value)*100,2) revenue_difference
from previous_revenue
order by y_m;


-- 42. Classify each business as either a restaurant, cafe, school, or other. A restaurant should have the word 'restaurant' in the business name. For cafes, either 'cafe', 'café', or 'coffee' can be in the business name. 'School' should be in the business name for schools. All other businesses should be classified as 'other'. Output the business name and the calculated classification. (City of San Francisco)

SELECT DISTINCT business_name,
CASE WHEN LOWER(business_name) like '%restaurant%' THEN 'restaurant' 
WHEN LOWER(business_name) REGEXP ('cafe|café|coffee') THEN 'cafe'
WHEN LOWER(business_name) like '%school%' THEN 'school'
ELSE 'other' END AS business_classification
FROM sf_restaurant_health_violations
ORDER BY 2;


-- 43. You're given a dataset of health inspections. Count the number of violation in an inspection in 'Roxanne Cafe' for each year. If an inspection resulted in a violation, there will be a value in the 'violation_id' column. Output the number of violations by year in ascending order. (City of San Francisco)

SELECT YEAR(inspection_date) year, COUNT(violation_id) violations
FROM  sf_restaurant_health_violations
WHERE business_name = 'Roxanne Cafe'
GROUP BY 1
ORDER BY 1;


-- 44. Find the customer with the highest daily total order cost between 2019-02-01 to 2019-05-01. If customer had more than one order on a certain day, sum the order costs on daily basis. Output customer's first name, total cost of their items, and the date. (Amazon)

SELECT first_name, order_date, SUM(total_order_cost) daily_order_cost
FROM customers c
JOIN orders o
ON c.id = o.cust_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;


-- 45. Find order details made by Jill and Eva. Consider Jill and Eva as first names of customers. Output the order date, details and cost along with the first name. Order records based on the customer id in ascending order. (Amazon)

select first_name, order_date, order_details, total_order_cost
from customers c
join orders o
on c.id = o.cust_id
where first_name in ('Jill','Eva')
order by 1;


-- 46. Find the details of each customer regardless of whether the customer made an order. Output the customer's first name, last name, and the city along with the order details. You may have duplicate rows in your results due to a customer ordering several of the same items. Sort records based on the customer's first name and the order details in ascending order. (Amazon)

select first_name, last_name, city, order_details
from customers c
left join orders o
on c.id = o.cust_id
order by 1,4;


-- 47. You’re given a table of rental property searches by users. The table consists of search results and outputs host information for searchers. Find the minimum, average, maximum rental prices for each host’s popularity rating. (Airbnb)

with host_search as(
select distinct CONCAT(price, room_type, host_since, zipcode, number_of_reviews) as host_id,  price, 
case when number_of_reviews = 0 then 'New'
when number_of_reviews between 1 and 5 then 'Rising'
when number_of_reviews between 6 and 15 then 'Trending Up'
when number_of_reviews between 16 and 40 then 'Popular'
when number_of_reviews >40 then 'Hot'
end as host_rating
from airbnb_host_searches)
select host_rating, min(price) min_price, max(price) max_price, avg(price) avg_price
from host_search
group by 1;


-- 48. Find the average number of bathrooms and bedrooms for each city’s property types. Output the result along with the city name and the property type. (Airbnb)

select city, property_type, avg(bathrooms) avg_bathrooms, avg(bedrooms) avg_bedrooms
from airbnb_search_details
group by 1,2;


-- 49. You have a table of in-app purchases by user. Users that make their first in-app purchase are placed in a marketing campaign where they see call-to-actions for more in-app purchases. Find the number of users that made additional in-app purchases due to the success of the marketing campaign.
The marketing campaign doesn't start until one day after the initial in-app purchase so users that only made one or multiple purchases on the first day do not count, nor do we count users that over time purchase only the products they purchased on the first day. (Amazon)

with temp as (SELECT
        user_id, created_at, product_id,
        DENSE_RANK() OVER(partition by user_id order by created_at) date_rnk,
        DENSE_RANK() OVER(partition by user_id, product_id order by created_at) product_rnk
    FROM marketing_campaign)
select count(*) users from(
select distinct user_id users
from temp
where date_rnk > 1 
and product_rnk = 1) t;


