-- automate_dv.stage() for SAT_CLAIM_LITIGATION, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADVISORY_COMMITTEE_REFERRAL_INDICATOR'
      - 'CONSUMER_FORUM_CASE_INDICATOR'
      - 'LITIGATION_INDICATOR'
      - 'OTHER_LITIGATION_INDICATOR'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR, CLAIM_LITIGATION__CONSUMER_FORUM_CASE_INDICATOR, CLAIM_LITIGATION__LITIGATION_INDICATOR, CLAIM_LITIGATION__OTHER_LITIGATION_INDICATOR) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  ADVISORY_COMMITTEE_REFERRAL_INDICATOR: 'CLAIM_LITIGATION__ADVISORY_COMMITTEE_REFERRAL_INDICATOR'
  CONSUMER_FORUM_CASE_INDICATOR: 'CLAIM_LITIGATION__CONSUMER_FORUM_CASE_INDICATOR'
  LITIGATION_INDICATOR: 'CLAIM_LITIGATION__LITIGATION_INDICATOR'
  OTHER_LITIGATION_INDICATOR: 'CLAIM_LITIGATION__OTHER_LITIGATION_INDICATOR'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V02_CLAIM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
