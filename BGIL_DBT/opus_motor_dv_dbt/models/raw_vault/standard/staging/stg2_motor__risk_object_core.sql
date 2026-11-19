-- automate_dv.stage() for SAT_RISK_OBJECT_CORE, read off central view stitch_motor__v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v16_policy'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACQUISITION_DATE'
      - 'RISK_OBJECT_DESCRIPTION'
      - 'RISK_OBJECT_NAME'
      - 'RISK_OBJECT_REFERENCE_NUMBER'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_OBJECT_CORE__ACQUISITION_DATE, RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION, RISK_OBJECT_CORE__RISK_OBJECT_NAME, RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  ACQUISITION_DATE: 'RISK_OBJECT_CORE__ACQUISITION_DATE'
  RISK_OBJECT_DESCRIPTION: 'RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION'
  RISK_OBJECT_NAME: 'RISK_OBJECT_CORE__RISK_OBJECT_NAME'
  RISK_OBJECT_REFERENCE_NUMBER: 'RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V16_POLICY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
