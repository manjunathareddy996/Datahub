-- automate_dv.stage() for SAT_AUG_PARTY_KYC, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CKYC_DETAILS_DESCRIPTION'
      - 'KYC_DETAIL_DESCRIPTION'
      - 'OPTIONAL_PROOF_OF_POSSESSION_TYPE'
      - 'PRIMARY_PROOF_OF_POSSESSION_TYPE'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_KYC__CKYC_DETAILS_DESCRIPTION, AUG_PARTY_KYC__KYC_DETAIL_DESCRIPTION, AUG_PARTY_KYC__OPTIONAL_PROOF_OF_POSSESSION_TYPE, AUG_PARTY_KYC__PRIMARY_PROOF_OF_POSSESSION_TYPE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CKYC_DETAILS_DESCRIPTION: 'AUG_PARTY_KYC__CKYC_DETAILS_DESCRIPTION'
  KYC_DETAIL_DESCRIPTION: 'AUG_PARTY_KYC__KYC_DETAIL_DESCRIPTION'
  OPTIONAL_PROOF_OF_POSSESSION_TYPE: 'AUG_PARTY_KYC__OPTIONAL_PROOF_OF_POSSESSION_TYPE'
  PRIMARY_PROOF_OF_POSSESSION_TYPE: 'AUG_PARTY_KYC__PRIMARY_PROOF_OF_POSSESSION_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
