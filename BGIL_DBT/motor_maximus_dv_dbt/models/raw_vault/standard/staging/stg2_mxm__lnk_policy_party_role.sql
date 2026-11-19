-- automate_dv.stage() for SAT_LNK_POLICY_PARTY_ROLE, read off central view stitch_mxm__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v10_party'
hashed_columns:
  POLICY_PARTY_HKEY: 'POLICY_PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ATTRIBUTION_PERCENTAGE'
      - 'PARTY_ROLE_TYPE'
      - 'PARTY_ROLE_TYPE_CK'
      - 'ROLE_SEQUENCE_CK'
derived_columns:
  POLICY_PARTY_NK: "case when coalesce(LNK_POLICY_PARTY_ROLE__ATTRIBUTION_PERCENTAGE, LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE) is not null then 'LNK_POLICY_PARTY|' || PARTY_BK || '|' || POLICY_BK end"
  PARTY_ROLE_TYPE_CK: 'LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK'
  ROLE_SEQUENCE_CK: 'LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK'
  ATTRIBUTION_PERCENTAGE: 'LNK_POLICY_PARTY_ROLE__ATTRIBUTION_PERCENTAGE'
  PARTY_ROLE_TYPE: 'LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE'
  LOAD_DATETIME: 'PARTY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
