-- automate_dv.stage() for SAT_POLICY_TAX_BREAKUP, read off central view stitch_v27_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v27_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CESS_AMOUNT'
      - 'CGST_AMOUNT'
      - 'IGST_AMOUNT'
      - 'SGST_AMOUNT'
      - 'STAMP_DUTY_AMOUNT'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_TAX_BREAKUP__CESS_AMOUNT, POLICY_TAX_BREAKUP__CGST_AMOUNT, POLICY_TAX_BREAKUP__IGST_AMOUNT, POLICY_TAX_BREAKUP__SGST_AMOUNT, POLICY_TAX_BREAKUP__STAMP_DUTY_AMOUNT) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CESS_AMOUNT: 'POLICY_TAX_BREAKUP__CESS_AMOUNT'
  CGST_AMOUNT: 'POLICY_TAX_BREAKUP__CGST_AMOUNT'
  IGST_AMOUNT: 'POLICY_TAX_BREAKUP__IGST_AMOUNT'
  SGST_AMOUNT: 'POLICY_TAX_BREAKUP__SGST_AMOUNT'
  STAMP_DUTY_AMOUNT: 'POLICY_TAX_BREAKUP__STAMP_DUTY_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v27_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
