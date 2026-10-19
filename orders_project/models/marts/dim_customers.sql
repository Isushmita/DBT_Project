with customers as (
    select * from {{ ref('stg_customers') }}
),

regions as (
    select * from {{ ref('stg_customer_regions') }}
),

genders as (
    select * from {{ ref('stg_customer_genders') }}
)

select
    customers.customer_id,
    customers.first_name,
    customers.last_name,
    customers.email,
    customers.signup_date,
    regions.region,
    coalesce(genders.gender, 'unknown') as gender
from customers
left join regions
    on regions.customer_id = customers.customer_id
left join genders
    on genders.customer_id = customers.customer_id
