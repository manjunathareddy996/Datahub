{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_RISK_HEALTH_MEMBER_COVERAGE, table 'BJAZ_HCF_MEMBER_DTLS' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hcf_member_dtls'
hashed_columns:
  RISK_OBJECT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CUMULATIVE_BONUS_AMOUNT'
      - 'CUMULATIVE_BONUS_PERCENTAGE'
      - 'LOADING_REASON'
      - 'MEMBER_SUM_INSURED'
derived_columns:
  PARENT_BK: "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')"
  PARENT_NK: "'HUB_RISK_OBJECT|' || (nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))"
  MEMBER_REFERENCE_CK: '!'
  CUMULATIVE_BONUS_AMOUNT: 'cumulative_amt'
  CUMULATIVE_BONUS_PERCENTAGE: 'cumulative_bnouz_per'
  LOADING_REASON: 'loading_reason'
  MEMBER_SUM_INSURED: 'sum_insured'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HCF_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
