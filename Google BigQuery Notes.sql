
-- BigQuery standard syntax
-- Updated: 2019-10-30

							---------- GENERAL -----------

-- CREATING TABLES WITH A COLUMN LIST
CREATE TABLE `project.dataset.table1` (
  column1 {TYPE},
  column2 {TYPE}
)

-- CREATE (OR REPLACE) TABLES WITH A SELECT *
CREATE OR REPLACE `project.dataset.table1` AS
{query}

-- INSERT. Inserts data into a table with/without column list supplied
INSERT `project.dataset.table1`
{query}

-- UPDATE. Updates column values (use WHERE 1 = 1 if updating without a 'WHERE' statement)
	UPDATE `project.dataset.table1`
	SET col1 = new_value,
	WHERE col1 = old_value
	
	-- Update columns with a join on another table.
	UPDATE `project.dataset.table1` AS t1
	SET t1_col1 = t2_col1
	FROM `project.dataset.table2` AS t2
	WHERE t1_col2 = t2_col2

-- MERGE. Delete/update/insert in a single statement
	MERGE `project.dataset.table1` AS t1
	USING `project.dataset.table2` AS t2
	ON t1.col1 = t2.col2
	WHEN NOT MATCHED AND {condition} THEN
	INSERT(col1, col2, col3)
	VALUES(val1, val2, ARRAY<STRUCT<col3a {type}, col3b {type}>>[val3a, val3b)])
	WHEN MATCHED THEN
	UDDATE(product, quantity, supply_constrained) -- <!>

-- PARTITION BY. Partitions a table by a date column. Reduces cost and speeds up qurying
	CREATE OR REPLACE TABLE table1  PARTITION BY DATE(date_column) AS
	
-- CLUSTER BY. Sort of like indexing. Currently only works on partitioned tables and supporst up to 4 columns
	CREATE OR REPLACE TABLE table1  PARTITION BY DATE(date_column) CLUSTER BY Column1, Column2, ... AS

							---------- DATE FORMATS -----------

	-- TIMESTAMP - the date time with timezone info
	-- DATETIME - the 'local' date time with no timezone info

							---------- FUNCTIONS -----------

-- CURRENT_TIMESTAMP. Returns the current date and time
	CURRENT_TIMESTAMP() -- '2017-11-05 00:00:00'
	
-- CURRENT_DATE. Returns the current date
	CURRENT_DATE() -- '2017-11-05'

-- DATE_ADD. Adds a specified time interval to a DATE. (date_expression, INTERVAL INT64_expr date_part)
	SELECT DATE_ADD(DATE "2008-12-25", INTERVAL 5 DAY) as five_days_later

-- DATE_SUB. Subtracts a specified time interval from a DATE. (date_expression, INTERVAL INT64_expr date_part)
	DATE_SUB('2018-12-18', INTERVAL 7 DAY) -- 2018-12-11
	
-- TIMESTAMP_ADD (see DATE_ADD)
-- TIMESTAMP_SUB (see DATE_SUB)

-- TIMESTAMP_TRUNC. Truncates datetime to a spefici part, rounding it to the first.
	TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), MONTH) -- Beginning of the month
	-- Acceptable parameters:
	MICROSECOND
	MILLISECOND
	SECOND
	MINUTE
	HOUR
	DAY
	WEEK
	WEEK(<WEEKDAY>) -- Truncates timestamp_expression to the preceding week boundary, where weeks begin on WEEKDAY. Valid values for WEEKDAY are SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, and SATURDAY.
	ISOWEEK --Truncates timestamp_expression to the preceding ISO 8601 week boundary. ISOWEEKs begin on Monday. The first ISOWEEK of each ISO year contains the first Thursday of the corresponding Gregorian calendar year. Any date_expression earlier than this will truncate to the preceding Monday.
	MONTH
	QUARTER
	YEAR
	ISOYEAR: Truncates timestamp_expression to the preceding ISO 8601 week-numbering year boundary. The ISO year boundary is the Monday of the first week whose Thursday belongs to the corresponding Gregorian calendar year.
	
-- EXTRACT. Extracts time parts
	-- DAYOFWEEK
	SELECT EXTRACT(DAYOFWEEK FROM CURRENT_DATE())

-- CAST. Converts a string into a datetime
	CAST('2019-03-10' AS TIMESTAMP)
	TIMESTAMP('2019-03-10')

-- LAG. Lags by a number of rows
	LAG(col1, 1) OVER (PARTITION BY col1 ORDER BY col1 ASC) from table1

-- LEAD. Leads by a number of rows
	LEAD(col1, 1) OVER (PARTITION BY col1 ORDER BY col1 ASC) from table1

-- RAND(). Generates a random real number between 0 and 1
	RAND()

-- REPLACE. Replaces all occurrences of from_value with to_value in original_value. If from_value is empty, no replacement is made
	REPLACE(original_value, from_value, to_value)

-- SPLIT(data, delimiter). Splits input data by a specified delimiter
	SPLIT(col1, ",")

