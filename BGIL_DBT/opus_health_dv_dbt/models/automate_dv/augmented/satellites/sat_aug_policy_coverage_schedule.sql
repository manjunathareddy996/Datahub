-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_POLICY_COVERAGE_SCHEDULE (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v25_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_coverage_schedule'
src_pk: 'POLICY_HKEY'
src_cdk:
  - 'COVERAGE_REFERENCE_CK'
  - 'COVERAGE_SEQUENCE_CK'
src_payload:
  - 'AGENT_COMMISSION_COMPANY_SHARE_AMOUNT'
  - 'AGENT_COMMISSION_COMPANY_SHARE_CURRENCY_CODE'
  - 'AGENT_COMMISSION_WHOLE_COVER_AMOUNT'
  - 'AGENT_COMMISSION_WHOLE_COVER_CURRENCY_CODE'
  - 'COVER_VARIANT_CLASSIFICATION_CODE'
  - 'CO_INSURANCE_SHARE_PORTION'
  - 'FULL_TERM_PREMIUM_ORIGINAL_COMPANY_SHARE'
  - 'FULL_TERM_PREMIUM_ORIGINAL_COMPANY_SHARE_CURRENCY_CODE'
  - 'FULL_TERM_PREMIUM_ORIGINAL_WHOLE_COVER'
  - 'FULL_TERM_PREMIUM_ORIGINAL_WHOLE_COVER_CURRENCY_CODE'
  - 'FULL_TERM_PREMIUM_SYSTEM_COMPANY_SHARE'
  - 'FULL_TERM_PREMIUM_SYSTEM_COMPANY_SHARE_CURRENCY_CODE'
  - 'FULL_TERM_PREMIUM_SYSTEM_WHOLE_COVER_CURRENCY_CODE'
  - 'PARENT_COVERAGE_CONTRACT_REFERENCE'
  - 'PARENT_COVERAGE_PARTITION_NUMBER'
  - 'PARENT_COVERAGE_REFERENCE'
  - 'PARENT_COVERAGE_SEQUENCE'
  - 'PLAN_REFERENCE'
  - 'REINSURABLE_RISK_AMOUNT'
  - 'REINSURABLE_RISK_AMOUNT_CURRENCY_CODE'
  - 'SECTION_REFERENCE'
  - 'SOURCE_ROW_VERSION_NUMBER'
  - 'SUM_INSURED_COMPANY_SHARE'
  - 'SUM_INSURED_COMPANY_SHARE_CURRENCY_CODE'
  - 'SUM_INSURED_WHOLE_COVER_CURRENCY_CODE'
  - 'SURCHARGE_OR_DISCOUNT_AMOUNT'
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
