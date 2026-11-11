-- automate_dv.stage() for SAT_AUG_POLICY_DISCOUNT_LOADING_APPLIED, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPLICABLE_TO_OTHER_MEMBERS_INDICATOR'
      - 'APPLICATION_LEVEL'
      - 'LOADING_WAIVER_INDICATOR'
      - 'ITEM_CODE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICABLE_TO_OTHER_MEMBERS_INDICATOR, AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICATION_LEVEL, AUG_POLICY_DISCOUNT_LOADING_APPLIED__LOADING_WAIVER_INDICATOR) is not null then 'HUB_POLICY|' || POLICY_BK end"
  ITEM_CODE_CK: 'AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK'
  APPLICABLE_TO_OTHER_MEMBERS_INDICATOR: 'AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICABLE_TO_OTHER_MEMBERS_INDICATOR'
  APPLICATION_LEVEL: 'AUG_POLICY_DISCOUNT_LOADING_APPLIED__APPLICATION_LEVEL'
  LOADING_WAIVER_INDICATOR: 'AUG_POLICY_DISCOUNT_LOADING_APPLIED__LOADING_WAIVER_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
