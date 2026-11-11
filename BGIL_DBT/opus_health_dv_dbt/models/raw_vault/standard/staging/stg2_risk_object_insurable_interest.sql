-- automate_dv.stage() for SAT_RISK_OBJECT_INSURABLE_INTEREST, read off central view stitch_v31_product.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v31_product'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FINANCIER_NAME'
      - 'LOAN_AMOUNT'
      - 'LOAN_TYPE'
      - 'INTEREST_TYPE_CK'
      - 'INTEREST_HOLDER_REFERENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME, RISK_OBJECT_INSURABLE_INTEREST__LOAN_AMOUNT, RISK_OBJECT_INSURABLE_INTEREST__LOAN_TYPE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  INTEREST_TYPE_CK: 'RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK'
  INTEREST_HOLDER_REFERENCE_CK: 'RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK'
  FINANCIER_NAME: 'RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME'
  LOAN_AMOUNT: 'RISK_OBJECT_INSURABLE_INTEREST__LOAN_AMOUNT'
  LOAN_TYPE: 'RISK_OBJECT_INSURABLE_INTEREST__LOAN_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v31_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
