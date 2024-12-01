SELECT jmp_job_id,jmp_customer_organization_id,omp_customer_organization_id
FROM jobs INNER JOIN sales_orders ON jmp_customer_organization_id = omp_customer_organization_id
 
--a1)
SELECT DISTINCT omp_customer_organization_id, count(jmp_job_id) as job_count
FROM jobs Full Join sales_orders ON jmp_customer_organization_id = omp_customer_organization_id
GROUP BY omp_customer_organization_id
ORDER BY  job_count desc

--a2)
SELECT omp_customer_organization_id, sum(omp_order_subtotal_base)::numeric::money, count(jmp_job_id) as job_count
FROM jobs Full Join sales_orders ON jmp_customer_organization_id = omp_customer_organization_id
GROUP BY omp_customer_organization_id
ORDER BY  job_count desc;


--b)How has the volume of work changed for each customer over time? 
--Are there any seasonal patterns? How have the number of estimated hours per 
--customer changed over time? Estimated hours are in the jmo_estimated_production_hours 
--columns of the job_operations_2023/job_operations_2024 tables.
:30
WITH jobs_2024 AS (SELECT sc.omp_customer_organization_id, COUNT(jo24.jmo_job_id) AS volume_of_jobs_2024 --SUM(jo24.jmo_estimated_production_hours) AS hours_2024
					FROM sales_orders AS sc
						FULL JOIN jobs jc
						ON sc.omp_customer_organization_id = jc.jmp_customer_organization_id
							FULL JOIN job_operations_2024 AS jo24
							ON jc.jmp_job_id= jo24.jmo_job_id
					GROUP BY sc.omp_customer_organization_id),
jobs_2023 AS (SELECT sc.omp_customer_organization_id, COUNT(jo23.jmo_job_id) AS volume_of_jobs_2023--,SUM(jo23.jmo_estimated_production_hours) AS hours_2023
				FROM sales_orders AS sc
					FULL JOIN jobs jc
					ON sc.omp_customer_organization_id = jc.jmp_customer_organization_id
						FULL JOIN job_operations_2023 AS jo23
						ON jc.jmp_job_id= jo23.jmo_job_id
				GROUP BY sc.omp_customer_organization_id)
SELECT j24.omp_customer_organization_id, (j24.volume_of_jobs_2024 - j23.volume_of_jobs_2023) AS yearly23_24_volume_differnce
FROM jobs_2024 AS j24
	FULL JOIN jobs_2023 AS j23
	USING(omp_customer_organization_id)
	ORDER BY yearly23_24_volume_differnce
	
--1b)	

WITH P_HRS_23 AS (SELECT omp_customer_organization_id, sum(jo_23.jmo_estimated_production_hours)::int as production_hrs_23, count(jmp_job_id) as job_count
FROM jobs Full Join sales_orders ON jmp_customer_organization_id = omp_customer_organization_id
		  LEFT JOIN job_operations_2023 AS jo_23 ON jmp_job_id = jo_23.jmo_job_id
GROUP BY omp_customer_organization_id
ORDER BY production_hrs_23 desc NULLS LAST),

	P_HRS_24 AS(SELECT omp_customer_organization_id, sum(jo_24.jmo_estimated_production_hours)::integer as production_hrs_24, count(jmp_job_id) as job_count
FROM jobs Full Join sales_orders ON jmp_customer_organization_id = omp_customer_organization_id
		  LEFT JOIN job_operations_2024 AS jo_24 ON jmp_job_id = jo_24.jmo_job_id
GROUP BY omp_customer_organization_id
ORDER BY  production_hrs_24 desc NULLS LAST)

SELECT omp_customer_organization_id, production_hrs_24 - production_hrs_23 AS change_in_hrs
FROM P_HRS_23 FULL JOIN P_HRS_24 USING(omp_customer_organization_id)
ORDER BY change_in_hrs desc NULLS LAST;

--Seasonal Patterns:volume of work for each customer
SELECT TO_CHAR(jmp_scheduled_start_date, 'YYYY-MM'), omp_customer_organization_id, jmp_job_id
FROM jobs FULL JOIN sales_orders ON jmp_customer_organization_id = omp_customer_organization_id


--
SELECT TO_CHAR(jmp_job_date,'YYYY-MM'), omp_customer_organization_id, count(jmp_job_id) as job_count
FROM jobs Full Join sales_orders ON jmp_customer_organization_id = omp_customer_organization_id
GROUP BY omp_customer_organization_id, jmp_job_date
ORDER BY jmp_job_date desc NULLS LAST;


SELECT TO_CHAR(jmp_job_date,'YYYY-MM') as year_month, count(jmp_job_id) as job_count
FROM jobs Full Join sales_orders ON jmp_customer_organization_id = omp_customer_organization_id
GROUP BY jmp_job_date
ORDER BY jmp_job_date desc NULLS LAST;

--1dcustomers by opperation
--make into a table: lazer cutting top, worth looking in to that lazer cutting is so work heavy, but getting caught up.
--looking for downtime, so you look at where the hold ups are
--2)



--1. Do an analysis of customers. The customer can be identified using 
--the jmp_customer_organization_id from the jobs table or the 
--omp_customer_organization_id from the sales_orders table. Here are some 
--example questions to get started:  
-- a. Which customers have the highest volume of jobs? Which generate the 
--most revenue (as indicated by the omp_order_subtotal_base in the sales_order table)?  
-- b. How has the volume of work changed for each customer over time? 
--Are there any seasonal patterns? How have the number of estimated hours per 
--customer changed over time? Estimated hours are in the jmo_estimated_production_hours 
--columns of the job_operations_2023/job_operations_2024 tables.  
-- c. How has the customer base changed over time? What percentage of jobs are for new 
--customers compared to repeat customers?  
-- d. Perform a breakdown of customers by operation (as indicated by the jmo_process short_description in the job_operations_20



 --2Parts:  
