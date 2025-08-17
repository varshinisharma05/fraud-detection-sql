USE FraudDetectionDB;

-- 1) High-Value Transactions (> 5000)
SELECT t.transaction_id, t.user_id, t.amount, t.transaction_date, t.transaction_type, t.merchant_name
FROM Transactions t
WHERE t.amount > 5000 AND t.status = 'approved';

-- 2) Transactions Outside Business Hours (09:00:00 - 21:00:00)
SELECT t.transaction_id, t.user_id, t.amount, t.transaction_date, TIME(t.transaction_date) AS transaction_time, t.merchant_name
FROM Transactions t
WHERE TIME(t.transaction_date) NOT BETWEEN '09:00:00' AND '21:00:00' AND t.status = 'approved';

-- 3) Users with > 5 Transactions in the Last 24 Hours
SELECT t.user_id, COUNT(*) AS transaction_count, MAX(t.transaction_date) AS last_transaction
FROM Transactions t
WHERE t.transaction_date > (SELECT MAX(transaction_date) FROM Transactions) - INTERVAL 1 DAY
  AND t.status = 'approved'
GROUP BY t.user_id
HAVING COUNT(*) > 5;

-- 4) Repeated Transactions to the Same Merchant (> 3)
SELECT t.user_id, t.merchant_name, COUNT(*) AS transaction_count
FROM Transactions t
GROUP BY t.user_id, t.merchant_name
HAVING COUNT(*) > 3;

-- 5) Debit Exceeding User's Average by 1.5x
SELECT T.user_id, T.transaction_id, T.amount, AVG(T2.amount) AS user_avg_debit
FROM Transactions T
JOIN Transactions T2 ON T.user_id = T2.user_id AND T2.transaction_type = 'debit' AND T2.status = 'approved'
WHERE T.transaction_type = 'debit' AND T.status = 'approved'
GROUP BY T.user_id, T.transaction_id, T.amount
HAVING T.amount > 1.5 * AVG(T2.amount);

-- 6) Three Consecutive Declined Transactions (per user) using window functions (MySQL 8+)
WITH ordered AS (
  SELECT
    t.*,
    CASE WHEN t.status = 'declined' THEN 1 ELSE 0 END AS is_declined,
    ROW_NUMBER() OVER (PARTITION BY t.user_id ORDER BY t.transaction_date) AS rn_all,
    ROW_NUMBER() OVER (PARTITION BY t.user_id, CASE WHEN t.status = 'declined' THEN 1 ELSE 0 END ORDER BY t.transaction_date) AS rn_decl
  FROM Transactions t
),
runs AS (
  SELECT
    user_id,
    transaction_id,
    transaction_date,
    is_declined,
    (rn_all - rn_decl) AS grp
  FROM ordered
)
SELECT user_id, MIN(transaction_date) AS start_time, COUNT(*) AS decline_streak
FROM runs
WHERE is_declined = 1
GROUP BY user_id, grp
HAVING COUNT(*) >= 3;

-- 7) Users with Highest Total Spend (approved debits)
SELECT t.user_id, SUM(t.amount) AS total_spent
FROM Transactions t
WHERE t.transaction_type = 'debit' AND t.status = 'approved'
GROUP BY t.user_id
ORDER BY total_spent DESC
LIMIT 5;

-- 8) Merchant-wise Totals
SELECT t.merchant_name, COUNT(*) AS transaction_count, SUM(CASE WHEN t.status='approved' THEN t.amount ELSE 0 END) AS total_amount
FROM Transactions t
GROUP BY t.merchant_name
ORDER BY total_amount DESC;

-- 9) Location Mismatch vs User Home (optional rule)
SELECT t.transaction_id, u.user_id, u.user_home_location, t.location, t.amount, t.transaction_date
FROM Transactions t
JOIN Users u ON t.user_id = u.user_id
WHERE t.location IS NOT NULL AND u.user_home_location IS NOT NULL
  AND t.location <> u.user_home_location
  AND t.status = 'approved';
