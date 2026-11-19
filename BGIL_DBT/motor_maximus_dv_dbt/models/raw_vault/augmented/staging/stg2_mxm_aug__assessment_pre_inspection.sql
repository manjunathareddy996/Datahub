-- automate_dv.stage() for SAT_MOTOR_AUG_ASSESSMENT_PRE_INSPECTION, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'IMPOSED_EXCESS_AMOUNT'
      - 'IMPOSED_EXCESS_INDICATOR'
      - 'INSPECTION_DELAY_DAYS'
      - 'OWN_DAMAGE_INSPECTION_LOCATION_ADDRESS'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_AMOUNT, AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_INDICATOR, AUG_ASSESSMENT_PRE_INSPECTION__INSPECTION_DELAY_DAYS, AUG_ASSESSMENT_PRE_INSPECTION__OWN_DAMAGE_INSPECTION_LOCATION_ADDRESS) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  IMPOSED_EXCESS_AMOUNT: 'AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_AMOUNT'
  IMPOSED_EXCESS_INDICATOR: 'AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_INDICATOR'
  INSPECTION_DELAY_DAYS: 'AUG_ASSESSMENT_PRE_INSPECTION__INSPECTION_DELAY_DAYS'
  OWN_DAMAGE_INSPECTION_LOCATION_ADDRESS: 'AUG_ASSESSMENT_PRE_INSPECTION__OWN_DAMAGE_INSPECTION_LOCATION_ADDRESS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v01_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
