-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_CLAIM_COMMUNICATION (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v04_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_communication'
src_pk:
  - 'CLAIM_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'COMMUNICATION_DATE_CK'
  - 'SEQUENCE_CK'
src_payload:
  - 'ACKNOWLEDGEMENT_RECEIVED_INDICATOR'
  - 'COURIER_VENDOR_NAME'
  - 'DISPATCH_MODE'
  - 'INWARD_MODE'
  - 'INWARD_REGISTRATION_DATE'
  - 'OUTWARD_REGISTRATION_DATE'
  - 'OUTWARD_REGISTRATION_NUMBER'
  - 'PROOF_OF_DELIVERY_NUMBER'
  - 'SENDER_NAME'
  - 'SENT_TO_NAME'
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
