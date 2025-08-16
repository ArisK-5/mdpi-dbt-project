-- 2. For each product, the number of items sold as well as their average price, tax included
with
items_sold_with_tax as (
    select
        i.product_id,
        i.product_name,
        i.product_price * (1 + coalesce(l.tax_rate, 0)) as price_with_tax
    from {{ ref('order_items') }} as i
    inner join {{ ref('orders') }} as o
        on i.order_id = o.order_id
    inner join {{ ref('locations') }} as l
        on o.location_id = l.location_id
)

select
    product_id,
    max(product_name) as product_name,
    count(*) as items_sold,
    avg(price_with_tax)::numeric(10, 2) as avg_price_with_tax
from items_sold_with_tax
group by product_id
order by items_sold desc
