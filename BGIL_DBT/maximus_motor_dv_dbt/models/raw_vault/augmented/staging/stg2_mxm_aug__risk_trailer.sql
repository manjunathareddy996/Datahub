-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_TRAILER, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TOWING_VEHICLE_REFERENCE'
      - 'TRAILER_DETAIL_TEXT'
      - 'TRAILER_TOTAL_VALUE'
      - 'TRAILER_SEQUENCE_CK'
      - 'TRAILER_REGISTRATION_NUMBER_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_TRAILER__TOWING_VEHICLE_REFERENCE, AUG_RISK_TRAILER__TRAILER_DETAIL_TEXT, AUG_RISK_TRAILER__TRAILER_TOTAL_VALUE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  TRAILER_SEQUENCE_CK: 'AUG_RISK_TRAILER__TRAILER_SEQUENCE_CK'
  TRAILER_REGISTRATION_NUMBER_CK: 'AUG_RISK_TRAILER__TRAILER_REGISTRATION_NUMBER_CK'
  TOWING_VEHICLE_REFERENCE: 'AUG_RISK_TRAILER__TOWING_VEHICLE_REFERENCE'
  TRAILER_DETAIL_TEXT: 'AUG_RISK_TRAILER__TRAILER_DETAIL_TEXT'
  TRAILER_TOTAL_VALUE: 'AUG_RISK_TRAILER__TRAILER_TOTAL_VALUE'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v14_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
