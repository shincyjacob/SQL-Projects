-- source : chandoo.org
use awesome_chocolates;
-- 1. Print details of shipments (sales) where amounts are > 2,000 and boxes are <100?
SELECT *
FROM sales
WHERE amount > 2000 AND boxes < 100;
-- 2. How many shipments (sales) each of the sales persons had in the month of January 2022?
SELECT salesperson, COUNT(*) no_of_shipments
FROM sales
JOIN people
ON sales.spid = people.spid
WHERE MONTH(saledate) = 1 AND YEAR(saledate) = 2022
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Which product sells more boxes? Milk Bars or Eclairs?
SELECT product, SUM(boxes) boxes
FROM products
JOIN sales 
ON products.pid = sales.pid
WHERE product IN ('Milk Bars' , 'Eclairs')
GROUP BY 1
ORDER BY 2 DESC;

-- 4. Which product sold more boxes in the first 7 days of February 2022? Milk Bars or Eclairs?
SELECT product, SUM(boxes) boxes
FROM products
JOIN sales 
ON products.pid = sales.pid
WHERE product IN ('Milk Bars' , 'Eclairs')
AND saledate between '2022-02-01' and '2022-02-07'
GROUP BY 1
ORDER BY 2 DESC;

-- 5. Which shipments had under 100 customers & under 100 boxes? Did any of them occur on Wednesday?
SELECT  *
FROM sales
WHERE customers < 100 AND boxes < 100;
SELECT count(*) sales_wednesday
FROM sales
WHERE customers < 100 AND boxes < 100
AND weekday(saledate) = 2;

-- 6. What are the names of salespersons who had at least one shipment (sale) in the first 7 days of January 2022?
SELECT distinct salesperson
FROM sales
JOIN people
ON sales.spid = people.spid
WHERE saledate between '2022-01-01' and '2022-01-07'
ORDER BY 1;

-- 7. Which salespersons did not make any shipments in the first 7 days of January 2022?
SELECT salesperson FROM people
WHERE salesperson NOT IN 
(SELECT distinct salesperson
FROM sales
JOIN people
ON sales.spid = people.spid
WHERE saledate between '2022-01-01' and '2022-01-07')
ORDER BY 1;

-- 8. How many times we shipped more than 1,000 boxes in each month?
SELECT YEAR(saledate) year_sales, MONTH(saledate) month_sales, COUNT(*) shipped_more_than_1000_boxes
FROM sales
WHERE boxes > 1000
GROUP BY 1,2
ORDER BY 1,2;

-- 9. Did we ship at least one box of ‘After Nines’ to ‘New Zealand’ on all the months?
SELECT *,
CASE WHEN sales > 0 THEN 'Yes' ELSE 'No' END AS 'Shipped at least one box of After Nines to New Zealand'
FROM
	(SELECT YEAR(Saledate) 'Year' ,MONTH(Saledate) 'Month' , SUM(boxes) sales
	FROM products p
	JOIN sales s 
	ON p.pid = s.pid
	JOIN geo g 
	ON s.geoid = g.geoid
	WHERE product = 'After Nines' AND geo = 'New Zealand'
	GROUP BY 1,2
	ORDER BY 1,2) t;

-- 10. India or Australia? Who buys more chocolate boxes on a monthly basis?
SELECT year(saledate) 'Year', month(saledate) 'Month', 
SUM(CASE WHEN g.geo='India' THEN boxes ELSE 0 END) India,
SUM(CASE WHEN g.geo='Australia' THEN boxes ELSE 0 END) Australia
FROM sales s
JOIN geo g 
ON s.geoid = g.geoid
GROUP BY 1,2
ORDER BY 1,2;
