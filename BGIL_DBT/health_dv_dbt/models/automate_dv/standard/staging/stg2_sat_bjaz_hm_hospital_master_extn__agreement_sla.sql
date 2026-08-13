{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_AGREEMENT_SLA, table 'BJAZ_HM_HOSPITAL_MASTER_EXTN' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hospital_master_extn'
hashed_columns:
  AGREEMENT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SERVICE_LEVEL_TARGET'
      - 'TAT_COMMITMENT'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_AGREEMENT|' || (hosid)"
  SERVICE_LEVEL_TARGET: 'bill_rec_time'
  TAT_COMMITMENT: 'claim_pymt_tat'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSPITAL_MASTER_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
