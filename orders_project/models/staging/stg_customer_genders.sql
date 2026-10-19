with source as (
    select
        customer_id,
        upper(trim(gender)) as gender
    from {{ source('shop', 'raw_customer_genders') }}
)

select
    customer_id,
    case gender
        when 'F' then 'female'
        when 'M' then 'male'
        else 'unknown'
    end as gender
from source
