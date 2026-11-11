-- automate_dv.stage() for SAT_ASSESSMENT_FRAUD_INVESTIGATION, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FINDINGS_SUMMARY'
      - 'MISREPRESENTATION_INDICATOR'
      - 'TRIGGER_REASON'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(ASSESSMENT_FRAUD_INVESTIGATION__FINDINGS_SUMMARY, ASSESSMENT_FRAUD_INVESTIGATION__MISREPRESENTATION_INDICATOR, ASSESSMENT_FRAUD_INVESTIGATION__TRIGGER_REASON) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  FINDINGS_SUMMARY: 'ASSESSMENT_FRAUD_INVESTIGATION__FINDINGS_SUMMARY'
  MISREPRESENTATION_INDICATOR: 'ASSESSMENT_FRAUD_INVESTIGATION__MISREPRESENTATION_INDICATOR'
  TRIGGER_REASON: 'ASSESSMENT_FRAUD_INVESTIGATION__TRIGGER_REASON'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
