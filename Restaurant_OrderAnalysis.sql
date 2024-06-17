/*
Exploring items table

My first objective is to better understand the items table by finding the
number of rows in the table, the least and most expensive items, and the item
prices within each category.

*/

-- Look through the menu_items table
SELECT *
FROM menu_items;

-- Count the total number of records in the menu_items table
SELECT COUNT(*)
FROM menu_items;

-- Find the menu item with the highest price
SELECT *
FROM menu_items
ORDER BY price DESC
LIMIT 1;


-- Find the menu item with the lowest price
SELECT *
FROM menu_items
ORDER BY price
LIMIT 1;

-- Count the number of Italian dishes
SELECT COUNT(*)
FROM menu_items
WHERE category = 'Italian';

-- Found the most expensive Italian item
SELECT *
FROM menu_items
WHERE category = 'Italian'
ORDER BY price DESC
LIMIT 1;

-- Found the most cheapest Italian item
SELECT *
FROM menu_items
WHERE category = 'Italian'
ORDER BY price
LIMIT 1;

-- Found the number of dishes in each category and the average dish price within each category
SELECT category, COUNT(category) , CONCAT('$',ROUND(AVG(price),2)) AS avg_price
FROM menu_items
GROUP BY category;

/*
Exploring the orders table

My second objective is to better understand the orders table by finding the 
date range, the number of items within each order, and the orders with the 
highest number of items.

*/

-- Look at all the columns from the order_details table
SELECT * 
FROM order_details

-- Find date range
SELECT MIN(order_date), MAX(order_date)
FROM order_details;

--Number of orders made within the date range
SELECT COUNT(DISTINCT order_id)
FROM order_details;

--Number of items ordered within this date range
SELECT COUNT(DISTINCT order_details_id)
FROM order_details;

--Order that had the most number of item
SELECT order_id, COUNT(DISTINCT order_details_id) AS num_items
FROM order_details
GROUP BY order_id
ORDER BY num_items DESC;

--Number of order that had more than 12 items
SELECT COUNT(*)
FROM (
	SELECT order_id, COUNT(DISTINCT order_details_id) AS num_items
	FROM order_details
	GROUP BY order_id
	HAVING COUNT(DISTINCT order_details_id) > 12
	ORDER BY num_items DESC
);

/*
Analyze customer behavior

My last objective is to combine the items and order tables, find the least 
and most ordered categories, and dive into the details of the highest spend
orders.
*/

--Created a temporary table with joined order and item table to make things easier
CREATE TEMPORARY TABLE joined_table AS
(
	SELECT *
	FROM order_details AS o
	LEFT JOIN menu_items AS m
	ON m.menu_item_id = o.item_id
);

--Finding the most ordered item and the category that they are in
(SELECT item_name, category, COUNT(*) AS item_count
FROM joined_table
GROUP BY item_name, category
ORDER BY item_count DESC
LIMIT 1)

UNION
--finding the least ordered item and the category that they are in
(SELECT item_name, category, COUNT(*) AS item_count
FROM joined_table
GROUP BY item_name, category
ORDER BY item_count ASC
LIMIT 1)

--Created a cte of the top 5 highest spend orders
WITH top5 AS(
	SELECT order_id, SUM(price) AS total
	FROM joined_table 
	WHERE price IS NOT NULL
	GROUP BY order_id 
	ORDER BY total DESC
	LIMIT 5
)

--Provide details for the top 5 orders
SELECT *
FROM joined_table
WHERE order_id IN (SELECT order_id FROM top5)


