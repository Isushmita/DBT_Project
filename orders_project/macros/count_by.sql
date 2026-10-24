{#
    count_by: makes one count column for each value in a list.

    Example call:
        {{ count_by('status', ['completed', 'cancelled']) }}

    Builds this SQL:
        sum(case when lower(status) = 'completed' then 1 else 0 end) as completed_count,
        sum(case when lower(status) = 'cancelled' then 1 else 0 end) as cancelled_count
#}

{% macro count_by(column_name, values) %}

    {% for value in values %}

        {# one column per value: 1 if the row matches, 0 if not, then add them up #}
        sum(
            case
                when lower({{ column_name }}) = '{{ value }}' then 1
                else 0
            end
        ) as {{ value }}_count

        {# a comma between columns, but not after the last one #}
        {% if not loop.last %} , {% endif %}

    {% endfor %}

{% endmacro %}
