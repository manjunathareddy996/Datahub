-- automate_dv.stage() for SAT_PARTY_FINANCIAL_PROFILE, read off central view stitch_v21_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v21_party'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ANNUAL_INCOME'
derived_columns:
  PARTY_NK: "case when PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME is not null then 'HUB_PARTY|' || PARTY_BK end"
  ANNUAL_INCOME: 'PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v21_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
