{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_INSTALMENT_SCHEDULE, table 'BA_HCP_DT_PREMIUM' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_dt_premium'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DUE_DATE'
      - 'INSTALMENT_AMOUNT'
      - 'OUTSTANDING_AFTER_INSTALMENT'
      - 'PAID_AMOUNT'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  INSTALMENT_NUMBER_CK: '!'
  DUE_DATE: 'inst_date'
  INSTALMENT_AMOUNT: 'next_inst_amt'
  OUTSTANDING_AFTER_INSTALMENT: 'inst_total_pending_amt'
  PAID_AMOUNT: 'inst_paid_amt'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_DT_PREMIUM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
