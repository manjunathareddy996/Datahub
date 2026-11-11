-- automate_dv.stage() for SAT_LNK_ROLE_TPA, read off central view stitch_v11_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v11_claim'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TPA_CODE'
      - 'ROLE_TYPE_CK'
derived_columns:
  PARTY_NK: "case when LNK_ROLE_TPA__TPA_CODE is not null then 'HUB_PARTY|' || PARTY_BK end"
  ROLE_TYPE_CK: 'LNK_ROLE_TPA__ROLE_TYPE_CK'
  TPA_CODE: 'LNK_ROLE_TPA__TPA_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v11_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
