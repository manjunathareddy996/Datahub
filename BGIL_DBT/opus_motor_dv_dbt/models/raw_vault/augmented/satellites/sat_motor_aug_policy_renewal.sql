-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_POLICY_RENEWAL (parent HUB_POLICY, history SCD2), fed whole from central view stitch_motor__v14_policy.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__policy_renewal'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'BANK_PARTNER_VERSION_MARKER'
  - 'DIRECT_MARKETING_LOCATION_CODE'
  - 'DOCUMENT_DISPATCH_INDICATOR'
  - 'EXPIRING_POLICY_CLAIM_RATIO'
  - 'EXPIRING_POLICY_INCURRED_CLAIM_RATIO'
  - 'LAST_ENDORSEMENT_DATE'
  - 'POLICY_CANCELLATION_REASON'
  - 'PREVIOUS_POLICY_TERM'
  - 'PREVIOUS_VEHICLE_MAKE_CODE'
  - 'PREVIOUS_VEHICLE_MODEL_CODE'
  - 'PREVIOUS_VEHICLE_REGISTRATION_NUMBER'
  - 'PREVIOUS_VEHICLE_SUB_TYPE_CODE'
  - 'PREVIOUS_VEHICLE_TYPE_CODE'
  - 'PROFITABILITY_INDICATOR'
  - 'PROSPECT_REFERENCE'
  - 'QUALITY_CHECK_STATUS'
  - 'RENEWAL_CHANNEL'
  - 'RENEWAL_GROSS_PREMIUM'
  - 'RENEWAL_NOTICE_DOCUMENT_REFERENCE'
  - 'RENEWAL_NOTICE_PRINTED_INDICATOR'
  - 'RENEWAL_NOTICE_REFERENCE'
  - 'RENEWAL_NOTICE_REGENERATED_DATE'
  - 'RENEWAL_NOTICE_REGENERATED_INDICATOR'
  - 'RENEWAL_POLICY_NUMBER'
  - 'RENEWAL_PRICED_INDICATOR'
  - 'RENEWAL_REGENERATED_INDICATOR'
  - 'RENEWAL_REGENERATION_DATE'
  - 'RENEWAL_TARIFF_RATE'
  - 'RENEWED_INTO_POLICY_REFERENCE'
  - 'RENEWED_POLICY_REFERENCE'
  - 'UNDERWRITING_PROFITABILITY_INDICATOR'
  - 'UNIFIED_RENEWAL_STATUS'
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
