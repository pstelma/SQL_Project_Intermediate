
SELECT
	cohort_year,
	SUM(total_net_revenue) AS total_revenue,
	COUNT(DISTINCT customerkey) AS customer_count,
	ROUND(SUM(total_net_revenue)::numeric / COUNT(DISTINCT customerkey)::numeric,2) AS customer_revenue
FROM
	cohort_analysis
GROUP BY cohort_year
ORDER BY cohort_year ASC;

