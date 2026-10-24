with orders as (
    select * from {{ ref('stg_orders') }}
    where status = 'completed'
),

customers as (
    select * from {{ ref('dim_customers') }}
)

select
    customers.customer_id,
    customers.first_name || ' ' || customers.last_name   as customer_name,
    customers.region,
    customers.gender,
    count(orders.order_id)                              as completed_orders,
    coalesce(sum(orders.amount), 0)                     as total_revenue
from customers
left join orders
    on orders.customer_id = customers.customer_id
group by 1, 2, 3, 4
order by total_revenue desc
