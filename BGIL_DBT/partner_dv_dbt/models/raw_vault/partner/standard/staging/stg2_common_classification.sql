{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stage() pass for stitch_common_classification -- serves SAT_COMMON_CLASSIFICATION.
-- PARTY_HKEY hashed once here (namespaced: 'HUB_PARTY|' || raw key).

{%- set yaml_metadata -%}
source_model: 'stitch_common_classification'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRIORITYCODE'
      - 'SEGMENTCODE'
derived_columns:
  PARTY_NK: "'HUB_PARTY|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{#-- Stamp DBT_RUN_TS = run timestamp in IST (frozen run_started_at, UTC->Asia/Kolkata). var('to_date') overrides. --#}
{%- set run_ts_utc = run_started_at.strftime('%Y-%m-%d %H:%M:%S') -%}
{%- if var('to_date', none) is not none -%}
    {%- set dbt_run_ts_expr = "CAST('" ~ var('to_date') ~ "' AS TIMESTAMP_NTZ)" -%}
{%- else -%}
    {%- set dbt_run_ts_expr = "CAST(CONVERT_TIMEZONE('UTC','Asia/Kolkata', '" ~ run_ts_utc ~ "'::timestamp_ntz) AS TIMESTAMP_NTZ)" -%}
{%- endif -%}

SELECT
    staged.*,
    {{ dbt_run_ts_expr }} AS DBT_RUN_TS
FROM (

    {{ automate_dv.stage(include_source_columns=true,
                          source_model=metadata_dict['source_model'],
                          hashed_columns=metadata_dict['hashed_columns'],
                          derived_columns=metadata_dict['derived_columns']) }}

) AS staged
