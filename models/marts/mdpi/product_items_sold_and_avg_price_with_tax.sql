-- 2. For each product, the number of items sold as well as their average price, tax included
select
    i.product_id,
    max(i.product_name) as product_name,
    count(*) as items_sold,
    avg(i.product_price * (1 + coalesce(l.tax_rate, 0)))::numeric(10, 2) as avg_price_with_tax
from marts.order_items as i
inner join marts.orders as o
    on i.order_id = o.order_id
inner join marts.locations as l
    on o.location_id = l.location_id
group by i.product_id
order by items_sold desc
