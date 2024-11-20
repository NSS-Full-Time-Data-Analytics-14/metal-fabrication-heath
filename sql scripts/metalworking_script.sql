-- Count of Description between 2023 and 2024
WITH desc_2023 AS (SELECT jmo_process_short_description, COUNT(jmo_process_short_description) AS count_of_desc_2023
FROM job_operations_2023
GROUP BY jmo_process_short_description
ORDER BY jmo_process_short_description ASC)

SELECT jmo_process_short_description, COUNT(jmo_process_short_description) AS count_of_desc_2024, count_of_desc_2023
FROM job_operations_2024 INNER JOIN desc_2023 USING (jmo_process_short_description)
GROUP BY jmo_process_short_description, count_of_desc_2023
ORDER BY jmo_process_short_description ASC




--Hours each process (description) has ran in 2023 and 2024 wip.
SELECT jmo_process_short_description, SUM(job_operations_2023.jmo_completed_production_hours) AS prod_hours_2023, SUM(job_operations_2024.jmo_completed_production_hours) AS prod_hours_2024
FROM job_operations_2023 INNER JOIN job_operations_2024 USING (jmo_process_short_description)
GROUP BY jmo_process_short_description
ORDER BY prod_hours_2023 DESC;


-- Fun description details I guess wip.
WITH desc_counts AS (SELECT jmo_process_short_description, COUNT(job_operations_2023.jmo_process_short_description)::numeric AS count_desc_2023, COUNT(job_operations_2024.jmo_process_short_description)::numeric AS count_desc_2024
FROM job_operations_2023 INNER JOIN job_operations_2024 USING (jmo_process_short_description)
GROUP BY jmo_process_short_description)

-- SELECT jmo_process_short_description, SUM(count_desc_2023 + count_desc_2024) AS total_sum_desc
-- FROM desc_counts
-- GROUP BY jmo_process_short_description
-- ORDER BY total_sum_desc DESC


SELECT job_operations_2023.jmo_process_short_description, SUM(count_desc_2023 + count_desc_2024) AS sum_of_desc, SUM(job_operations_2024.jmo_actual_production_hours + job_operations_2024.jmo_actual_production_hours) AS prod_time
FROM jobs 
		INNER JOIN job_operations_2023 ON jmp_job_id = jmo_job_id
		INNER JOIN job_operations_2024 ON jobs.jmp_job_id = job_operations_2024.jmo_job_id
		INNER JOIN sales_order_job_links ON jmp_job_id = omj_job_id
		INNER JOIN sales_orders ON omp_sales_order_id = omj_sales_order_id
		INNER JOIN desc_counts ON desc_counts.jmo_process_short_description = job_operations_2023.jmo_process_short_description
GROUP BY job_operations_2023.jmo_process_short_description
ORDER BY sum_of_desc DESC;




--Top 10 frequent customers (based on counting how many times they ordered in the sales_orders table)
SELECT omp_customer_organization_id, COUNT(omp_customer_organization_id) AS customer_org_count
FROM sales_orders
				-- INNER JOIN sales_order_job_links ON omp_sales_order_id = omj_sales_order_id
				-- INNER JOIN jobs ON jmp_job_id = omj_job_id
				-- INNER JOIN job_operations_2023 ON jmp_job_id = jmo_job_id
				-- INNER JOIN job_operations_2024 USING (jmo_process_short_descriptions)
GROUP BY omp_customer_organization_id
ORDER BY customer_org_count DESC
LIMIT 10
