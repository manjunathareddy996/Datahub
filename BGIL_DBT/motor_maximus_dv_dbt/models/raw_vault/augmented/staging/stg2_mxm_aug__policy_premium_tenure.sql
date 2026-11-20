-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_PREMIUM_TENURE, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EARNED_PREMIUM_AMOUNT'
      - 'EARNED_PREMIUM_SUB_TOTAL_AMOUNT'
      - 'HEAD_PREMIUM_AMOUNT'
      - 'TENURE_YEAR_CK'
      - 'PREMIUM_HEAD_CODE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_AMOUNT, AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_SUB_TOTAL_AMOUNT, AUG_POLICY_PREMIUM_TENURE__HEAD_PREMIUM_AMOUNT) is not null then 'HUB_POLICY|' || POLICY_BK end"
  TENURE_YEAR_CK: 'AUG_POLICY_PREMIUM_TENURE__TENURE_YEAR_CK'
  PREMIUM_HEAD_CODE_CK: 'AUG_POLICY_PREMIUM_TENURE__PREMIUM_HEAD_CODE_CK'
  EARNED_PREMIUM_AMOUNT: 'AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_AMOUNT'
  EARNED_PREMIUM_SUB_TOTAL_AMOUNT: 'AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_SUB_TOTAL_AMOUNT'
  HEAD_PREMIUM_AMOUNT: 'AUG_POLICY_PREMIUM_TENURE__HEAD_PREMIUM_AMOUNT'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v01_assessment'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
