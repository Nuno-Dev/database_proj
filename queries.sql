-- Query 1
SELECT x.retailer_name FROM (SELECT retailer_name, COUNT(*) AS count  FROM responsible_for INNER JOIN retailer ON 
(retailer.retailer_tin=responsible_for.retailer_tin)  GROUP BY retailer_name) AS x WHERE x.count = (SELECT MAX(x.count) 
FROM (SELECT retailer_name, COUNT(*) AS count  FROM responsible_for INNER JOIN retailer ON 
(retailer.retailer_tin=responsible_for.retailer_tin)  GROUP BY retailer_name) AS x);

-- Query 2
SELECT DISTINCT retailer_name FROM retailer INNER JOIN (SELECT retailer_tin FROM responsible_for INNER JOIN 
(SELECT simple_category_name FROM simple_category INNER JOIN category ON (simple_category.simple_category_name = category.category_name))
 AS x ON (responsible_for.category_name = x.simple_category_name)) AS y ON (retailer.retailer_tin = y.retailer_tin);

-- Query 3
SELECT product_ean FROM product WHERE product_ean NOT IN (SELECT product_ean FROM replenish_event);

-- Query 4
SELECT y.product_ean FROM (SELECT x.product_ean, COUNT(*) AS count  FROM (SELECT DISTINCT product_ean,retailer_tin 
FROM replenish_event) AS x GROUP BY x.product_ean) AS y WHERE y.count = 1;