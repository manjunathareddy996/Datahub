-- automate_dv.stage() for SAT_MOTOR_AUG_QUOTE_UNDERWRITING_WORKFLOW, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDITIONAL_INFORMATION_TEXT'
      - 'DEFICIENCY_STATUS'
      - 'UNDERWRITER_ACCEPTANCE_DECISION'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_UNDERWRITING_WORKFLOW__ADDITIONAL_INFORMATION_TEXT, AUG_QUOTE_UNDERWRITING_WORKFLOW__DEFICIENCY_STATUS, AUG_QUOTE_UNDERWRITING_WORKFLOW__UNDERWRITER_ACCEPTANCE_DECISION) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  ADDITIONAL_INFORMATION_TEXT: 'AUG_QUOTE_UNDERWRITING_WORKFLOW__ADDITIONAL_INFORMATION_TEXT'
  DEFICIENCY_STATUS: 'AUG_QUOTE_UNDERWRITING_WORKFLOW__DEFICIENCY_STATUS'
  UNDERWRITER_ACCEPTANCE_DECISION: 'AUG_QUOTE_UNDERWRITING_WORKFLOW__UNDERWRITER_ACCEPTANCE_DECISION'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v14_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
