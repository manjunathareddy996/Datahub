-- automate_dv.stage() for SAT_PARTY_POLICY_HISTORY, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FIRST_POLICY_DATE'
derived_columns:
  PARTY_NK: "case when PARTY_POLICY_HISTORY__FIRST_POLICY_DATE is not null then 'HUB_PARTY|' || PARTY_BK end"
  FIRST_POLICY_DATE: 'PARTY_POLICY_HISTORY__FIRST_POLICY_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
