-- automate_dv.stage() for SAT_AUG_POLICY_DISCOUNT_LOADING_APPLIED, read off central view stitch_v27_policy.
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
      - 'ITEM_APPLIED_INDICATOR'
derived_columns:
  POLICY_NK: "case when AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR is not null then 'HUB_POLICY|' || POLICY_BK end"
  ITEM_APPLIED_INDICATOR: 'AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v27_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
