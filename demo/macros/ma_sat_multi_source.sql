{%- macro ma_sat_multi_source(src_pk, src_cdk, src_hashdiff, src_payload, src_ldts, src_source, source_model, src_extra_columns=none, src_column_map=none, src_run_ts='DBT_RUN_TS') -%}

{#--
    Multi-active, multi-source satellite.

    Combines the UNION-ALL / column-alignment / watermark front half of
    sat_multi_source with the GROUP-BASED change detection of automate_dv.ma_sat.

    Grain: one row per (src_pk, src_cdk, record_source). A parent key (src_pk) has
    many concurrently-active child rows (one per src_cdk value), and each source
    contributes its own group (Option B: group by src_pk + record_source).

    Change detection is by GROUP, not by row: for a given (src_pk, record_source)
    the incoming set of child rows is compared against the stored set. The group is
    re-inserted if any member's hashdiff differs OR the member count changed. Because
    each source is its own group, a late-arriving source does not make another
    source's group look like it shrank (no phantom versions).

    Required: src_pk, src_cdk, src_hashdiff, src_payload, src_ldts, src_source, source_model
    Optional: src_extra_columns, src_column_map, src_run_ts (default 'DBT_RUN_TS')
--#}

{#-- Required parameter validation --#}
{%- if src_pk is none -%}
    {{ exceptions.raise_compiler_error("src_pk is a required parameter for ma_sat_multi_source") }}
{%- endif -%}
{%- if src_cdk is none -%}
    {{ exceptions.raise_compiler_error("src_cdk is a required parameter for ma_sat_multi_source") }}
{%- endif -%}
{%- if src_hashdiff is none -%}
    {{ exceptions.raise_compiler_error("src_hashdiff is a required parameter for ma_sat_multi_source") }}
{%- endif -%}
{%- if src_payload is none -%}
    {{ exceptions.raise_compiler_error("src_payload is a required parameter for ma_sat_multi_source") }}
{%- endif -%}
{%- if src_ldts is none -%}
    {{ exceptions.raise_compiler_error("src_ldts is a required parameter for ma_sat_multi_source") }}
{%- endif -%}
{%- if src_source is none -%}
    {{ exceptions.raise_compiler_error("src_source is a required parameter for ma_sat_multi_source") }}
{%- endif -%}
{%- if source_model is none -%}
    {{ exceptions.raise_compiler_error("source_model is a required parameter for ma_sat_multi_source") }}
{%- endif -%}

{#-- Normalise src_cdk to a list (it may be a single string) --#}
{%- set cdk_cols = [src_cdk] if src_cdk is string else src_cdk -%}

{#-- source_model must be a non-empty list of strings --#}
{%- if source_model is string or source_model is mapping or source_model is not iterable -%}
    {{ exceptions.raise_compiler_error("source_model must be a list of model names for ma_sat_multi_source") }}
{%- endif -%}
{%- if source_model | length == 0 -%}
    {{ exceptions.raise_compiler_error("source_model list must contain at least one model name") }}
{%- endif -%}
{%- for m in source_model -%}
    {%- if m is not string or m | trim | length == 0 -%}
        {{ exceptions.raise_compiler_error("source_model entry at position " ~ loop.index ~ " must be a non-empty string") }}
    {%- endif -%}
{%- endfor -%}

{#-- Column resolution: determine payload columns per source model --#}
{%- set ns = namespace(source_columns={}) -%}

{%- if src_column_map is not none and src_column_map is mapping -%}
    {%- for map_key in src_column_map.keys() -%}
        {%- if map_key not in source_model -%}
            {{ log("WARNING: src_column_map contains model '" ~ map_key ~ "' not in source_model list " ~ source_model ~ ". Ignoring.", info=true) }}
        {%- endif -%}
    {%- endfor -%}
    {%- for model_name in source_model -%}
        {%- if model_name in src_column_map -%}
            {%- do ns.source_columns.update({model_name: src_column_map[model_name]}) -%}
        {%- else -%}
            {%- do ns.source_columns.update({model_name: []}) -%}
        {%- endif -%}
    {%- endfor -%}
{%- else -%}
    {%- for model_name in source_model -%}
        {%- set rel = adapter.get_relation(database=ref(model_name).database, schema=ref(model_name).schema, identifier=ref(model_name).identifier) -%}
        {%- if rel is none -%}
            {%- do ns.source_columns.update({model_name: src_payload | list}) -%}
        {%- else -%}
            {%- set columns = adapter.get_columns_in_relation(ref(model_name)) -%}
            {%- do ns.source_columns.update({model_name: columns | map(attribute='name') | list}) -%}
        {%- endif -%}
    {%- endfor -%}
{%- endif -%}

{#-- Superset of payload columns. src_payload is authoritative when provided. --#}
{%- set system_cols = [src_pk | upper, src_hashdiff | upper, src_ldts | upper, src_source | upper, src_run_ts | upper] -%}
{%- for c in cdk_cols -%}
    {%- do system_cols.append(c | upper) -%}
{%- endfor -%}

{%- set superset = src_payload | sort -%}

{%- if src_extra_columns is not none -%}
    {%- set extra_list = [src_extra_columns] if src_extra_columns is string else src_extra_columns -%}
    {%- set ns_extra = namespace(merged=superset | list) -%}
    {%- for ec in extra_list -%}
        {%- set existing_upper = ns_extra.merged | map('upper') | list -%}
        {%- if ec | upper not in existing_upper -%}
            {%- set ns_extra.merged = ns_extra.merged + [ec] -%}
        {%- endif -%}
    {%- endfor -%}
    {%- set superset = ns_extra.merged | sort -%}
{%- endif -%}

{#-- Keep system columns (run_ts, cdk) out of the payload superset so the padding
     loop never nulls or duplicates them. --#}
{%- set ns_clean = namespace(cols=[]) -%}
{%- for col in superset -%}
    {%- if col | upper not in system_cols -%}
        {%- do ns_clean.cols.append(col) -%}
    {%- endif -%}
{%- endfor -%}
{%- set superset = ns_clean.cols -%}

{%- if superset | length == 0 -%}
    {{ exceptions.raise_compiler_error("No payload columns found across source models") }}
{%- endif -%}

{#-- Watermark window (identical resolution to sat_multi_source). --#}
{%- set sentinel = '1900-01-01' -%}

{%- if var('to_date', none) is not none -%}
    {%- set to_date_expr = "CAST('" ~ var('to_date') ~ "' AS TIMESTAMP_NTZ)" -%}
{%- else -%}
    {%- set to_date_expr = "CAST(CONVERT_TIMEZONE('UTC','Asia/Kolkata', '" ~ run_started_at.strftime('%Y-%m-%d %H:%M:%S') ~ "'::timestamp_ntz) AS TIMESTAMP_NTZ)" -%}
{%- endif -%}

{%- if var('from_date', none) is not none -%}
    {%- set from_date = "'" ~ var('from_date') ~ "'" -%}
{%- elif not execute -%}
    {%- set from_date = "'" ~ sentinel ~ "'" -%}
{%- else -%}
    {%- set sat_rel = adapter.get_relation(database=this.database, schema=this.schema, identifier=this.identifier) -%}
    {%- if sat_rel is none -%}
        {%- set from_date = "'" ~ sentinel ~ "'" -%}
    {%- else -%}
        {%- set wm_query -%}
            SELECT COALESCE(MAX({{ src_run_ts }}), TO_TIMESTAMP_NTZ('{{ sentinel }}')) AS mx FROM {{ sat_rel }}
        {%- endset -%}
        {%- set results = run_query(wm_query) -%}
        {%- if results and (results.rows | length) > 0 and results.rows[0][0] is not none -%}
            {%- set from_date = "'" ~ results.rows[0][0] ~ "'" -%}
        {%- else -%}
            {%- set from_date = "'" ~ sentinel ~ "'" -%}
        {%- endif -%}
    {%- endif -%}
{%- endif -%}

{#-- Grouping key for Option B: parent key + record source. Each source's set of
     child rows for a parent is an independent group. --#}
WITH source_data AS (
    {%- for model_name in source_model %}
    -- Source {{ loop.index }}: {{ model_name }}
    SELECT
        a.{{ src_pk }},
        {%- for c in cdk_cols %}
        a.{{ c }},
        {%- endfor %}
        a.{{ src_hashdiff }},
        {%- set src_cols_upper = ns.source_columns[model_name] | map('upper') | list %}
        {#-- Payload cast to VARCHAR so all UNION ALL branches share a type. --#}
        {%- for col in superset %}
        {%- if col | upper in src_cols_upper %}
        CAST(a.{{ col }} AS VARCHAR) AS {{ col }},
        {%- else %}
        CAST(NULL AS VARCHAR) AS {{ col }},
        {%- endif %}
        {%- endfor %}
        a.{{ src_ldts }},
        a.{{ src_source }},
        {{ to_date_expr }} AS {{ src_run_ts }}
    FROM {{ ref(model_name) }} AS a
    WHERE a.{{ src_pk }} IS NOT NULL
        {%- for c in cdk_cols %}
      AND a.{{ c }} IS NOT NULL
        {%- endfor %}
      AND a.{{ src_ldts }} >  CAST({{ from_date }} AS TIMESTAMP_NTZ)
      AND a.{{ src_ldts }} <= {{ to_date_expr }}
    {%- if not loop.last %}

    UNION ALL
    {%- endif %}
    {%- endfor %}
)

{%- if automate_dv.is_any_incremental() %}
,

{#-- (parent, source) groups with at least one member inside the watermark window.
     source_data is used ONLY to discover WHICH groups changed. A member-level
     watermark cannot rebuild a full group on its own (an unchanged sibling keeps
     its old ldts and is filtered out), so the full set is re-fetched below. --#}
changed_groups AS (
    SELECT DISTINCT {{ src_pk }}, {{ src_source }}
    FROM source_data
),

{#-- FULL current set of members for each changed group, WITHOUT the watermark
     lower bound. This is how AutomateDV's ma_sat behaves: it re-inserts the whole
     group when any member changes, so every current member (including unchanged
     siblings) must be present. --#}
full_group_data AS (
    {%- for model_name in source_model %}
    -- Source {{ loop.index }} (full group): {{ model_name }}
    SELECT
        a.{{ src_pk }},
        {%- for c in cdk_cols %}
        a.{{ c }},
        {%- endfor %}
        a.{{ src_hashdiff }},
        {%- set src_cols_upper = ns.source_columns[model_name] | map('upper') | list %}
        {%- for col in superset %}
        {%- if col | upper in src_cols_upper %}
        CAST(a.{{ col }} AS VARCHAR) AS {{ col }},
        {%- else %}
        CAST(NULL AS VARCHAR) AS {{ col }},
        {%- endif %}
        {%- endfor %}
        a.{{ src_ldts }},
        a.{{ src_source }},
        {{ to_date_expr }} AS {{ src_run_ts }}
    FROM {{ ref(model_name) }} AS a
    INNER JOIN changed_groups AS cg
        ON a.{{ src_pk }} = cg.{{ src_pk }}
        AND a.{{ src_source }} = cg.{{ src_source }}
    WHERE a.{{ src_pk }} IS NOT NULL
        {%- for c in cdk_cols %}
      AND a.{{ c }} IS NOT NULL
        {%- endfor %}
      AND a.{{ src_ldts }} <= {{ to_date_expr }}
    {%- if not loop.last %}

    UNION ALL
    {%- endif %}
    {%- endfor %}
),

{#-- Collapse to one row per (parent, source, cdk): the current state of each
     member. If a member was edited more than once in the window we keep its
     latest src_ldts / hashdiff / payload. --#}
full_group_current AS (
    SELECT *
    FROM full_group_data
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY {{ src_pk }}, {{ src_source }}{%- for c in cdk_cols %}, {{ c }}{%- endfor %}
        ORDER BY {{ src_ldts }} DESC
    ) = 1
),

{#-- Incoming group member count (distinct cdk+hashdiff members per parent+source). --#}
source_data_with_count AS (
    SELECT a.*, b.source_count
    FROM full_group_current AS a
    INNER JOIN (
        SELECT {{ src_pk }}, {{ src_source }}, COUNT(*) AS source_count
        FROM (
            SELECT DISTINCT {{ src_pk }}, {{ src_source }}, {{ src_hashdiff }}
                {%- for c in cdk_cols -%}, {{ c }}{%- endfor %}
            FROM full_group_current
        ) AS d
        GROUP BY {{ src_pk }}, {{ src_source }}
    ) AS b
        ON a.{{ src_pk }} = b.{{ src_pk }}
        AND a.{{ src_source }} = b.{{ src_source }}
),

{#-- Latest stored VERSION per (parent, source). A version shares one src_ldts, so
     it is identified by MAX(src_ldts). Its members are the rows carrying that ldts. --#}
latest_version AS (
    SELECT mas.{{ src_pk }}, mas.{{ src_source }}, MAX(mas.{{ src_ldts }}) AS version_ldts
    FROM {{ this }} AS mas
    INNER JOIN changed_groups AS cg
        ON mas.{{ src_pk }} = cg.{{ src_pk }}
        AND mas.{{ src_source }} = cg.{{ src_source }}
    GROUP BY mas.{{ src_pk }}, mas.{{ src_source }}
),

latest_records AS (
    SELECT
        mas.{{ src_pk }},
        mas.{{ src_source }},
        mas.{{ src_hashdiff }},
        {%- for c in cdk_cols %}
        mas.{{ c }},
        {%- endfor %}
        mas.{{ src_ldts }}
    FROM {{ this }} AS mas
    INNER JOIN latest_version AS lv
        ON mas.{{ src_pk }} = lv.{{ src_pk }}
        AND mas.{{ src_source }} = lv.{{ src_source }}
        AND mas.{{ src_ldts }} = lv.version_ldts
),

latest_group_details AS (
    SELECT
        {{ src_pk }},
        {{ src_source }},
        COUNT(*) AS latest_count
    FROM latest_records
    GROUP BY {{ src_pk }}, {{ src_source }}
)
{%- endif %}

,

records_to_insert AS (
{%- if not automate_dv.is_any_incremental() %}
    SELECT * FROM source_data
{%- else %}
    {#-- Emit the WHOLE current group, stamped with a single shared version
         timestamp ({{ src_run_ts }} value = the batch to_date), when the group
         differs from the latest stored version. This mirrors AutomateDV ma_sat:
         a new version re-inserts every member (changed and unchanged) sharing one
         LOAD_DATETIME. The trigger is group-level (any member new/changed OR the
         member count changed), correlated only on (parent, source). --#}
    SELECT
        sdc.{{ src_pk }},
        {%- for c in cdk_cols %}
        sdc.{{ c }},
        {%- endfor %}
        sdc.{{ src_hashdiff }},
        {%- for col in superset %}
        sdc.{{ col }},
        {%- endfor %}
        sdc.{{ src_run_ts }} AS {{ src_ldts }},
        sdc.{{ src_source }},
        sdc.{{ src_run_ts }}
    FROM source_data_with_count AS sdc
    WHERE EXISTS (
        SELECT 1
        FROM source_data_with_count AS stage
        LEFT JOIN latest_group_details AS lg
            ON stage.{{ src_pk }} = lg.{{ src_pk }}
            AND stage.{{ src_source }} = lg.{{ src_source }}
        WHERE stage.{{ src_pk }} = sdc.{{ src_pk }}
          AND stage.{{ src_source }} = sdc.{{ src_source }}
          AND (
            {# new group, or member count changed (member added/removed) #}
            lg.latest_count IS NULL
            OR stage.source_count != lg.latest_count
            {# or this member is absent from the stored version (payload changed) #}
            OR NOT EXISTS (
                SELECT 1
                FROM latest_records AS lr
                WHERE lr.{{ src_pk }} = stage.{{ src_pk }}
                  AND lr.{{ src_source }} = stage.{{ src_source }}
                  AND lr.{{ src_hashdiff }} = stage.{{ src_hashdiff }}
                  {%- for c in cdk_cols %}
                  AND lr.{{ c }} = stage.{{ c }}
                  {%- endfor %}
            )
          )
    )
{%- endif %}
)

SELECT * FROM records_to_insert

{%- endmacro -%}
