-- automate_dv.stage() for SAT_AUG_PARTY_PREFERENCE_PROFILE, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR'
      - 'PREFERRED_REIMBURSEMENT_METHOD'
      - 'PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR'
      - 'REIMBURSEMENT_PREFERENCE'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR, AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_REIMBURSEMENT_METHOD, AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR, AUG_PARTY_PREFERENCE_PROFILE__REIMBURSEMENT_PREFERENCE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR: 'AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR'
  PREFERRED_REIMBURSEMENT_METHOD: 'AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_REIMBURSEMENT_METHOD'
  PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR: 'AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR'
  REIMBURSEMENT_PREFERENCE: 'AUG_PARTY_PREFERENCE_PROFILE__REIMBURSEMENT_PREFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
