-- automate_dv.stage() for SAT_LNK_PARTY_ROLE_CORE, read off central view stitch_motor__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v03_claim'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ROLE_START_DATE'
      - 'ROLE_CODE_CK'
      - 'ROLE_SEQUENCE'
derived_columns:
  PARTY_NK: "case when LNK_PARTY_ROLE_CORE__ROLE_START_DATE is not null then 'HUB_PARTY|' || PARTY_BK end"
  ROLE_CODE_CK: 'LNK_PARTY_ROLE_CORE__ROLE_CODE_CK'
  ROLE_SEQUENCE: 'LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK'
  ROLE_START_DATE: 'LNK_PARTY_ROLE_CORE__ROLE_START_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
