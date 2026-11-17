-- automate_dv.stage() for SAT_RISK_TRAILER, read off central view stitch_motor__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ATTACHED_INDICATOR'
      - 'TRAILER_IDV'
      - 'TRAILER_REGISTRATION_NUMBER'
      - 'TRAILER_SEQUENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_TRAILER__ATTACHED_INDICATOR, RISK_TRAILER__TRAILER_IDV, RISK_TRAILER__TRAILER_REGISTRATION_NUMBER) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  TRAILER_SEQUENCE_CK: 'RISK_TRAILER__TRAILER_SEQUENCE_CK'
  ATTACHED_INDICATOR: 'RISK_TRAILER__ATTACHED_INDICATOR'
  TRAILER_IDV: 'RISK_TRAILER__TRAILER_IDV'
  TRAILER_REGISTRATION_NUMBER: 'RISK_TRAILER__TRAILER_REGISTRATION_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
