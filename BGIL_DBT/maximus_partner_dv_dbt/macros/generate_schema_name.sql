{#
    Schema resolution for maximus_partner_dv.

    Existing behaviour is preserved: dbt's default `<target.schema>_<custom>` concatenation
    still applies to every model, so nothing that already runs changes.

    The exception is any schema listed in the `absolute_schemas` var. Those are returned
    verbatim, which is what lets this project write into partner_dv_dbt's vault schema
    (BGIL_DATA_MODEL) rather than a target-prefixed copy of it. partner_dv_dbt resolves
    BGIL_DATA_MODEL verbatim too, so both projects land on the same physical relation.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set absolute_schemas = var('absolute_schemas', ['BGIL_DATA_MODEL']) -%}

    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- elif custom_schema_name | trim in absolute_schemas -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ target.schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}

{%- endmacro %}
