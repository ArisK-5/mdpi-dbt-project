-- 1. Average number of items in orders by location
with
agg_orders as (
    select
        location_id,
        avg(count_order_items) as avg_items_per_order,
        count(*) as orders_count
    from {{ ref('orders') }}
    group by location_id
)

select
    l.location_id,
    l.location_name,
    ao.orders_count,
    ao.avg_items_per_order::numeric(10, 2) as avg_items_per_order
from agg_orders as ao
left join {{ ref('locations') }} as l
    on ao.location_id = l.location_id
