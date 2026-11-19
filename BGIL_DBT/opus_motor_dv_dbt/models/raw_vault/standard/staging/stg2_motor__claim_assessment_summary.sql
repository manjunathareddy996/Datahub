-- automate_dv.stage() for SAT_CLAIM_ASSESSMENT_SUMMARY, read off central view stitch_motor__v01_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v01_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSESSED_LOSS_AMOUNT'
      - 'EXCESS_DEDUCTED'
      - 'SALVAGE_AMOUNT'
      - 'TOTAL_DEDUCTION_AMOUNT'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_ASSESSMENT_SUMMARY__ASSESSED_LOSS_AMOUNT, CLAIM_ASSESSMENT_SUMMARY__EXCESS_DEDUCTED, CLAIM_ASSESSMENT_SUMMARY__SALVAGE_AMOUNT, CLAIM_ASSESSMENT_SUMMARY__TOTAL_DEDUCTION_AMOUNT) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  ASSESSED_LOSS_AMOUNT: 'CLAIM_ASSESSMENT_SUMMARY__ASSESSED_LOSS_AMOUNT'
  EXCESS_DEDUCTED: 'CLAIM_ASSESSMENT_SUMMARY__EXCESS_DEDUCTED'
  SALVAGE_AMOUNT: 'CLAIM_ASSESSMENT_SUMMARY__SALVAGE_AMOUNT'
  TOTAL_DEDUCTION_AMOUNT: 'CLAIM_ASSESSMENT_SUMMARY__TOTAL_DEDUCTION_AMOUNT'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V01_CLAIM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
