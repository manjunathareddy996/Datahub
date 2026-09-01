{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_FINTXN_PREMIUM, table 'BA_TRV_DATA_POLICY_DTLS_MV'.
-- data_7 sync (MAPPER_NOTE_TRAVEL_DATA7_SYNC.md): DISCOUNT_PER folded augmentation ->
-- mapped, data_7 canonicalised it as Discount Percentage. Moved here from
-- SAT_AUG_FINTXN_PREMIUM (was stg2_aug_fintxn_premium_ba_trv_data_policy_dtls_mv_
-- discount_per.sql) -- same table, same row, folds cleanly into this existing branch
-- rather than adding a redundant one. The two special-discount columns (SP_DISCOUNT_PER/
-- AMT) stay augmented -- data_7 gave a home to standard discount, not special discount.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISCOUNT_AMOUNT'
      - 'DISCOUNT_PERCENTAGE'
      - 'GROSS_PREMIUM'
      - 'LOADING_AMOUNT'
      - 'NET_PREMIUM'
      - 'COLLECTION_MODE'
derived_columns:
  PARENT_BK: 'transaction_id'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (transaction_id)"
  DISCOUNT_AMOUNT: 'discount_amt'
  DISCOUNT_PERCENTAGE: 'discount_per'
  GROSS_PREMIUM: 'final_premium'
  LOADING_AMOUNT: 'loading_amt'
  NET_PREMIUM: 'net_premium'
  COLLECTION_MODE: 'payment_mode'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
