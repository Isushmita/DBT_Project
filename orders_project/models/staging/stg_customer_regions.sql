with source as (
    select
        customer_id,
        lower(trim(region)) as region
    from {{ source('shop', 'raw_customer_regions') }}
)

select
    customer_id,
    case region
        when 'north america' then 'North America'
        when 'south america' then 'South America'
        when 'europe'        then 'Europe'
        when 'middle east'   then 'Middle East'
        when 'apac'          then 'APAC'
    end as region
from source
