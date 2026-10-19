with orders as (
    select * from {{ ref('stg_orders') }}
    where status = 'completed'
),

customers as (
    select * from {{ ref('stg_customers') }}
)

select
    customers.customer_id,
    customers.first_name || ' ' || customers.last_name   as customer_name,
    count(orders.order_id)                              as completed_orders,
    coalesce(sum(orders.amount), 0)                     as total_revenue
from customers
left join orders
    on orders.customer_id = customers.customer_id
group by 1, 2
order by total_revenue desc
