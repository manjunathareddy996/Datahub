{% macro hash(columns) %}
    {% if columns is string %}
        MD5(UPPER(TRIM(COALESCE(CAST({{ columns }} AS VARCHAR), ''))))
    {% else %}
        MD5(
            CONCAT_WS('||',
                {% for col in columns %}
                UPPER(TRIM(COALESCE(CAST({{ col }} AS VARCHAR), '')))
                {% if not loop.last %},{% endif %}
                {% endfor %}
            )
        )
    {% endif %}
{% endmacro %}

{% macro hash_diff(columns) %}
    MD5(
        CONCAT_WS('||',
            {% for col in columns %}
            UPPER(TRIM(COALESCE(CAST({{ col }} AS VARCHAR), '')))
            {% if not loop.last %},{% endif %}
            {% endfor %}
        )
    )
{% endmacro %}
