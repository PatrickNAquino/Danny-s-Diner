# Customer Behavior Analysis
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

![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/d3d734e9-b16a-4b7c-9f4c-a86cf3dc112e)


Rank All The Things

Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/98c6ad87-9faa-4731-bc75-f44acb5fbc32)

### Answers

1. What is the total amount each customer spent at the restaurant?
```mysql
SELECT
	sales.customer_id,
	SUM(menu.price) AS total_amount
FROM sales
LEFT JOIN menu USING(product_id)
GROUP BY 1
ORDER BY 2 DESC
;
```
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/7a1269f3-f0c1-4f03-b3b3-6279cbce2307)


2. How many days has each customer visited the restaurant?
```mysql
SELECT
	customer_id,
	COUNT(DISTINCT order_date) AS days
FROM sales
GROUP BY 1
ORDER BY 2 DESC
;
```
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/d864e9a6-4754-4338-96dd-29b20d413ca7)

3. What was the first item from the menu purchased by each customer?
```mysql
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
```
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/a11ef0f5-79cb-48d5-a31d-98e9cb1fc214)

4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```mysql
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

-- Best way using subquery
SELECT
	customer_id,
	COUNT(product_id) times_purchased_ramen
FROM sales
INNER JOIN menu USING(product_id)
WHERE product_name = (
			SELECT product_name
            		FROM(
				SELECT
					product_name,
					COUNT(product_name)
				FROM sales
				INNER JOIN menu USING(product_id)
				GROUP BY 1
				ORDER BY 2 DESC
				LIMIT 1
			) AS subquery)
GROUP BY 1
;
```
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/198f2fe2-1191-4067-9dfa-ca3fa368f730)

5. Which item was the most popular for each customer?
```mysql
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
```
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/cf49c216-1f24-4854-acbe-4032af8ec77b)

6. Which item was purchased first by the customer after they became a member?
```mysql
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
```
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/31005f20-2366-4877-b00e-0bc546bfd2ed)

7. Which item was purchased just before the customer became a member?
```mysql
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
```
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/e81dc1d5-f4f9-48b3-ada0-a9a64b8bef52)

8. What is the total items and amount spent for each member before they became a member?
```mysql
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
```
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/d6699608-e05d-4288-a7fa-ca36f89f2225)

9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```mysql
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
```
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/6d0b845a-11e9-4a5d-8a82-2a86cea67de2)

10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```mysql
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
	GROUP BY 1,2,3,4,5
) AS sub
GROUP BY 1
;
```
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/b733cb38-0b98-4fa5-98d1-bc638e576c23)

-- BONUS QUESTIONS

Join All The Things
```mysql
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
```
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/4f0bfb22-a18a-4184-92bb-7c5f12bf6920)

Rank All The Things
```mysql
WITH CTE_joined_table
AS (
	SELECT
		customer_id,
		order_date,
		product_name,
		price,
		CASE WHEN order_date >= join_date THEN 'y' ELSE 'N' END AS member,
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
![image](https://github.com/PatrickNAquino/Danny-s-Diner/assets/118391206/b05b328b-e4b7-48f5-ab2a-76257d486d2b)
