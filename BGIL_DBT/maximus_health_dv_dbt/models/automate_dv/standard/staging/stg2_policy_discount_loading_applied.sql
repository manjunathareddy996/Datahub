-- automate_dv.stage() for SAT_POLICY_DISCOUNT_LOADING_APPLIED, read off central view stitch_v17_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v17_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AMOUNT_APPLIED'
      - 'BASIS'
      - 'EXTRA_DISCOUNT_OPTED_INDICATOR'
      - 'ITEM_CODE'
      - 'ITEM_TYPE'
      - 'JUSTIFICATION'
      - 'PERCENTAGE_APPLIED'
      - 'ITEM_CODE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED, POLICY_DISCOUNT_LOADING_APPLIED__BASIS, POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_TYPE, POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION, POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED) is not null then 'HUB_POLICY|' || POLICY_BK end"
  ITEM_CODE_CK: 'POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK'
  AMOUNT_APPLIED: 'POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED'
  BASIS: 'POLICY_DISCOUNT_LOADING_APPLIED__BASIS'
  EXTRA_DISCOUNT_OPTED_INDICATOR: 'POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR'
  ITEM_CODE: 'POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE'
  ITEM_TYPE: 'POLICY_DISCOUNT_LOADING_APPLIED__ITEM_TYPE'
  JUSTIFICATION: 'POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION'
  PERCENTAGE_APPLIED: 'POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v17_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
