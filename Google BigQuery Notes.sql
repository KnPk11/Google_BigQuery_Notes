-- Schema types:
	RECORD		: A collection of schema elements in the same table

-- ARRAY
SELECT ARRAY<STRING>['value1', 'value2', 'value3', 'value4']
AS array1

	-- Array of arrays
	SELECT ARRAY
	(
		SELECT list_items
		FROM UNNEST(list) AS list_items
		WHERE 'value1' IN UNNEST(list)
	) FROM
	
-- STRUCT
SELECT STRUCT<INT64, STRING>(35 AS age, 'Jacob' AS name) AS customers -- customers.age, customers.name columns

	-- A struct of arrays
	SELECT 
		STRUCT(35 AS age,
		'Jacob' AS name,
		['apple', 'pear', 'peach'] AS items)
	AS customers
	
	--

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


