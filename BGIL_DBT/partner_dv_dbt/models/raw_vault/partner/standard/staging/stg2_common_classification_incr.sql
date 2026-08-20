{{ config(materialized='view') }}

-- POC: stage() over the watermark-windowed stitch (stitch_common_classification_incr).
-- PARTY_HKEY + HASHDIFF hashed here (namespaced: 'HUB_PARTY|' || raw key).
-- DBT_RUN_TS = to_date (frozen run timestamp) is added in an outer SELECT (as a real TIMESTAMP_NTZ),
-- NOT via automate_dv derived_columns, because the '!' prefix would wrap the whole expression in quotes.
-- It is carried into the sat as a NON-hashdiff extra column, and is the value the stitch reads MAX() of.

{#-- run_started_at is UTC; use Snowflake CONVERT_TIMEZONE for reliable IST conversion --#}
{%- set to_date = var('to_date', none) -%}

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
