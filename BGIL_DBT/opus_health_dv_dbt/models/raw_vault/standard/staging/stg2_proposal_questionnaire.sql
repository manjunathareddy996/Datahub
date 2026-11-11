-- automate_dv.stage() for SAT_PROPOSAL_QUESTIONNAIRE, read off central view stitch_v32_product.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v32_product'
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
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v32_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
