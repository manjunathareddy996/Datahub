-- automate_dv.stage() for SAT_FINTXN_CLAIM_PAYMENT, read off central view stitch_motor__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v03_claim'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PAYMENT_MODE'
      - 'RECOVERY_AMOUNT'
      - 'SALVAGE_REALISATION_AMOUNT'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_CLAIM_PAYMENT__PAYMENT_MODE, FINTXN_CLAIM_PAYMENT__RECOVERY_AMOUNT, FINTXN_CLAIM_PAYMENT__SALVAGE_REALISATION_AMOUNT) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  PAYMENT_MODE: 'FINTXN_CLAIM_PAYMENT__PAYMENT_MODE'
  RECOVERY_AMOUNT: 'FINTXN_CLAIM_PAYMENT__RECOVERY_AMOUNT'
  SALVAGE_REALISATION_AMOUNT: 'FINTXN_CLAIM_PAYMENT__SALVAGE_REALISATION_AMOUNT'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
