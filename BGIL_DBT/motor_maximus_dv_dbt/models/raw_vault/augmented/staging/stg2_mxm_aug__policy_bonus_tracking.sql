-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_BONUS_TRACKING, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NCB_STATUS'
      - 'PREVIOUS_BONUS_AMOUNT'
      - 'PREVIOUS_NCB_PERCENTAGE'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_BONUS_TRACKING__NCB_STATUS, AUG_POLICY_BONUS_TRACKING__PREVIOUS_BONUS_AMOUNT, AUG_POLICY_BONUS_TRACKING__PREVIOUS_NCB_PERCENTAGE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  NCB_STATUS: 'AUG_POLICY_BONUS_TRACKING__NCB_STATUS'
  PREVIOUS_BONUS_AMOUNT: 'AUG_POLICY_BONUS_TRACKING__PREVIOUS_BONUS_AMOUNT'
  PREVIOUS_NCB_PERCENTAGE: 'AUG_POLICY_BONUS_TRACKING__PREVIOUS_NCB_PERCENTAGE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
