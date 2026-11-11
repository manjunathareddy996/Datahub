-- automate_dv.stage() for SAT_AUG_LNK_POLICY_PARTY_ROLE, read off central view stitch_v23_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v23_policy'
hashed_columns:
  POLICY_PARTY_HKEY: 'POLICY_PARTY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISCLAIMER_ACCEPTED_INDICATOR'
derived_columns:
  POLICY_PARTY_NK: "case when AUG_LNK_POLICY_PARTY_ROLE__DISCLAIMER_ACCEPTED_INDICATOR is not null then 'LNK_POLICY_PARTY|' || PARTY_BK || '|' || POLICY_BK end"
  DISCLAIMER_ACCEPTED_INDICATOR: 'AUG_LNK_POLICY_PARTY_ROLE__DISCLAIMER_ACCEPTED_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v23_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
