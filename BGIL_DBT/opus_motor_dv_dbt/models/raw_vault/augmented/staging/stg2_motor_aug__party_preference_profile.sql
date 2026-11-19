-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_PREFERENCE_PROFILE, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CALLBACK_REQUESTED_INDICATOR'
      - 'DOCUMENT_PICKUP_PREFERRED_DATE'
      - 'DOCUMENT_PICKUP_PREFERRED_TIME'
      - 'PREFERRED_CONTACT_DATE'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_PREFERENCE_PROFILE__CALLBACK_REQUESTED_INDICATOR, AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_DATE, AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_TIME, AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_CONTACT_DATE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CALLBACK_REQUESTED_INDICATOR: 'AUG_PARTY_PREFERENCE_PROFILE__CALLBACK_REQUESTED_INDICATOR'
  DOCUMENT_PICKUP_PREFERRED_DATE: 'AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_DATE'
  DOCUMENT_PICKUP_PREFERRED_TIME: 'AUG_PARTY_PREFERENCE_PROFILE__DOCUMENT_PICKUP_PREFERRED_TIME'
  PREFERRED_CONTACT_DATE: 'AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_CONTACT_DATE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V11_PARTY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
