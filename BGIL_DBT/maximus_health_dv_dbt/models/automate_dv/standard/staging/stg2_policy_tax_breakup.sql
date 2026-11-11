-- automate_dv.stage() for SAT_POLICY_TAX_BREAKUP, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CGST_AMOUNT'
      - 'GSTIN_OF_INSURER'
      - 'IGST_AMOUNT'
      - 'SGST_AMOUNT'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_TAX_BREAKUP__CGST_AMOUNT, POLICY_TAX_BREAKUP__GSTIN_OF_INSURER, POLICY_TAX_BREAKUP__IGST_AMOUNT, POLICY_TAX_BREAKUP__SGST_AMOUNT) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CGST_AMOUNT: 'POLICY_TAX_BREAKUP__CGST_AMOUNT'
  GSTIN_OF_INSURER: 'POLICY_TAX_BREAKUP__GSTIN_OF_INSURER'
  IGST_AMOUNT: 'POLICY_TAX_BREAKUP__IGST_AMOUNT'
  SGST_AMOUNT: 'POLICY_TAX_BREAKUP__SGST_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
