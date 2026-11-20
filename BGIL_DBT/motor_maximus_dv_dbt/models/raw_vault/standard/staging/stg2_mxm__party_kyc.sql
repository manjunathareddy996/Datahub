-- automate_dv.stage() for SAT_PARTY_KYC, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CKYC_NUMBER'
      - 'CKYC_REGISTRATION_STATUS'
      - 'KYC_COMPLETION_DATE'
      - 'KYC_STATUS'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_KYC__CKYC_NUMBER, PARTY_KYC__CKYC_REGISTRATION_STATUS, PARTY_KYC__KYC_COMPLETION_DATE, PARTY_KYC__KYC_STATUS) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CKYC_NUMBER: 'PARTY_KYC__CKYC_NUMBER'
  CKYC_REGISTRATION_STATUS: 'PARTY_KYC__CKYC_REGISTRATION_STATUS'
  KYC_COMPLETION_DATE: 'PARTY_KYC__KYC_COMPLETION_DATE'
  KYC_STATUS: 'PARTY_KYC__KYC_STATUS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
