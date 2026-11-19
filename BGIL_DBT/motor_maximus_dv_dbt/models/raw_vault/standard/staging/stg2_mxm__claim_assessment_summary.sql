-- automate_dv.stage() for SAT_CLAIM_ASSESSMENT_SUMMARY, read off central view stitch_mxm__v03_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v03_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADMISSIBLE_LOSS_AMOUNT'
      - 'DEDUCTIBLE_APPLIED'
      - 'NET_ASSESSED_AMOUNT'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_ASSESSMENT_SUMMARY__ADMISSIBLE_LOSS_AMOUNT, CLAIM_ASSESSMENT_SUMMARY__DEDUCTIBLE_APPLIED, CLAIM_ASSESSMENT_SUMMARY__NET_ASSESSED_AMOUNT) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  ADMISSIBLE_LOSS_AMOUNT: 'CLAIM_ASSESSMENT_SUMMARY__ADMISSIBLE_LOSS_AMOUNT'
  DEDUCTIBLE_APPLIED: 'CLAIM_ASSESSMENT_SUMMARY__DEDUCTIBLE_APPLIED'
  NET_ASSESSED_AMOUNT: 'CLAIM_ASSESSMENT_SUMMARY__NET_ASSESSED_AMOUNT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v03_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
