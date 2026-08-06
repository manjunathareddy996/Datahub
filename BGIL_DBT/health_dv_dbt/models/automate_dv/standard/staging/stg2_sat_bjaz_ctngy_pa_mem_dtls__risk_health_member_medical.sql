{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_RISK_HEALTH_MEMBER_MEDICAL, table 'BJAZ_CTNGY_PA_MEM_DTLS' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_ctngy_pa_mem_dtls'
hashed_columns:
  RISK_OBJECT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CONDITION_NAME'
derived_columns:
  PARENT_BK: "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_ref_number)), '')"
  PARENT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_ref_number)), ''))"
  MEMBER_REFERENCE_CK: '!'
  CONDITION_NAME: 'pre_exist_disease'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CTNGY_PA_MEM_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
