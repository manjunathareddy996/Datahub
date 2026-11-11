-- automate_dv.stage() for SAT_AUG_PARTY_IDENTITY, read off central view stitch_v15_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGE_DAYS_COMPONENT'
      - 'AGE_MONTHS_COMPONENT'
      - 'AGE_RESIDUAL_MONTHS'
      - 'LEGACY_MEMBER_NUMBER'
      - 'NATIONAL_CARD_HOLDER_INDICATOR'
      - 'REACTIVATION_DATE'
      - 'STATUS_REMARK'
derived_columns:
  PARTY_NK: "case when coalesce(AUG_PARTY_IDENTITY__AGE_DAYS_COMPONENT, AUG_PARTY_IDENTITY__AGE_MONTHS_COMPONENT, AUG_PARTY_IDENTITY__AGE_RESIDUAL_MONTHS, AUG_PARTY_IDENTITY__LEGACY_MEMBER_NUMBER, AUG_PARTY_IDENTITY__NATIONAL_CARD_HOLDER_INDICATOR, AUG_PARTY_IDENTITY__REACTIVATION_DATE, AUG_PARTY_IDENTITY__STATUS_REMARK) is not null then 'HUB_PARTY|' || PARTY_BK end"
  AGE_DAYS_COMPONENT: 'AUG_PARTY_IDENTITY__AGE_DAYS_COMPONENT'
  AGE_MONTHS_COMPONENT: 'AUG_PARTY_IDENTITY__AGE_MONTHS_COMPONENT'
  AGE_RESIDUAL_MONTHS: 'AUG_PARTY_IDENTITY__AGE_RESIDUAL_MONTHS'
  LEGACY_MEMBER_NUMBER: 'AUG_PARTY_IDENTITY__LEGACY_MEMBER_NUMBER'
  NATIONAL_CARD_HOLDER_INDICATOR: 'AUG_PARTY_IDENTITY__NATIONAL_CARD_HOLDER_INDICATOR'
  REACTIVATION_DATE: 'AUG_PARTY_IDENTITY__REACTIVATION_DATE'
  STATUS_REMARK: 'AUG_PARTY_IDENTITY__STATUS_REMARK'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
