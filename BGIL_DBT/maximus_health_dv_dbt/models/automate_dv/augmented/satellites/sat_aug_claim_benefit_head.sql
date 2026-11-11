-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CLAIM_BENEFIT_HEAD (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v02_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_benefit_head'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'BENEFIT_HEAD_CODE_CK'
src_payload:
  - 'BALANCE_SUM_INSURED'
  - 'BENEFIT_MULTIPLIER'
  - 'BENEFIT_PAYABLE_PERCENTAGE'
  - 'BENEFIT_PERIOD_FROM_DATE'
  - 'BENEFIT_PERIOD_TO_DATE'
  - 'CLAIMED_BENEFIT_WEEKS'
  - 'CLAIMED_NUMBER_OF_DAYS'
  - 'ELIGIBLE_BENEFIT_DAYS'
  - 'ELIGIBLE_BENEFIT_WEEKS'
  - 'INCURRED_EXPENSE_AMOUNT'
  - 'LAST_EMI_PAID_DATE'
  - 'MAXIMUM_BENEFIT_WEEKS_APPROVED'
  - 'NSBP_COVERAGE_DETAIL'
  - 'ORIGINAL_APPROVED_AMOUNT'
  - 'OTHER_ATTRIBUTE_VALUE'
  - 'OUTSTANDING_LOAN_AMOUNT'
  - 'PER_SITTING_CHARGE_AMOUNT'
  - 'PREVIOUS_APPROVED_AMOUNT'
  - 'SITTING_COUNT'
  - 'SUM_INSURED_PAYABLE_PERCENTAGE'
  - 'SYSTEM_CALCULATED_AMOUNT'
  - 'TOTAL_BENEFIT_APPROVED_AMOUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
