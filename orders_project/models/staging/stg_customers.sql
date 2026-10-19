with source as (
    select
        id,
        trim(first_name) as first_name,
        trim(last_name)  as last_name,
        email,
        signup_date
    from {{ source('shop', 'raw_customers') }}
)

select
    id                                                      as customer_id,
    upper(left(first_name, 1)) || lower(substr(first_name, 2)) as first_name,
    upper(left(last_name, 1))  || lower(substr(last_name, 2))  as last_name,
    lower(email)                                            as email,
    signup_date
from source
