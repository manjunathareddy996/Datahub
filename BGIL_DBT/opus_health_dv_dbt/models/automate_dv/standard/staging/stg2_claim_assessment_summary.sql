-- automate_dv.stage() for SAT_CLAIM_ASSESSMENT_SUMMARY, read off central view stitch_v01_agreement.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v01_agreement'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADMISSIBLE_LOSS_AMOUNT'
      - 'ASSESSMENT_DATE'
      - 'DEDUCTIBLE_APPLIED'
      - 'TOTAL_DEDUCTION_AMOUNT'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_ASSESSMENT_SUMMARY__ADMISSIBLE_LOSS_AMOUNT, CLAIM_ASSESSMENT_SUMMARY__ASSESSMENT_DATE, CLAIM_ASSESSMENT_SUMMARY__DEDUCTIBLE_APPLIED, CLAIM_ASSESSMENT_SUMMARY__TOTAL_DEDUCTION_AMOUNT) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  ADMISSIBLE_LOSS_AMOUNT: 'CLAIM_ASSESSMENT_SUMMARY__ADMISSIBLE_LOSS_AMOUNT'
  ASSESSMENT_DATE: 'CLAIM_ASSESSMENT_SUMMARY__ASSESSMENT_DATE'
  DEDUCTIBLE_APPLIED: 'CLAIM_ASSESSMENT_SUMMARY__DEDUCTIBLE_APPLIED'
  TOTAL_DEDUCTION_AMOUNT: 'CLAIM_ASSESSMENT_SUMMARY__TOTAL_DEDUCTION_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v01_agreement'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
