SELECT jmo_process_id, COUNT(jmo_process_id) AS count_process_2023
FROM jobs
		INNER JOIN job_operations_2023 ON jobs.jmp_job_id = job_operations_2023.jmo_job_id
WHERE jmo_start_date>= '2023-01-01 00:00:00' AND jmo_start_date<= '2023-10-31 00:00:00'
GROUP BY jmo_process_id
ORDER BY count_process_2023 DESC;



SELECT jmo_process_id, COUNT(jmo_process_id) AS count_process_2024
FROM jobs
		INNER JOIN job_operations_2024 ON jobs.jmp_job_id = job_operations_2024.jmo_job_id
WHERE jmo_start_date>= '2024-01-01 00:00:00' AND jmo_start_date<= '2024-10-31 00:00:00'
GROUP BY jmo_process_id
ORDER BY count_process_2024 DESC;




(SELECT jmo_process_id, COUNT(jmo_process_id) AS count_process_2023
FROM jobs
		INNER JOIN job_operations_2023 ON jobs.jmp_job_id = job_operations_2023.jmo_job_id
WHERE jmo_start_date>= '2023-01-01 00:00:00' AND jmo_start_date<= '2023-10-31 00:00:00'
GROUP BY jmo_process_id
ORDER BY count_process_2023 DESC)

UNION 

(SELECT jmo_process_id, COUNT(jmo_process_id) AS count_process_2024
FROM jobs
		INNER JOIN job_operations_2024 ON jobs.jmp_job_id = job_operations_2024.jmo_job_id
WHERE jmo_start_date>= '2024-01-01 00:00:00' AND jmo_start_date<= '2024-10-31 00:00:00'
GROUP BY jmo_process_id
ORDER BY count_process_2024 DESC);









SELECT jmo_process_short_description, COUNT(jmo_process_id) AS count_of_process_23
FROM job_operations_2023
GROUP BY jmo_process_short_description
ORDER BY count_of_process_23 DESC;

SELECT jmo_process_short_description, COUNT(jmo_process_id) AS count_of_process_24
FROM job_operations_2024
GROUP BY jmo_process_short_description
ORDER BY count_of_process_24 DESC;







WITH job_operations AS (SELECT jmo_job_id AS job_id, 
								jmo_process_short_description AS short_description, 
								jmo_process_id AS process_id 
							FROM job_operations_2023
								UNION
						SELECT jmo_job_id AS job_id, 
								jmo_process_short_description AS short_description, 
								jmo_process_id AS process_id
							FROM job_operations_2024),
	jobs_clean AS (SELECT jmp_job_id AS job_id,
							to_char(jmp_created_date, 'YYYY-MM-DD')::DATE AS created_date,
							to_char(jmp_production_due_date, 'YYYY-MM-DD')::DATE AS production_due_date,
							to_char(jmp_completed_date, 'YYYY-MM-DD')::DATE AS completed_date,
							jmp_part_id, 
							jmp_order_quantity, 
							jmp_production_quantity
							FROM jobs)
SELECT *,
	completed_date - created_date AS open_close_days,
	completed_date - production_due_date AS due_date_diff,
	CASE
	  WHEN (completed_date - production_due_date) > 0 THEN 'Late'
	  WHEN (completed_date - production_due_date) IS NULL THEN 'Incomplete'
	ELSE
	  'On-time'
	END AS completion_status
FROM job_operations
LEFT JOIN jobs_clean
	USING(job_id)
ORDER BY created_date;





