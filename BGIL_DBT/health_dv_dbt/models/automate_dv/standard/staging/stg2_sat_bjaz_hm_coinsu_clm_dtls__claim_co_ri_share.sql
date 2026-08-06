{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_CLAIM_CO_RI_SHARE, table 'BJAZ_HM_COINSU_CLM_DTLS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_coinsu_clm_dtls'
hashed_columns:
  CLAIM_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CO_INSURANCE_OUR_SHARE_AMOUNT'
derived_columns:
  PARENT_BK: 'claim_id'
  PARENT_NK: "'HUB_CLAIM|' || (claim_id)"
  CO_INSURANCE_OUR_SHARE_AMOUNT: 'amount'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_COINSU_CLM_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
