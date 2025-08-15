-- 4. Compute the total invoiced amount variation (in %) between months
with
monthly as (
    select
        date_trunc('month', ordered_at)::date as month,
        sum(order_total) as invoiced_amount
    from {{ ref('orders') }}
    group by month
),

previous as (
    select
        month,
        invoiced_amount,
        lag(invoiced_amount) over (order by month) as prev_invoiced_amount
    from monthly
)

select
    month,
    invoiced_amount::numeric(10, 2) as invoiced_amount,
    prev_invoiced_amount::numeric(10, 2) as prev_invoiced_amount,
    (
        case
            when prev_invoiced_amount is null or prev_invoiced_amount = 0 then null
            else (invoiced_amount - prev_invoiced_amount) * 100.0 / prev_invoiced_amount
        end
    )::numeric(10, 2) as invoiced_variation_pct
from previous
order by month
