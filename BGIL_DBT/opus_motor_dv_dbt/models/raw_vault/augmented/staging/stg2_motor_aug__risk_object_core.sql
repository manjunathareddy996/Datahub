-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_OBJECT_CORE, read off central view stitch_motor__v26_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v26_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ISSUANCE_BLOCK_FROM_DATE'
      - 'ISSUANCE_BLOCK_STATUS'
      - 'ISSUANCE_BLOCK_TO_DATE'
      - 'MULTI_VEHICLE_REQUEST_REFERENCE'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_FROM_DATE, AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_STATUS, AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_TO_DATE, AUG_RISK_OBJECT_CORE__MULTI_VEHICLE_REQUEST_REFERENCE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  ISSUANCE_BLOCK_FROM_DATE: 'AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_FROM_DATE'
  ISSUANCE_BLOCK_STATUS: 'AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_STATUS'
  ISSUANCE_BLOCK_TO_DATE: 'AUG_RISK_OBJECT_CORE__ISSUANCE_BLOCK_TO_DATE'
  MULTI_VEHICLE_REQUEST_REFERENCE: 'AUG_RISK_OBJECT_CORE__MULTI_VEHICLE_REQUEST_REFERENCE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v26_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
