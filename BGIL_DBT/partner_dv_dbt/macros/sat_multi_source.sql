{%- macro sat_multi_source(src_pk, src_hashdiff, src_payload, src_ldts, src_source, source_model, src_extra_columns=none, src_eff=none, src_column_map=none, src_run_ts='DBT_RUN_TS') -%}

{#-- Required parameter validation --#}
{%- if src_pk is none -%}
    {{ exceptions.raise_compiler_error("src_pk is a required parameter for sat_multi_source") }}
{%- endif -%}

{%- if src_hashdiff is none -%}
    {{ exceptions.raise_compiler_error("src_hashdiff is a required parameter for sat_multi_source") }}
{%- endif -%}

{%- if src_payload is none -%}
    {{ exceptions.raise_compiler_error("src_payload is a required parameter for sat_multi_source") }}
{%- endif -%}

{%- if src_ldts is none -%}
    {{ exceptions.raise_compiler_error("src_ldts is a required parameter for sat_multi_source") }}
{%- endif -%}

{%- if src_source is none -%}
    {{ exceptions.raise_compiler_error("src_source is a required parameter for sat_multi_source") }}
{%- endif -%}

{%- if source_model is none -%}
    {{ exceptions.raise_compiler_error("source_model is a required parameter for sat_multi_source") }}
{%- endif -%}

{#-- Type checking and delegation --#}
{%- if source_model is string -%}

    {#-- Single-string delegation: produce identical output to automate_dv.sat() --#}
    {{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff, src_payload=src_payload, src_extra_columns=src_extra_columns, src_eff=src_eff, src_ldts=src_ldts, src_source=src_source, source_model=source_model) }}

{%- elif source_model is iterable and source_model is not mapping -%}

    {#-- List validation: must be non-empty --#}
    {%- if source_model | length == 0 -%}
        {{ exceptions.raise_compiler_error("source_model list must contain at least one model name") }}
    {%- endif -%}

    {#-- List validation: each entry must be a non-empty string --#}
    {%- for m in source_model -%}
        {%- if m is not string or m | trim | length == 0 -%}
            {{ exceptions.raise_compiler_error("source_model entry at position " ~ loop.index ~ " must be a non-empty string") }}
        {%- endif -%}
    {%- endfor -%}

    {#-- Column resolution: determine payload columns per source model --#}
    {%- set ns = namespace(source_columns={}) -%}

    {%- if src_column_map is not none and src_column_map is mapping -%}
        {#-- Explicit column map provided: warn about extra keys not in source_model --#}
        {%- for map_key in src_column_map.keys() -%}
            {%- if map_key not in source_model -%}
                {{ log("WARNING: src_column_map contains model '" ~ map_key ~ "' not in source_model list " ~ source_model ~ ". Ignoring.", info=true) }}
            {%- endif -%}
        {%- endfor -%}

        {#-- Populate per-source column lists from the explicit map --#}
        {%- for model_name in source_model -%}
            {%- if model_name in src_column_map -%}
                {%- do ns.source_columns.update({model_name: src_column_map[model_name]}) -%}
            {%- else -%}
                {%- do ns.source_columns.update({model_name: []}) -%}
            {%- endif -%}
        {%- endfor -%}
    {%- else -%}
        {#-- No column map: introspect each source model via adapter --#}
        {%- for model_name in source_model -%}
            {%- set rel = adapter.get_relation(database=ref(model_name).database, schema=ref(model_name).schema, identifier=ref(model_name).identifier) -%}
            {%- if rel is none -%}
                {#-- Relation not yet materialised (first run / fresh schema): assume
                     source provides all payload columns.  Snowflake will raise a clear
                     error at execution time if a column is genuinely absent. --#}
                {%- if src_payload is not none and src_payload | length > 0 -%}
                    {%- do ns.source_columns.update({model_name: src_payload | list}) -%}
                {%- else -%}
                    {{ exceptions.raise_compiler_error("Source model '" ~ model_name ~ "' does not resolve to a valid relation and no src_payload was provided to fall back on") }}
                {%- endif -%}
            {%- else -%}
                {%- set columns = adapter.get_columns_in_relation(ref(model_name)) -%}
                {%- set col_names = columns | map(attribute='name') | list -%}
                {%- do ns.source_columns.update({model_name: col_names}) -%}
            {%- endif -%}
        {%- endfor -%}
    {%- endif -%}

    {#-- Superset computation --#}
    {%- set system_cols = [src_pk | upper, src_hashdiff | upper, src_ldts | upper, src_source | upper, src_run_ts | upper] -%}
    {%- if src_eff is not none -%}
        {%- do system_cols.append(src_eff | upper) -%}
    {%- endif -%}

    {%- if src_payload is not none and src_payload | length > 0 -%}
        {#-- src_payload is the authoritative superset --#}
        {%- set superset = src_payload | sort -%}
    {%- else -%}
        {#-- Derive superset from all source columns, excluding system columns --#}
        {%- set ns_sup = namespace(seen=[], result=[]) -%}
        {%- for model_name in source_model -%}
            {%- for col in ns.source_columns[model_name] -%}
                {%- if col | upper not in system_cols and col | upper not in ns_sup.seen -%}
                    {%- set ns_sup.seen = ns_sup.seen + [col | upper] -%}
                    {%- set ns_sup.result = ns_sup.result + [col] -%}
                {%- endif -%}
            {%- endfor -%}
        {%- endfor -%}
        {%- set superset = ns_sup.result | sort -%}
    {%- endif -%}

    {#-- Include src_extra_columns in superset if provided --#}
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

    {#-- src_run_ts is stamped as a system column below, so it must never sit in the
         payload superset. If it did, the padding loop would emit
         CAST(NULL AS VARCHAR) AS DBT_RUN_TS for every source (it is in no
         src_column_map entry) and also duplicate the column name. --#}
    {%- set superset = superset | reject('equalto', src_run_ts) | reject('equalto', src_run_ts | upper) | list -%}

    {#-- Validate we have payload columns --#}
    {%- if superset | length == 0 -%}
        {{ exceptions.raise_compiler_error("No payload columns found across source models") }}
    {%- endif -%}

    {#-- Watermark window, mirroring stitch_incremental:
         to_date   = var('to_date') override, else run_started_at (UTC) converted to IST.
         from_date = var('from_date') override, else MAX(DBT_RUN_TS) from this sat, else sentinel.
         The sat is read via {{ this }} (it IS the target), so there is no DAG cycle.
         Sources are filtered on their own src_ldts against this window; they never need
         a DBT_RUN_TS column of their own. --#}
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

    {#-- Generate source_data CTE with UNION ALL --#}
WITH source_data AS (
    {%- for model_name in source_model %}
    -- Source {{ loop.index }}: {{ model_name }}
    SELECT
        a.{{ src_pk }},
        a.{{ src_hashdiff }},
        {%- set src_cols_upper = ns.source_columns[model_name] | map('upper') | list %}
        {%- for col in superset %}
        {%- if col | upper in src_cols_upper %}
        a.{{ col }},
        {%- else %}
        CAST(NULL AS VARCHAR) AS {{ col }},
        {%- endif %}
        {%- endfor %}
        {%- if src_eff is not none %}
        a.{{ src_eff }},
        {%- endif %}
        a.{{ src_ldts }},
        a.{{ src_source }},
        {{ to_date_expr }} AS {{ src_run_ts }}
    FROM {{ ref(model_name) }} AS a
    WHERE a.{{ src_pk }} IS NOT NULL
      AND a.{{ src_ldts }} >  CAST({{ from_date }} AS TIMESTAMP_NTZ)
      AND a.{{ src_ldts }} <= {{ to_date_expr }}
    {%- if not loop.last %}

    UNION ALL
    {%- endif %}
    {%- endfor %}
),

    {#-- Change-detection CTEs and final SELECT --#}
{%- if automate_dv.is_any_incremental() %}
latest_records AS (
    SELECT
        current_records.{{ src_pk }},
        current_records.{{ src_hashdiff }},
        current_records.{{ src_ldts }}
    FROM {{ this }} AS current_records
    INNER JOIN (
        SELECT DISTINCT source_data.{{ src_pk }}
        FROM source_data
    ) AS source_records
        ON source_records.{{ src_pk }} = current_records.{{ src_pk }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY current_records.{{ src_pk }}
        ORDER BY current_records.{{ src_ldts }} DESC
    ) = 1
),
{%- endif %}

unique_source_records AS (
    SELECT
        sd.{{ src_pk }},
        sd.{{ src_hashdiff }},
        {%- for col in superset %}
        sd.{{ col }},
        {%- endfor %}
        {%- if src_eff is not none %}
        sd.{{ src_eff }},
        {%- endif %}
        sd.{{ src_ldts }},
        sd.{{ src_source }},
        sd.{{ src_run_ts }}
    FROM source_data AS sd
    {%- if automate_dv.is_any_incremental() %}
    LEFT OUTER JOIN latest_records AS lr
        ON sd.{{ src_pk }} = lr.{{ src_pk }}
    {%- endif %}
    QUALIFY sd.{{ src_hashdiff }} !=
        LAG(sd.{{ src_hashdiff }}, 1,
            {%- if automate_dv.is_any_incremental() %}
            COALESCE(lr.{{ src_hashdiff }}, CAST('FFFFFFFF' AS BINARY(4)))
            {%- else %}
            CAST('FFFFFFFF' AS BINARY(4))
            {%- endif %}
        ) OVER (
            PARTITION BY sd.{{ src_pk }}
            ORDER BY sd.{{ src_ldts }} ASC{%- if src_eff is not none %}, sd.{{ src_eff }} ASC{%- endif %}
        )
),

records_to_insert AS (
    SELECT * FROM unique_source_records
)

SELECT * FROM records_to_insert

{%- else -%}

    {#-- source_model is neither a string nor a list --#}
    {{ exceptions.raise_compiler_error("source_model must be a string or a list of strings") }}

{%- endif -%}

{%- endmacro -%}