-- automate_dv.stage() for SAT_MOTOR_AUG_CLAIM_COVER_SECTION_ASSESSMENT, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADVERSE_MEDICAL_HISTORY_FINDING'
      - 'CASE_MANAGEMENT_INDICATOR'
      - 'NON_DISCLOSURE_FINDING'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_COVER_SECTION_ASSESSMENT__ADVERSE_MEDICAL_HISTORY_FINDING, AUG_CLAIM_COVER_SECTION_ASSESSMENT__CASE_MANAGEMENT_INDICATOR, AUG_CLAIM_COVER_SECTION_ASSESSMENT__NON_DISCLOSURE_FINDING) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  ADVERSE_MEDICAL_HISTORY_FINDING: 'AUG_CLAIM_COVER_SECTION_ASSESSMENT__ADVERSE_MEDICAL_HISTORY_FINDING'
  CASE_MANAGEMENT_INDICATOR: 'AUG_CLAIM_COVER_SECTION_ASSESSMENT__CASE_MANAGEMENT_INDICATOR'
  NON_DISCLOSURE_FINDING: 'AUG_CLAIM_COVER_SECTION_ASSESSMENT__NON_DISCLOSURE_FINDING'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v01_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
