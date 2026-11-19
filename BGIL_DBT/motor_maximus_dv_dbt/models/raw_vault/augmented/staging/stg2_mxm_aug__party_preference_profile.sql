-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_PREFERENCE_PROFILE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR'
      - 'PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR, AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR: 'AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR'
  PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR: 'AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v09_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
