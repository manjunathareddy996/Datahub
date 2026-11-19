-- automate_dv.stage() for SAT_CLAIM_LITIGATION, read off central view stitch_mxm__v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v04_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADVISORY_COMMITTEE_REFERRAL_INDICATOR'
      - 'COURT_NAME'
      - 'COURT_TYPE'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR, CLAIM_LITIGATION__COURT_NAME, CLAIM_LITIGATION__COURT_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  ADVISORY_COMMITTEE_REFERRAL_INDICATOR: 'CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR'
  COURT_NAME: 'CLAIM_LITIGATION__COURT_NAME'
  COURT_TYPE: 'CLAIM_LITIGATION__COURT_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
