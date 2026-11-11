-- automate_dv.stage() for SAT_PARTY_FINANCIAL_PROFILE, read off central view stitch_v12_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v12_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ANNUAL_INCOME'
      - 'CREDIT_SCORE'
      - 'INCOME_SOURCE'
derived_columns:
  PARTY_NK: "case when coalesce(PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME, PARTY_FINANCIAL_PROFILE__CREDIT_SCORE, PARTY_FINANCIAL_PROFILE__INCOME_SOURCE) is not null then 'HUB_PARTY|' || PARTY_BK end"
  ANNUAL_INCOME: 'PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME'
  CREDIT_SCORE: 'PARTY_FINANCIAL_PROFILE__CREDIT_SCORE'
  INCOME_SOURCE: 'PARTY_FINANCIAL_PROFILE__INCOME_SOURCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v12_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
