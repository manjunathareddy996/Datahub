-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_ASSESSMENT_BUREAU_PRIOR_INSURANCE (parent HUB_ASSESSMENT, history SCD2), fed whole from central view stitch_motor__v10_party.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__assessment_bureau_prior_insurance'
src_pk:
  - 'ASSESSMENT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'BUREAU_CHECK_PERFORMED_INDICATOR'
  - 'BUREAU_DISCREPANCY_RULE_CODE'
  - 'BUREAU_REPORTED_POLICY_STATUS'
  - 'BUREAU_REPORTED_PREVIOUS_POLICY_EXPIRY_DATE'
  - 'BUREAU_REPORTED_PREVIOUS_POLICY_NUMBER'
  - 'BUREAU_REPORTED_PRIOR_CLAIM_INDICATOR'
  - 'CONTINUOUS_COVER_CONFIRMED_INDICATOR'
  - 'PREVIOUS_POLICY_EXPIRED_OVER_NINETY_DAYS_INDICATOR'
  - 'PREVIOUS_POLICY_EXPIRED_WITHIN_NINETY_DAYS_INDICATOR'
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
