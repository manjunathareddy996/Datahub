-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_IDENTIFICATION, read off central view stitch_motor__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NAME_AS_PER_IDENTIFICATION_DOCUMENT'
      - 'IDENTIFICATION_TYPE_CODE_CK'
derived_columns:
  PARTY_NK: "case when AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT is not null then 'HUB_PARTY|' || PARTY_BK end"
  IDENTIFICATION_TYPE_CODE_CK: 'AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK'
  NAME_AS_PER_IDENTIFICATION_DOCUMENT: 'AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
