{{ config(materialized='view', tags=['lnk_extra']) }}
-- stage() for LNK_FINTXN_INSTRUMENT: hub HKEYs (from each hub's own NK) and the link HKEY, over lnkbk_mt_fintxn_instrument.
-- Link NK = 'LNK_x|' || leg business keys, hubs in canonical-sheet order.
{%- set yaml_metadata -%}
source_model: 'lnkbk_mt_fintxn_instrument'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  PAYMENT_INSTRUMENT_HKEY: 'PAYMENT_INSTRUMENT_NK'
  FINTXN_INSTRUMENT_HKEY: 'FINTXN_INSTRUMENT_NK'
derived_columns:
  FINTXN_INSTRUMENT_NK: "'LNK_FINTXN_INSTRUMENT|' || FINANCIAL_TRANSACTION_BK || '|' || PAYMENT_INSTRUMENT_BK"
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
