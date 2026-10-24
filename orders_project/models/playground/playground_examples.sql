-- playground_examples: a safe place to try things out.
-- Nothing reads from this model, so breaking it won't affect fct_orders or any mart.
-- Use the Preview CTE button on each example below.

with

-- Example 1: date_diff and current_date
date_diff_example as (
    select
        date '2026-09-12'                                    as signup_date,
        current_date                                         as today,
        date_diff('day', date '2026-09-12', current_date)    as days_since_signup
),

-- Example 2: safe_divide on plain numbers
safe_divide_example as (
    select
        {{ safe_divide('10', '2') }} as should_be_5,
        {{ safe_divide('10', '0') }} as should_be_null
),

-- Example 3: count_by macro (one count column per status)
count_by_example as (
    select
        customer_id,
        {{ count_by('status', ['completed', 'cancelled', 'pending']) }}
    from {{ ref('stg_orders') }}
    group by customer_id
)

-- per-customer metrics moved to models/intermediate/int_customer_metrics.sql

select * from count_by_example