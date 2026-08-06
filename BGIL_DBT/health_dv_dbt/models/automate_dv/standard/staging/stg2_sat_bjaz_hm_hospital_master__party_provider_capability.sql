{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_PROVIDER_CAPABILITY, table 'BJAZ_HM_HOSPITAL_MASTER' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hospital_master'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AVAILABLE_INDICATOR'
      - 'FACILITY_CATEGORY'
      - 'FACILITY_NAME'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  FACILITY_CODE_CK: '!'
  AVAILABLE_INDICATOR: 'diagno_yn'
  FACILITY_CATEGORY: 'hosp_spec_type'
  FACILITY_NAME: 'hosp_speciality'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSPITAL_MASTER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
