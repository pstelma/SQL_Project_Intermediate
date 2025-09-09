CREATE VIEW public.cohort_analysis AS 

 WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.quantity::double precision * s.netprice * s.exchangerate) AS total_net_revenue,
            count(s.orderkey) AS num_orders,
            c.countryfull,
            c.age,
            CONCAT(TRIM(c.givenname), ' ', TRIM(c.surname)) AS cleaned_name
           FROM sales s
             LEFT JOIN customer c ON c.customerkey = s.customerkey
          GROUP BY s.customerkey, s.orderdate, c.countryfull, age, cleaned_name
        )
 SELECT customerkey,
    orderdate,
    total_net_revenue,
    num_orders,
    countryfull,
    age,
    cleaned_name,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue cr;