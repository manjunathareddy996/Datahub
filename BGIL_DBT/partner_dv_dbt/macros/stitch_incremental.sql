{% macro stitch_incremental(sources, output_columns, coalesce_rules, unique_key='parent_bk', target_sat=none) %}

{#-- OPEN ITEM (decide later): the sat_multi_source macro re-applies a LOAD_DATETIME
     window on top of the one this stitch already applies. For a steady-state stitch
     input that time window is largely redundant with the stitch's; it is still needed
     generically for direct (non-stitched) sources, mixed inputs, and first-run sources.
     Revisit whether the sat-level time window can be dropped when every source_model is
     a stitch view. The sat-level hashdiff change detection is always required. --#}

{#-- When target_sat is provided, use the parameterized watermark window
     (from_date < ldts_column <= to_date). Otherwise keep the original T-1 filter. --#}
{%- if target_sat is not none -%}

    {#-- Derive the single source-system group for this stitch from the source_tag
         prefixes (text before the first underscore, e.g. 'OPUS_AZBJ_...' -> 'OPUS').
         A stitch is single-system by design, so validate that every source shares the
         same prefix and error otherwise. The group scopes the MAX(DBT_RUN_TS) watermark
         to this system's rows in the shared target sat via RECORD_SOURCE LIKE '<group>_%'. --#}
    {%- set ns_grp = namespace(group=none) -%}
    {%- for src in sources -%}
        {%- if src.source_tag is none or '_' not in src.source_tag -%}
            {{ exceptions.raise_compiler_error("stitch_incremental: source '" ~ (src.model | default('?')) ~ "' has a missing or malformed source_tag '" ~ (src.source_tag | default('')) ~ "' (expected '<SYSTEM>_<TABLE>')") }}
        {%- endif -%}
        {%- set src_group = src.source_tag.split('_')[0] -%}
        {%- if ns_grp.group is none -%}
            {%- set ns_grp.group = src_group -%}
        {%- elif src_group != ns_grp.group -%}
            {{ exceptions.raise_compiler_error("stitch_incremental: mixed source-system prefixes in one stitch ('" ~ ns_grp.group ~ "' vs '" ~ src_group ~ "'). A stitch must be single-system.") }}
        {%- endif -%}
    {%- endfor -%}
    {%- set source_group = ns_grp.group -%}

    {#-- Resolve to_date. var('to_date') overrides; otherwise convert run_started_at (UTC) to IST in SQL
         via CONVERT_TIMEZONE so it is guaranteed IST regardless of run_started_at's rendered timezone.
         Stored as a SQL expression string (not a quoted literal) so it is used directly in the filter. --#}
    {%- if var('to_date', none) is not none -%}
        {%- set to_date_expr = "CAST('" ~ var('to_date') ~ "' AS TIMESTAMP_NTZ)" -%}
    {%- else -%}
        {%- set to_date_expr = "CAST(CONVERT_TIMEZONE('UTC','Asia/Kolkata', '" ~ run_started_at.strftime('%Y-%m-%d %H:%M:%S') ~ "'::timestamp_ntz) AS TIMESTAMP_NTZ)" -%}
    {%- endif -%}

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
                SELECT COALESCE(MAX(DBT_RUN_TS), TO_TIMESTAMP_NTZ('{{ sentinel }}')) AS mx
                FROM {{ sat_rel }}
                WHERE RECORD_SOURCE LIKE '{{ source_group }}_%'
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
      AND {{ src.ldts_column }} <= {{ to_date_expr }}
    {%- else %}
      AND {{ src.ldts_column }} >= DATEADD(DAY, -1, CURRENT_DATE())
    {%- endif %}
    {% if not loop.last %}UNION{% endif %}
    {% endfor %}
),
{%- for src in sources %}
{{ src.alias }} AS (
    SELECT DISTINCT
        {{ src.key_column }} AS {{ unique_key }}
        {%- for col in src.columns %},
        NULLIF(TRIM(TO_VARCHAR({{ col.src }})), '') AS {{ col.tgt }}
        {%- endfor %},
        {{ src.ldts_column }}
    FROM {{ this.database }}.{{ this.schema }}.{{ src.model }}
    WHERE {{ src.key_column }} IS NOT NULL
),
{%- endfor %}
{#-- Build a single ORDER BY for the final QUALIFY (prefer rows that carry values) --#}
{%- set ns = namespace(order_terms=[]) -%}
{%- for src in sources -%}
    {%- for col in src.columns -%}
        {%- do ns.order_terms.append(src.alias ~ '.' ~ col.tgt ~ ' NULLS LAST') -%}
    {%- endfor -%}
{%- endfor -%}
final AS (
    SELECT
        ak.{{ unique_key }} AS {{ unique_key }},
        {%- for col in output_columns %}
        {% if coalesce_rules[col] | length == 1 %}{{ coalesce_rules[col][0] }}.{{ col }}{% else %}COALESCE({% for alias in coalesce_rules[col] %}{{ alias }}.{{ col }}{% if not loop.last %}, {% endif %}{% endfor %}){% endif %} AS {{ col }},
        {%- endfor %}
        ARRAY_TO_STRING(ARRAY_CONSTRUCT_COMPACT(
            {%- for src in sources %}
            CASE WHEN {{ src.alias }}.{{ unique_key }} IS NOT NULL THEN '{{ src.source_tag }}' END{% if not loop.last %},{% endif %}
            {%- endfor %}
        ), ', ') AS record_source,
        GREATEST_IGNORE_NULLS({% for src in sources %}{{ src.alias }}.{{ src.ldts_column }}{% if not loop.last %}, {% endif %}{% endfor %}) AS inc_job_updated_at
    FROM affected_keys ak
    {%- for src in sources %}
    LEFT JOIN {{ src.alias }} ON {{ src.alias }}.{{ unique_key }} = ak.{{ unique_key }}
    {%- endfor %}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY ak.{{ unique_key }}
        ORDER BY {{ ns.order_terms | join(', ') }}
    ) = 1
)

SELECT
    {{ unique_key }},
    {%- for col in output_columns %}
    {{ col }},
    {%- endfor %}
    record_source,
    inc_job_updated_at
FROM final

{% endmacro %}
