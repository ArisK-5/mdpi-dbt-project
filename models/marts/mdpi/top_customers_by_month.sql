-- 3. Get the top 3 customers by invoiced amount by month
with
customer_monthly_totals as (
    select
        date_trunc('month', ordered_at)::date as month_date,
        customer_id,
        sum(order_total) as invoiced_amount
    from {{ ref('orders') }}
    group by month_date, customer_id
),

ranked_monthly_totals as (
    select
        month_date,
        customer_id,
        invoiced_amount,
        dense_rank() over (partition by month_date order by invoiced_amount desc) as customer_rank
    from customer_monthly_totals
)

select
    r.month_date,
    r.customer_id,
    c.customer_name,
    r.invoiced_amount::numeric(10, 2) as invoiced_amount,
    r.customer_rank
from ranked_monthly_totals as r
left join {{ ref('customers') }} as c
    on r.customer_id = c.customer_id
where r.customer_rank <= 3
order by r.month_date, r.customer_rank, r.customer_id
