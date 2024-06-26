# Danny-s-Diner
First case study from the 8 week SQL challenge (https://8weeksqlchallenge.com/case-study-1/)

![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/823b9411-27f4-44b2-b66a-3bb7f98c654e)

### Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

### Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:

- sales
- menu
- members

### Entity Relationship Diagram
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/1a77fa47-415e-41cb-8867-a191c50b89e4)

### Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

### Bonus Questions
Join All The Things

The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

Recreate the following table output using the available data:

customer_id	order_date	product_name	price	member
A	2021-01-01	curry	15	N
A	2021-01-01	sushi	10	N
A	2021-01-07	curry	15	Y
A	2021-01-10	ramen	12	Y
A	2021-01-11	ramen	12	Y
A	2021-01-11	ramen	12	Y
B	2021-01-01	curry	15	N
B	2021-01-02	curry	15	N
B	2021-01-04	sushi	10	N
B	2021-01-11	sushi	10	Y
B	2021-01-16	ramen	12	Y
B	2021-02-01	ramen	12	Y
C	2021-01-01	ramen	12	N
C	2021-01-01	ramen	12	N
C	2021-01-07	ramen	12	N

Rank All The Things

Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

customer_id	order_date	product_name	price	member	ranking
A	2021-01-01	curry	15	N	null
A	2021-01-01	sushi	10	N	null
A	2021-01-07	curry	15	Y	1
A	2021-01-10	ramen	12	Y	2
A	2021-01-11	ramen	12	Y	3
A	2021-01-11	ramen	12	Y	3
B	2021-01-01	curry	15	N	null
B	2021-01-02	curry	15	N	null
B	2021-01-04	sushi	10	N	null
B	2021-01-11	sushi	10	Y	1
B	2021-01-16	ramen	12	Y	2
B	2021-02-01	ramen	12	Y	3
C	2021-01-01	ramen	12	N	null
C	2021-01-01	ramen	12	N	null
C	2021-01-07	ramen	12	N	null

### Answers

```mysql
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
  WHEN product_name = 'sushi' THEN price*10*2 ELSE price*10 END) AS points
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
```
