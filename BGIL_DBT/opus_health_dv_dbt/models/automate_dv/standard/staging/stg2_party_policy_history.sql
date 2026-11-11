-- automate_dv.stage() for SAT_PARTY_POLICY_HISTORY, read off central view stitch_v21_party.
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
      - 'CONTINUOUS_YEARS_INSURED'
derived_columns:
  PARTY_NK: "case when PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED is not null then 'HUB_PARTY|' || PARTY_BK end"
  CONTINUOUS_YEARS_INSURED: 'PARTY_POLICY_HISTORY__CONTINUOUS_YEARS_INSURED'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v21_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
