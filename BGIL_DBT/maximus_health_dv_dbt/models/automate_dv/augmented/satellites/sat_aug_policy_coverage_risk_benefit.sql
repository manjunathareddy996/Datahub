-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_POLICY_COVERAGE_RISK_BENEFIT (parent LNK_POLICY_COVERAGE_RISK, history SCD2), fed whole from central view stitch_v06_coverage.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_coverage_risk_benefit'
src_pk: 'POLICY_COVERAGE_RISK_HKEY'
src_cdk:
  - 'BENEFIT_CODE_CK'
src_payload:
  - 'BALANCE_LOAN_TERM'
  - 'BENEFIT_APPLICABLE_INDICATOR'
  - 'BENEFIT_CUMULATIVE_BONUS_AMOUNT'
  - 'BENEFIT_FIRST_INCEPTION_DATE'
  - 'BENEFIT_LIMIT'
  - 'BENEFIT_MINIMUM_LIMIT'
  - 'BENEFIT_OPTION_SELECTED'
  - 'BENEFIT_SUM_INSURED'
  - 'COVERAGE_STATUS'
  - 'CO_PAYMENT_APPLICABLE_INDICATOR'
  - 'CO_PAYMENT_PERCENTAGE'
  - 'DEDUCTIBLE_AMOUNT'
  - 'LIMIT_AMOUNT'
  - 'LIMIT_PERCENTAGE'
  - 'PER_DAY_BENEFIT_AMOUNT'
  - 'PER_DAY_LIMIT'
  - 'RESTORATION_INDICATOR'
  - 'RESTORATION_LIMIT'
  - 'SOURCE_COVERAGE_REFERENCE'
  - 'WAITING_PERIOD'
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
