{% macro stitch_incremental(sources, output_columns, coalesce_rules, unique_key='parent_bk', target_sat=none) %}

{#-- When target_sat is provided, use the parameterized watermark window
     (from_date < ldts_column <= to_date). Otherwise keep the original T-1 filter. --#}
{%- if target_sat is not none -%}

    {#-- Resolve to_date: var override or run_started_at --#}
    {%- set td = var('to_date', run_started_at.strftime('%Y-%m-%d %H:%M:%S')) -%}
    {%- set to_date = "'" ~ td ~ "'" -%}

    {#-- Resolve from_date: var override -> MAX(DBT_RUN_TS) from sat -> sentinel --#}
    {%- set sentinel = '1900-01-01' -%}
    {%- if var('from_date', none) is not none -%}
        {%- set from_date = "'" ~ var('from_date') ~ "'" -%}
    {%- elif not execute -%}
        {%- set from_date = "'" ~ sentinel ~ "'" -%}
    {%- else -%}
        {%- set sat_rel = adapter.get_relation(
                database=this.database if this else target.database,
                schema=this.schema if this else target.schema,
                identifier=target_sat) -%}
        {%- if sat_rel is none -%}
            {%- set from_date = "'" ~ sentinel ~ "'" -%}
        {%- else -%}
            {%- set wm_query -%}
                SELECT COALESCE(MAX(DBT_RUN_TS), TO_TIMESTAMP_NTZ('{{ sentinel }}')) AS mx FROM {{ sat_rel }}
            {%- endset -%}
            {%- set results = run_query(wm_query) -%}
            {%- if results and (results.rows | length) > 0 and results.rows[0][0] is not none -%}
                {%- set from_date = "'" ~ results.rows[0][0] ~ "'" -%}
            {%- else -%}
                {%- set from_date = "'" ~ sentinel ~ "'" -%}
            {%- endif -%}
        {%- endif -%}
    {%- endif -%}

{%- endif -%}

WITH affected_keys AS (
    {% for src in sources %}
    SELECT DISTINCT {{ src.key_column }} AS {{ unique_key }}
    FROM {{ this.database }}.{{ this.schema }}.{{ src.model }}
    WHERE {{ src.key_column }} IS NOT NULL
    {%- if target_sat is not none %}
      AND {{ src.ldts_column }} >  CAST({{ from_date }} AS TIMESTAMP_NTZ)
      AND {{ src.ldts_column }} <= CAST({{ to_date }} AS TIMESTAMP_NTZ)
    {%- else %}
      AND {{ src.ldts_column }} >= DATEADD(DAY, -1, CURRENT_DATE())
    {%- endif %}
    {% if not loop.last %}UNION{% endif %}
    {% endfor %}
),
{% for src in sources %}
{{ src.alias }} AS (
    SELECT DISTINCT
        {{ src.key_column }} AS {{ unique_key }}
        {%- for col in src.columns %},
        NULLIF(TRIM(TO_VARCHAR({{ col.src }})), '') AS {{ col.tgt }}
        {%- endfor %}
    FROM {{ this.database }}.{{ this.schema }}.{{ src.model }}
    WHERE {{ src.key_column }} IS NOT NULL
      AND {{ src.key_column }} IN (SELECT {{ unique_key }} FROM affected_keys)
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY {{ src.key_column }}
        ORDER BY {% for col in src.columns %}{{ col.tgt }}{% if not loop.last %}, {% endif %}{% endfor %}
    ) = 1
),
{% endfor %}
stitched AS (
    SELECT
        COALESCE({% for src in sources %}{{ src.alias }}.{{ unique_key }}{% if not loop.last %}, {% endif %}{% endfor %}) AS {{ unique_key }},
        {%- for col in output_columns %}
        {% if coalesce_rules[col] | length == 1 %}{{ coalesce_rules[col][0] }}.{{ col }}{% else %}COALESCE({% for alias in coalesce_rules[col] %}{{ alias }}.{{ col }}{% if not loop.last %}, {% endif %}{% endfor %}){% endif %} AS {{ col }},
        {%- endfor %}
        ARRAY_TO_STRING(ARRAY_CONSTRUCT_COMPACT(
            {%- for src in sources %}
            CASE WHEN {{ src.alias }}.{{ unique_key }} IS NOT NULL THEN '{{ src.source_tag }}' END{% if not loop.last %},{% endif %}
            {%- endfor %}
        ), ', ') AS record_source
    FROM {{ sources[0].alias }}
    {%- for src in sources[1:] %}
    FULL OUTER JOIN {{ src.alias }}
        ON {% if loop.index == 1 %}{{ sources[0].alias }}.{{ unique_key }}{% else %}COALESCE({% for prev in sources[:loop.index] %}{{ prev.alias }}.{{ unique_key }}{% if not loop.last %}, {% endif %}{% endfor %}){% endif %} = {{ src.alias }}.{{ unique_key }}
    {%- endfor %}
)

SELECT
    {{ unique_key }},
    {%- for col in output_columns %}
    {{ col }},
    {%- endfor %}
    record_source
FROM stitched

{% endmacro %}
