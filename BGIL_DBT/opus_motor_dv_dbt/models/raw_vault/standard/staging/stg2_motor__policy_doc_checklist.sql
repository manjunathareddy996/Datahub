-- automate_dv.stage() for SAT_POLICY_DOC_CHECKLIST, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'VERIFICATION_STATUS'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when POLICY_DOC_CHECKLIST__VERIFICATION_STATUS is not null then 'HUB_POLICY|' || POLICY_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK'
  VERIFICATION_STATUS: 'POLICY_DOC_CHECKLIST__VERIFICATION_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
