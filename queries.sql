-- ==========================================
-- SQL Queries for Customer Shopping Behavior Analysis
-- Database: PostgreSQL
-- Table: customer_behavior
-- ==========================================

-- 1. Revenue by Gender
SELECT gender, SUM(purchase_amount) AS total_revenue
FROM customer_behavior
GROUP BY gender
ORDER BY total_revenue DESC;

-- 2. High-Spend Discount Users (Discount applied and spent above overall average purchase amount)
SELECT COUNT(*) AS high_spend_discount_users
FROM customer_behavior
WHERE discount_applied = 'Yes'
  AND purchase_amount > (SELECT AVG(purchase_amount) FROM customer_behavior);

-- 3. Top 5 Products by Average Rating
SELECT item_purchased, ROUND(AVG(review_rating)::numeric, 2) AS avg_rating
FROM customer_behavior
GROUP BY item_purchased
ORDER BY avg_rating DESC
LIMIT 5;

-- 4. Average Purchase Amount by Shipping Type
SELECT shipping_type, ROUND(AVG(purchase_amount)::numeric, 2) AS avg_purchase_amount
FROM customer_behavior
GROUP BY shipping_type
ORDER BY avg_purchase_amount DESC;

-- 5. Subscribers vs Non-Subscribers Count and Average Purchase Amount
SELECT subscription_status, COUNT(*) AS customer_count, ROUND(AVG(purchase_amount)::numeric, 2) AS avg_purchase_amount
FROM customer_behavior
GROUP BY subscription_status;

-- 6. Discount-Dependent Products (Percentage of item purchases made with a discount applied)
SELECT item_purchased,
       COUNT(CASE WHEN discount_applied = 'Yes' THEN 1 END) AS discount_purchases,
       COUNT(*) AS total_purchases,
       ROUND((COUNT(CASE WHEN discount_applied = 'Yes' THEN 1 END) * 100.0 / COUNT(*))::numeric, 1) AS discount_percentage
FROM customer_behavior
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;

-- 7. Customer Segmentation based on Previous Purchases
-- New: 1 or fewer previous purchases
-- Returning: Between 2 and 10 previous purchases
-- Loyal: More than 10 previous purchases
SELECT
  CASE
    WHEN previous_purchases <= 1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
    ELSE 'Loyal'
  END AS customer_segment,
  COUNT(*) AS customer_count
FROM customer_behavior
GROUP BY customer_segment
ORDER BY customer_count ASC;

-- 8. Top 3 Products per Category (by total purchase amount/revenue)
WITH ranked_products AS (
  SELECT category, item_purchased, SUM(purchase_amount) AS revenue,
         ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(purchase_amount) DESC) AS rank
  FROM customer_behavior
  GROUP BY category, item_purchased
)
SELECT category, item_purchased, revenue
FROM ranked_products
WHERE rank <= 3;

-- 9. Repeat Buyers (> 5 previous purchases) by Subscription Status
SELECT subscription_status, COUNT(*) AS repeat_buyers_count
FROM customer_behavior
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- 10. Revenue by Age Group
-- Young Adult: 18-31
-- Adult: 32-44
-- Middle-Aged: 45-57
-- Senior: 58-70
SELECT
  CASE
    WHEN age BETWEEN 18 AND 31 THEN 'Young Adult'
    WHEN age BETWEEN 32 AND 44 THEN 'Adult'
    WHEN age BETWEEN 45 AND 57 THEN 'Middle-Aged'
    ELSE 'Senior'
  END AS age_segment,
  SUM(purchase_amount) AS total_revenue
FROM customer_behavior
GROUP BY age_segment
ORDER BY total_revenue DESC;
