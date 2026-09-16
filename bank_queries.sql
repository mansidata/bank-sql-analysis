-- ============================================================
-- Retail Banking Practice Database — Solved Business Queries
-- ============================================================
-- Uses: bank_practice (see bank_setup.sql for schema)
-- ============================================================

-- ------------------------------------------------------------
-- 1. Foundations: filtering, sorting, aggregation
-- ------------------------------------------------------------

-- How many customers do we have per city?
SELECT city, COUNT(customer_id) AS customer_count
FROM customers
GROUP BY city
ORDER BY COUNT(customer_id) DESC;

-- Total balance held per account type, only types exceeding 1 crore
SELECT account_type, SUM(balance) AS total_balance
FROM accounts
GROUP BY account_type
HAVING SUM(balance) > 10000000
ORDER BY SUM(balance) DESC;

-- Customers whose name starts with 'A'
SELECT full_name, city
FROM customers
WHERE full_name LIKE 'A%';

-- Top 3 highest-balance accounts
SELECT account_id, balance
FROM accounts
ORDER BY balance DESC
LIMIT 3;

-- Label each account as High or Low tier based on balance
SELECT account_id, balance,
       CASE
           WHEN balance > 1000000 THEN 'High'
           ELSE 'Low'
       END AS tier
FROM accounts;

-- Count of transactions in June
SELECT COUNT(txn_id)
FROM transactions
WHERE MONTH(txn_date) = 6;

-- ------------------------------------------------------------
-- 2. JOINs and business scenarios
-- ------------------------------------------------------------

-- HNI Product Targeting: HNI customers with total balance
-- above a defined threshold, for a Platinum Card campaign
SELECT c.customer_id, c.full_name, SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
WHERE c.segment = 'HNI'
GROUP BY c.customer_id, c.full_name
HAVING SUM(a.balance) > 5000000
ORDER BY SUM(a.balance) DESC;

-- Top 3 richest customers in cities starting with 'M'
SELECT c.full_name, c.city, SUM(a.balance) AS total_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
WHERE c.city LIKE 'M%'
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY SUM(a.balance) DESC
LIMIT 3;

-- Dormant Account Detection: accounts with zero transactions
-- (LEFT JOIN + IS NULL pattern)
SELECT a.account_id, a.account_type, a.balance
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE t.account_id IS NULL;

-- ------------------------------------------------------------
-- 3. Subqueries
-- ------------------------------------------------------------

-- Correlated subquery: transactions above their OWN channel's
-- average amount (not the overall average)
SELECT t.txn_id, t.channel, t.amount
FROM transactions t
WHERE t.amount > (
    SELECT AVG(t2.amount)
    FROM transactions t2
    WHERE t.channel = t2.channel
);

-- Correlated subquery: customers whose balance exceeds their
-- OWN segment's average balance
SELECT c.customer_id, c.full_name, c.segment, a.balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
WHERE a.balance > (
    SELECT AVG(a2.balance)
    FROM accounts a2
    JOIN customers c2 ON a2.customer_id = c2.customer_id
    WHERE c2.segment = c.segment
);
