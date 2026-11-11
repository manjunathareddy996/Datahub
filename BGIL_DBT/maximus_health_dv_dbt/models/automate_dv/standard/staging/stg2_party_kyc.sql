-- automate_dv.stage() for SAT_PARTY_KYC, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CKYC_NUMBER'
      - 'CKYC_REGISTRATION_STATUS'
      - 'KYC_COMPLETED_INDICATOR'
      - 'KYC_WAIVER_INDICATOR'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_KYC__CKYC_NUMBER, PARTY_KYC__CKYC_REGISTRATION_STATUS, PARTY_KYC__KYC_COMPLETED_INDICATOR, PARTY_KYC__KYC_WAIVER_INDICATOR) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CKYC_NUMBER: 'PARTY_KYC__CKYC_NUMBER'
  CKYC_REGISTRATION_STATUS: 'PARTY_KYC__CKYC_REGISTRATION_STATUS'
  KYC_COMPLETED_INDICATOR: 'PARTY_KYC__KYC_COMPLETED_INDICATOR'
  KYC_WAIVER_INDICATOR: 'PARTY_KYC__KYC_WAIVER_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
