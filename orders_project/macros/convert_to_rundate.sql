{% macro convert_to_rundate(column_name) %}
    strftime(cast({{ column_name }} as date), '%Y%m%d')
{% endmacro %}
