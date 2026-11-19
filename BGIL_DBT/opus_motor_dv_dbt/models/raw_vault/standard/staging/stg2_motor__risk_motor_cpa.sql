-- automate_dv.stage() for SAT_RISK_MOTOR_CPA, read off central view stitch_motor__v25_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v25_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMPULSORY_PA_EFFECTIVE_DATE'
      - 'COMPULSORY_PA_EXPIRY_DATE'
      - 'COMPULSORY_PA_OWNER_DRIVER_INDICATOR'
      - 'COMPULSORY_PA_PREMIUM'
      - 'COMPULSORY_PA_SUM_INSURED'
      - 'COMPULSORY_PA_WAIVER_INDICATOR'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_MOTOR_CPA__COMPULSORY_PA_EFFECTIVE_DATE, RISK_MOTOR_CPA__COMPULSORY_PA_EXPIRY_DATE, RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR, RISK_MOTOR_CPA__COMPULSORY_PA_PREMIUM, RISK_MOTOR_CPA__COMPULSORY_PA_SUM_INSURED, RISK_MOTOR_CPA__COMPULSORY_PA_WAIVER_INDICATOR) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  COMPULSORY_PA_EFFECTIVE_DATE: 'RISK_MOTOR_CPA__COMPULSORY_PA_EFFECTIVE_DATE'
  COMPULSORY_PA_EXPIRY_DATE: 'RISK_MOTOR_CPA__COMPULSORY_PA_EXPIRY_DATE'
  COMPULSORY_PA_OWNER_DRIVER_INDICATOR: 'RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR'
  COMPULSORY_PA_PREMIUM: 'RISK_MOTOR_CPA__COMPULSORY_PA_PREMIUM'
  COMPULSORY_PA_SUM_INSURED: 'RISK_MOTOR_CPA__COMPULSORY_PA_SUM_INSURED'
  COMPULSORY_PA_WAIVER_INDICATOR: 'RISK_MOTOR_CPA__COMPULSORY_PA_WAIVER_INDICATOR'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V25_RISK_OBJECT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
