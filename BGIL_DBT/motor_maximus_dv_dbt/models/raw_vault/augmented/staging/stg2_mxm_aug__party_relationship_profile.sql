-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_RELATIONSHIP_PROFILE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EXISTING_CUSTOMER_DECLARED_INDICATOR'
      - 'FINAL_LOYALTY_SEVERITY'
      - 'LOYALTY_BUCKET_BY_SEVERITY'
      - 'NOMINEE_DETAIL_TEXT'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_RELATIONSHIP_PROFILE__EXISTING_CUSTOMER_DECLARED_INDICATOR, AUG_PARTY_RELATIONSHIP_PROFILE__FINAL_LOYALTY_SEVERITY, AUG_PARTY_RELATIONSHIP_PROFILE__LOYALTY_BUCKET_BY_SEVERITY, AUG_PARTY_RELATIONSHIP_PROFILE__NOMINEE_DETAIL_TEXT) is not null then 'HUB_PARTY|' || PARTY_BK end"
  EXISTING_CUSTOMER_DECLARED_INDICATOR: 'AUG_PARTY_RELATIONSHIP_PROFILE__EXISTING_CUSTOMER_DECLARED_INDICATOR'
  FINAL_LOYALTY_SEVERITY: 'AUG_PARTY_RELATIONSHIP_PROFILE__FINAL_LOYALTY_SEVERITY'
  LOYALTY_BUCKET_BY_SEVERITY: 'AUG_PARTY_RELATIONSHIP_PROFILE__LOYALTY_BUCKET_BY_SEVERITY'
  NOMINEE_DETAIL_TEXT: 'AUG_PARTY_RELATIONSHIP_PROFILE__NOMINEE_DETAIL_TEXT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
