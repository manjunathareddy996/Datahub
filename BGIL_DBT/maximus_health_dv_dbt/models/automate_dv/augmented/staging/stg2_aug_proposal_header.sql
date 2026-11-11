-- automate_dv.stage() for SAT_AUG_PROPOSAL_HEADER, read off central view stitch_v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'QUOTE_VALIDITY_DATE'
      - 'QUOTE_VALIDITY_PERIOD'
derived_columns:
  PROPOSAL_NK: "case when coalesce(AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_DATE, AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_PERIOD) is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  QUOTE_VALIDITY_DATE: 'AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_DATE'
  QUOTE_VALIDITY_PERIOD: 'AUG_PROPOSAL_HEADER__QUOTE_VALIDITY_PERIOD'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
