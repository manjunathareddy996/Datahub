{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_RISK_HEALTH_MEMBER_COVERAGE, table 'BJAZ_EC_MEM_DTLS_EXTN' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_ec_mem_dtls_extn'
hashed_columns:
  RISK_OBJECT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MEMBER_SUM_INSURED'
      - 'PRE_POLICY_CHECKUP_INDICATOR'
derived_columns:
  PARENT_BK: "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')"
  PARENT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))"
  MEMBER_REFERENCE_CK: '!'
  MEMBER_SUM_INSURED: 'sum_insured'
  PRE_POLICY_CHECKUP_INDICATOR: 'medical_checkup'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_EC_MEM_DTLS_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
