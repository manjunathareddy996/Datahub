-- automate_dv.stage() for SAT_FINTXN_PREMIUM, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COLLECTION_MODE'
      - 'COLLECTION_STATUS'
      - 'DISCOUNT_AMOUNT'
      - 'GROSS_PREMIUM'
      - 'LOADING_AMOUNT'
      - 'NET_PREMIUM'
      - 'STAMP_DUTY_AMOUNT'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_PREMIUM__COLLECTION_MODE, FINTXN_PREMIUM__COLLECTION_STATUS, FINTXN_PREMIUM__DISCOUNT_AMOUNT, FINTXN_PREMIUM__GROSS_PREMIUM, FINTXN_PREMIUM__LOADING_AMOUNT, FINTXN_PREMIUM__NET_PREMIUM, FINTXN_PREMIUM__STAMP_DUTY_AMOUNT) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  COLLECTION_MODE: 'FINTXN_PREMIUM__COLLECTION_MODE'
  COLLECTION_STATUS: 'FINTXN_PREMIUM__COLLECTION_STATUS'
  DISCOUNT_AMOUNT: 'FINTXN_PREMIUM__DISCOUNT_AMOUNT'
  GROSS_PREMIUM: 'FINTXN_PREMIUM__GROSS_PREMIUM'
  LOADING_AMOUNT: 'FINTXN_PREMIUM__LOADING_AMOUNT'
  NET_PREMIUM: 'FINTXN_PREMIUM__NET_PREMIUM'
  STAMP_DUTY_AMOUNT: 'FINTXN_PREMIUM__STAMP_DUTY_AMOUNT'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v11_party'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
