{{ config(materialized='view') }}

-- POC: stage() over the watermark-windowed stitch (stitch_common_classification_incr).
-- PARTY_HKEY + HASHDIFF hashed here (namespaced: 'HUB_PARTY|' || raw key).
-- DBT_RUN_TS = to_date (frozen run timestamp) is added in an outer SELECT (as a real TIMESTAMP_NTZ),
-- NOT via automate_dv derived_columns, because the '!' prefix would wrap the whole expression in quotes.
-- It is carried into the sat as a NON-hashdiff extra column, and is the value the stitch reads MAX() of.

{#-- Convert run_started_at (UTC) to IST in SQL via CONVERT_TIMEZONE, so the result is guaranteed IST
     regardless of how run_started_at's timezone is rendered. var('to_date') overrides (used as-is). --#}
{%- set run_ts_utc = run_started_at.strftime('%Y-%m-%d %H:%M:%S') -%}
{%- if var('to_date', none) is not none -%}
    {%- set dbt_run_ts_expr = "CAST('" ~ var('to_date') ~ "' AS TIMESTAMP_NTZ)" -%}
{%- else -%}
    {%- set dbt_run_ts_expr = "CAST(CONVERT_TIMEZONE('UTC','Asia/Kolkata', '" ~ run_ts_utc ~ "'::timestamp_ntz) AS TIMESTAMP_NTZ)" -%}
{%- endif -%}

{%- set yaml_metadata -%}
source_model: 'stitch_common_classification_incr'
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

SELECT
    staged.*,
    {{ dbt_run_ts_expr }} AS DBT_RUN_TS
FROM (

    {{ automate_dv.stage(include_source_columns=true,
                          source_model=metadata_dict['source_model'],
                          hashed_columns=metadata_dict['hashed_columns'],
                          derived_columns=metadata_dict['derived_columns']) }}

) AS staged
