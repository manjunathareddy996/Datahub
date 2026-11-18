-- automate_dv.stage() for SAT_POLICY_PORTABILITY_MIGRATION, read off central view stitch_motor__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREVIOUS_INSURER_NAME'
      - 'PREVIOUS_POLICY_NUMBER'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME, POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER) is not null then 'HUB_POLICY|' || POLICY_BK end"
  PREVIOUS_INSURER_NAME: 'POLICY_PORTABILITY_MIGRATION__PREVIOUS_INSURER_NAME'
  PREVIOUS_POLICY_NUMBER: 'POLICY_PORTABILITY_MIGRATION__PREVIOUS_POLICY_NUMBER'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
