-- automate_dv.stage() for SAT_AUG_PARTY_POLICY_HISTORY, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OTHER_HELD_POLICY_NUMBER'
derived_columns:
  PARTY_NK: "case when AUG_PARTY_POLICY_HISTORY__OTHER_HELD_POLICY_NUMBER is not null then 'HUB_PARTY|' || PARTY_BK end"
  OTHER_HELD_POLICY_NUMBER: 'AUG_PARTY_POLICY_HISTORY__OTHER_HELD_POLICY_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
