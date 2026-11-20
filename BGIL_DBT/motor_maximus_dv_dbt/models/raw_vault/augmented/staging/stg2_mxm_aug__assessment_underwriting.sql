-- automate_dv.stage() for SAT_MOTOR_AUG_ASSESSMENT_UNDERWRITING, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REFERRAL_LIMIT_AMOUNT'
derived_columns:
  ASSESSMENT_NK: "case when AUG_ASSESSMENT_UNDERWRITING__REFERRAL_LIMIT_AMOUNT is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  REFERRAL_LIMIT_AMOUNT: 'AUG_ASSESSMENT_UNDERWRITING__REFERRAL_LIMIT_AMOUNT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v12_policy'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
