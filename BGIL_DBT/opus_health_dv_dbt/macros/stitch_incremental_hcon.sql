{% macro stitch_incremental_hcon(sources, output_columns, coalesce_rules, hub_keys=[], unique_key='parent_bk', target_sat=none) %}

{#-- OPEN ITEM (decide later): the sat_multi_source macro re-applies a LOAD_DATETIME
     window on top of the one this stitch already applies. For a steady-state stitch
     input that time window is largely redundant with the stitch's; it is still needed
     generically for direct (non-stitched) sources, mixed inputs, and first-run sources.
     Revisit whether the sat-level time window can be dropped when every source_model is
     a stitch view. The sat-level hashdiff change detection is always required. --#}

{#-- stitch_incremental_hcon is a copy of stitch_incremental extended with a hub_keys
     parameter and per-source hub_key_columns threading. The watermark/affected_keys/
     QUALIFY row-pick logic is identical to stitch_incremental; it additionally carries
     each source's hub-key source expressions through the per-source CTEs and emits the
     central view's hub business-key columns in the final SELECT. The partner original in
     macros/stitch_incremental.sql is left unchanged. --#}

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
            {{ exceptions.raise_compiler_error("stitch_incremental_hcon: source '" ~ (src.model | default('?')) ~ "' has a missing or malformed source_tag '" ~ (src.source_tag | default('')) ~ "' (expected '<SYSTEM>_<TABLE>')") }}
        {%- endif -%}
        {%- set src_group = src.source_tag.split('_')[0] -%}
        {%- if ns_grp.group is none -%}
            {%- set ns_grp.group = src_group -%}
        {%- elif src_group != ns_grp.group -%}
            {{ exceptions.raise_compiler_error("stitch_incremental_hcon: mixed source-system prefixes in one stitch ('" ~ ns_grp.group ~ "' vs '" ~ src_group ~ "'). A stitch must be single-system.") }}
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

{#-- Resolve the SQL expression for each source's key. key_column may be an ALIAS that
     is the tgt of a hub_key_columns entry (not a real column in the stg model); in that
     case use that entry's src_expr. Otherwise fall back to key_column unchanged.
     Keyed by src.alias. --#}
{%- set key_exprs = {} -%}
{%- for src in sources -%}
    {%- set kns = namespace(expr=src.key_column) -%}
    {%- for hk in (src.hub_key_columns | default([])) -%}
        {%- if hk.tgt == src.key_column -%}
            {%- set kns.expr = hk.src_expr -%}
        {%- endif -%}
    {%- endfor -%}
    {%- do key_exprs.update({src.alias: kns.expr}) -%}
{%- endfor -%}

WITH affected_keys AS (
    {% for src in sources %}
    SELECT DISTINCT {{ key_exprs[src.alias] }} AS {{ unique_key }}
    FROM {{ this.database }}.{{ this.schema }}.{{ src.model }}
    WHERE {{ key_exprs[src.alias] }} IS NOT NULL
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
        {{ key_exprs[src.alias] }} AS {{ unique_key }}
        {%- for col in src.columns %},
        NULLIF(TRIM(TO_VARCHAR({{ col.src }})), '') AS {{ col.tgt }}
        {%- endfor %}
        {%- for hk in (src.hub_key_columns | default([])) %},
        {{ hk.src_expr }} AS {{ hk.tgt }}
        {%- endfor %},
        {{ src.ldts_column }}
    FROM {{ this.database }}.{{ this.schema }}.{{ src.model }}
    WHERE {{ key_exprs[src.alias] }} IS NOT NULL
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
        {%- for hk in hub_keys %}
        {{ hk.expr }} AS {{ hk.name }},
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
    {%- for hk in hub_keys %}
    {{ hk.name }},
    {%- endfor %}
    record_source,
    inc_job_updated_at
FROM final

{% endmacro %}
