{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='HASHDIFF'
    )
}}

-- PARTNER STANDARD-MODEL sat() for SAT_COMMON_CLASSIFICATION (HUB_PARTY grain) -- stitch-backed, 5 table(s).
-- Source: stg2_common_classification.

{%- set yaml_metadata -%}
source_model: 'stg2_common_classification'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'PRIORITYCODE'
  - 'SEGMENTCODE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_extra_columns:
  - 'DBT_RUN_TS'
  - 'INC_JOB_UPDATED_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_extra_columns=metadata_dict['src_extra_columns'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
