-- automate_dv.stage() for SAT_AUG_PARTY_BANKING, read off central view stitch_v11_claim.
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
      - 'BRANCH_ADDRESS'
      - 'BRANCH_CONTACT_MANDATE_INDICATOR'
      - 'BRANCH_CONTACT_NUMBER'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_BANKING__BRANCH_ADDRESS, AUG_PARTY_BANKING__BRANCH_CONTACT_MANDATE_INDICATOR, AUG_PARTY_BANKING__BRANCH_CONTACT_NUMBER) is not null then 'HUB_PARTY|' || PARTY_BK end"
  BRANCH_ADDRESS: 'AUG_PARTY_BANKING__BRANCH_ADDRESS'
  BRANCH_CONTACT_MANDATE_INDICATOR: 'AUG_PARTY_BANKING__BRANCH_CONTACT_MANDATE_INDICATOR'
  BRANCH_CONTACT_NUMBER: 'AUG_PARTY_BANKING__BRANCH_CONTACT_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v11_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
