-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_QUOTE_COVERAGE_SCHEDULE (parent HUB_QUOTE, history SCD2), fed whole from central view stitch_mxm__v01_assessment.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__quote_coverage_schedule'
src_pk:
  - 'QUOTE_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'COVERAGE_REFERENCE_CK'
  - 'COVERAGE_SEQUENCE_CK'
src_payload:
  - 'COVERAGE_AVAILED_FROM_DATE'
  - 'COVERAGE_AVAILED_TO_DATE'
  - 'COVERAGE_BASE_CURRENCY_CODE'
  - 'COVERAGE_DELETED_INDICATOR'
  - 'COVERAGE_DURATION'
  - 'COVERAGE_END_DATE'
  - 'COVERAGE_RECORD_EFFECTIVE_DATE'
  - 'COVERAGE_RECORD_EXPIRY_DATE'
  - 'COVERAGE_START_DATE'
  - 'COVERAGE_STATUS'
  - 'COVERAGE_SUM_INSURED_CURRENCY_CODE'
  - 'COVERAGE_TERM'
  - 'COVERAGE_TERM_UNIT'
  - 'COVERAGE_TRANSACTION_CURRENCY_CODE'
  - 'DISCOUNT_PERCENTAGE_APPLIED'
  - 'PREMIUM_FOR_COVERAGE'
  - 'PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY'
  - 'SUM_INSURED'
  - 'SUM_INSURED_IN_BASE_CURRENCY'
  - 'SUM_INSURED_IN_TRANSACTION_CURRENCY'
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
