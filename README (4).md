# Retail Banking SQL Analysis

A SQL portfolio project combining a self-built practice banking database and a real-world public dataset (Telco Customer Churn), used to solve realistic Business Analyst scenarios — from basic filtering through JOINs, aggregations, and correlated subqueries.

## Tech Used
MySQL 8.0, MySQL Workbench

---

## Part 1 — Practice Banking Database

A self-built relational database simulating a retail bank, designed to mirror how real banking data is structured, with intentional edge cases (dormant accounts, customers with multiple accounts) built in to practice real analytical patterns.

### Database Structure
- **customers** — customer_id, full_name, city, segment, join_date
- **accounts** — account_id, customer_id, account_type, balance, open_date
- **transactions** — txn_id, account_id, txn_date, txn_type, amount, channel

### Business Scenarios Solved
1. **HNI Product Targeting** — Identified High-Net-Worth-Individual (HNI) customers with total balance exceeding a defined threshold, for a targeted Platinum Credit Card campaign. Built using JOIN, GROUP BY, and HAVING.
2. **Dormant Account Detection** — Found accounts with zero recorded transactions using a LEFT JOIN + IS NULL pattern, flagging customers at risk of disengagement.
3. **Revenue Concentration Analysis** — Measured what share of total transaction revenue comes from each customer segment.
4. **Above-Average Spend Identification** — Used a correlated subquery to find customers whose account balance exceeds the average balance within their own segment (not the overall average) — a more precise, segment-aware threshold than a flat comparison.

### Key Finding
> HNI customers make up roughly 25% of the customer base but generate over **82% of total transaction revenue** — a significant concentration that suggests both an opportunity (deepen HNI relationships) and a risk (over-reliance on a small customer segment).

### Sample Query — Correlated Subquery
```sql
-- Customers whose balance exceeds their OWN segment's average
-- (not the overall average) — demonstrates a correlated subquery
SELECT c.customer_id, c.full_name, c.segment, a.balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
WHERE a.balance > (
    SELECT AVG(a2.balance)
    FROM accounts a2
    JOIN customers c2 ON a2.customer_id = c2.customer_id
    WHERE c2.segment = c.segment
);
```

### Sample Query — Dormant Account Detection
```sql
-- Accounts with no transactions recorded (LEFT JOIN + IS NULL pattern)
SELECT a.account_id, a.account_type, a.balance
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE t.txn_id IS NULL;
```

---

## Part 2 — Telco Customer Churn Analysis (Real-World Dataset)

Applied the same SQL skill set to a publicly available, real-world dataset (Kaggle: Telco Customer Churn, ~7,032 customer records) to test whether the techniques transfer beyond a self-built database to unfamiliar, larger-scale data.

### Business Questions Solved
1. **Overall churn rate** — What proportion of customers have churned?
2. **Tenure by contract type** — Do longer contracts correlate with longer customer relationships?
3. **Pricing by service type** — Which internet service tier commands the highest average monthly charge?
4. **High-risk segment identification** — New, high-paying, flexible-contract customers (a realistic retention-team request)
5. **Churn rate by payment method** — Which payment method has the highest percentage (not just count) of churned customers?
6. **Data quality investigation** — Checked the known TotalCharges blank-value quirk in this dataset, and confirmed the import process handled it (no blank strings or NULLs found, worth flagging for further verification).

### Key Findings
> - **Overall churn rate: 26.6%** (1,869 of 7,032 customers) — a meaningful retention concern.
> - **Contract length strongly predicts tenure**: Two-year contract customers average **57 months** of tenure vs. just **18 months** for Month-to-month customers — nearly a 3x difference.
> - **Fiber optic customers pay the most**, averaging **$91.50/month**, well above the $70 threshold used to flag premium service tiers.

### Sample Query — Conditional Aggregation (Churn Rate by Payment Method)
```sql
-- Churn RATE (not just count) per payment method,
-- using a conditional SUM to count only churned customers per group
SELECT PaymentMethod,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_count,
       COUNT(*) AS total_count,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100 AS churn_rate_pct
FROM telco_customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;
```

### Sample Query — High-Risk Retention Segment
```sql
-- Retention team request: new, high-paying, flexible-contract customers
-- (highest churn-risk profile)
SELECT customerID
FROM telco_customers
WHERE Contract = 'Month-to-month'
  AND tenure < 6
  AND MonthlyCharges > 80;
```

---

## Files in This Repository
- `bank_setup.sql` — Schema and sample data for the practice banking database
- `queries/` — SQL solutions organized by topic (foundations, aggregations, JOINs, subqueries)
- `telco_churn_analysis.sql` — Full query set for the Telco Customer Churn analysis

## About This Project
Built as part of a self-directed transition into a Business Analyst role, combining prior client-facing banking experience (HNI Relationship Management) with hands-on technical skill-building in SQL, Excel, and Power BI.

## Author
**Mansi Patil**
