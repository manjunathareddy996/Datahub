-- automate_dv.stage() for SAT_PARTY_ORG_DIRECTORS, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DIRECTOR_NAME'
      - 'DIN_NUMBER_CK'
derived_columns:
  PARTY_NK: "case when PARTY_ORG_DIRECTORS__DIRECTOR_NAME is not null then 'HUB_PARTY|' || PARTY_BK end"
  DIN_NUMBER_CK: 'PARTY_ORG_DIRECTORS__DIN_NUMBER_CK'
  DIRECTOR_NAME: 'PARTY_ORG_DIRECTORS__DIRECTOR_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
