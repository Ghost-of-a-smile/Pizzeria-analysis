-- Creating tables for futher downloading data from excel (csv)
CREATE TABLE orders(order_id  INT NOT NULL AUTO_INCREMENT,
					order_date DATE,
                    order_time TIME,
                    PRIMARY KEY(order_id));
                    
CREATE TABLE order_details(order_details_id INT NOT NULL AUTO_INCREMENT,
						   order_id INT,
                           quantity INT,
                           total_price DECIMAL(5,2),
                           PRIMARY KEY(order_details_id),
                           FOREIGN KEY(order_id) REFERENCES orders(order_id));
                           
CREATE TABLE pizza_types(pizza_id VARCHAR(50),
						 pizza_name VARCHAR(75),
                         pizza_category VARCHAR(25),
                         pizza_ingredients VARCHAR(200),
						 PRIMARY KEY(pizza_id));
                       
CREATE TABLE pizzas(pizza_details_id INT NOT NULL AUTO_INCREMENT,
					pizza_id VARCHAR(50),
					pizza_size ENUM('XXL', 'XL', 'L', 'M', 'S'),
					unit_price DECIMAL(4,2),
					PRIMARY KEY(pizza_details_id),
					FOREIGN KEY(pizza_id) REFERENCES pizza_types(pizza_id),
                    FOREIGN KEY(pizza_details_id) REFERENCES order_details(order_details_id));   

-- Filling tables with data from dataset and testing

-- Getting answers


-- 1. What days and times do we tend to be busiest?


SELECT AVG(quantity)
FROM order_details;

-- TOP 5 busiest days

SELECT DAY(order_date) AS _day,
	   COUNT(order_id) AS count_orders
FROM order_details od
INNER JOIN orders o USING(order_id)
GROUP BY DAY(order_date)
ORDER BY COUNT(order_id) DESC
LIMIT 5;

-- TOP 5 busiest hours

SELECT HOUR(order_time) AS _hour,
	   COUNT(o.order_id) AS count_orders
FROM order_details od
INNER JOIN orders o USING(order_id)
GROUP BY HOUR(order_time)
ORDER BY COUNT(o.order_id) DESC
LIMIT 5;


-- 2. How many pizzas are we making during peak periods?

-- Peak periods will be called hours when there are amount of orders which is more than "AVG(COUNT(order_id)) + AVG(COUNT(order_id))/2"

WITH c_orders AS
(SELECT HOUR(order_time) AS _hour,
	    COUNT(order_id) AS count_orders -- 21350
FROM orders
GROUP BY 1)

SELECT AVG(count_orders)
FROM c_orders; -- 1423.3

SELECT HOUR(order_time) AS _hour,
	   COUNT(order_id) AS count_orders
FROM orders
GROUP BY 1
HAVING COUNT(order_id) > 1423.3 + 1423.3/2; -- Peak hours are 12, 13, 17 and 18

-- Now let's get to know how many pizzas the restaurant making during these hours in total and in average

WITH sum_quantity AS
(SELECT HOUR(order_time) AS _hour,
	   SUM(quantity) AS pizza_quantity
FROM orders o
INNER JOIN order_details od ON o.order_id = od.order_id
WHERE HOUR(order_time) IN(12, 13, 17, 18)
GROUP BY 1) -- in total by the end on of the year 

-- SELECT AVG(pizza_quantity)/365 + (AVG(pizza_quantity)/365)/2
-- FROM sum_quantity

SELECT _hour,
	   ROUND(pizza_quantity/365, 2) AS avg_quantity
FROM sum_quantity; -- average in an every peak hour during the whole year

-- 3. What are our best and worst selling pizzas?

SELECT pizza_name,
	   unit_price,
	   SUM(quantity),
	   SUM(total_price)
FROM order_details od
INNER JOIN pizzas p ON od.order_details_id = p.pizza_details_id
INNER JOIN pizza_types pt USING(pizza_id)
GROUP BY 1, 2
ORDER BY 4 DESC, 3 DESC; 

SELECT pizza_id,
	   pizza_name,
	   unit_price,
	   SUM(quantity),
	   SUM(total_price)
FROM order_details od
INNER JOIN pizzas p ON od.order_details_id = p.pizza_details_id
INNER JOIN pizza_types pt USING(pizza_id)
GROUP BY 1, 2, 3
ORDER BY 4 ASC, 3 ASC;      
       
SELECT pizza_name,
	   unit_price,
	   SUM(quantity)
