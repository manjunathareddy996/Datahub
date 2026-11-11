-- automate_dv.stage() for SAT_FINTXN_COMMISSION, read off central view stitch_v31_product.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v31_product'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMMISSION_RATE'
      - 'COMMISSION_TYPE_CK'
      - 'INTERMEDIARY_REFERENCE_CK'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when FINTXN_COMMISSION__COMMISSION_RATE is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  COMMISSION_TYPE_CK: 'FINTXN_COMMISSION__COMMISSION_TYPE_CK'
  INTERMEDIARY_REFERENCE_CK: 'FINTXN_COMMISSION__INTERMEDIARY_REFERENCE_CK'
  COMMISSION_RATE: 'FINTXN_COMMISSION__COMMISSION_RATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v31_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
