{% macro get_run_date() %}
    {#
        Returns the date to filter source data for a single day.
        Override at runtime: dbt run --vars '{"run_date": "2024-02-20"}'
        Defaults to '2026-02-20' (last date with data in source).
    #}
    {% if var('run_date', none) is not none %}
        '{{ var("run_date") }}'
    {% else %}
        '2026-02-20'
    {% endif %}
{% endmacro %}
