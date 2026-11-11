-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_POLICY_HEADER (parent HUB_POLICY, history SCD2), fed whole from central view stitch_v24_policy.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_policy_header'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'ADDITIONAL_REMARKS'
  - 'APPLICATION_SUBMISSION_DATE'
  - 'CONTRACT_PARTITION_NUMBER'
  - 'CO_APPLICANT_COVER_REQUESTED_INDICATOR'
  - 'CUSTOMER_COMMUNICATION_TEXT'
  - 'INTERNAL_TRACKING_NUMBER'
  - 'LOAN_CO_APPLICANT_COUNT'
  - 'POLICY_ISSUANCE_CONFIRMATION_INDICATOR'
  - 'POLICY_ISSUED_INDICATOR'
  - 'POLICY_VERSION_NUMBER'
  - 'PREMIUM_CALCULATION_PERIOD'
  - 'PRODUCT_VERSION_APPLIED'
  - 'SHORT_PERIOD_END_DATE'
  - 'UNDERWRITING_REVIEW_INDICATOR'
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
