-- automate_dv.stage() for SAT_PROPOSAL_HEADER, read off central view stitch_v28_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v28_policy'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PROPOSAL_STATUS'
derived_columns:
  PROPOSAL_NK: "case when PROPOSAL_HEADER__PROPOSAL_STATUS is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  PROPOSAL_STATUS: 'PROPOSAL_HEADER__PROPOSAL_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v28_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