-- STRUCT. (grouping multiple fields into one category)
	SELECT STRUCT<INT64, STRING>(35 AS age, 'Jacob' AS name) AS customers

	-- Arrays inside a struct
	SELECT STRUCT(35 AS age, 'Jacob' AS name, ['apple', 'pear', 'peach'] AS items) AS customers

	-- Example of categorising multiple columns into one category
	WITH table1 AS 
	(
	  SELECT 'a' AS col1,  'val1' AS col2, 'otherval1' AS col3 UNION ALL
	  SELECT 'a' AS col1,  'val2' AS col2, 'otherval2' AS col3 UNION ALL
	  SELECT 'b' AS col1,  'val3' AS col2, 'otherval3' AS col3 UNION ALL
	  SELECT 'b' AS col1,  'val4' AS col2, 'otherval4' AS col3
	)
	SELECT col1, STRUCT(col2, col3) AS categorised
	FROM table1

-- ARRAY
	SELECT ARRAY<STRING>['value1', 'value2', 'value3', 'value4'] AS array1

	-- Array of arrays
	SELECT ARRAY
	(
		SELECT list_items
		FROM UNNEST(list) AS list_items
		WHERE 'value1' IN UNNEST(list)
	) FROM

-- NESTED FIELDS
	-- UNNESTING (can have ',' instead of 'LEFT JOIN')
	SELECT col1, a.* FROM table1
	LEFT JOIN UNNEST(array1) as a
	
	-- ARRAY_AGG (nesting)
	WITH table1 AS 
	(
	  SELECT 'a' AS col1,  'val1' AS col2, 'otherval1' AS col3 UNION ALL
	  SELECT 'a' AS col1,  'val2' AS col2, 'otherval2' AS col3 UNION ALL
	  SELECT 'b' AS col1,  'val3' AS col2, 'otherval3' AS col3 UNION ALL
	  SELECT 'b' AS col1,  'val4' AS col2, 'otherval4' AS col3
	)
	SELECT col1, ARRAY_AGG(STRUCT(col2, col3)) AS nested
	FROM table1
	GROUP BY col1


----- SYSTEM FUNCTIONS ------
-- Table basics (location, modification time, row count, size)
SELECT *, TIMESTAMP_MILLIS(last_modified_time)
FROM `project.dataset.__TABLES__` 
WHERE table_id = 'table1'

-- INFORMATION_SCHEMA. Query table schema
SELECT * FROM `project.dataset.table1`.COLUMNS 
WHERE table_name = 'table1'

-- Count the number of nested and total columns for a table
SELECT sum(CASE WHEN field_path NOT LIKE '%STRUCT%' THEN 1 END) AS unnested_column_numbers 
     , sum(CASE WHEN field_path NOT LIKE '%.%' THEN 1 END) AS nested_column_numbers 
FROM `project.dataset.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS` a 
WHERE table_name IN ('table1')
	
------ OTHER ------
-- \. Escaping characters

-- Variables
	-- Named parameters (variables) are supported in BigQuery only through the API using standard SQL, not the web UI.

-- Schema types:
	RECORD {datatype}	: A collection of schema elements in the same table
	RECORD REPEATED		: A collection of schema elements in the same table

------ CUSTOM SCRIPTS ------
-- Using the same date range in multiple parts of the query as a parameter
WITH date_ranges AS
(
  SELECT TIMESTAMP('2017-01-01') AS start_date, TIMESTAMP('2017-12-31') AS end_date
), 
{query}
WHERE datepartition BETWEEN (SELECT start_date FROM date_ranges) AND (SELECT end_date FROM date_ranges)

-- Randomise the result set of a table
SELECT col1, RAND() FROM table1
ORDER BY RAND() ASC

-- Split the comma-separated list of dependencies into one per row
WITH raw AS
(
  SELECT 'a,b,c' AS col1
)
SELECT
    SUBSTR(col1, STRPOS(col1, '.')+1, LENGTH(col1)) AS split
FROM raw AS r
, UNNEST(SPLIT(col1, ',')) AS col1

-- Convert tabular table format to a 'skinny' format
WITH Input AS (
  SELECT 1 AS col1, 2 AS col2, 3 AS col3
  UNION ALL
  SELECT 3, 4, 5
), json AS
(
  SELECT 
      SPLIT(REPLACE(REPLACE(REPLACE(TO_JSON_STRING(Input), '"', ''),'{', ''),'}', '') , ',') AS js
  FROM Input AS Input
)
SELECT 
  SPLIT(js, ':')[OFFSET(0)] col_name,
  SPLIT(js, ':')[OFFSET(1)] value
FROM json
, UNNEST(js) AS js











	


-- Sort later !!! --
-- OFFSET. Displays an array index starting from 0.
SELECT array1[OFFSET(2)] -- value3
AS zero_indexed
FROM array1

	-- WITH OFFSET. Labels each elemen when unnested.
	SELECT items, customer
	FROM UNNEST(['value1', 'value2', 'value3'] AS items
	WITH OFFSET AS index
	ORDER BY index

-- ORDINAL. Displays an array index starting from 1.
SELECT array1[ORDINAL(2)] -- value2
AS one_indexed
FROM array1

-- ARRAY_LENGTH
-- OFFSET. Displays an array index starting from 0.
SELECT ARRAY_LENGTH(array1) -- value3
AS zero_size
FROM array1

-- Unflattening an array. Outputs a singular row for customer 1 with 3 items for that customer appearing on three lines.
SELECT
	['value1', 'value2', 'value3'] AS item
	'customer1' AS customer
	
-- Flattening an array. Returns one row for each array element.
SELECT items, customer
FROM UNNEST(['value1', 'value2', 'value3'] AS items
CROSS JOIN (SELECT 'customer1' AS customer) -- CROSS JOIN is optional to include, put a comma after items

-- Author: Konstantin

-- https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-and-operators
