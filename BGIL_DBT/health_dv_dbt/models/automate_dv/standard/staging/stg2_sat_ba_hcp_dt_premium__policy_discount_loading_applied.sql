{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_DISCOUNT_LOADING_APPLIED, table 'BA_HCP_DT_PREMIUM' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_dt_premium'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AMOUNT_APPLIED'
      - 'PERCENTAGE_APPLIED'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  ITEM_CODE_CK: '!'
  AMOUNT_APPLIED: 'family_disc_amt'
  PERCENTAGE_APPLIED: 'family_disc_rate'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_DT_PREMIUM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