WITH year_quarter_parts_rank AS (SELECT imp_part_id, imp_short_description, imp_long_description_text, imo_unit_cost1, COUNT(imp_part_id) AS part_counts,
																			CASE WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 1 AND 3 THEN 'Quarter 1 - 2023'
																					WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 4 AND 6 THEN 'Quarter 2 - 2023'
        																				WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 7 AND 9 THEN 'Quarter 3 - 2023'
        																					WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 10 AND 12 THEN 'Quarter 4 - 2023'
    																	END AS year_quarter, ROW_NUMBER() OVER(PARTITION BY CASE WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 1 AND 3 THEN 'Quarter 1 - 2023'
WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 4 AND 6 THEN 'Quarter 2 - 2023'
WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 7 AND 9 THEN 'Quarter 3 - 2023'
WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 10 AND 12 THEN 'Quarter 4 - 2023'
END
 	ORDER BY  COUNT(imp_part_id) DESC) AS parts_ranked_quarter
FROM parts
	INNER JOIN part_operations AS j_ops ON J_ops.imo_part_id = parts.imp_part_id
	INNER JOIN job_operations_2023 as y23
		ON y23.jmo_part_id = parts.imp_part_id
WHERE j_ops.imo_created_date >= '2023-01-01 00:00:00' AND j_ops.imo_created_date <= '2024-10-31 23:59:59'
GROUP BY imp_part_id, imp_short_description, imp_long_description_text, imo_unit_cost1, j_ops.imo_created_date
UNION ALL
SELECT imp_part_id, imp_short_description, imp_long_description_text, imo_unit_cost1, COUNT(imp_part_id) AS part_counts,
																			CASE WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 1 AND 3 THEN 'Quarter 1 - 2024'
																					WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 4 AND 6 THEN 'Quarter 2 - 2024'
        																				WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 7 AND 9 THEN 'Quearter 3 - 2024'
        																					WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 10 AND 12 THEN 'Quarter 4 - 2024'
    																	END AS year_quarter, ROW_NUMBER() OVER(PARTITION BY CASE WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 1 AND 3 THEN 'Quarter 1 - 2024'
WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 4 AND 6 THEN 'Quarter 2 - 2024'
WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 7 AND 9 THEN 'Quarter 3 - 2024'
WHEN EXTRACT(MONTH FROM imo_created_date) BETWEEN 10 AND 12 THEN 'Quarter 4 - 2024'
END
 	ORDER BY COUNT(imp_part_id) DESC) AS parts_ranked_quarter
FROM parts
	INNER JOIN part_operations AS j_ops ON J_ops.imo_part_id = parts.imp_part_id
	INNER JOIN job_operations_2024 as y24
		ON y24.jmo_part_id = parts.imp_part_id
WHERE j_ops.imo_created_date >= '2023-01-01 00:00:00' AND j_ops.imo_created_date <= '2024-10-31 23:59:59'
GROUP BY imp_part_id, imp_short_description, imp_long_description_text, imo_unit_cost1, j_ops.imo_created_date
ORDER BY year_quarter ASC)
SELECT *
FROM year_quarter_parts_rank
ORDER BY year_quarter ASC, parts_ranked_quarter;
















WITH job_operations AS(SELECT jmo_job_id, jmo_process_short_description, jmo_estimated_production_hours
					  FROM job_operations_2023
					  UNION 
					  SELECT jmo_job_id, jmo_process_short_description, jmo_estimated_production_hours
					  FROM job_operations_2024),

other_tables AS 
(SELECT * 
FROM sales_order_job_links INNER JOIN jobs ON omj_job_id = jmp_job_id
                           INNER JOIN job_operations ON jmp_job_id = jmo_job_id)
						   
SELECT DISTINCT oml_sales_order_line_id, jmo_process_short_description, jmo_estimated_production_hours, jmp_scheduled_due_date, jmp_scheduled_start_date, jmp_completed_date, oml_sales_order_id, oml_part_id, oml_part_short_description, oml_order_quantity, oml_full_unit_price_base, oml_full_extended_price_base, omp_full_order_subtotal_base
FROM sales_order_lines INNER JOIN sales_orders ON omp_sales_order_id = oml_sales_order_id
                       INNER JOIN other_tables ON oml_sales_order_id = omj_sales_order_id;