-- automate_dv.stage() for SAT_LNK_PARTY_ROLE_CORE, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ROLE_CODE'
      - 'ROLE_END_DATE'
      - 'ROLE_TYPE'
      - 'ROLE_CODE_CK'
      - 'ROLE_SEQUENCE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(LNK_PARTY_ROLE_CORE__ROLE_CODE, LNK_PARTY_ROLE_CORE__ROLE_END_DATE, LNK_PARTY_ROLE_CORE__ROLE_TYPE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ROLE_CODE_CK: 'LNK_PARTY_ROLE_CORE__ROLE_CODE_CK'
  ROLE_SEQUENCE_CK: 'LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK'
  ROLE_CODE: 'LNK_PARTY_ROLE_CORE__ROLE_CODE'
  ROLE_END_DATE: 'LNK_PARTY_ROLE_CORE__ROLE_END_DATE'
  ROLE_TYPE: 'LNK_PARTY_ROLE_CORE__ROLE_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
