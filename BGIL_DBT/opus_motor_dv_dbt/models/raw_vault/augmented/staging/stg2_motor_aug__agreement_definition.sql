-- automate_dv.stage() for SAT_MOTOR_AUG_AGREEMENT_DEFINITION, read off central view stitch_motor__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v12_policy'
hashed_columns:
  AGREEMENT_HKEY: 'AGREEMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGREEMENT_LINE_SEQUENCE_NUMBER'
derived_columns:
  AGREEMENT_NK: "case when AUG_AGREEMENT_DEFINITION__AGREEMENT_LINE_SEQUENCE_NUMBER is not null then 'HUB_AGREEMENT|' || AGREEMENT_BK end"
  AGREEMENT_LINE_SEQUENCE_NUMBER: 'AUG_AGREEMENT_DEFINITION__AGREEMENT_LINE_SEQUENCE_NUMBER'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
