{% macro capitalize_status(column_name) %}
    upper({{ column_name }})
{% endmacro %}