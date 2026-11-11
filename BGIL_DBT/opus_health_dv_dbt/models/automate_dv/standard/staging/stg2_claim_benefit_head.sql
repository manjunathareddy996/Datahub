-- automate_dv.stage() for SAT_CLAIM_BENEFIT_HEAD, read off central view stitch_v07_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v07_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPROVED_AMOUNT'
      - 'BENEFIT_HEAD_CODE'
      - 'CLAIMED_AMOUNT'
      - 'DEDUCTION_AMOUNT'
      - 'DEDUCTION_REASON'
      - 'BENEFIT_HEAD_CODE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_BENEFIT_HEAD__APPROVED_AMOUNT, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE, CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT, CLAIM_BENEFIT_HEAD__DEDUCTION_AMOUNT, CLAIM_BENEFIT_HEAD__DEDUCTION_REASON) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  BENEFIT_HEAD_CODE_CK: 'CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK'
  APPROVED_AMOUNT: 'CLAIM_BENEFIT_HEAD__APPROVED_AMOUNT'
  BENEFIT_HEAD_CODE: 'CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE'
  CLAIMED_AMOUNT: 'CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT'
  DEDUCTION_AMOUNT: 'CLAIM_BENEFIT_HEAD__DEDUCTION_AMOUNT'
  DEDUCTION_REASON: 'CLAIM_BENEFIT_HEAD__DEDUCTION_REASON'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v07_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
