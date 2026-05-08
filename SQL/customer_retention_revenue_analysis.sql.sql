select * from customer limit 20;

-- Q1. Which customer group (by gender) contributes more to overall revenue, and how significant is the gap?
SELECT gender, SUM(purchase_amount) AS total_revenue, ROUND(100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount))
OVER (), 2) AS revenue_percentage FROM customer GROUP BY gender ORDER BY total_revenue DESC;

-- Q2. Identify high-value customers who used discounts but still spent above the overall average purchase amount.
SELECT customer_id, purchase_amount FROM customer WHERE discount_applied = 'Yes' AND purchase_amount > (SELECT AVG(purchase_amount)
FROM customer) ORDER BY purchase_amount DESC;

-- Q3. Which products consistently receive the highest customer satisfaction based on average review ratings?
SELECT item_purchased, ROUND(AVG(review_rating)::numeric, 2) AS avg_rating, COUNT(*) AS total_reviews
FROM customer GROUP BY item_purchased HAVING COUNT(*) > 10 ORDER BY avg_rating DESC LIMIT 5;

-- Q4. How does purchase behavior differ across shipping types, and which method leads to higher spending?
SELECT shipping_type, ROUND(AVG(purchase_amount), 2) AS avg_purchase, SUM(purchase_amount) AS total_revenue,
COUNT(*) AS total_orders FROM customer GROUP BY shipping_type ORDER BY avg_purchase DESC;

-- Q5. Do subscribed customers generate more revenue compared to non-subscribers?
SELECT subscription_status, COUNT(DISTINCT customer_id) AS total_customers, ROUND(AVG(purchase_amount), 2) AS avg_spend,
SUM(purchase_amount) AS total_revenue FROM customer GROUP BY subscription_status ORDER BY total_revenue DESC;

-- Q6. Which products are most dependent on discounts, based on the percentage of discounted purchases?
SELECT item_purchased, ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2)
AS discount_dependency_percentage FROM customer GROUP BY item_purchased ORDER BY discount_dependency_percentage DESC LIMIT 5;

-- Q7. How are customers distributed across lifecycle stages (New, Returning, Loyal) based on purchase history?
SELECT customer_segment, COUNT(*) AS total_customers FROM (SELECT customer_id, CASE WHEN previous_purchases = 1 THEN 'New'
WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning' ELSE 'Loyal' END AS customer_segment FROM customer) AS sub
GROUP BY customer_segment ORDER BY total_customers DESC;

-- Q8. Which products dominate each category based on order volume?
SELECT item_rank, category, item_purchased, total_orders FROM (SELECT category, item_purchased, COUNT(*) AS total_orders,
ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS item_rank FROM customer
GROUP BY category, item_purchased) AS ranked_products WHERE item_rank <= 3 ORDER BY category, item_rank;

-- Q9. Are frequent buyers more likely to become subscribers?
SELECT subscription_status, COUNT(*) AS frequent_buyers, ROUND(AVG(previous_purchases)::numeric, 2) AS avg_previous_purchases,
ROUND(AVG(purchase_amount)::numeric, 2) AS avg_purchase_amount FROM customer WHERE previous_purchases > 5
GROUP BY subscription_status ORDER BY frequent_buyers DESC;

-- Q10. Which age groups contribute the most revenue and customer volume?
SELECT age_group, COUNT(DISTINCT customer_id) AS total_customers, SUM(purchase_amount) AS total_revenue,
ROUND(AVG(purchase_amount)::numeric, 2) AS avg_purchase_amount FROM customer GROUP BY age_group ORDER BY total_revenue DESC;
