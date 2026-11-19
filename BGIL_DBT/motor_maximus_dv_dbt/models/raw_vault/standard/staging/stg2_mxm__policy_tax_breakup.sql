-- automate_dv.stage() for SAT_POLICY_TAX_BREAKUP, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CGST_AMOUNT'
      - 'CGST_RATE'
      - 'GST_RATE'
      - 'IGST_AMOUNT'
      - 'PLACE_OF_SUPPLY'
      - 'SGST_AMOUNT'
      - 'SUPPLIER_STATE_CODE'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_TAX_BREAKUP__CGST_AMOUNT, POLICY_TAX_BREAKUP__CGST_RATE, POLICY_TAX_BREAKUP__GST_RATE, POLICY_TAX_BREAKUP__IGST_AMOUNT, POLICY_TAX_BREAKUP__PLACE_OF_SUPPLY, POLICY_TAX_BREAKUP__SGST_AMOUNT, POLICY_TAX_BREAKUP__SUPPLIER_STATE_CODE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CGST_AMOUNT: 'POLICY_TAX_BREAKUP__CGST_AMOUNT'
  CGST_RATE: 'POLICY_TAX_BREAKUP__CGST_RATE'
  GST_RATE: 'POLICY_TAX_BREAKUP__GST_RATE'
  IGST_AMOUNT: 'POLICY_TAX_BREAKUP__IGST_AMOUNT'
  PLACE_OF_SUPPLY: 'POLICY_TAX_BREAKUP__PLACE_OF_SUPPLY'
  SGST_AMOUNT: 'POLICY_TAX_BREAKUP__SGST_AMOUNT'
  SUPPLIER_STATE_CODE: 'POLICY_TAX_BREAKUP__SUPPLIER_STATE_CODE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
