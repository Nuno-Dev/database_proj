DROP VIEW sales;

create or replace function GET_TRIMESTRE(timestamp)
returns integer language sql immutable as $$
    select (extract('month' from $1::date-9)::int-1)/3+1
$$;

CREATE VIEW sales
AS
SELECT DISTINCT 
replenish_event.product_ean ean, 
category_name cat,
TO_CHAR(replenish_event_instant::timestamp,'YYYY') ano, 
GET_TRIMESTRE(replenish_event_instant::timestamp) trimestre,
TO_CHAR(replenish_event_instant::timestamp,'DD') dia_mes, 
TO_CHAR(replenish_event_instant::timestamp,'Day') dia_semana, 
retail_point_district distrito,retail_point_county concelho,
replenish_event_units unidades 
FROM replenish_event 
INNER JOIN (SELECT category_name, product.product_ean, retail_point_district,retail_point_county FROM product 
INNER JOIN (SELECT product_ean,retail_point_district,retail_point_county FROM retail_point 
INNER JOIN (SELECT * FROM installed_at 
INNER JOIN (SELECT product.product_ean,ivm_serial_number FROM replenish_event
INNER JOIN product ON (replenish_event.product_ean = product.product_ean)) AS x ON (installed_at.ivm_serial_number = x.ivm_serial_number))
AS y ON (retail_point. retail_point_name = y.retail_point_name)) AS w ON (product.product_ean = w.product_ean)) AS a ON (replenish_event.product_ean = a. product_ean);




