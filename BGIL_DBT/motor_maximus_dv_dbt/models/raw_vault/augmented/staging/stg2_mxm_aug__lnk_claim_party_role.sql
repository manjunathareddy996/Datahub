-- automate_dv.stage() for SAT_MOTOR_AUG_LNK_CLAIM_PARTY_ROLE, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RELATIONSHIP_TO_INSURED'
      - 'PARTY_ROLE_TYPE_CK'
      - 'ROLE_SEQUENCE_CK'
derived_columns:
  CLAIM_PARTY_NK: "case when AUG_LNK_CLAIM_PARTY_ROLE__RELATIONSHIP_TO_INSURED is not null then 'LNK_CLAIM_PARTY|' || CLAIM_BK || '|' || PARTY_BK end"
  PARTY_ROLE_TYPE_CK: 'AUG_LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK'
  ROLE_SEQUENCE_CK: 'AUG_LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK'
  RELATIONSHIP_TO_INSURED: 'AUG_LNK_CLAIM_PARTY_ROLE__RELATIONSHIP_TO_INSURED'
  LOAD_DATETIME: 'CLAIM_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
