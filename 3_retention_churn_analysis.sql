
WITH last_purchase AS (
	SELECT 
		customerkey,
		cleaned_name,
		cohort_year,
		first_purchase_date,
		MAX(orderdate) AS last_purchase_date
	FROM
		cohort_analysis
	GROUP BY
		customerkey, cleaned_name, cohort_year, first_purchase_date

), churn AS (
	SELECT
		cohort_year,
		COUNT(DISTINCT customerkey) AS total_customers,
		COUNT(CASE 
			WHEN last_purchase_date >= (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 month' THEN customerkey
		END) AS active_customers,
		COUNT(CASE 
			WHEN last_purchase_date <= (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 month' THEN customerkey
		END) AS churned_customers
	FROM 
		last_purchase
	WHERE
		 first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 month'
		 -- If we want to exclude customers that have only made one purchase:
		-- AND first_purchase_date != last_purchase_date 
	GROUP BY
		cohort_year
	ORDER BY cohort_year
)
SELECT
    *,
    ROUND((active_customers::numeric / total_customers::numeric * 100), 2) || '%' AS percent_active,
    ROUND((churned_customers::numeric / total_customers::numeric * 100), 2) || '%' AS percent_churned
FROM
    churn
	
