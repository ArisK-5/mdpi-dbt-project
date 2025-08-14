-- 5. The total cost paid by supply and product type in 2016
with 
	items_2016 as (
		select
			product_id,
			count(*) as items_sold
		from marts.order_items
		where ordered_at >= '2016-01-01'
			and ordered_at < '2017-01-01' 
		group by product_id
	) -- zero because data includes only 2024 & 2025
select
	s.supply_name,
	p.product_type,
	sum(i.items_sold * s.supply_cost)::numeric(10,2) as total_cost_2016
from items_2016 i
join marts.supplies s
 	on i.product_id = s.product_id
left join marts.products p
 	on i.product_id = p.product_id
group by s.supply_name, p.product_type
order by s.supply_name, p.product_type
