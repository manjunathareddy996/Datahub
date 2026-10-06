{%- macro sat_multi_source(src_pk, src_hashdiff, src_payload, src_ldts, src_source, source_model, src_extra_columns=none, src_eff=none, src_column_map=none, src_run_ts='DBT_RUN_TS', src_record_source_map=none, src_object_columns=none, src_hashdiff_alias=none) -%}

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

    {%- if source_model | length == 0 -%}
        {{ exceptions.raise_compiler_error("source_model list must contain at least one model name") }}
    {%- endif -%}
    {%- for m in source_model -%}
        {%- if m is not string or m | trim | length == 0 -%}
            {{ exceptions.raise_compiler_error("source_model entry at position " ~ loop.index ~ " must be a non-empty string") }}
        {%- endif -%}
    {%- endfor -%}

    {%- if src_record_source_map is none or src_record_source_map is not mapping -%}
        {{ exceptions.raise_compiler_error("src_record_source_map is required and must be a mapping when source_model is a list") }}
    {%- endif -%}
    {%- for model_name in source_model -%}
        {%- if model_name not in src_record_source_map -%}
            {{ exceptions.raise_compiler_error("No RECORD_SOURCE mapping found for source model '" ~ model_name ~ "'") }}
        {%- endif -%}
        {%- if src_record_source_map[model_name] is none or src_record_source_map[model_name] | trim | length == 0 -%}
            {{ exceptions.raise_compiler_error("RECORD_SOURCE mapping for source model '" ~ model_name ~ "' cannot be empty") }}
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
        {%- set superset = src_payload | sort -%}
    {%- else -%}
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

    {%- set superset = superset | reject('equalto', src_run_ts) | reject('equalto', src_run_ts | upper) | list -%}

    {%- if superset | length == 0 -%}
        {{ exceptions.raise_compiler_error("No payload columns found across source models") }}
    {%- endif -%}

    {#-- Object-column setup. object_cols = payload columns to objectify; plain_cols = the rest. --#}
    {%- set object_cols = [] -%}
    {%- if src_object_columns is not none -%}
        {%- set obj_list = [src_object_columns] if src_object_columns is string else src_object_columns -%}
        {%- for oc in obj_list -%}
            {%- if oc | upper in (superset | map('upper') | list) -%}
                {%- do object_cols.append(oc | upper) -%}
            {%- else -%}
                {{ exceptions.raise_compiler_error("src_object_columns entry '" ~ oc ~ "' is not in the payload superset") }}
            {%- endif -%}
        {%- endfor -%}
    {%- endif -%}
    {%- set use_object = object_cols | length > 0 -%}
    {%- set plain_cols = [] -%}
    {%- for col in superset -%}
        {%- if col | upper not in object_cols -%}
            {%- do plain_cols.append(col) -%}
        {%- endif -%}
    {%- endfor -%}

    {%- set sentinel = '1900-01-01' -%}

    {#-- Option A: output hashdiff column name. The source stg2 may expose a suffixed hashdiff
         (e.g. HASHDIFF_COMMON_CONTACT in a wide maximus view); src_hashdiff_alias lets the
         satellite WRITE it into the shared table under a common name (e.g. HASHDIFF) so both
         projects share one hashdiff column. Defaults to src_hashdiff (no rename). --#}
    {%- set out_hashdiff = src_hashdiff_alias if src_hashdiff_alias is not none else src_hashdiff -%}
    {%- set do_incremental = automate_dv.is_any_incremental() -%}

    {%- if var('to_date', none) is not none -%}
        {%- set to_date_expr = "CAST('" ~ var('to_date') ~ "' AS TIMESTAMP_NTZ)" -%}
    {%- else -%}
        {%- set to_date_expr = "CAST(CONVERT_TIMEZONE('UTC','Asia/Kolkata', '" ~ run_started_at.strftime('%Y-%m-%d %H:%M:%S') ~ "'::timestamp_ntz) AS TIMESTAMP_NTZ)" -%}
    {%- endif -%}

    {%- set source_watermarks = {} -%}

    {%- if var('from_date', none) is not none -%}
        {%- for model_name in source_model -%}
            {%- set source_group = src_record_source_map[model_name] -%}
            {%- do source_watermarks.update({source_group: "'" ~ var('from_date') ~ "'"}) -%}
        {%- endfor -%}
    {%- elif not execute -%}
        {%- for model_name in source_model -%}
            {%- set source_group = src_record_source_map[model_name] -%}
            {%- do source_watermarks.update({source_group: "'" ~ sentinel ~ "'"}) -%}
        {%- endfor -%}
    {%- else -%}
        {%- set sat_rel = adapter.get_relation(database=this.database, schema=this.schema, identifier=this.identifier) -%}
        {%- for model_name in source_model -%}
            {%- set source_group = src_record_source_map[model_name] -%}
            {%- if source_group not in source_watermarks -%}
                {%- if sat_rel is none -%}
                    {%- do source_watermarks.update({source_group: "'" ~ sentinel ~ "'"}) -%}
                {%- else -%}
                    {%- set wm_query -%}
                        SELECT COALESCE(MAX({{ src_run_ts }}), TO_TIMESTAMP_NTZ('{{ sentinel }}')) AS mx
                        FROM {{ sat_rel }}
                        WHERE {{ src_source }} LIKE '{{ source_group }}_%'
                    {%- endset -%}
                    {%- set results = run_query(wm_query) -%}
                    {%- if results and (results.rows | length) > 0 and results.rows[0][0] is not none -%}
                        {%- do source_watermarks.update({source_group: "'" ~ results.rows[0][0] ~ "'"}) -%}
                    {%- else -%}
                        {%- do source_watermarks.update({source_group: "'" ~ sentinel ~ "'"}) -%}
                    {%- endif -%}
                {%- endif -%}
            {%- endif -%}
        {%- endfor -%}
    {%- endif -%}

    {#-- Generate source_data CTE with UNION ALL --#}
WITH source_data AS (
    {%- for model_name in source_model %}
    {%- set current_source_group = src_record_source_map[model_name] -%}
    {%- set current_from_date = source_watermarks[current_source_group] -%}

    -- Source {{ loop.index }}: {{ model_name }}
    SELECT
        a.{{ src_pk }},
        a.{{ src_hashdiff }} AS {{ out_hashdiff }},
        {%- set src_cols_upper = ns.source_columns[model_name] | map('upper') | list %}
        {#-- Payload is cast to VARCHAR so every UNION ALL branch agrees on type. --#}
        {%- for col in superset %}
        {%- if col | upper in src_cols_upper %}
        CAST(a.{{ col }} AS VARCHAR) AS {{ col }},
        {%- else %}
        CAST(NULL AS VARCHAR) AS {{ col }},
        {%- endif %}
        {%- endfor %}
        {%- if src_eff is not none %}
        a.{{ src_eff }},
        {%- endif %}
        a.{{ src_ldts }},
        a.{{ src_source }} AS {{ src_source }},
        {%- if use_object %}
        '{{ current_source_group }}' AS SOURCE_GROUP,
        REGEXP_REPLACE(a.{{ src_source }}, '^{{ current_source_group }}_', '') AS SOURCE_TABLE,
        {%- endif %}

        {{ to_date_expr }} AS {{ src_run_ts }}
    FROM {{ ref(model_name) }} AS a
    WHERE a.{{ src_pk }} IS NOT NULL
      AND a.{{ src_ldts }} > CAST({{ current_from_date }} AS TIMESTAMP_NTZ)
      AND a.{{ src_ldts }} <= {{ to_date_expr }}
    {%- if not loop.last %}

    UNION ALL
    {%- endif %}
    {%- endfor %}
)

{%- if not use_object %}
,
    {#-- Change-detection CTEs and final SELECT --#}
{%- if do_incremental %}
latest_records AS (
    SELECT
        current_records.{{ src_pk }},
        current_records.{{ out_hashdiff }},
        current_records.{{ src_source }},
        current_records.{{ src_ldts }}
    FROM {{ this }} AS current_records
    INNER JOIN (
        SELECT DISTINCT source_data.{{ src_pk }}, source_data.{{ src_source }}
        FROM source_data
    ) AS source_records
        ON source_records.{{ src_pk }} = current_records.{{ src_pk }}
        AND source_records.{{ src_source }} = current_records.{{ src_source }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY current_records.{{ src_pk }}, current_records.{{ src_source }}
        ORDER BY current_records.{{ src_ldts }} DESC
    ) = 1
),
{%- endif %}

unique_source_records AS (
    SELECT
        sd.{{ src_pk }},
        sd.{{ out_hashdiff }},
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
    {%- if do_incremental %}
    LEFT OUTER JOIN latest_records AS lr
        ON sd.{{ src_pk }} = lr.{{ src_pk }}
        AND sd.{{ src_source }} = lr.{{ src_source }}
    {%- endif %}
    QUALIFY sd.{{ out_hashdiff }} !=
        LAG(sd.{{ out_hashdiff }}, 1,
            {%- if do_incremental %}
            COALESCE(lr.{{ out_hashdiff }}, CAST('FFFFFFFF' AS BINARY(4)))
            {%- else %}
            CAST('FFFFFFFF' AS BINARY(4))
            {%- endif %}
        ) OVER (
            PARTITION BY sd.{{ src_pk }}, sd.{{ src_source }}
            ORDER BY sd.{{ src_ldts }} ASC{%- if src_eff is not none %}, sd.{{ src_eff }} ASC{%- endif %}
        )
),

records_to_insert AS (
    SELECT * FROM unique_source_records
)

SELECT * FROM records_to_insert

{%- else %}
,
{#-- OBJECT branch (src_object_columns set): grain = one row per (src_pk, source group).
     First collapse to one value per (src_pk, group, source_table) so OBJECT_AGG never sees a
     duplicate key (a source table can have many rows per party). --#}
source_deduped AS (
    SELECT
        sd.{{ src_pk }},
        sd.SOURCE_GROUP,
        sd.SOURCE_TABLE,
        {%- for col in object_cols %}
        MAX(sd.{{ col }}) AS {{ col }},
        {%- endfor %}
        {%- for col in plain_cols %}
        MAX(sd.{{ col }}) AS {{ col }},
        {%- endfor %}
        MAX(sd.{{ src_ldts }}) AS {{ src_ldts }},
        MAX(sd.{{ src_run_ts }}) AS {{ src_run_ts }}
    FROM source_data AS sd
    GROUP BY sd.{{ src_pk }}, sd.SOURCE_GROUP, sd.SOURCE_TABLE
),

object_rows AS (
    SELECT
        sdd.{{ src_pk }},
        sdd.SOURCE_GROUP AS {{ src_source }},
        {%- for col in object_cols %}
        OBJECT_AGG(sdd.SOURCE_TABLE, TO_VARIANT(sdd.{{ col }})) AS {{ col }},
        {%- endfor %}
        {%- for col in plain_cols %}
        MAX(sdd.{{ col }}) AS {{ col }},
        {%- endfor %}
        MAX(sdd.{{ src_ldts }}) AS {{ src_ldts }},
        MAX(sdd.{{ src_run_ts }}) AS {{ src_run_ts }}
    FROM source_deduped AS sdd
    GROUP BY sdd.{{ src_pk }}, sdd.SOURCE_GROUP
),

hashed AS (
    SELECT
        orw.{{ src_pk }},
        CAST(MD5_BINARY(CONCAT(
            {%- for col in object_cols %}
            IFNULL(TO_JSON(orw.{{ col }}), '^^'), '||',
            {%- endfor %}
            {%- for col in plain_cols %}
            IFNULL(CAST(orw.{{ col }} AS VARCHAR), '^^'){%- if not loop.last %}, '||',{%- endif %}
            {%- endfor %}
        )) AS BINARY(16)) AS {{ out_hashdiff }},
        {%- for col in object_cols %}
        orw.{{ col }},
        {%- endfor %}
        {%- for col in plain_cols %}
        orw.{{ col }},
        {%- endfor %}
        orw.{{ src_ldts }},
        orw.{{ src_source }},
        orw.{{ src_run_ts }}
    FROM object_rows AS orw
)

{%- if do_incremental %}
,
latest_records AS (
    SELECT
        current_records.{{ src_pk }},
        current_records.{{ out_hashdiff }},
        current_records.{{ src_source }},
        current_records.{{ src_ldts }}
    FROM {{ this }} AS current_records
    INNER JOIN (
        SELECT DISTINCT hashed.{{ src_pk }}, hashed.{{ src_source }}
        FROM hashed
    ) AS source_records
        ON source_records.{{ src_pk }} = current_records.{{ src_pk }}
        AND source_records.{{ src_source }} = current_records.{{ src_source }}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY current_records.{{ src_pk }}, current_records.{{ src_source }}
        ORDER BY current_records.{{ src_ldts }} DESC
    ) = 1
)
{%- endif %}
,
records_to_insert AS (
    SELECT
        h.{{ src_pk }},
        h.{{ out_hashdiff }},
        {%- for col in object_cols %}
        h.{{ col }},
        {%- endfor %}
        {%- for col in plain_cols %}
        h.{{ col }},
        {%- endfor %}
        h.{{ src_ldts }},
        h.{{ src_source }},
        h.{{ src_run_ts }}
    FROM hashed AS h
    {%- if do_incremental %}
    LEFT OUTER JOIN latest_records AS lr
        ON h.{{ src_pk }} = lr.{{ src_pk }}
        AND h.{{ src_source }} = lr.{{ src_source }}
    WHERE lr.{{ out_hashdiff }} IS NULL
       OR h.{{ out_hashdiff }} != lr.{{ out_hashdiff }}
    {%- endif %}
)

SELECT * FROM records_to_insert

{%- endif %}

{%- else -%}
    {{ exceptions.raise_compiler_error("source_model must be a string or a list of strings") }}
{%- endif -%}

{%- endmacro -%}
