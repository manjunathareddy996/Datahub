{{ config(materialized='view') }}

-- POC: stage() over the watermark-windowed stitch (stitch_common_classification_incr).
-- PARTY_HKEY + HASHDIFF hashed here (namespaced: 'HUB_PARTY|' || raw key).
-- DBT_RUN_TS = to_date (frozen run timestamp). It is stamped here, carried into the sat as a
-- NON-hashdiff extra column, and is the value get_from_date() reads MAX() of on the next run.

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
  DBT_RUN_TS: "!CAST('{{ var('to_date', run_started_at.strftime('%Y-%m-%d %H:%M:%S')) }}' AS TIMESTAMP_NTZ)"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
