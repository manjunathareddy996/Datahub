-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_RISK_HEALTH_MEMBER_MEDICAL (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_v34_risk_object.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_risk_health_member_medical'
src_pk: 'RISK_OBJECT_HKEY'
src_cdk:
  - 'MEMBER_REFERENCE_CK'
  - 'CONDITION_CODE_CK'
src_payload:
  - 'DECLARED_HEALTH_REMARKS'
  - 'DECLARED_INSURANCE_PERIOD'
  - 'DIAGNOSTIC_CENTRE_REMARKS'
  - 'FAMILY_MEDICAL_HISTORY_DETAIL'
  - 'GESTATION_MONTHS'
  - 'ILLNESS_DURATION'
  - 'PRESCRIPTION_DETAIL'
  - 'PRESCRIPTION_SUBMITTED_INDICATOR'
  - 'TREATING_DOCTOR_NAME'
  - 'TREATMENT_DESCRIPTION'
  - 'TREATMENT_DETAILS_NARRATIVE'
  - 'TREATMENT_PERIOD'
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
