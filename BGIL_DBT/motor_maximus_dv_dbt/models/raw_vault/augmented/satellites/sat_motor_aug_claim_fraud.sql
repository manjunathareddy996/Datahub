-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CLAIM_FRAUD (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_fraud'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'ACCEPTANCE_ANALYTICAL_DESCRIPTION'
  - 'ALERT_RAISED_DATE'
  - 'ANALYTICS_TRIGGER_FEEDBACK'
  - 'CLOSE_PROXIMITY_CASE_INDICATOR'
  - 'CLOSE_PROXIMITY_CASE_REMARKS'
  - 'FRAUD_APPROVED_BY_USER_REFERENCE'
  - 'FRAUD_APPROVER_REMARKS'
  - 'FRAUD_CLASSIFICATION'
  - 'FRAUD_INVESTIGATION_REQUESTED_BY_USER_REFERENCE'
  - 'FRAUD_REFERRAL_APPROVED_BY_USER_REFERENCE'
  - 'FRAUD_REFERRAL_APPROVER_REMARKS'
  - 'FRAUD_REFERRAL_REQUESTED_BY_USER_REFERENCE'
  - 'FRAUD_SEVERITY'
  - 'FRAUD_TRIGGER_TYPE'
  - 'NON_DISCLOSURE_FINDING'
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
