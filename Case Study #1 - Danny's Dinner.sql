-- Case Study #1 - Danny's Diner

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	sales.customer_id,
    SUM(menu.price) AS total_amount
FROM sales
LEFT JOIN menu USING(product_id)
GROUP BY 1
ORDER BY 2 DESC
;

-- 2. How many days has each customer visited the restaurant?
SELECT
	customer_id,
	COUNT(DISTINCT order_date) AS days
FROM sales
GROUP BY 1
ORDER BY 2 DESC
;

-- 3. What was the first item from the menu purchased by each customer?
SELECT
	customer_id,
	MIN(order_date)
FROM sales
GROUP BY 1
;

SELECT
customer_id,
product_name
FROM(
SELECT
customer_id,
product_name,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY product_name, customer_id DESC) as rn
FROM sales
INNER JOIN menu USING(product_id)
WHERE order_date = '2021-01-01' -- min date is the same for all customers
) AS sub
WHERE rn = 1
;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	product_name,
    COUNT(product_name)
FROM sales
INNER JOIN menu USING(product_id)
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1
;
-- ramen is the most purchased product

SELECT
	customer_id,
    COUNT(product_id) times_purchased_ramen
FROM sales
INNER JOIN menu USING(product_id)
WHERE product_name = 'ramen'
GROUP BY 1
;

-- 5. Which item was the most popular for each customer?

SELECT
customer_id,
product_name,
qtd_product
FROM(
SELECT
	customer_id,
	product_name,
    COUNT(product_name) AS qtd_product,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY COUNT(product_name) DESC, customer_id) as rn
FROM sales
INNER JOIN menu USING(product_id)
GROUP BY 1,2
ORDER BY 1,3 DESC
) AS sub
WHERE rn = 1
GROUP BY 1,2
;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT
	customer_id,
    product_name
FROM(
SELECT
	*,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY join_date, customer_id) AS rn
FROM sales
LEFT JOIN menu USING(product_id)
LEFT JOIN members USING(customer_id)
WHERE order_date >= join_date
) AS sub
WHERE rn = 1
;

-- 7. Which item was purchased just before the customer became a member?
SELECT
	customer_id,
    product_name
FROM(
SELECT
	*,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY join_date, customer_id) AS rn
FROM sales
LEFT JOIN menu USING(product_id)
LEFT JOIN members USING(customer_id)
WHERE order_date < join_date
) AS sub
WHERE rn = 1
;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT
	customer_id,
    COUNT(product_id) AS items,
    SUM(price) AS amount_spent
FROM sales
LEFT JOIN menu USING(product_id)
LEFT JOIN members USING(customer_id)
WHERE order_date < join_date
GROUP BY 1
;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	customer_id,
    SUM(CASE
		WHEN product_name = 'sushi' THEN price*10*2
        ELSE price*10
    END) AS points
FROM sales
LEFT JOIN menu USING(product_id)
LEFT JOIN members USING(customer_id)
WHERE order_date >= join_date
GROUP BY 1
;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT
	customer_id,
    SUM(points) AS points
FROM(
SELECT
	customer_id,
    product_name,
    price,
    order_date,
    join_date,
    order_date - join_date,
    SUM(CASE
		WHEN product_name = 'sushi' THEN price*10*2
        WHEN (order_date - join_date) < 7 THEN price*10*2
        ELSE price*10
    END) AS points
FROM sales
LEFT JOIN menu USING(product_id)
LEFT JOIN members USING(customer_id)
WHERE order_date >= join_date
	AND MONTH(order_date) = '01'
GROUP BY 1,2,3,4,5) AS sub
GROUP BY 1
;

-- BONUS QUESTIONS

SELECT
	customer_id,
    order_date,
    product_name,
    price,
    CASE
		WHEN order_date >= join_date THEN 'y' ELSE 'N'
    END AS member
FROM sales
LEFT JOIN menu USING(product_id)
LEFT JOIN members USING(customer_id)
;

-- Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

WITH CTE_joined_table
AS (
SELECT
	customer_id,
    order_date,
    product_name,
    price,
    CASE
		WHEN order_date >= join_date THEN 'y' ELSE 'N'
    END AS member,
    ROW_NUMBER() OVER(PARTITION BY customer_id) AS rn
FROM sales
LEFT JOIN menu USING(product_id)
LEFT JOIN members USING(customer_id)	
)
SELECT
 customer_id,
 order_date,
 product_name,
 price,
 member,
 CASE WHEN member = 'Y' THEN RANK() OVER(PARTITION BY customer_id, member ORDER BY rn) ELSE NULL END AS ranking
 FROM CTE_joined_table
 ;

