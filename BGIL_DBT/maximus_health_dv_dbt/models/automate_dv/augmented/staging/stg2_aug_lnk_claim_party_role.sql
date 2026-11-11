-- automate_dv.stage() for SAT_AUG_LNK_CLAIM_PARTY_ROLE, read off central view stitch_v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v04_claim'
hashed_columns:
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FIXED_PAYMENT_AMOUNT'
      - 'PARTY_ROLE_TYPE_CK'
      - 'ROLE_SEQUENCE_CK'
derived_columns:
  CLAIM_PARTY_NK: "case when AUG_LNK_CLAIM_PARTY_ROLE__FIXED_PAYMENT_AMOUNT is not null then 'LNK_CLAIM_PARTY|' || CLAIM_BK || '|' || PARTY_BK end"
  PARTY_ROLE_TYPE_CK: 'AUG_LNK_CLAIM_PARTY_ROLE__PARTY_ROLE_TYPE_CK'
  ROLE_SEQUENCE_CK: 'AUG_LNK_CLAIM_PARTY_ROLE__ROLE_SEQUENCE_CK'
  FIXED_PAYMENT_AMOUNT: 'AUG_LNK_CLAIM_PARTY_ROLE__FIXED_PAYMENT_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
