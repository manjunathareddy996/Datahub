{{ config(materialized='view', tags=['lnk_extra']) }}
-- stage() for LNK_FINTXN_CLAIM: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_fintxn_claim.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_fintxn_claim'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  CLAIM_HKEY: 'CLAIM_NK'
  FINTXN_CLAIM_HKEY: 'FINTXN_CLAIM_NK'
derived_columns:
  FINTXN_CLAIM_NK: "'LNK_FINTXN_CLAIM|' || FINANCIAL_TRANSACTION_BK || '|' || CLAIM_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
