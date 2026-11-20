-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_RISK_MOTOR_NCB_HISTORY (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_mxm__v15_risk_object.
-- DUAL-GRAIN HUB_RISK_OBJECT: some feeders key the hub at INTEREST (policy-risk-line) grain, others at
-- object/vehicle grain. Ruled legitimate by the senior mapper; the two grains are NOT unified (BUILD_INSTRUCTIONS s3).
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__risk_motor_ncb_history'
src_pk:
  - 'RISK_OBJECT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'BUREAU_REPORTED_NCB_PERCENTAGE'
  - 'ELIGIBLE_NCB_PERCENTAGE'
  - 'EXISTING_CLAIM_WITH_INSURER_DECLARED_INDICATOR'
  - 'EXISTING_INSURER_MOTOR_POLICY_INDICATOR'
  - 'EXISTING_POLICY_WITH_INSURER_DECLARED_INDICATOR'
  - 'EXPIRING_POLICY_OWN_DAMAGE_CLAIM_COUNT'
  - 'IIB_NCB_MASTER_REFERENCE'
  - 'NCB_CARRIED_FROM_REFERENCE'
  - 'NCB_ELIGIBILITY_MASTER_REFERENCE'
  - 'NCB_PLAN_TYPE'
  - 'OWN_DAMAGE_CLAIM_PATTERN'
  - 'PREVIOUS_CLAIM_LOSS_NATURE'
  - 'PREVIOUS_NCB_PERCENTAGE_BAND'
  - 'PREVIOUS_OD_POLICY_EXPIRY_DATE'
  - 'PREVIOUS_OD_POLICY_INSURER_NAME'
  - 'PREVIOUS_OD_POLICY_NUMBER'
  - 'PREVIOUS_OD_POLICY_OWNERSHIP_TRANSFER_DATE'
  - 'PREVIOUS_OD_POLICY_OWNERSHIP_TRANSFER_INDICATOR'
  - 'PREVIOUS_OD_POLICY_START_DATE'
  - 'PREVIOUS_OWN_DAMAGE_CLAIM_LOSS_NATURE'
  - 'PREVIOUS_OWN_DAMAGE_POLICY_CLAIM_COUNT'
  - 'PREVIOUS_PERSONAL_ACCIDENT_CLAIM_LOSS_NATURE'
  - 'PREVIOUS_POLICY_ADD_ON_COVER_LIST'
  - 'PREVIOUS_POLICY_AVAILABLE_INDICATOR'
  - 'PREVIOUS_POLICY_CHASSIS_NUMBER'
  - 'PREVIOUS_POLICY_DETAILS_SUPPLIED_INDICATOR'
  - 'PREVIOUS_POLICY_ENGINE_NUMBER'
  - 'PREVIOUS_POLICY_OD_TENURE_YEARS'
  - 'PREVIOUS_POLICY_TERM'
  - 'PREVIOUS_POLICY_TP_TENURE_YEARS'
  - 'PREVIOUS_THIRD_PARTY_POLICY_CLAIM_COUNT'
  - 'PREVIOUS_TP_POLICY_EXPIRY_DATE'
  - 'PREVIOUS_TP_POLICY_INSURER_NAME'
  - 'PREVIOUS_TP_POLICY_NUMBER'
  - 'PREVIOUS_TP_POLICY_START_DATE'
  - 'PREVIOUS_VEHICLE_REGISTRATION_NUMBER'
  - 'THIRD_PARTY_CLAIM_COUNT_IN_EXPIRING_POLICY'
  - 'THIRD_PARTY_CLAIM_PATTERN'
  - 'THIRD_PARTY_LOSS_RATIO'
  - 'THIRD_PARTY_POLICY_CLAIM_COUNT'
  - 'TOTAL_LOSS_RATIO'
  - 'USER_ENTERED_RELATED_POLICY_NUMBER'
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
