-- automate_dv.stage() for SAT_AUG_PARTY_PAYOUT_PROFILE, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FLOAT_ACCOUNT_ACCESS_INDICATOR'
      - 'PAYMENT_MODE'
      - 'REWARD_SCHEME_APPLICABLE_INDICATOR'
      - 'TDS_CODE'
      - 'TDS_CODE_DESCRIPTION'
      - 'TDS_DETAILS'
      - 'TDS_DETAILS_DESCRIPTION'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_PAYOUT_PROFILE__FLOAT_ACCOUNT_ACCESS_INDICATOR, AUG_PARTY_PAYOUT_PROFILE__PAYMENT_MODE, AUG_PARTY_PAYOUT_PROFILE__REWARD_SCHEME_APPLICABLE_INDICATOR, AUG_PARTY_PAYOUT_PROFILE__TDS_CODE, AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION, AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS, AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS_DESCRIPTION) is not null then 'HUB_PARTY|' || PARTY_BK end"
  FLOAT_ACCOUNT_ACCESS_INDICATOR: 'AUG_PARTY_PAYOUT_PROFILE__FLOAT_ACCOUNT_ACCESS_INDICATOR'
  PAYMENT_MODE: 'AUG_PARTY_PAYOUT_PROFILE__PAYMENT_MODE'
  REWARD_SCHEME_APPLICABLE_INDICATOR: 'AUG_PARTY_PAYOUT_PROFILE__REWARD_SCHEME_APPLICABLE_INDICATOR'
  TDS_CODE: 'AUG_PARTY_PAYOUT_PROFILE__TDS_CODE'
  TDS_CODE_DESCRIPTION: 'AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION'
  TDS_DETAILS: 'AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS'
  TDS_DETAILS_DESCRIPTION: 'AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS_DESCRIPTION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
