{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_LNK_PARTY_ROLE_CORE, table 'BA_HCP_PROD_8439_CLH_LOADER' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8439_clh_loader'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ROLE_CATEGORY'
      - 'ROLE_TYPE'
derived_columns:
  PARENT_BK: 'pd_premium_payer_id'
  PARENT_NK: "'HUB_PARTY|' || (pd_premium_payer_id)"
  ROLE_CODE_CK: '!'
  ROLE_SEQUENCE_CK: '!'
  ROLE_CATEGORY: 'plc_borrower_type'
  ROLE_TYPE: 'md_is_proposer_yes_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8439_CLH_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
