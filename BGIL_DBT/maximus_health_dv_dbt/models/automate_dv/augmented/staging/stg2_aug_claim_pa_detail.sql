-- automate_dv.stage() for SAT_AUG_CLAIM_PA_DETAIL, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISABILITY_DESCRIPTION'
      - 'DISABLEMENT_DURATION'
      - 'DISABLEMENT_DURATION_WEEKS'
      - 'LEAVE_DURATION'
      - 'LEAVE_PERIOD_FROM_DATE'
      - 'LEAVE_PERIOD_TO_DATE'
      - 'MEMBER_DISABILITY_INDICATOR'
      - 'NSBP_IPTT_DISABILITY_TYPE'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_PA_DETAIL__DISABILITY_DESCRIPTION, AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION, AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION_WEEKS, AUG_CLAIM_PA_DETAIL__LEAVE_DURATION, AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_FROM_DATE, AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_TO_DATE, AUG_CLAIM_PA_DETAIL__MEMBER_DISABILITY_INDICATOR, AUG_CLAIM_PA_DETAIL__NSBP_IPTT_DISABILITY_TYPE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  DISABILITY_DESCRIPTION: 'AUG_CLAIM_PA_DETAIL__DISABILITY_DESCRIPTION'
  DISABLEMENT_DURATION: 'AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION'
  DISABLEMENT_DURATION_WEEKS: 'AUG_CLAIM_PA_DETAIL__DISABLEMENT_DURATION_WEEKS'
  LEAVE_DURATION: 'AUG_CLAIM_PA_DETAIL__LEAVE_DURATION'
  LEAVE_PERIOD_FROM_DATE: 'AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_FROM_DATE'
  LEAVE_PERIOD_TO_DATE: 'AUG_CLAIM_PA_DETAIL__LEAVE_PERIOD_TO_DATE'
  MEMBER_DISABILITY_INDICATOR: 'AUG_CLAIM_PA_DETAIL__MEMBER_DISABILITY_INDICATOR'
  NSBP_IPTT_DISABILITY_TYPE: 'AUG_CLAIM_PA_DETAIL__NSBP_IPTT_DISABILITY_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
