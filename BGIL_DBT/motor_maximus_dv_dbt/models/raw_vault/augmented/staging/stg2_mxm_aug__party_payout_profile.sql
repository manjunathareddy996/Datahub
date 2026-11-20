-- automate_dv.stage() for SAT_MOTOR_AUG_PARTY_PAYOUT_PROFILE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOWER_TDS_CERTIFICATE_REFERENCE'
      - 'REFUND_BENEFICIARY_PARTY_REFERENCE'
      - 'TDS_CODE'
      - 'TDS_CODE_DESCRIPTION'
      - 'TDS_DETAIL_TEXT'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_PAYOUT_PROFILE__LOWER_TDS_CERTIFICATE_REFERENCE, AUG_PARTY_PAYOUT_PROFILE__REFUND_BENEFICIARY_PARTY_REFERENCE, AUG_PARTY_PAYOUT_PROFILE__TDS_CODE, AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION, AUG_PARTY_PAYOUT_PROFILE__TDS_DETAIL_TEXT) is not null then 'HUB_PARTY|' || PARTY_BK end"
  LOWER_TDS_CERTIFICATE_REFERENCE: 'AUG_PARTY_PAYOUT_PROFILE__LOWER_TDS_CERTIFICATE_REFERENCE'
  REFUND_BENEFICIARY_PARTY_REFERENCE: 'AUG_PARTY_PAYOUT_PROFILE__REFUND_BENEFICIARY_PARTY_REFERENCE'
  TDS_CODE: 'AUG_PARTY_PAYOUT_PROFILE__TDS_CODE'
  TDS_CODE_DESCRIPTION: 'AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION'
  TDS_DETAIL_TEXT: 'AUG_PARTY_PAYOUT_PROFILE__TDS_DETAIL_TEXT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
