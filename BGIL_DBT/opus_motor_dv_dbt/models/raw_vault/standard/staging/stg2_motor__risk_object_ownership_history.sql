-- automate_dv.stage() for SAT_RISK_OBJECT_OWNERSHIP_HISTORY, read off central view stitch_motor__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v09_party'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OWNER_SEQUENCE'
      - 'OWNER_SEQUENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  OWNER_SEQUENCE_CK: 'RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK'
  OWNER_SEQUENCE: 'RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v09_party'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
