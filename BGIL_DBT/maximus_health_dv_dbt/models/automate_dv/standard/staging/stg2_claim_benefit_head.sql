-- automate_dv.stage() for SAT_CLAIM_BENEFIT_HEAD, read off central view stitch_v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPROVED_AMOUNT'
      - 'ASSESSED_AMOUNT'
      - 'BENEFIT_HEAD_CODE'
      - 'CLAIMED_AMOUNT'
      - 'CO_PAY_APPLIED'
      - 'DEDUCTION_AMOUNT'
      - 'DEDUCTION_REASON'
      - 'HEAD_DESCRIPTION'
      - 'STATUS'
      - 'BENEFIT_HEAD_CODE_CK'
derived_columns:
  CLAIM_NK: "case when coalesce(CLAIM_BENEFIT_HEAD__APPROVED_AMOUNT, CLAIM_BENEFIT_HEAD__ASSESSED_AMOUNT, CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE, CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT, CLAIM_BENEFIT_HEAD__CO_PAY_APPLIED, CLAIM_BENEFIT_HEAD__DEDUCTION_AMOUNT, CLAIM_BENEFIT_HEAD__DEDUCTION_REASON, CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION, CLAIM_BENEFIT_HEAD__STATUS) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  BENEFIT_HEAD_CODE_CK: 'CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE_CK'
  APPROVED_AMOUNT: 'CLAIM_BENEFIT_HEAD__APPROVED_AMOUNT'
  ASSESSED_AMOUNT: 'CLAIM_BENEFIT_HEAD__ASSESSED_AMOUNT'
  BENEFIT_HEAD_CODE: 'CLAIM_BENEFIT_HEAD__BENEFIT_HEAD_CODE'
  CLAIMED_AMOUNT: 'CLAIM_BENEFIT_HEAD__CLAIMED_AMOUNT'
  CO_PAY_APPLIED: 'CLAIM_BENEFIT_HEAD__CO_PAY_APPLIED'
  DEDUCTION_AMOUNT: 'CLAIM_BENEFIT_HEAD__DEDUCTION_AMOUNT'
  DEDUCTION_REASON: 'CLAIM_BENEFIT_HEAD__DEDUCTION_REASON'
  HEAD_DESCRIPTION: 'CLAIM_BENEFIT_HEAD__HEAD_DESCRIPTION'
  STATUS: 'CLAIM_BENEFIT_HEAD__STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
