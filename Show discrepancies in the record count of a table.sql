-- Search for period-over-period discrepancies in the count of records grouped by date

WITH raw AS
(
  SELECT 
    DATE_TRUNC(DATE(datepartition), MONTH) AS time_interval, 
    COUNT(*) current_count
  FROM `bigquery-analytics-workbench.gold_read.ff_sessions`
  WHERE DATE(datepartition) > (SELECT DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH))
  GROUP BY DATE_TRUNC(DATE(datepartition), MONTH)
),
raw2 AS
(
  SELECT 
    time_interval, 
    SUM(current_count) AS current_count,
    LAG(SUM(current_count), 1) OVER (ORDER BY time_interval ASC) AS previous_count,
    ROUND(((SUM(current_count) - LAG(SUM(current_count), 1) OVER (ORDER BY time_interval ASC))/LAG(SUM(current_count), 1) OVER (ORDER BY time_interval ASC))*100, 1) AS percentage_change
  FROM raw
  GROUP BY time_interval
  ORDER BY time_interval
),
results2
AS
(
  SELECT *, ROUND(PERCENT_RANK() OVER (ORDER BY percentage_change), 3) AS percentile
  FROM raw2
  ORDER BY time_interval
)
SELECT * FROM results2
-- WHERE percentile < 0.05
-- OR percentile > 0.95
ORDER BY time_interval
