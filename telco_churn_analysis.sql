-- ============================================================
-- Telco Customer Churn Analysis
-- ============================================================
-- Public dataset (Kaggle: Telco Customer Churn, ~7,032 rows),
-- imported into MySQL and analyzed using the same SQL patterns
-- developed on the practice banking database — to test whether
-- these skills transfer to a real-world, unfamiliar dataset.
-- ============================================================

-- Create a simplified view over the raw imported table
-- (original table name is long and hyphenated)
CREATE VIEW telco_customers AS
SELECT * FROM telco_practice.`wa_fn-usec_-telco-customer-churn`;

-- Quick look at the data
SELECT *
FROM telco_customers
LIMIT 10;

-- ------------------------------------------------------------
-- 1. Foundations
-- ------------------------------------------------------------

-- How many customers are on Month-to-month contracts?
SELECT COUNT(customerID)
FROM telco_customers
WHERE contract = 'Month-to-month';

-- Average monthly charges across all customers
SELECT AVG(MonthlyCharges)
FROM telco_customers;

-- ------------------------------------------------------------
-- 2. Aggregations
-- ------------------------------------------------------------

-- Churn count: how many customers churned vs. stayed?
-- Result: No = 5,163 | Yes = 1,869  (~26.6% churn rate)
SELECT Churn, COUNT(customerID)
FROM telco_customers
GROUP BY Churn;

-- Average tenure per contract type, highest first
-- Result: Two-year = 57.1 months | One-year = 42.1 | Month-to-month = 18.0
-- Finding: longer contracts strongly predict longer customer tenure
SELECT contract, AVG(tenure)
FROM telco_customers
GROUP BY contract
ORDER BY AVG(tenure) DESC;

-- Average monthly charge by internet service type, only
-- types averaging above $70
-- Result: Fiber optic = $91.50
SELECT InternetService, AVG(MonthlyCharges) AS avg_charge
FROM telco_customers
GROUP BY InternetService
HAVING AVG(MonthlyCharges) > 70
ORDER BY AVG(MonthlyCharges) DESC;

-- ------------------------------------------------------------
-- 3. Data quality investigation
-- ------------------------------------------------------------
-- This dataset is known to sometimes have blank TotalCharges
-- values. Checked whether the import preserved these as blank
-- strings or true NULLs.

-- Check for blank-string TotalCharges values
SELECT customerID, TotalCharges + 0
FROM telco_customers
WHERE TotalCharges = '';

-- Check for true NULL TotalCharges values
SELECT COUNT(*)
FROM telco_customers
WHERE TotalCharges IS NULL;

-- Result: neither check returned rows — the import process
-- appears to have handled the known blank-value quirk, though
-- this is worth verifying further before relying on TotalCharges
-- in downstream financial calculations.

-- ------------------------------------------------------------
-- 4. Business scenarios
-- ------------------------------------------------------------

-- Retention team request: identify the highest-risk churn
-- segment — new, high-paying, flexible-contract customers
SELECT customerID
FROM telco_customers
WHERE Contract = 'Month-to-month' AND tenure < 6 AND MonthlyCharges > 80;

-- Churn RATE (not just count) by payment method, using a
-- conditional SUM to count only churned customers per group
SELECT PaymentMethod,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_count,
       COUNT(*) AS total_count,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100 AS churn_rate_pct
FROM telco_customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

-- ------------------------------------------------------------
-- 5. Subquery
-- ------------------------------------------------------------

-- Customers whose monthly charges exceed the overall average
SELECT customerID, MonthlyCharges
FROM telco_customers
WHERE MonthlyCharges > (SELECT AVG(MonthlyCharges) FROM telco_customers);
