-- automate_dv.stage() for SAT_PROPOSAL_HEADER, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMPLETENESS_INDICATOR'
      - 'DECLINE_REASON'
      - 'PROJECTED_PREMIUM_AMOUNT'
      - 'PROPOSAL_DATE'
      - 'PROPOSAL_MODE'
      - 'REQUESTED_SUM_INSURED'
      - 'SUBMISSION_CHANNEL'
derived_columns:
  PROPOSAL_NK: "case when coalesce(PROPOSAL_HEADER__COMPLETENESS_INDICATOR, PROPOSAL_HEADER__DECLINE_REASON, PROPOSAL_HEADER__PROJECTED_PREMIUM_AMOUNT, PROPOSAL_HEADER__PROPOSAL_DATE, PROPOSAL_HEADER__PROPOSAL_MODE, PROPOSAL_HEADER__REQUESTED_SUM_INSURED, PROPOSAL_HEADER__SUBMISSION_CHANNEL) is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  COMPLETENESS_INDICATOR: 'PROPOSAL_HEADER__COMPLETENESS_INDICATOR'
  DECLINE_REASON: 'PROPOSAL_HEADER__DECLINE_REASON'
  PROJECTED_PREMIUM_AMOUNT: 'PROPOSAL_HEADER__PROJECTED_PREMIUM_AMOUNT'
  PROPOSAL_DATE: 'PROPOSAL_HEADER__PROPOSAL_DATE'
  PROPOSAL_MODE: 'PROPOSAL_HEADER__PROPOSAL_MODE'
  REQUESTED_SUM_INSURED: 'PROPOSAL_HEADER__REQUESTED_SUM_INSURED'
  SUBMISSION_CHANNEL: 'PROPOSAL_HEADER__SUBMISSION_CHANNEL'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
