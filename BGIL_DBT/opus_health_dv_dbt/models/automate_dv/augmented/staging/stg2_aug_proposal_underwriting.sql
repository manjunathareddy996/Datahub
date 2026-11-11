-- automate_dv.stage() for SAT_AUG_PROPOSAL_UNDERWRITING, read off central view stitch_v33_quote.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v33_quote'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SPECIAL_APPROVAL_DETAIL'
derived_columns:
  PROPOSAL_NK: "case when AUG_PROPOSAL_UNDERWRITING__SPECIAL_APPROVAL_DETAIL is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  SPECIAL_APPROVAL_DETAIL: 'AUG_PROPOSAL_UNDERWRITING__SPECIAL_APPROVAL_DETAIL'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v33_quote'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