FROM order_details od
INNER JOIN pizzas p ON od.order_details_id = p.pizza_details_id
INNER JOIN pizza_types pt USING(pizza_id)
GROUP BY 1, 2
ORDER BY 3 DESC; -- the most popular pizzas regarding sales quantity

SELECT pizza_name,
	   unit_price,
	   SUM(quantity)
FROM order_details od
INNER JOIN pizzas p ON od.order_details_id = p.pizza_details_id
INNER JOIN pizza_types pt USING(pizza_id)
GROUP BY 1, 2
ORDER BY 3 ASC;  -- the most unpopular pizzas regarding sales quantity   

SELECT pizza_name,
	   unit_price,
	   SUM(total_price)
FROM order_details od
INNER JOIN pizzas p ON od.order_details_id = p.pizza_details_id
INNER JOIN pizza_types pt USING(pizza_id)
GROUP BY 1, 2
ORDER BY 3 DESC; -- the most lucrative pizzas regarding total profit

SELECT pizza_name,
	   unit_price,
	   SUM(total_price)
FROM order_details od
INNER JOIN pizzas p ON od.order_details_id = p.pizza_details_id
INNER JOIN pizza_types pt USING(pizza_id)
GROUP BY 1, 2
ORDER BY 3 ASC;   -- the most non-profit pizzas


-- 4. What's our average order value? AOV = "Средний чек"


SELECT SUM(total_price) AS revenue,
	   COUNT(o.order_id) AS orders_amount,
       ROUND(SUM(total_price)/COUNT(o.order_id), 2) AS AOV
FROM orders o
INNER JOIN order_details od USING(order_id); -- AOV for the year = 16,82 

SELECT order_date,
	   ROUND(SUM(total_price)/COUNT(o.order_id), 2) AS AOV
FROM orders o
INNER JOIN order_details od USING(order_id)
GROUP BY 1;  

-- 5. How well are we utilizing our seating capacity? (we have 15 tables and 60 seats)

-- To assess how well the restaurant is using its seating capacity, 
-- we need to check how many clients the restaurant has in average during a usual hour and during a peak hour 
-- and how many pizzas the clients get

SELECT HOUR(order_time) AS _hour,
	   ROUND(COUNT(o.order_id)/365, 2) AS orders_amount,
       ROUND(SUM(quantity)/365, 2) AS pizzas_sum
FROM orders o
INNER JOIN order_details od USING(order_id)
GROUP BY 1
ORDER BY 2 DESC, 3 DESC;
       
-- So we also have something in our data that will help to assess the seating capacity,
-- to be more specific - the size of the pizza.
-- So, let's say that the S-size pizza is for 1 person, M-size - for 2, L-size - for 3, XL - for 4, XXL - for 5 people

SELECT pizza_size,
	   ROUND(COUNT(pizza_size)/365, 2) AS orders_amount
FROM pizzas
GROUP BY 1;

WITH avg_clients AS
(WITH total_clients AS
(WITH size_orders_amount AS
(SELECT HOUR(order_time) AS _hour,
	   pizza_size,
	   ROUND(COUNT(o.order_id)/365, 2) AS orders_amount,
       ROUND(SUM(quantity)/365, 2) AS pizzas_sum,
       COUNT(pizza_size) AS total_size_orders
FROM orders o
INNER JOIN order_details od USING(order_id)
INNER JOIN pizzas p ON od.order_details_id = p.pizza_details_id
GROUP BY 1, 2
ORDER BY 1, 5 DESC)

SELECT _hour,
	   IF(pizza_size = 'S', SUM(orders_amount)*1, 
       IF(pizza_size = 'M', SUM(orders_amount)*2,
       IF(pizza_size = 'L', SUM(orders_amount)*3,
       IF(pizza_size = 'XL', SUM(orders_amount)*4,
       IF(pizza_size = 'XXL', SUM(orders_amount)*5, 0))))) AS clients_amount
FROM size_orders_amount
GROUP BY _hour, pizza_size)

SELECT _hour,
	   SUM(clients_amount) AS clients_amount
FROM total_clients
GROUP BY 1
ORDER BY 2 DESC)    
 
SELECT AVG(clients_amount)
FROM avg_clients;


-- Now the final step - getting separately some most significant values for better visualizations


-- total amount of orders

SELECT COUNT(order_id) AS total_orders
FROM orders;

-- total revenue

SELECT SUM(total_price) AS revenue
FROM order_details;

-- total sold pizzas

SELECT SUM(quantity) AS total_pizzas
FROM order_details;