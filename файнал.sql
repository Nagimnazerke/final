SELECT
main.quarter,
main.age_group,
COUNT(DISTINCT main.ID_client) AS unique_clients,
COUNT(main.Id_check) AS total_operations,
ROUND(SUM(main.Sum_payment), 2) AS total_payment,
ROUND(SUM(main.Sum_payment) / COUNT(DISTINCT main.ID_client), 2) AS avg_payment_per_client,
ROUND(COUNT(main.Id_check) / COUNT(DISTINCT main.ID_client), 2) AS avg_ops_per_client,

ROUND(
COUNT(DISTINCT main.ID_client) / total.total_clients_in_quarter * 100, 2
) AS client_share_percent

FROM (
SELECT
CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter,
t.ID_client,
t.Id_check,
t.Sum_payment,
CASE
			WHEN c.Age IS NULL THEN 'Unknown'
            WHEN c.Age < 20 THEN '0–19'
	        WHEN c.Age BETWEEN 20 AND 29 THEN '20–29'
            WHEN c.Age BETWEEN 30 AND 39 THEN '30–39'
            WHEN c.Age BETWEEN 40 AND 49 THEN '40–49'
            WHEN c.Age BETWEEN 50 AND 59 THEN '50–59'
            WHEN c.Age BETWEEN 60 AND 69 THEN '60–69'
            WHEN c.Age >= 70 THEN '70+'
        END AS age_group
    FROM transactions t
    LEFT JOIN customer c ON t.ID_client = c.Id_client
    WHERE t.date_new >= '2015-06-01' AND t.date_new < '2016-06-01'
) AS main

JOIN (
    SELECT
        CONCAT(YEAR(date_new), '-Q', QUARTER(date_new)) AS quarter,
        COUNT(DISTINCT ID_client) AS total_clients_in_quarter
    FROM transactions
    WHERE date_new >= '2015-06-01' AND date_new < '2016-06-01'
    GROUP BY CONCAT(YEAR(date_new), '-Q', QUARTER(date_new))
) AS total
ON main.quarter = total.quarter

GROUP BY main.quarter, main.age_group
ORDER BY main.quarter, main.age_group;
