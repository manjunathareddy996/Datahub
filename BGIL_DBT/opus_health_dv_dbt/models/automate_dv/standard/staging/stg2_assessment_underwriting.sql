-- automate_dv.stage() for SAT_ASSESSMENT_UNDERWRITING, read off central view stitch_v22_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v22_policy'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RISK_ACCEPTANCE_AUTHORITY'
      - 'SPECIAL_CONDITIONS_RECOMMENDED'
      - 'UNDERWRITING_REMARKS'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY, ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED, ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  RISK_ACCEPTANCE_AUTHORITY: 'ASSESSMENT_UNDERWRITING__RISK_ACCEPTANCE_AUTHORITY'
  SPECIAL_CONDITIONS_RECOMMENDED: 'ASSESSMENT_UNDERWRITING__SPECIAL_CONDITIONS_RECOMMENDED'
  UNDERWRITING_REMARKS: 'ASSESSMENT_UNDERWRITING__UNDERWRITING_REMARKS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v22_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
