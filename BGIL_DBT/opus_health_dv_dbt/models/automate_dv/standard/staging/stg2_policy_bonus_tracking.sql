-- automate_dv.stage() for SAT_POLICY_BONUS_TRACKING, read off central view stitch_v14_org_unit.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v14_org_unit'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BONUS_AMOUNT'
      - 'CUMULATIVE_BONUS_PERCENTAGE'
      - 'NCB_PERCENTAGE'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_BONUS_TRACKING__BONUS_AMOUNT, POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE, POLICY_BONUS_TRACKING__NCB_PERCENTAGE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  BONUS_AMOUNT: 'POLICY_BONUS_TRACKING__BONUS_AMOUNT'
  CUMULATIVE_BONUS_PERCENTAGE: 'POLICY_BONUS_TRACKING__CUMULATIVE_BONUS_PERCENTAGE'
  NCB_PERCENTAGE: 'POLICY_BONUS_TRACKING__NCB_PERCENTAGE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v14_org_unit'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
