-- automate_dv.stage() for SAT_PARTY_RELATIONSHIP_PROFILE, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOYALTY_TIER'
      - 'PROFITABILITY_INDEX'
      - 'RELATIONSHIP_TENURE'
      - 'TOTAL_PREMIUM_PAID_LIFETIME'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_RELATIONSHIP_PROFILE__LOYALTY_TIER, PARTY_RELATIONSHIP_PROFILE__PROFITABILITY_INDEX, PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_TENURE, PARTY_RELATIONSHIP_PROFILE__TOTAL_PREMIUM_PAID_LIFETIME) is not null then 'HUB_PARTY|' || PARTY_BK end"
  LOYALTY_TIER: 'PARTY_RELATIONSHIP_PROFILE__LOYALTY_TIER'
  PROFITABILITY_INDEX: 'PARTY_RELATIONSHIP_PROFILE__PROFITABILITY_INDEX'
  RELATIONSHIP_TENURE: 'PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_TENURE'
  TOTAL_PREMIUM_PAID_LIFETIME: 'PARTY_RELATIONSHIP_PROFILE__TOTAL_PREMIUM_PAID_LIFETIME'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
