-- automate_dv.stage() for SAT_PARTY_FINANCIAL_PROFILE, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CREDIT_SCORE'
      - 'INCOME_SOURCE'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_FINANCIAL_PROFILE__CREDIT_SCORE, PARTY_FINANCIAL_PROFILE__INCOME_SOURCE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  CREDIT_SCORE: 'PARTY_FINANCIAL_PROFILE__CREDIT_SCORE'
  INCOME_SOURCE: 'PARTY_FINANCIAL_PROFILE__INCOME_SOURCE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
