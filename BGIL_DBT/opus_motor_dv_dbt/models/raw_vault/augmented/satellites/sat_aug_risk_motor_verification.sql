-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_RISK_MOTOR_VERIFICATION (parent HUB_RISK_OBJECT, history SCD2), fed whole from central view stitch_motor__v26_risk_object.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__risk_motor_verification'
src_pk: 'RISK_OBJECT_HKEY'
src_payload:
  - 'BUREAU_ENQUIRY_RECORD_REFERENCE'
  - 'CHANGE_APPROVAL_RECEIVED_INDICATOR'
  - 'CHASSIS_NUMBER_AS_VERIFIED'
  - 'ENGINE_NUMBER_AS_VERIFIED'
  - 'PREVIOUS_VERIFICATION_STATUS'
  - 'REGISTRATION_NUMBER_AS_VERIFIED'
  - 'STATUS_CHANGE_DATE'
  - 'USER_REMARKS'
  - 'VEHICLE_DATA_SERVICE_PROVIDER'
  - 'VENDOR_VERIFICATION_REFERENCE'
  - 'VERIFICATION_DATA_SOURCE'
  - 'VERIFICATION_REQUEST_SOURCE'
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
