-- automate_dv.stage() for SAT_PROPOSAL_UNDERWRITING, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REFERRAL_INDICATOR'
      - 'UNDERWRITING_REMARKS'
      - 'UNDERWRITING_STATUS'
derived_columns:
  PROPOSAL_NK: "case when coalesce(PROPOSAL_UNDERWRITING__REFERRAL_INDICATOR, PROPOSAL_UNDERWRITING__UNDERWRITING_REMARKS, PROPOSAL_UNDERWRITING__UNDERWRITING_STATUS) is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  REFERRAL_INDICATOR: 'PROPOSAL_UNDERWRITING__REFERRAL_INDICATOR'
  UNDERWRITING_REMARKS: 'PROPOSAL_UNDERWRITING__UNDERWRITING_REMARKS'
  UNDERWRITING_STATUS: 'PROPOSAL_UNDERWRITING__UNDERWRITING_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
