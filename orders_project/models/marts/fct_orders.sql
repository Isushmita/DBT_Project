-- fct_orders: one row per order, with customer info and order-level metrics.
-- Experiments and examples live in models/playground/playground_examples.sql

with

orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

final as (

    select
        -- order columns from stg_orders
        orders.order_id,
        orders.customer_id,
        orders.amount,
        orders.status,
        orders.order_date,
        orders.order_rundate,

        -- customer columns from dim_customers
        customers.region,
        customers.signup_date,

        -- 1st, 2nd, 3rd... order for each customer (oldest first, order_id breaks ties)
        row_number() over (
            partition by orders.customer_id
            order by orders.order_date, orders.order_id
        ) as customer_order_number,

        -- true for the customer's first order
        customer_order_number = 1 as is_first_order,

        -- day gaps
        date_diff('day', customers.signup_date, orders.order_date) as days_order_since_signup,  -- fixed per order
        date_diff('day', customers.signup_date, current_date)      as days_customer_since_signup,  -- changes daily
        date_diff('day', orders.order_date, current_date)          as days_since_order             -- changes daily

    from orders
    left join customers
        on orders.customer_id = customers.customer_id
)

select * from final
