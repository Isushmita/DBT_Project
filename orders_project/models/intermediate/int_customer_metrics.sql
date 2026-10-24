-- int_customer_metrics: one row per customer with order-based metrics.
-- Starts FROM customers so customers with no orders (like 108) are kept, with null metrics.
-- No status filter in the join, because cancellation_rate needs ALL orders;
-- the case whens pick out completed orders inside each sum instead.

with

orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        customers.customer_id,

        -- completed revenue / completed orders (cancelled orders don't count)
        {{ safe_divide(
            "sum(case when orders.status = 'completed' then orders.amount else 0 end)",
            "sum(case when orders.status = 'completed' then 1 else 0 end)"
        ) }} as avg_order_value,

        -- by hand this would be:
        -- sum(case when orders.status = 'cancelled' then 1 else 0 end) / nullif(count(orders.order_id), 0)
        {{ safe_divide(
            "sum(case when orders.status = 'cancelled' then 1 else 0 end)",
            "count(orders.order_id)"
        ) }} as cancellation_rate

    from customers
    left join orders
        on customers.customer_id = orders.customer_id
    group by customers.customer_id
)

select * from final
