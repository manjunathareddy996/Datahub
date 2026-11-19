-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_CANCELLATION, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ELAPSED_PERIOD_PREMIUM_AMOUNT'
      - 'RETAINED_ADMINISTRATION_CHARGES'
      - 'UNEXPIRED_PERIOD_PREMIUM_AMOUNT'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_CANCELLATION__ELAPSED_PERIOD_PREMIUM_AMOUNT, AUG_POLICY_CANCELLATION__RETAINED_ADMINISTRATION_CHARGES, AUG_POLICY_CANCELLATION__UNEXPIRED_PERIOD_PREMIUM_AMOUNT) is not null then 'HUB_POLICY|' || POLICY_BK end"
  ELAPSED_PERIOD_PREMIUM_AMOUNT: 'AUG_POLICY_CANCELLATION__ELAPSED_PERIOD_PREMIUM_AMOUNT'
  RETAINED_ADMINISTRATION_CHARGES: 'AUG_POLICY_CANCELLATION__RETAINED_ADMINISTRATION_CHARGES'
  UNEXPIRED_PERIOD_PREMIUM_AMOUNT: 'AUG_POLICY_CANCELLATION__UNEXPIRED_PERIOD_PREMIUM_AMOUNT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
