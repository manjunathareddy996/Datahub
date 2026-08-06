{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_COVERAGE_SCHEDULE, table 'BJAZ_GRP_HLT_MATERNITY_DTLS' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_maternity_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CO_PAYMENT_AMOUNT'
      - 'CO_PAYMENT_PERCENTAGE'
      - 'COVERAGE_OPTED_INDICATOR'
      - 'SUB_LIMIT_AMOUNT'
derived_columns:
  PARENT_BK: 'reg_no'
  PARENT_NK: "'HUB_POLICY|' || (reg_no)"
  COVERAGE_REFERENCE_CK: '!'
  COVERAGE_SEQUENCE_CK: '!'
  CO_PAYMENT_AMOUNT: 'maternity_copayment_amt'
  CO_PAYMENT_PERCENTAGE: 'maternity_copayment_per'
  COVERAGE_OPTED_INDICATOR: 'out_patient_treatment'
  SUB_LIMIT_AMOUNT: 'maternity_benefit'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_MATERNITY_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
