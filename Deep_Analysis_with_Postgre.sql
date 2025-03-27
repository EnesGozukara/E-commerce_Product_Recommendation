
SELECT * 
FROM olist_order_items
WHERE product_id ='1e9e8ef04dbcff4541ed26657ea517e5'


SELECT * 
FROM olist_products_dataset



SELECT DISTINCT 
    product_id,
    product_category_name
FROM 
    olist_products_dataset
WHERE 
    product_category_name IS NOT NULL
    
