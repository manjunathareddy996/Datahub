-- automate_dv.stage() for SAT_PROPOSAL_QUESTIONNAIRE, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'QUESTION_CODE'
      - 'QUESTION_TEXT'
      - 'RESPONSE_VALUE'
      - 'QUESTION_CODE_CK'
derived_columns:
  PROPOSAL_NK: "case when coalesce(PROPOSAL_QUESTIONNAIRE__QUESTION_CODE, PROPOSAL_QUESTIONNAIRE__QUESTION_TEXT, PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE) is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  QUESTION_CODE_CK: 'PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK'
  QUESTION_CODE: 'PROPOSAL_QUESTIONNAIRE__QUESTION_CODE'
  QUESTION_TEXT: 'PROPOSAL_QUESTIONNAIRE__QUESTION_TEXT'
  RESPONSE_VALUE: 'PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
