-- automate_dv.stage() for SAT_COMMON_MONETARY_CONTEXT, read off central view stitch_motor__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v03_claim'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CURRENCY_CODE'
      - 'EXCHANGE_RATE'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(COMMON_MONETARY_CONTEXT__CURRENCY_CODE, COMMON_MONETARY_CONTEXT__EXCHANGE_RATE) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  CURRENCY_CODE: 'COMMON_MONETARY_CONTEXT__CURRENCY_CODE'
  EXCHANGE_RATE: 'COMMON_MONETARY_CONTEXT__EXCHANGE_RATE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
