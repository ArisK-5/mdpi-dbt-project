-- 3. Get the top 3 customers by invoiced amount by month
with
order_totals as (
    select
        date_trunc('month', ordered_at)::date as month,
        customer_id,
        sum(order_total) as invoiced_amount
    from {{ ref('orders') }}
    group by month, customer_id
),

ranked as (
    select
        month,
        customer_id,
        invoiced_amount,
        dense_rank() over (partition by month order by invoiced_amount desc) as customer_rank
    from order_totals
)

select
    r.month,
    r.customer_id,
    c.customer_name,
    r.invoiced_amount::numeric(10, 2) as invoiced_amount,
    r.customer_rank
from ranked as r
left join {{ ref('customers') }} as c
    on r.customer_id = c.customer_id
where r.customer_rank <= 3
order by r.month, r.customer_rank, r.customer_id
