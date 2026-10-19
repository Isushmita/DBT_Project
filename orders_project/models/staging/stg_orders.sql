select
    id                  as order_id,
    cust_id             as customer_id,
    amt_cents / 100.0   as amount,
    lower(status)       as status,
    created             as order_date
from {{ source('shop', 'raw_orders') }}
