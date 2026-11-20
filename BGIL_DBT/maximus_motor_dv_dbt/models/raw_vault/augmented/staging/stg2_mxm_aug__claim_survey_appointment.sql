-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_SURVEY_APPOINTMENT, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INSPECTION_ADDRESS_TEXT'
      - 'LIVE_VIDEO_SURVEY_INDICATOR'
      - 'SURVEY_CARRIED_OUT_INDICATOR'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_SURVEY_APPOINTMENT__INSPECTION_ADDRESS_TEXT, AUG_CLAIM_SURVEY_APPOINTMENT__LIVE_VIDEO_SURVEY_INDICATOR, AUG_CLAIM_SURVEY_APPOINTMENT__SURVEY_CARRIED_OUT_INDICATOR) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  INSPECTION_ADDRESS_TEXT: 'AUG_CLAIM_SURVEY_APPOINTMENT__INSPECTION_ADDRESS_TEXT'
  LIVE_VIDEO_SURVEY_INDICATOR: 'AUG_CLAIM_SURVEY_APPOINTMENT__LIVE_VIDEO_SURVEY_INDICATOR'
  SURVEY_CARRIED_OUT_INDICATOR: 'AUG_CLAIM_SURVEY_APPOINTMENT__SURVEY_CARRIED_OUT_INDICATOR'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v04_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
