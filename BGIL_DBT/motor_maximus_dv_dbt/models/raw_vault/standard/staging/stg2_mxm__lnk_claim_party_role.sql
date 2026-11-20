-- automate_dv.stage() for SAT_LNK_CLAIM_PARTY_ROLE, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PARTY_ROLE_TYPE'
      - 'ROLE_CATEGORY'
      - 'PARTY_ROLE_TYPE_CK'
      - 'ROLE_SEQUENCE_CK'
derived_columns:
  CLAIM_PARTY_NK: "case when coalesce(LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE, LNK_CLAIM_PARTY_ROLE__ROLE_CATEGORY) is not null then 'LNK_CLAIM_PARTY|' || CLAIM_BK || '|' || PARTY_BK end"
  PARTY_ROLE_TYPE_CK: 'LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK'
  ROLE_SEQUENCE_CK: 'LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK'
  PARTY_ROLE_TYPE: 'LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE'
  ROLE_CATEGORY: 'LNK_CLAIM_PARTY_ROLE__ROLE_CATEGORY'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v03_claim'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
