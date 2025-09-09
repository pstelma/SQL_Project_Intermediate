WITH customer_ltv AS (
	SELECT
		customerkey,
		cleaned_name,
		SUM(total_net_revenue) AS total_ltv
	FROM
		cohort_analysis 
	GROUP BY
		customerkey,
		cleaned_name
),
customer_segmentation AS (
	SELECT
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS "25th_percentile",
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS "75th_percentile"
	FROM
		customer_ltv	
), segment_values AS (
	SELECT
		customer_ltv.*,
		CASE
			WHEN total_ltv < "25th_percentile" THEN '1-LOW-VALUE'
			WHEN total_ltv BETWEEN "25th_percentile" AND "75th_percentile"  THEN '2-MID-VALUE'
			ELSE '3-HIGH-VALUE'
		END AS customer_segment
	FROM 
		customer_ltv, customer_segmentation
)
SELECT
	customer_segment,
	SUM(total_ltv) AS total_ltv,
	count(DISTINCT customerkey) AS customer_count,
	AVG(total_ltv) AS avg_ltv
FROM segment_values
GROUP BY customer_segment
ORDER BY total_ltv DESC


