-- automate_dv.stage() for SAT_LNK_PARTY_ROLE_CORE, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ROLE_CODE'
      - 'ROLE_START_DATE'
      - 'ROLE_CODE_CK'
      - 'ROLE_SEQUENCE_CK'
derived_columns:
  PARTY_NK: "case when coalesce(LNK_PARTY_ROLE_CORE__ROLE_CODE, LNK_PARTY_ROLE_CORE__ROLE_START_DATE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ROLE_CODE_CK: 'LNK_PARTY_ROLE_CORE__ROLE_CODE_CK'
  ROLE_SEQUENCE_CK: 'LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK'
  ROLE_CODE: 'LNK_PARTY_ROLE_CORE__ROLE_CODE'
  ROLE_START_DATE: 'LNK_PARTY_ROLE_CORE__ROLE_START_DATE'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v12_policy'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
