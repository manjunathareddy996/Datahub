-- automate_dv.stage() for SAT_FINTXN_TAX, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SERVICE_TAX_AMOUNT'
      - 'TAX_TYPE'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when FINTXN_TAX__SERVICE_TAX_AMOUNT is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  TAX_TYPE: 'FINTXN_TAX__TAX_TYPE_CK'
  SERVICE_TAX_AMOUNT: 'FINTXN_TAX__SERVICE_TAX_AMOUNT'
  LOAD_DATETIME: 'FINTXN_TAX__LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
