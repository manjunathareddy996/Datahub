-- automate_dv.stage() for SAT_RISK_MOTOR_FITMENTS, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FITMENT_DESCRIPTION'
      - 'FITMENT_TYPE_CK'
      - 'SEQUENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  FITMENT_TYPE_CK: 'RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK'
  SEQUENCE_CK: 'RISK_MOTOR_FITMENTS__SEQUENCE_CK'
  FITMENT_DESCRIPTION: 'RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v01_assessment'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
