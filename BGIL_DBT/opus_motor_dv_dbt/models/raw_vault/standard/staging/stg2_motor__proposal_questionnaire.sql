-- automate_dv.stage() for SAT_PROPOSAL_QUESTIONNAIRE, read off central view stitch_motor__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RESPONSE_VALUE'
      - 'QUESTION_CODE_CK'
derived_columns:
  PROPOSAL_NK: "case when PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  QUESTION_CODE_CK: 'PROPOSAL_QUESTIONNAIRE__QUESTION_CODE_CK'
  RESPONSE_VALUE: 'PROPOSAL_QUESTIONNAIRE__RESPONSE_VALUE'
  LOAD_DATETIME: 'PROPOSAL_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_MOTOR_V10_PARTY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
