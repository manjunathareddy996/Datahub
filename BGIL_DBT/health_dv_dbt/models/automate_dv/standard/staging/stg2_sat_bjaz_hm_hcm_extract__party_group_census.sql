{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_GROUP_CENSUS, table 'BJAZ_HM_HCM_EXTRACT' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hcm_extract'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DATE_OF_JOINING'
derived_columns:
  PARENT_BK: 'hospital_id'
  PARENT_NK: "'HUB_PARTY|' || (hospital_id)"
  MEMBER_REFERENCE_CK: '!'
  DATE_OF_JOINING: 'doj'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HCM_EXTRACT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
