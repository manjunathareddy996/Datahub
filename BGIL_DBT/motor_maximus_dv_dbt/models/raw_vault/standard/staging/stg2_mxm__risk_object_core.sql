-- automate_dv.stage() for SAT_RISK_OBJECT_CORE, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ACQUISITION_DATE'
      - 'EXPOSURE_UNIT'
      - 'NEW_OR_USED_INDICATOR'
      - 'OWNERSHIP_TYPE'
      - 'RISK_CLASS_CODE'
      - 'RISK_OBJECT_DESCRIPTION'
      - 'RISK_OBJECT_REFERENCE_NUMBER'
      - 'RISK_OBJECT_TYPE'
      - 'USAGE_TYPE'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_OBJECT_CORE__ACQUISITION_DATE, RISK_OBJECT_CORE__EXPOSURE_UNIT, RISK_OBJECT_CORE__NEW_OR_USED_INDICATOR, RISK_OBJECT_CORE__OWNERSHIP_TYPE, RISK_OBJECT_CORE__RISK_CLASS_CODE, RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION, RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER, RISK_OBJECT_CORE__RISK_OBJECT_TYPE, RISK_OBJECT_CORE__USAGE_TYPE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  ACQUISITION_DATE: 'RISK_OBJECT_CORE__ACQUISITION_DATE'
  EXPOSURE_UNIT: 'RISK_OBJECT_CORE__EXPOSURE_UNIT'
  NEW_OR_USED_INDICATOR: 'RISK_OBJECT_CORE__NEW_OR_USED_INDICATOR'
  OWNERSHIP_TYPE: 'RISK_OBJECT_CORE__OWNERSHIP_TYPE'
  RISK_CLASS_CODE: 'RISK_OBJECT_CORE__RISK_CLASS_CODE'
  RISK_OBJECT_DESCRIPTION: 'RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION'
  RISK_OBJECT_REFERENCE_NUMBER: 'RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER'
  RISK_OBJECT_TYPE: 'RISK_OBJECT_CORE__RISK_OBJECT_TYPE'
  USAGE_TYPE: 'RISK_OBJECT_CORE__USAGE_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v14_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
