-- automate_dv.stage() for SAT_ASSESSMENT_PRE_INSPECTION, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EXISTING_DAMAGE_DESCRIPTION'
      - 'INSPECTION_DATE'
      - 'INSPECTION_LOCATION_ADDRESS'
      - 'INSPECTOR_REFERENCE'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(ASSESSMENT_PRE_INSPECTION__EXISTING_DAMAGE_DESCRIPTION, ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE, ASSESSMENT_PRE_INSPECTION__INSPECTION_LOCATION_ADDRESS, ASSESSMENT_PRE_INSPECTION__INSPECTOR_REFERENCE) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  EXISTING_DAMAGE_DESCRIPTION: 'ASSESSMENT_PRE_INSPECTION__EXISTING_DAMAGE_DESCRIPTION'
  INSPECTION_DATE: 'ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE'
  INSPECTION_LOCATION_ADDRESS: 'ASSESSMENT_PRE_INSPECTION__INSPECTION_LOCATION_ADDRESS'
  INSPECTOR_REFERENCE: 'ASSESSMENT_PRE_INSPECTION__INSPECTOR_REFERENCE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v14_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
