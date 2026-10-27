{{ config(materialized='incremental') }}

-- MAXIMUS TRAVEL V2 ma_sat() for SAT_AUG_CLAIM_PROVIDER_BILLING.
-- Writes the SAME physical table as the OPUS build travel_dv_dbt: separate projects,
-- separate pipelines, one shared vault. This model declares ONLY this project's own
-- sources and only the payload it populates -- it does not union the sibling's models.
--
-- The sibling does not build this satellite, so this build ESTABLISHES its contract
-- (BUILD_RULES 7.3): bare HASHDIFF, CLAIM_HKEY, multi-active on BILL_NUMBER.

{%- set yaml_metadata -%}
source_model:
  - 'satfeed_mtv2_aug_sat_aug_claim_provider_billing'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'BILL_NUMBER'
src_payload:
  - 'ADMISSIBLE_AMOUNT_IN_INR'
  - 'APPLICABLE_TERM_END_DATE'
  - 'APPLICABLE_TERM_START_DATE'
  - 'ASSISTANCE_COMPANY_REPRICING_DISCOUNT_AMOUNT'
  - 'BALANCE_SUM_INSURED_AMOUNT'
  - 'BILLED_AMOUNT_IN_BILL_CURRENCY'
  - 'BILL_AMOUNT_BREAKUP'
  - 'BILL_CURRENCY_CODE'
  - 'BILL_DISCOUNT_AMOUNT'
  - 'BILL_LINE_PARTICULARS'
  - 'BILL_PAYABLE_REASON'
  - 'DEDUCTION_AMOUNT_IN_SUM_INSURED_CURRENCY'
  - 'DISALLOWANCE_BREAKUP'
  - 'EXCHANGE_RATE_APPLICABLE_DATE'
  - 'EXCHANGE_RATE_TO_INR'
  - 'EXCHANGE_RATE_TO_POLICY_SUM_INSURED_CURRENCY'
  - 'FINAL_ADMISSIBLE_AMOUNT_IN_BILL_CURRENCY'
  - 'FINAL_ADMISSIBLE_AMOUNT_IN_POLICY_SUM_INSURED_CURRENCY'
  - 'NON_ADMISSIBLE_AMOUNT'
  - 'NON_ADMISSIBLE_REMARKS'
  - 'PROVIDER_FACILITY_NAME'
  - 'REVIEWED_AMOUNT'
  - 'REVIEW_DESCRIPTION'
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
