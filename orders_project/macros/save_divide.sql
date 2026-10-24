{#
    safe_divide: divides without blowing up when the bottom number is 0.

    Example call:
        {{ safe_divide('total_revenue', 'completed_orders') }}

    Builds this SQL:
        total_revenue / nullif(completed_orders, 0)

    If the bottom is 0, nullif turns it into null, so the answer is null
    (instead of NaN in DuckDB, or a "division by zero" crash in Snowflake).
#}

{% macro safe_divide(numerator, denominator) %}
    ({{ numerator }}) / nullif({{ denominator }}, 0)
{% endmacro %}
