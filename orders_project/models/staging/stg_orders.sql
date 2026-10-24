select
    id                                   as order_id,
    cust_id                              as customer_id,
    {{ cents_to_dollars('amt_cents') }}  as amount,          -- 1
    lower(status)                        as status,          -- 2
    created                              as order_date,
    {{ convert_to_rundate('created') }}  as order_rundate    -- 3
from {{ source('shop', 'raw_orders') }}
