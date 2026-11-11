-- automate_dv.stage() for SAT_POLICY_EXCESS_STRUCTURE, read off central view stitch_v28_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v28_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EXCESS_AMOUNT'
      - 'EXCESS_PERCENTAGE'
      - 'EXCESS_CODE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT, POLICY_EXCESS_STRUCTURE__EXCESS_PERCENTAGE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  EXCESS_CODE_CK: 'POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK'
  EXCESS_AMOUNT: 'POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT'
  EXCESS_PERCENTAGE: 'POLICY_EXCESS_STRUCTURE__EXCESS_PERCENTAGE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v28_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
