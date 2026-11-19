-- automate_dv.stage() for SAT_PARTY_INTERACTION_EVENT, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FOLLOW_UP_DATE'
      - 'INTERACTION_DATE'
      - 'INTERACTION_SEQUENCE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_INTERACTION_EVENT__FOLLOW_UP_DATE, PARTY_INTERACTION_EVENT__INTERACTION_DATE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  INTERACTION_SEQUENCE_CK: 'PARTY_INTERACTION_EVENT__INTERACTION_SEQUENCE_CK'
  FOLLOW_UP_DATE: 'PARTY_INTERACTION_EVENT__FOLLOW_UP_DATE'
  INTERACTION_DATE: 'PARTY_INTERACTION_EVENT__INTERACTION_DATE'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
