
-- Clean, prepared tables for explore, "null" values removed.
SELECT * 
FROM olist_order_items

--Clean and ready to join.
SELECT *
FROM olist_orders_dataset

--Cleaning needs, after null values removed, table will be added to join.
SELECT *
FROM olist_products_dataset

-- First, we'll check the null values.
SELECT * 
FROM olist_products_dataset
WHERE product_category_name IS NULL

--After, we remove(delete) "null" values from the table
DELETE FROM olist_products_dataset
WHERE product_category_name IS NULL

--Quick check for cleaning query
SELECT *
FROM olist_products_dataset
WHERE product_category_name IS NULL
-- Table has been altered for joining.

-- Check for any null values for the last table.
SELECT *
FROM olist_customers_dataset
WHERE customer_id IS NULL
    OR customer_unique_id IS NULL

-- Clean and ready to join
SELECT *
FROM olist_customers_dataset

-- Finally, 4 tables following :
-- **olist_customers_dataset**
-- **olist_order_items**
-- **olist_orders_dataset**
-- **olist_products_dataset**
-- are all ready to finely explore and ready to finalize EDM


-- Orders daily purchase time(per 6 hours/day) distributions.
SELECT 
    COUNT(*)
FROM olist_orders_dataset
WHERE order_purchase_timestamp  > "hh:mm:ss" AND order_purchase_timestamp < "hh:mm:ss"

-----------------------------------------------------------------------------------------------
-- Orders status distributions by types. (Delivered,Cancelled,Etc..)
SELECT
    order_status,
    COUNT(*) as status_count
FROM 
    olist_orders_dataset
GROUP BY
    order_status

-- 72.165 
SELECT 
    COUNT(*)
FROM olist_order_items
WHERE  
    price < 100.00 AND price > 0.00

-- 40.313
SELECT 
    COUNT(*)
FROM olist_order_items
WHERE  
    price > 100.00

--- AVG 'price' value for orders : 120
SELECT 
    AVG(price) as avg_price
FROM
    olist_order_items

-- MEDIAN 'price' value for orders : 74.99
SELECT
    AVG(price) AS average_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price
FROM
    olist_order_items;

SELECT
    COUNT(*)
FROM
    olist_order_items
WHERE
    price > 1000.00 AND price <= 6735.00


SELECT *
FROM olist_order_items
WHERE price <= 120
--------------------------------------------------------------

-- Total number of product_id number from table : 112.650

SELECT
    COUNT(product_id) as numbers
FROM
    olist_order_items

-- Unique values from product_id column(To find most repeated, best sellers): 32.950

SELECT
    COUNT(DISTINCT product_id) as unique_product_id
FROM 
    olist_order_items

-- Now, we need to product_id trends in here. After we monitorize trends, we can use for joining product categories to create recommendations.

SELECT
    product_id,
    COUNT(*) as product_count
FROM 
    olist_order_items
GROUP BY
    product_id
ORDER BY
    product_count DESC;

-- We can call this above queried small dataframe as "Bestseller_product_id" which it will work for product category matching.
-- After save the dataframe, we'll have the distribution of best seller product_id group.

CREATE TABLE bestseller_product_id AS
SELECT
    product_id,
    COUNT(*) as product_count
FROM 
    olist_order_items
GROUP BY
    product_id
ORDER BY
    product_count DESC;

-- AVG sell count for bestsellers distribution

---- %5 rank for bestsellers
WITH Ranked_products AS (
    SELECT 
        product_id,
        product_count,
        NTILE(100) OVER (ORDER BY product_count DESC) AS percentile_rank
    FROM
        bestseller_product_id
)
SELECT 
    COUNT(percentile_rank) as Top_numbers_product_id
FROM 
    Ranked_products
WHERE
    percentile_rank < 6;

--- Avarage order count for bestsellers 3,40

SELECT 
    AVG(product_count) as avg_product_count
FROM bestseller_product_id

-- The product_id counts for avarage order count 3,40. 
 
SELECT 
    COUNT(product_count) AS less_than_50tile
FROM 
    bestseller_product_id
WHERE
    product_count > 0 AND product_count <= 4 


-- Remaning rank will be dedicated from expecting over %50 tile.

CREATE TABLE bestseller_over50tile_table AS
    SELECT 
        product_id,
        product_count
    FROM 
        bestseller_product_id
    WHERE
        product_count > 4 

SELECT  *
FROM bestseller_over50tile_table

-- Again we need an avarage value for this table. AVG = 15.00

SELECT 
    AVG(product_count) as avg_product_count2
FROM
    bestseller_over50tile_table

--- Same process will be continue as above listed tables.

SELECT 
    COUNT(product_count) AS less_than_20tile
FROM 
    bestseller_over50tile_table
WHERE
    product_count >= 15  

CREATE TABLE bestseller_over20tile_table AS
    SELECT 
        product_id,
        product_count
    FROM 
        bestseller_over50tile_table
    WHERE
        product_count > 15 

SELECT *
FROM bestseller_over20tile_table

SELECT 
    AVG(product_count) as avg_product_count3
FROM
    bestseller_over20tile_table

SELECT 
    COUNT(product_count) AS less_than_10tile
FROM
    bestseller_over20tile_table
WHERE
    product_count >= 39

CREATE TABLE bestseller_over10tile_table AS
    SELECT
        product_id,
        product_count
    FROM 
        bestseller_over20tile_table
    WHERE
        product_count > 39

SELECT *
FROM bestseller_over10tile_table

SELECT
    AVG(product_count) AS avg_product_count4
FROM
    bestseller_over10tile_table

SELECT
    COUNT(product_count) AS less_than_1tile
FROM 
    bestseller_over10tile_table
WHERE
    product_count > 87

------------------------------------------------

-- Product Table Distributions for EDA

SELECT *
FROM olist_products_dataset

-- Unique values for product_category_name matched with product_id

SELECT
    COUNT(DISTINCT product_category_name) AS unique_product_categories
FROM
    olist_products_dataset;

-- Total 73.00 categories
CREATE TABLE product_category_distribution AS
    SELECT
        product_category_name,
        COUNT(*) AS num_categories
    FROM
        olist_products_dataset
    GROUP BY
        product_category_name
    ORDER BY
        num_categories DESC;

----------------------------------------------------
-- We need to analyze deep more product and categories with price segmentation.
-- at this point, we'll join olist_order_items with olist_products_dataset to find
-- more insights bridges between orders and categories connection.

CREATE TABLE orders_categories_values AS
    SELECT
        ooi.order_id,
        opd.product_category_name,
        ooi.price
    FROM
        olist_order_items ooi
    JOIN
        olist_products_dataset opd ON ooi.product_id = opd.product_id

SELECT * FROM orders_categories_values
