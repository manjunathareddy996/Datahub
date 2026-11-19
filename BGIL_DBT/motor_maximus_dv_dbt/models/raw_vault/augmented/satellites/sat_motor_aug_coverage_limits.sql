-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_COVERAGE_LIMITS (parent HUB_COVERAGE, history SCD2), fed whole from central view stitch_mxm__v01_assessment.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__coverage_limits'
src_pk: 'COVERAGE_HKEY'
src_payload:
  - 'BENEFIT_PERIOD'
  - 'CLAIM_REGISTRATION_COUNT_LIMIT'
  - 'CLAIM_REGISTRATION_LIMIT'
  - 'COVERAGE_SUM_INSURED'
  - 'COVERAGE_SUM_INSURED_CURRENCY'
  - 'DAILY_ALLOWANCE_LIMIT'
  - 'LIMIT_AMOUNT_IN_USD'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                   src_payload=metadata_dict['src_payload'],
                   src_hashdiff=metadata_dict['src_hashdiff'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
