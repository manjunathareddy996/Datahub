-- automate_dv.stage() for SAT_LNK_CLAIM_PARTY_ROLE, read off central view stitch_v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v11_party'
hashed_columns:
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ATTRIBUTION_PERCENTAGE'
      - 'PARTY_ROLE_TYPE'
      - 'ROLE_CATEGORY'
      - 'ROLE_EFFECTIVE_DATE'
      - 'ROLE_END_DATE'
      - 'PARTY_ROLE_TYPE_CK'
      - 'ROLE_SEQUENCE_CK'
derived_columns:
  CLAIM_PARTY_NK: "case when coalesce(LNK_CLAIM_PARTY_ROLE__ATTRIBUTION_PERCENTAGE, LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE, LNK_CLAIM_PARTY_ROLE__ROLE_CATEGORY, LNK_CLAIM_PARTY_ROLE__ROLE_EFFECTIVE_DATE, LNK_CLAIM_PARTY_ROLE__ROLE_END_DATE) is not null then 'LNK_CLAIM_PARTY|' || CLAIM_BK || '|' || PARTY_BK end"
  PARTY_ROLE_TYPE_CK: 'LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK'
  ROLE_SEQUENCE_CK: 'LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK'
  ATTRIBUTION_PERCENTAGE: 'LNK_CLAIM_PARTY_ROLE__ATTRIBUTION_PERCENTAGE'
  PARTY_ROLE_TYPE: 'LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE'
  ROLE_CATEGORY: 'LNK_CLAIM_PARTY_ROLE__ROLE_CATEGORY'
  ROLE_EFFECTIVE_DATE: 'LNK_CLAIM_PARTY_ROLE__ROLE_EFFECTIVE_DATE'
  ROLE_END_DATE: 'LNK_CLAIM_PARTY_ROLE__ROLE_END_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
